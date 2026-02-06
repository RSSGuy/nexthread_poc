// lib/core/ai_service.dart

import 'dart:async';
import 'dart:math'; // For shuffling
import '../../secrets.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';
import 'market_data_provider.dart';

// PROVIDERS
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'ollama_provider.dart';
import 'gemini_provider.dart';
import '../ui/widgets/console_log_widget.dart';

// PROMPTS
import 'prompts/ai_prompts.dart';

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

  // --- 1. GLOBAL MARKET ANALYSIS (Restored for Global Indices Dialog) ---
  Future<String> analyzeGlobalMarket(List<TopicConfig> topics, MarketFact globalBenchmarks) async {
    ConsoleLogger.log("AIService: Starting Global Market Analysis across ${topics.length} sectors...", type: 'system');

    // 1. Gather Context
    StringBuffer contextBuilder = StringBuffer();
    contextBuilder.writeln("=== GLOBAL INDICES DATA ===");
    for (var f in globalBenchmarks.subFacts) {
      contextBuilder.writeln("${f.name}: ${f.value} (${f.trend})");
    }

    contextBuilder.writeln("\n=== CROSS-SECTOR NEWS INTELLIGENCE ===");

    // Fetch headlines from ALL topics in parallel
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
    contextBuilder.writeln(results.whereType<String>().join("\n\n"));

    // 2. Use extracted prompt
    try {
      final json = await _activeProvider.generateBriefingJson(
          systemPrompt: AiPrompts.globalMarketSystem,
          userContext: contextBuilder.toString()
      );

      return json['analysis'] ?? "## Analysis Error\nThe AI could not generate a valid report.";
    } catch (e) {
      ConsoleLogger.error("Global Analysis Failed: $e");
      return "## System Error\nUnable to perform global analysis: $e";
    }
  }

  // --- 2. GLOBAL TRENDS ANALYSIS (New Method for Global Trends View) ---
  Future<Map<String, dynamic>> analyzeGlobalTrends(List<String> newsItems, MarketFact globalData) async {
    // Use extracted prompt
    final systemPrompt = AiPrompts.globalTrendsSystem(globalData.toString(), newsItems);

    try {
      final response = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: "Global Trends Deep Dive",
      );

      // Validation to ensure structure exists
      if (response['summary'] == null) {
        response['summary'] = "Analysis generated, but format was unexpected.";
      }
      if (response['expansions'] == null) {
        response['expansions'] = [];
      }

      return response;
    } catch (e) {
      return {
        "summary": "## System Error\nUnable to generate global analysis: $e",
        "expansions": []
      };
    }
  }

  // --- PRE-FLIGHT GUARDRAIL ---
  Future<Map<String, dynamic>> _checkRelevance(String scenario, String topicName) async {
    // Use extracted prompt
    final guardrailPrompt = AiPrompts.relevanceCheckSystem(topicName, scenario);

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

    // Use extracted prompt
    final systemPrompt = AiPrompts.askAboutBriefingSystem(brief, userQuestion);

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
    List<String>? manualFeedPaths,
    String? customScenario,
    List<TopicConfig>? allTopics
  }) async {

    if (_activeProvider is OpenAIProvider && Secrets.openAiApiKey.contains("YOUR_")) {
      manualFeedPaths = ['assets/feeds/fallback_news.xml'];
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

      // 1. FETCH PRIMARY DATA
      Future<List<String>> newsFuture;
      if (manualFeedPaths != null && manualFeedPaths.isNotEmpty) {
        newsFuture = _localFeedService.getHeadlinesFromPaths(manualFeedPaths, topic.keywords);
      } else {
        newsFuture = _feedService.fetchHeadlines(topic.sources, topic.keywords);
      }

      final results = await Future.wait([
        topic.fetchMarketPulse(),
        newsFuture,
        MarketDataProvider().getGlobalBenchmarks()
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;
      final MarketFact globalFact = results[2] as MarketFact;

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

  // --- EXPAND BRIEFING ---
  Future<void> expandBriefing(Briefing brief, List<TopicConfig> allTopics) async {
    ConsoleLogger.log("AIService: Expanding briefing '${brief.title}' with cross-sector data...", type: 'system');

    TopicConfig? topic;
    try {
      topic = allTopics.firstWhere((t) => t.name == brief.subsector);
    } catch (e) {
      ConsoleLogger.error("Could not find topic config for ${brief.subsector}");
      return;
    }

    final extraNews = await _pollOtherSectors(topic, allTopics);
    if (extraNews.isEmpty) {
      ConsoleLogger.warning("No significant cross-sector news found.");
      return;
    }

    final news = List<String>.from(brief.headlines);
    news.addAll(extraNews);

    // Use extracted prompt
    final systemPrompt = AiPrompts.expandBriefingSystem(topic.name, brief, extraNews);

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

  Future<Map<String, dynamic>> _generateInternal(
      TopicConfig topic,
      MarketFact marketFact,
      List<String> news,
      String? customScenario,
      String globalContext,
      {bool forceCrossSectorAnalysis = false}
      ) async {

    // Use extracted prompt
    final systemPrompt = AiPrompts.generateBriefingSystem(
        topicName: topic.name,
        globalContext: globalContext,
        marketFactStr: marketFact.toString(),
        news: news,
        riskRules: topic.riskRules,
        customScenario: customScenario,
        forceCrossSectorAnalysis: forceCrossSectorAnalysis
    );

    // 1. Capture response as dynamic to allow Type checking
    final dynamic rawResponse = await _activeProvider.generateBriefingJson(
      systemPrompt: systemPrompt,
      userContext: customScenario ?? "",
    );

    // 2. Safety Check: Did we get a String instead of a Map?
    if (rawResponse is String) {
      // Create a fallback wrapper for the raw text
      return {
        "briefs": [
          {
            "id": DateTime.now().millisecondsSinceEpoch.toString(),
            "subsector": topic.name,
            "title": "${topic.name} Report",
            "summary": rawResponse, // Put the raw markdown here
            "severity": "Low",
            "fact_score": 50,
            "sent_score": 50,
            "divergence_tag": "Analysis",
            "divergence_desc": "AI returned raw text format.",
            "metrics": {
              "commodity": topic.name,
              "price": marketFact.value,
              "trend": marketFact.trend
            },
            "chart_data": [],
            "headlines": [],
            "is_fallback": false
          }
        ]
      };
    }

    // 3. Return as Map if it was successful
    return Map<String, dynamic>.from(rawResponse);
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
        if (marketFact.lineData.isNotEmpty) brief['chart_data'] = marketFact.lineData;
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
      "briefs": [{
        "id": "1", "subsector": topic.name, "title": "Simulation / Error Report",
        "summary": "AI service unreachable.", "severity": "Low",
        "fact_score": 50, "sent_score": 50, "divergence_tag": "Simulation", "divergence_desc": "Analysis based on: ${headlines.length} items.",
        "metrics": {"commodity": topic.name, "price": "--", "trend": "0%"},
        "headlines": headlines.take(5).toList(), "chart_data": [1.0, 2.0], "is_fallback": true,
        "sources": topic.sources.map((s) => s.name).toList()
      }]
    };
  }
}

