

/*
import 'dart:convert';
import 'dart:async';
import 'package:dart_openai/dart_openai.dart'; // Retained for type safety if needed
import '../../secrets.dart';
import 'gemini_provider.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';

// PROVIDERS
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'ollama_provider.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final FeedService _feedService = FeedService();
  final LocalFeedService _localFeedService = LocalFeedService();

  // --- PROVIDER MANAGEMENT ---
  AIProvider _activeProvider = OpenAIProvider(); // Default to OpenAI

  void setProvider(String providerType) {
    if (providerType == 'ollama') {
      _activeProvider = OllamaProvider();
    } else if (providerType == 'gemini') {
      _activeProvider = GeminiProvider();
    } else {
      _activeProvider = OpenAIProvider();
    }
    print("AIService: Switched to ${_activeProvider.name}");
  }

  String get currentProviderName => _activeProvider.name;

  // --- GENERATION LOGIC ---
  Future<void> generateBriefing(TopicConfig topic, {String? manualFeedPath, String? customScenario}) async {
    // Fallback if API Key is missing and using OpenAI (Ollama doesn't need key)
    if (_activeProvider is OpenAIProvider && apiKey.contains("YOUR_")) {
      print("AIService: No API Key, defaulting to standard fallback.");
      manualFeedPath = 'assets/feeds/fallback_news.xml';
    }

    try {
      print("AIService: Generating via ${_activeProvider.name} for ${topic.id}...");

      // 1. DATA INGESTION
      Future<List<String>> newsFuture;
      if (manualFeedPath != null) {
        newsFuture = _localFeedService.getHeadlinesFromPath(manualFeedPath, topic.keywords);
      } else {
        newsFuture = _feedService.fetchHeadlines(topic.sources, topic.keywords);
      }

      final results = await Future.wait([
        topic.fetchMarketPulse(),
        newsFuture
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;

      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      // 2. PROMPT CONSTRUCTION
      // Includes logic for Custom Scenarios and Relevance Guardrails
      String scenarioBlock = "";
      if (customScenario != null && customScenario.isNotEmpty) {
        scenarioBlock = '''
        [USER SIMULATION / WHAT-IF SCENARIO]
        The user has engaged a simulation mode. 
        HYPOTHESIS: "$customScenario"
        
        *** STRICT GUARDRAILS ***
        1. RELEVANCE CHECK: You must strictly evaluate if this hypothesis is relevant to the ${topic.name} industry, its supply chain, or macro-economics.
        2. IF IRRELEVANT (e.g. sports scores, celebrity gossip, coding questions): 
           - IGNORE the hypothesis.
           - Return a single brief with Title: "Simulation Ignored" and Severity: "Low".
           - Set 'divergence_desc' to: "Input rejected: Scenario unrelated to ${topic.name} sector."
        3. IF RELEVANT: Analyze the Market Data and News assuming this hypothesis is TRUE or IMMINENT.
           - If the hypothesis conflicts with current data, prioritize the hypothesis as a "Developing Crisis" or "Sudden Shift".
           - Adjust 'Severity' and 'Divergence Description' to reflect this simulated outcome.
        ''';
      }

      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      $scenarioBlock
      
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

      // 3. DELEGATE TO PROVIDER
      Map<String, dynamic> jsonResponse = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: customScenario ?? "",
      );

      // 4. POST-PROCESSING
      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          // Inject real chart data if available
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }

          // Tag as simulation in title if applicable
          if (customScenario != null && customScenario.isNotEmpty) {
            // Only tag if it wasn't rejected by the guardrail
            if (brief['title'] != "Simulation Ignored") {
              brief['title'] = "[SIMULATION] ${brief['title']}";
            }
            brief['is_fallback'] = false;
          }
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } catch (e) {
      print("AI Generation Error: $e");
      final errorData = _getDummyResponse(topic, ["System Error: $e"]);
      await StorageService.saveBriefing(topic.id, errorData);
    }
  }

  // Helper for offline/error states
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
          "is_fallback": true
        }
      ]
    };
  }
}*/

