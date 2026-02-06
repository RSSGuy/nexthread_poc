

import 'dart:async';
import 'dart:math'; // For shuffling
import '../../secrets.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';
import 'market_data_provider.dart'; // Required for global data

// PROVIDERS
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'ollama_provider.dart';
import 'gemini_provider.dart';
import '../ui/widgets/console_log_widget.dart';

// CUSTOM EXCEPTION
class IrrelevantScenarioException implements Exception {
  final String message;
  IrrelevantScenarioException(this.message);
  @override
  String toString() => message;
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final FeedService _feedService = FeedService();
  final LocalFeedService _localFeedService = LocalFeedService();

  AIProvider _activeProvider = OpenAIProvider();

  String get currentProviderName => _activeProvider.name;

  void setProvider(String providerType, {Map<String, String>? config}) {
    if (providerType == 'ollama') {
      final url = config?['url'] ?? "";
      final model = config?['model'] ?? "llama3";
      final apiKey = config?['apiKey'];
      final proxy = config?['proxy'];

      _activeProvider = OllamaProvider(
          baseUrl: url,
          modelName: model,
          apiKey: apiKey,
          proxyUrl: proxy
      );
    } else if (providerType == 'gemini') {
      _activeProvider = GeminiProvider();
    } else {
      _activeProvider = OpenAIProvider();
    }
    print("AIService: Switched to ${_activeProvider.name}");
  }

  // --- NEW: GLOBAL MARKET ANALYSIS ---
  Future<String> analyzeGlobalMarket(List<TopicConfig> topics, MarketFact globalBenchmarks) async {
    ConsoleLogger.log("AIService: Starting Global Market Analysis across ${topics.length} sectors...", type: 'system');

    // 1. Gather Context
    StringBuffer contextBuilder = StringBuffer();
    contextBuilder.writeln("=== GLOBAL INDICES DATA ===");
    // Add subfacts (indices) to the prompt
    for (var f in globalBenchmarks.subFacts) {
      contextBuilder.writeln("${f.name}: ${f.value} (${f.trend})");
    }

    contextBuilder.writeln("\n=== CROSS-SECTOR NEWS INTELLIGENCE ===");

    // Fetch headlines from ALL topics in parallel
    // We limit to top 5 per sector to keep context window healthy but broad
    final futures = topics.map((t) async {
      try {
        final headlines = await _feedService.fetchHeadlines(t.sources, t.keywords);
        if (headlines.isNotEmpty) {
          return "SECTOR [${t.name.toUpperCase()}]:\n- ${headlines.take(5).join('\n- ')}";
        }
        return null;
      } catch (e) {
        return null;
      }
    });

    final results = await Future.wait(futures);
    // Filter out nulls and join
    contextBuilder.writeln(results.whereType<String>().join("\n\n"));

    // 2. Construct Prompt
    final systemPrompt = '''
    You are a Chief Global Market Strategist.
    
    TASK: Provide a comprehensive executive summary of the "Entire State of the World Market".
    
    INPUT:
    1. Live Global Market Indices (Equities, Forex, Volatility).
    2. Real-time Headlines from diverse industrial sectors (Agriculture, Manufacturing, Energy, etc.).
    
    INSTRUCTIONS:
    1. Synthesize the Indices Data with the Sector News.
    2. Identify MACRO TRENDS (e.g. "Energy prices driving manufacturing costs").
    3. Detect SYSTEMIC RISKS (Geopolitical instability, Inflation signals, Supply Chain fractures).
    4. Provide a "Global Sentiment" verdict (Bullish/Bearish/Neutral) with a rationale.
    5. Output the result as a well-formatted Markdown string.
    
    OUTPUT JSON FORMAT:
    {
      "analysis": "## Global Market Outlook\\n\\n..." 
    }
    ''';

    try {
      final json = await _activeProvider.generateBriefingJson(
          systemPrompt: systemPrompt,
          userContext: contextBuilder.toString()
      );

      return json['analysis'] ?? "## Analysis Error\nThe AI could not generate a valid report.";
    } catch (e) {
      ConsoleLogger.error("Global Analysis Failed: $e");
      return "## System Error\nUnable to perform global analysis: $e";
    }
  }