/*
import 'dart:convert';
import 'dart:async';
import 'package:dart_openai/dart_openai.dart';
import '../../secrets.dart';
import 'gemini_provider.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';

// PROVIDERS
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'ollama_provider.dart';

// CUSTOM EXCEPTION FOR UI HANDLING
class IrrelevantScenarioException implements Exception {
  final String message;
  IrrelevantScenarioException(this.message);
  @override
  String toString() => message;
}

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final FeedService _feedService = FeedService();
  final LocalFeedService _localFeedService = LocalFeedService();

  AIProvider _activeProvider = OpenAIProvider();

  void setProvider(String providerType) {
    if (providerType == 'ollama') {
      _activeProvider = OllamaProvider();
    } else if (providerType == 'gemini') {
      _activeProvider = GeminiProvider();
    } else {
      _activeProvider = OpenAIProvider();
    }
    print("AIService: Switched to ${_activeProvider.name}");
  }

  String get currentProviderName => _activeProvider.name;

  // --- PRE-FLIGHT GUARDRAIL ---
  Future<Map<String, dynamic>> _checkRelevance(String scenario, String topicName) async {
    final guardrailPrompt = '''
    SYSTEM: You are a Relevance Filter. 
    TASK: Determine if the following "What-If" scenario is RELEVANT to the $topicName industry, supply chain, or macro-economics.
    SCENARIO: "$scenario"
    
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
      print("Guardrail Check Failed: $e");
      return {"is_relevant": true}; // Fail open if API errors
    }
  }

  Future<void> generateBriefing(TopicConfig topic, {String? manualFeedPath, String? customScenario}) async {
    if (_activeProvider is OpenAIProvider && apiKey.contains("YOUR_")) {
      manualFeedPath = 'assets/feeds/fallback_news.xml';
    }

    try {
      // ---------------------------------------------------------
      // STEP 1: PRE-FLIGHT GUARDRAIL
      // ---------------------------------------------------------
      if (customScenario != null && customScenario.isNotEmpty) {
        print("AIService: Running pre-flight guardrail for '$customScenario'...");

        final guardrailCheck = await _checkRelevance(customScenario, topic.name);

        // IF IRRELEVANT: THROW EXCEPTION (Do not save brief)
        if (guardrailCheck['is_relevant'] == false) {
          print("AIService: BLOCKING irrelevant scenario.");
          throw IrrelevantScenarioException(
              guardrailCheck['reason'] ?? "Scenario unrelated to ${topic.name}"
          );
        }
      }

      // ---------------------------------------------------------
      // STEP 2: GENERATION (Only runs if Step 1 passes)
      // ---------------------------------------------------------
      print("AIService: Generating via ${_activeProvider.name} for ${topic.id}...");

      Future<List<String>> newsFuture;
      if (manualFeedPath != null) {
        newsFuture = _localFeedService.getHeadlinesFromPath(manualFeedPath, topic.keywords);
      } else {
        newsFuture = _feedService.fetchHeadlines(topic.sources, topic.keywords);
      }

      final results = await Future.wait([
        topic.fetchMarketPulse(),
        newsFuture
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;

      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      String scenarioBlock = "";
      if (customScenario != null && customScenario.isNotEmpty) {
        scenarioBlock = '''
        [USER SIMULATION ACTIVE]
        HYPOTHESIS: "$customScenario"
        INSTRUCTION: Analyze Market Data and News assuming this is TRUE.
        ''';
      }

      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      $scenarioBlock
      
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

      Map<String, dynamic> jsonResponse = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: customScenario ?? "",
      );

      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
          if (customScenario != null && customScenario.isNotEmpty) {
            brief['title'] = "[SIMULATION] ${brief['title']}";
            brief['is_fallback'] = false;
          }
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } on IrrelevantScenarioException {
      rethrow; // Pass up to UI
    } catch (e) {
      print("AI Generation Error: $e");
      final errorData = _getDummyResponse(topic, ["System Error: $e"]);
      await StorageService.saveBriefing(topic.id, errorData);
    }
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
          "is_fallback": true
        }
      ]
    };
  }
}
*/
/*

import 'dart:convert';
import 'dart:async';
import 'package:dart_openai/dart_openai.dart';
import '../../secrets.dart';
import 'gemini_provider.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';

// IMPORTS FOR PROVIDERS
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'ollama_provider.dart';

// CUSTOM EXCEPTION
class IrrelevantScenarioException implements Exception {
  final String message;
  IrrelevantScenarioException(this.message);
  @override
  String toString() => message;
}

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final FeedService _feedService = FeedService();
  final LocalFeedService _localFeedService = LocalFeedService();

  AIProvider _activeProvider = OpenAIProvider();

  void setProvider(String providerType) {
    if (providerType == 'ollama') {
      _activeProvider = OllamaProvider();
    } else if (providerType == 'gemini') {
      _activeProvider = GeminiProvider();
    } else {
      _activeProvider = OpenAIProvider();
    }
    print("AIService: Switched to ${_activeProvider.name}");
  }

  String get currentProviderName => _activeProvider.name;

  // --- HELPER: PRE-FLIGHT GUARDRAIL ---
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
      print("Guardrail Check Failed: $e");
      return {"is_relevant": true};
    }
  }

  // --- NEW: ASK AI ABOUT BRIEFING ---
  Future<String> askAboutBriefing(Briefing brief, String userQuestion) async {

    // 1. GUARDRAIL CHECK (Apply points logic in UI, but enforce rules here)
    print("AIService: Checking relevance for query: '$userQuestion'...");
    final guardrailCheck = await _checkRelevance(userQuestion, brief.subsector);

    if (guardrailCheck['is_relevant'] == false) {
      throw IrrelevantScenarioException(
          guardrailCheck['reason'] ?? "Query unrelated to ${brief.subsector}"
      );
    }

    // 2. Context Construction
    final contextPrompt = '''
    CONTEXT: You are an AI assistant analyzing a specific intelligence report.
    
    REPORT DETAILS:
    - Sector: ${brief.subsector}
    - Title: ${brief.title}
    - Summary: ${brief.summary}
    - Severity: ${brief.severity}
    - Divergence: ${brief.divergenceTag} (${brief.divergenceDesc})
    - Key Metrics: ${brief.metrics.commodity} is ${brief.metrics.price} (${brief.metrics.trend})
    - Source Headlines: ${brief.headlines.join(', ')}

    USER QUESTION: "$userQuestion"

    INSTRUCTION: Answer the user's question based strictly on the report details above. Keep the answer concise (under 3 sentences) and professional.
    ''';

    final systemPrompt = "$contextPrompt\n\nOUTPUT JSON: { \"answer\": \"your text here\" }";

    try {
      final response = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: "",
      );

      return response['answer'] ?? "I could not analyze that report.";
    } catch (e) {
      print("Ask AI Error: $e");
      return "System Error: Unable to process query.";
    }
  }

  // --- MAIN GENERATION ---
  Future<void> generateBriefing(TopicConfig topic, {String? manualFeedPath, String? customScenario}) async {
    if (_activeProvider is OpenAIProvider && apiKey.contains("YOUR_")) {
      manualFeedPath = 'assets/feeds/fallback_news.xml';
    }

    try {
      // GUARDRAIL for Simulations
      if (customScenario != null && customScenario.isNotEmpty) {
        final guardrailCheck = await _checkRelevance(customScenario, topic.name);
        if (guardrailCheck['is_relevant'] == false) {
          throw IrrelevantScenarioException(
              guardrailCheck['reason'] ?? "Scenario unrelated to ${topic.name}"
          );
        }
      }

      print("AIService: Generating via ${_activeProvider.name} for ${topic.id}...");

      Future<List<String>> newsFuture;
      if (manualFeedPath != null) {
        newsFuture = _localFeedService.getHeadlinesFromPath(manualFeedPath, topic.keywords);
      } else {
        newsFuture = _feedService.fetchHeadlines(topic.sources, topic.keywords);
      }

      final results = await Future.wait([
        topic.fetchMarketPulse(),
        newsFuture
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;

      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      String scenarioBlock = "";
      if (customScenario != null && customScenario.isNotEmpty) {
        scenarioBlock = '''
        [USER SIMULATION ACTIVE]
        HYPOTHESIS: "$customScenario"
        INSTRUCTION: Analyze Market Data and News assuming this is TRUE.
        ''';
      }

      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      $scenarioBlock
      
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

      Map<String, dynamic> jsonResponse = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: customScenario ?? "",
      );

      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
          if (customScenario != null && customScenario.isNotEmpty) {
            brief['title'] = "[SIMULATION] ${brief['title']}";
            brief['is_fallback'] = false;
          }
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } on IrrelevantScenarioException {
      rethrow;
    } catch (e) {
      print("AI Generation Error: $e");
      final errorData = _getDummyResponse(topic, ["System Error: $e"]);
      await StorageService.saveBriefing(topic.id, errorData);
    }
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
          "is_fallback": true
        }
      ]
    };
  }
}*/
/*

import 'dart:convert';
import 'dart:async';
import 'package:dart_openai/dart_openai.dart';
import '../../secrets.dart';
import 'gemini_provider.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';

// PROVIDERS
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'ollama_provider.dart';

// CUSTOM EXCEPTION
class IrrelevantScenarioException implements Exception {
  final String message;
  IrrelevantScenarioException(this.message);
  @override
  String toString() => message;
}

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final FeedService _feedService = FeedService();
  final LocalFeedService _localFeedService = LocalFeedService();

  AIProvider _activeProvider = OpenAIProvider();

  void setProvider(String providerType) {
    if (providerType == 'ollama') {
      _activeProvider = OllamaProvider();
    } else if (providerType == 'gemini') {
      _activeProvider = GeminiProvider();
    } else {
      _activeProvider = OpenAIProvider();
    }
    print("AIService: Switched to ${_activeProvider.name}");
  }

  String get currentProviderName => _activeProvider.name;

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
      print("Guardrail Check Failed: $e");
      return {"is_relevant": true};
    }
  }

  // --- ASK AI ABOUT BRIEFING ---
  Future<String> askAboutBriefing(Briefing brief, String userQuestion) async {

    // 1. GUARDRAIL CHECK
    print("AIService: Checking relevance for query: '$userQuestion'...");
    final guardrailCheck = await _checkRelevance(userQuestion, brief.subsector);

    if (guardrailCheck['is_relevant'] == false) {
      throw IrrelevantScenarioException(
          guardrailCheck['reason'] ?? "Query unrelated to ${brief.subsector}"
      );
    }

    // 2. CONTEXT CONSTRUCTION (REFINED FOR BETTER ANSWERS)
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
    2. You may use your general knowledge of the ${brief.subsector} industry to explain the *implications* of these specific facts.
    3. BE SPECIFIC. Cite the metrics or headlines if they support your answer.
    4. Do NOT be vague. If the data implies a risk, explain *why*.
    ''';

    final systemPrompt = "$contextPrompt\n\nOUTPUT JSON: { \"answer\": \"your text here\" }";

    try {
      final response = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: "",
      );

      return response['answer'] ?? "I could not analyze that report.";
    } catch (e) {
      print("Ask AI Error: $e");
      return "System Error: Unable to process query.";
    }
  }

  // --- MAIN GENERATION ---
  Future<void> generateBriefing(TopicConfig topic, {String? manualFeedPath, String? customScenario}) async {
    if (_activeProvider is OpenAIProvider && apiKey.contains("YOUR_")) {
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

      print("AIService: Generating via ${_activeProvider.name} for ${topic.id}...");

      Future<List<String>> newsFuture;
      if (manualFeedPath != null) {
        newsFuture = _localFeedService.getHeadlinesFromPath(manualFeedPath, topic.keywords);
      } else {
        newsFuture = _feedService.fetchHeadlines(topic.sources, topic.keywords);
      }

      final results = await Future.wait([
        topic.fetchMarketPulse(),
        newsFuture
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;

      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      String scenarioBlock = "";
      if (customScenario != null && customScenario.isNotEmpty) {
        scenarioBlock = '''
        [USER SIMULATION ACTIVE]
        HYPOTHESIS: "$customScenario"
        INSTRUCTION: Analyze Market Data and News assuming this is TRUE.
        ''';
      }

      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      $scenarioBlock
      
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

      Map<String, dynamic> jsonResponse = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: customScenario ?? "",
      );

      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
          if (customScenario != null && customScenario.isNotEmpty) {
            brief['title'] = "[SIMULATION] ${brief['title']}";
            brief['is_fallback'] = false;
          }
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } on IrrelevantScenarioException {
      rethrow;
    } catch (e) {
      print("AI Generation Error: $e");
      final errorData = _getDummyResponse(topic, ["System Error: $e"]);
      await StorageService.saveBriefing(topic.id, errorData);
    }
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
          "is_fallback": true
        }
      ]
    };
  }
}*/
/*

import 'dart:convert';
import 'dart:async';
import 'package:dart_openai/dart_openai.dart';
import '../../secrets.dart';
import 'gemini_provider.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';

// PROVIDERS
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'ollama_provider.dart';

// CUSTOM EXCEPTION
class IrrelevantScenarioException implements Exception {
  final String message;
  IrrelevantScenarioException(this.message);
  @override
  String toString() => message;
}

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final FeedService _feedService = FeedService();
  final LocalFeedService _localFeedService = LocalFeedService();

  AIProvider _activeProvider = OpenAIProvider();

  /// Updated setProvider to accept configuration for remote providers
  void setProvider(String providerType, {Map<String, String>? config}) {
    if (providerType == 'ollama') {
      // Extract configuration for remote connection
      final url = config?['url'] ?? "";
      final model = config?['model'] ?? "llama3";

      if (url.isEmpty) {
        print("AIService: Error - No Remote URL provided for Ollama.");
        // We do not switch the provider if the config is invalid
        return;
      }

      _activeProvider = OllamaProvider(baseUrl: url, modelName: model);
    } else if (providerType == 'gemini') {
      _activeProvider = GeminiProvider();
    } else {
      _activeProvider = OpenAIProvider();
    }
    print("AIService: Switched to ${_activeProvider.name}");
  }

  String get currentProviderName => _activeProvider.name;

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
      print("Guardrail Check Failed: $e");
      return {"is_relevant": true};
    }
  }

  // --- ASK AI ABOUT BRIEFING ---
  Future<String> askAboutBriefing(Briefing brief, String userQuestion) async {

    // 1. GUARDRAIL CHECK
    print("AIService: Checking relevance for query: '$userQuestion'...");
    final guardrailCheck = await _checkRelevance(userQuestion, brief.subsector);

    if (guardrailCheck['is_relevant'] == false) {
      throw IrrelevantScenarioException(
          guardrailCheck['reason'] ?? "Query unrelated to ${brief.subsector}"
      );
    }

    // 2. CONTEXT CONSTRUCTION (REFINED FOR BETTER ANSWERS)
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
    2. You may use your general knowledge of the ${brief.subsector} industry to explain the *implications* of these specific facts.
    3. BE SPECIFIC. Cite the metrics or headlines if they support your answer.
    4. Do NOT be vague. If the data implies a risk, explain *why*.
    ''';

    final systemPrompt = "$contextPrompt\n\nOUTPUT JSON: { \"answer\": \"your text here\" }";

    try {
      final response = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: "",
      );

      return response['answer'] ?? "I could not analyze that report.";
    } catch (e) {
      print("Ask AI Error: $e");
      return "System Error: Unable to process query.";
    }
  }

  // --- MAIN GENERATION ---
  Future<void> generateBriefing(TopicConfig topic, {String? manualFeedPath, String? customScenario}) async {
    if (_activeProvider is OpenAIProvider && apiKey.contains("YOUR_")) {
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

      print("AIService: Generating via ${_activeProvider.name} for ${topic.id}...");

      Future<List<String>> newsFuture;
      if (manualFeedPath != null) {
        newsFuture = _localFeedService.getHeadlinesFromPath(manualFeedPath, topic.keywords);
      } else {
        newsFuture = _feedService.fetchHeadlines(topic.sources, topic.keywords);
      }

      final results = await Future.wait([
        topic.fetchMarketPulse(),
        newsFuture
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;

      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      String scenarioBlock = "";
      if (customScenario != null && customScenario.isNotEmpty) {
        scenarioBlock = '''
        [USER SIMULATION ACTIVE]
        HYPOTHESIS: "$customScenario"
        INSTRUCTION: Analyze Market Data and News assuming this is TRUE.
        ''';
      }

      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      $scenarioBlock
      
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

      Map<String, dynamic> jsonResponse = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: customScenario ?? "",
      );

      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
          if (customScenario != null && customScenario.isNotEmpty) {
            brief['title'] = "[SIMULATION] ${brief['title']}";
            brief['is_fallback'] = false;
          }
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } on IrrelevantScenarioException {
      rethrow;
    } catch (e) {
      print("AI Generation Error: $e");
      final errorData = _getDummyResponse(topic, ["System Error: $e"]);
      await StorageService.saveBriefing(topic.id, errorData);
    }
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
          "is_fallback": true
        }
      ]
    };
  }
}*/
/*

import 'dart:async';
import '../../secrets.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';

// PROVIDERS
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'ollama_provider.dart';
import 'gemini_provider.dart';

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

  // Default to OpenAI
  AIProvider _activeProvider = OpenAIProvider();

  String get currentProviderName => _activeProvider.name;

  /// UPDATED: Handle Proxy and API Key passing
  void setProvider(String providerType, {Map<String, String>? config}) {
    if (providerType == 'ollama') {
      final url = config?['url'] ?? "";
      final model = config?['model'] ?? "llama3";
      final apiKey = config?['apiKey'];
      final proxy = config?['proxy']; // <--- CRITICAL FIX: Extract Proxy

      // We allow empty URL (defaults to ollama.com in provider)
      // We allow empty Proxy (defaults to null)

      _activeProvider = OllamaProvider(
          baseUrl: url,
          modelName: model,
          apiKey: apiKey,
          proxyUrl: proxy // <--- CRITICAL FIX: Pass to Provider
      );

    } else if (providerType == 'gemini') {
      _activeProvider = GeminiProvider();
    } else {
      _activeProvider = OpenAIProvider();
    }

    print("AIService: Switched to ${_activeProvider.name}");
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
      print("Guardrail Check Failed: $e");
      // Fail open if AI is down, or closed if you prefer strictness
      return {"is_relevant": true};
    }
  }

  // --- ASK AI ABOUT BRIEFING ---
  Future<String> askAboutBriefing(Briefing brief, String userQuestion) async {

    // 1. GUARDRAIL CHECK
    try {
      final guardrailCheck = await _checkRelevance(userQuestion, brief.subsector);
      if (guardrailCheck['is_relevant'] == false) {
        throw IrrelevantScenarioException(
            guardrailCheck['reason'] ?? "Query unrelated to ${brief.subsector}"
        );
      }
    } catch (e) {
      // If guardrail fails (e.g. network), we proceed cautiously or rethrow
      if (e is IrrelevantScenarioException) rethrow;
    }

    // 2. CONTEXT CONSTRUCTION
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
      print("Ask AI Error: $e");
      return "System Error: Unable to process query. ($e)";
    }
  }

  // --- MAIN GENERATION ---
  Future<void> generateBriefing(TopicConfig topic, {String? manualFeedPath, String? customScenario}) async {
    // Fallback for OpenAI demo mode
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

      print("AIService: Generating via ${_activeProvider.name} for ${topic.id}...");

      Future<List<String>> newsFuture;
      if (manualFeedPath != null) {
        newsFuture = _localFeedService.getHeadlinesFromPath(manualFeedPath, topic.keywords);
      } else {
        newsFuture = _feedService.fetchHeadlines(topic.sources, topic.keywords);
      }

      final results = await Future.wait([
        topic.fetchMarketPulse(),
        newsFuture
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;

      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      String scenarioBlock = "";
      if (customScenario != null && customScenario.isNotEmpty) {
        scenarioBlock = '''
        [USER SIMULATION ACTIVE]
        HYPOTHESIS: "$customScenario"
        INSTRUCTION: Analyze Market Data and News assuming this is TRUE.
        ''';
      }

      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      $scenarioBlock
      
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

      Map<String, dynamic> jsonResponse = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: customScenario ?? "",
      );

      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          // Augment with real data
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
          if (customScenario != null && customScenario.isNotEmpty) {
            brief['title'] = "[SIMULATION] ${brief['title']}";
            brief['is_fallback'] = false;
          }
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } on IrrelevantScenarioException {
      rethrow;
    } catch (e) {
      print("AI Generation Error: $e");
      final errorData = _getDummyResponse(topic, ["System Error: $e"]);
      await StorageService.saveBriefing(topic.id, errorData);
    }
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
          "is_fallback": true
        }
      ]
    };
  }
}*/

import 'dart:async';
import '../../secrets.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';

// PROVIDERS
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'ollama_provider.dart';
import 'gemini_provider.dart';

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

  // Default to OpenAI
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
      print("Guardrail Check Failed: $e");
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
      print("Ask AI Error: $e");
      return "System Error: Unable to process query. ($e)";
    }
  }

  // --- MAIN GENERATION ---
  Future<void> generateBriefing(TopicConfig topic, {String? manualFeedPath, String? customScenario}) async {
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

      print("AIService: Generating via ${_activeProvider.name} for ${topic.id}...");

      Future<List<String>> newsFuture;
      if (manualFeedPath != null) {
        newsFuture = _localFeedService.getHeadlinesFromPath(manualFeedPath, topic.keywords);
      } else {
        newsFuture = _feedService.fetchHeadlines(topic.sources, topic.keywords);
      }

      final results = await Future.wait([
        topic.fetchMarketPulse(),
        newsFuture
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;

      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      String scenarioBlock = "";
      if (customScenario != null && customScenario.isNotEmpty) {
        scenarioBlock = '''
        [USER SIMULATION ACTIVE]
        HYPOTHESIS: "$customScenario"
        INSTRUCTION: Analyze Market Data and News assuming this is TRUE.
        ''';
      }

      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      $scenarioBlock
      
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

      Map<String, dynamic> jsonResponse = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: customScenario ?? "",
      );

      // --- NEW: Capture Polled Sources for Storage ---
      final sourceNames = topic.sources.map((s) => s.name).toList();

      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          // Augment with real data
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
          if (customScenario != null && customScenario.isNotEmpty) {
            brief['title'] = "[SIMULATION] ${brief['title']}";
            brief['is_fallback'] = false;
          }
          // Inject polled sources into each brief for persistence
          brief['sources'] = sourceNames;
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } on IrrelevantScenarioException {
      rethrow;
    } catch (e) {
      print("AI Generation Error: $e");
      final errorData = _getDummyResponse(topic, ["System Error: $e"]);
      await StorageService.saveBriefing(topic.id, errorData);
    }
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
          "sources": topic.sources.map((s) => s.name).toList() // Save sources even in error
        }
      ]
    };
  }
}