  // --- PRE-FLIGHT GUARDRAIL ---
  Future<Map<String, dynamic>> _checkRelevance(String scenario, String topicName) async {
    final guardrailPrompt = '''
    SYSTEM: You are a Relevance Filter. 
    TASK: Determine if the following input is RELEVANT to the $topicName industry, supply chain, or macro-economics.
    INPUT: "$scenario"
    
    OUTPUT: JSON ONLY. Format: {"is_relevant": boolean, "reason": "string"}
    CRITERIA: 
    - Sports, celebrity, coding, or personal questions -> FALSE.
    - Economic, weather, trade, political, or logistic shocks -> TRUE.
    ''';

    try {
      return await _activeProvider.generateBriefingJson(
        systemPrompt: guardrailPrompt,
        userContext: "",
      );
    } catch (e) {
      return {"is_relevant": true};
    }
  }

  // --- ASK AI ABOUT BRIEFING ---
  Future<String> askAboutBriefing(Briefing brief, String userQuestion) async {
    try {
      final guardrailCheck = await _checkRelevance(userQuestion, brief.subsector);
      if (guardrailCheck['is_relevant'] == false) {
        throw IrrelevantScenarioException(
            guardrailCheck['reason'] ?? "Query unrelated to ${brief.subsector}"
        );
      }
    } catch (e) {
      if (e is IrrelevantScenarioException) rethrow;
    }

    final contextPrompt = '''
    CONTEXT: You are an Intelligence Analyst for the ${brief.subsector} sector.
    
    REPORT DATA:
    - Title: ${brief.title}
    - Summary: ${brief.summary}
    - Severity: ${brief.severity}
    - Key Metrics: ${brief.metrics.commodity} is ${brief.metrics.price} (${brief.metrics.trend})
    - Headlines Analyzed: ${brief.headlines.join(', ')}

    USER QUESTION: "$userQuestion"

    INSTRUCTION: 
    1. Answer the question using the Report Data.
    2. You may use your general knowledge of the ${brief.subsector} industry to explain the *implications*.
    3. BE SPECIFIC. Cite the metrics or headlines.
    ''';

    final systemPrompt = "$contextPrompt\n\nOUTPUT JSON: { \"answer\": \"your text here\" }";

    try {
      final response = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: "",
      );
      return response['answer'] ?? "I could not analyze that report.";
    } catch (e) {
      return "System Error: Unable to process query. ($e)";
    }
  }

  // --- MAIN GENERATION ---
  Future<void> generateBriefing(TopicConfig topic, {
    String? manualFeedPath,
    String? customScenario,
    List<TopicConfig>? allTopics
  }) async {

    if (_activeProvider is OpenAIProvider && Secrets.openAiApiKey.contains("YOUR_")) {
      manualFeedPath = 'assets/feeds/fallback_news.xml';
    }

    try {
      if (customScenario != null && customScenario.isNotEmpty) {
        final guardrailCheck = await _checkRelevance(customScenario, topic.name);
        if (guardrailCheck['is_relevant'] == false) {
          throw IrrelevantScenarioException(
              guardrailCheck['reason'] ?? "Scenario unrelated to ${topic.name}"
          );
        }
      }

      ConsoleLogger.log("AIService: Analyzing ${topic.id} via ${_activeProvider.name}...", type: 'system');

      // 1. FETCH PRIMARY DATA (Now includes Global Context)
      Future<List<String>> newsFuture;
      if (manualFeedPath != null) {
        newsFuture = _localFeedService.getHeadlinesFromPath(manualFeedPath, topic.keywords);
      } else {
        newsFuture = _feedService.fetchHeadlines(topic.sources, topic.keywords);
      }

      final results = await Future.wait([
        topic.fetchMarketPulse(),                // [0] Sector Specific Data
        newsFuture,                              // [1] Sector News
        MarketDataProvider().getGlobalBenchmarks() // [2] Global Macro Data
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;
      final MarketFact globalFact = results[2] as MarketFact;

      // Format Global Data for the Prompt
      final String globalContext = globalFact.subFacts
          .map((f) => "${f.name}: ${f.value} (${f.trend})")
          .join('\n');

      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      // 2. GENERATE INITIAL REPORT
      Map<String, dynamic> jsonResponse = await _generateInternal(
          topic, marketFact, news, customScenario, globalContext
      );

      // 3. AUTO-POLL (Only if Low Severity)
      bool expanded = false;
      if (jsonResponse['briefs'] != null && (jsonResponse['briefs'] as List).isNotEmpty) {
        final severity = jsonResponse['briefs'][0]['severity'] ?? "Low";
        if (severity == "Low" && allTopics != null && allTopics.isNotEmpty) {
          final extraNews = await _pollOtherSectors(topic, allTopics);
          if (extraNews.isNotEmpty) {
            news.addAll(extraNews);
            jsonResponse = await _generateInternal(
                topic, marketFact, news, customScenario, globalContext,
                forceCrossSectorAnalysis: true
            );
            expanded = true;
          }
        }
      }

      // 4. SAVE
      _finalizeAndSave(topic, marketFact, jsonResponse, customScenario, expanded);

    } on IrrelevantScenarioException {
      rethrow;
    } catch (e) {
      ConsoleLogger.error("AI Generation Error: $e");
      final errorData = _getDummyResponse(topic, ["System Error: $e"]);
      await StorageService.saveBriefing(topic.id, errorData);
    }
  }

  // --- NEW: MANUAL EXPANSION ---
  Future<void> expandBriefing(Briefing brief, List<TopicConfig> allTopics) async {
    ConsoleLogger.log("AIService: Expanding briefing '${brief.title}' with cross-sector data...", type: 'system');

    // 1. Find the topic config
    TopicConfig? topic;
    try {
      topic = allTopics.firstWhere((t) => t.name == brief.subsector);
    } catch (e) {
      ConsoleLogger.error("Could not find topic config for ${brief.subsector}");
      return;
    }

    // 2. Poll Other Sectors
    final extraNews = await _pollOtherSectors(topic, allTopics);
    if (extraNews.isEmpty) {
      ConsoleLogger.warning("No significant cross-sector news found.");
      return;
    }

    // 3. Re-Analyze
    final news = List<String>.from(brief.headlines);
    news.addAll(extraNews);

    final systemPrompt = '''
    You are an Intelligence Analyst for ${topic.name}.
    
    TASK: UPDATE an existing intelligence report with new Cross-Sector data.
    
    [ORIGINAL REPORT]
    Title: ${brief.title}
    Summary: ${brief.summary}
    Severity: ${brief.severity}
    Score: Fact ${brief.factScore} / Sent ${brief.sentScore}
    
    [NEW CROSS-SECTOR INTEL]
    ${extraNews.join('\n')}
    
    INSTRUCTION:
    1. Rewrite the "Summary" to include a new section "Cross-Sector Impact" at the end.
    2. Analyze how the new intel affects the original sector.
    3. You may adjust the "Severity" ONLY if the new info represents a critical external threat. Otherwise keep it as ${brief.severity}.
    
    OUTPUT JSON:
    {
      "briefs": [{
        "summary": "Updated summary text...",
        "severity": "High/Medium/Low",
        "divergence_desc": "Updated divergence description..."
      }]
    }
    ''';

    try {
      final response = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: "",
      );

      if (response['briefs'] != null && (response['briefs'] as List).isNotEmpty) {
        final update = response['briefs'][0];

        final fullJson = {
          "briefs": [{
            "id": brief.id,
            "subsector": brief.subsector,
            "title": brief.title,
            "summary": update['summary'] ?? brief.summary,
            "severity": update['severity'] ?? brief.severity,
            "fact_score": brief.factScore,
            "sent_score": brief.sentScore,
            "divergence_tag": brief.divergenceTag,
            "divergence_desc": update['divergence_desc'] ?? brief.divergenceDesc,
            "metrics": {
              "commodity": brief.metrics.commodity,
              "price": brief.metrics.price,
              "trend": brief.metrics.trend
            },
            "chart_data": brief.chartData,
            "headlines": brief.headlines,
            "sources": brief.sources,
            "is_fallback": brief.isFallback,
            "has_cross_sector": true
          }]
        };

        await StorageService.saveBriefing(topic.id, fullJson);
        ConsoleLogger.success("Briefing updated with cross-sector analysis.");
      }

    } catch (e) {
      ConsoleLogger.error("Failed to expand briefing: $e");
    }
  }

  // --- HELPERS ---

  Future<List<String>> _pollOtherSectors(TopicConfig currentTopic, List<TopicConfig> allTopics) async {
    List<String> crossSectorNews = [];
    var otherTopics = List<TopicConfig>.from(allTopics)..shuffle();

    for (var t in otherTopics) {
      if (t.id == currentTopic.id) continue;

      ConsoleLogger.log("Polling ${t.name}...", type: 'info');
      try {
        var h = await _feedService.fetchHeadlines(t.sources, t.keywords);
        if (h.isNotEmpty) {
          String item = "[SECTOR: ${t.name.toUpperCase()}] ${h.first}";
          crossSectorNews.add(item);
          if (crossSectorNews.length >= 3) break;
        }
      } catch (e) {
        // ignore
      }
    }
    return crossSectorNews;
  }

  // --- GLOBAL TRENDS ANALYSIS ---
  Future<String> analyzeGlobalTrends(List<String> newsItems, MarketFact globalData) async {
    final systemPrompt = '''
    You are a Macro-Economic Strategist.
    
    TASK: Produce an Executive Summary of Global Trends for the past month.
    
    [GLOBAL MARKET DATA]
    ${globalData.toString()}
    
    [NEWS ARCHIVE (PAST MONTH)]
    ${newsItems.take(50).join('\n')} 
    (Truncated to top 50 items for analysis)

    INSTRUCTION:
    1. Identify HIDDEN RELATIONSHIPS between the market data and the news.
    2. Point out OBVIOUS TRENDS that are shaping the global economy.
    3. Focus on "Market Facts" vs "News Sources" divergences.
    4. Output format: Markdown. Use headers like "## Key Hidden Relationships", "## Dominant Trends", "## Risk Outlook".
    ''';

    try {
      final response = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt + "\n\nOUTPUT JSON: { \"answer\": \"markdown text\" }",
        userContext: "Global Trends Analysis",
      );
      return response['answer'] ?? "Analysis complete, but no text returned.";
    } catch (e) {
      return "Unable to generate global analysis: $e";
    }
  }




  Future<Map<String, dynamic>> _generateInternal(
      TopicConfig topic,
      MarketFact marketFact,
      List<String> news,
      String? customScenario,
      String globalContext,
      {bool forceCrossSectorAnalysis = false}
      ) async {

    String scenarioBlock = "";
    if (customScenario != null && customScenario.isNotEmpty) {
      scenarioBlock = '''
        [USER SIMULATION ACTIVE]
        HYPOTHESIS: "$customScenario"
        INSTRUCTION: Analyze Market Data and News assuming this is TRUE.
        ''';
    }

    String crossSectorInstruction = "";
    if (forceCrossSectorAnalysis) {
      crossSectorInstruction = '''
        [ATTENTION: CROSS-SECTOR DATA INJECTED]
        I have provided headlines from OTHER sectors labeled [SECTOR: NAME].
        
        TASK:
        1. Explicitly add a paragraph starting with "Cross-Sector Observations:" in the summary.
        2. Explain how these events in other sectors might indirectly impact ${topic.name}.
        ''';
    }

    final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      
      [GLOBAL MACRO CONTEXT]
      $globalContext

      [SECTOR SPECIFIC DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      $scenarioBlock
      $crossSectorInstruction
      
      STEP 2: DETECT DIVERGENCE & TRENDS
      - Compare Data (Status/Trend) against News Sentiment.
      - Look for: RISKS (Panic, Crisis) AND EMERGING TRENDS (Opportunities, Shifts).

      STEP 3: OUTPUT JSON
      Return a JSON object with a "briefs" array. Each brief must have:
      - id, subsector (e.g. "${topic.name}"), title, summary
      - severity (High/Medium/Low)
      - fact_score (0-100), sent_score (0-100)
      - divergence_tag, divergence_desc
      - metrics (commodity, price, trend)
      - chart_data (placeholder array)
      - headlines (list of strings used)
      - is_fallback (false)
      ''';

    return await _activeProvider.generateBriefingJson(
      systemPrompt: systemPrompt,
      userContext: customScenario ?? "",
    );
  }

  Future<void> _finalizeAndSave(
      TopicConfig topic,
      MarketFact marketFact,
      Map<String, dynamic> jsonResponse,
      String? customScenario,
      bool hasCrossSector) async {

    final sourceNames = topic.sources.map((s) => s.name).toList();

    if (jsonResponse['briefs'] != null) {
      for (var brief in jsonResponse['briefs']) {
        if (marketFact.lineData.isNotEmpty) {
          brief['chart_data'] = marketFact.lineData;
        }
        if (customScenario != null && customScenario.isNotEmpty) {
          brief['title'] = "[SIMULATION] ${brief['title']}";
          brief['is_fallback'] = false;
        }
        brief['sources'] = sourceNames;
        brief['has_cross_sector'] = hasCrossSector;
      }
    }

    await StorageService.saveBriefing(topic.id, jsonResponse);
  }

  Map<String, dynamic> _getDummyResponse(TopicConfig topic, List<String> headlines) {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": topic.name,
          "title": "Simulation / Error Report",
          "summary": "This report was generated because the AI service is unreachable or simulated.",
          "severity": "Low",
          "fact_score": 50,
          "sent_score": 50,
          "divergence_tag": "Simulation",
          "divergence_desc": "Analysis based on: ${headlines.length} items.",
          "metrics": {"commodity": topic.name, "price": "--", "trend": "0%"},
          "headlines": headlines.take(5).toList(),
          "chart_data": [1.0, 2.0, 1.5, 2.5, 2.0],
          "is_fallback": true,
          "sources": topic.sources.map((s) => s.name).toList()
        }
      ]
    };
  }
}