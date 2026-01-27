/*


import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart'; // RSS Parsing
import 'secrets.dart'; // Import the secrets file

class AIService {
  final String apiKey = Secrets.openAiApiKey;

  AIService() {
    // Only initialize if the key is real
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
    }
  }

  // 1. SIMULATED SCRAPER: Fetches specific agricultural news
  Future<List<String>> fetchAgHeadlines() async {
    // In a real app, this would perform a real HTTP request to RSS feeds
    // For this POC, we return a static list to ensure reliability during demo
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      "Kansas winter wheat ratings drop to historic lows",
      "Brazil soy harvest accelerates, putting pressure on US exports",
      "Fertilizer prices stabilizing as natural gas costs retreat"
    ];
  }

  // 2. THE SYNTHESIZER: Sends data to GPT-4 for "Divergence" calculation
  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {

    // DEMO SAFEGUARD: If no key is set, return mock data immediately
    if (apiKey.contains("YOUR_")) {
      return _getFallbackData();
    }

    // The "Fact" Baseline (Hardcoded USDA Data for the POC)
    const facts = '''
    Corn: Ending Stocks +15% (Abundant)
    Wheat: Global Output -2% (Tight)
    Fertilizer: Price -25% (Cheap)
    ''';

    final systemPrompt = '''
    You are an Industrial Intelligence Analyst for NexThread.
    
    STEP 1: ANALYZE FACTS vs. SENTIMENT
    FACTS (Physical Reality):
    $facts
    
    SENTIMENT (News Headlines):
    ${news.join('\n')}
    
    STEP 2: DETECT DIVERGENCE
    - If Fact=Abundant but News=Panic, tag "Unjustified Panic".
    - If Fact=Cheap but News=HighPrice, tag "Margin Padding".
    - If Fact=Tight and News=Panic, tag "Confirmed Crisis".

    STEP 3: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (e.g. "311 Food"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100), sent_score (0-100)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (array of 7 doubles)
    ''';

    try {
      // Create the completion
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        responseFormat: {"type": "json_object"}, // Enforce JSON
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
            ],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      );

      final content = chatCompletion.choices.first.message.content?.first.text;
      if (content != null) {
        return json.decode(content);
      } else {
        throw Exception("Empty response from AI");
      }
    } catch (e) {
      print("AI Error: $e");
      return _getFallbackData(); // Fail gracefully if API key is invalid
    }
  }

  // Fallback data so your demo never crashes
  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "311 Food",
          "title": "Demo Mode: API Key Missing",
          "summary": "Please update your OpenAI Key in lib/secrets.dart to see live generation. Showing demo data.",
          "severity": "Low",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Demo: Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Config Required"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8]
        }
      ]
    };
  }
}*/
/*
import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart'; // Security
import 'news_sources.dart'; // Scraper Targets
import 'market_data_service.dart'; // Real-time Facts

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    // Only initialize if a real key is provided to avoid crashes in demo mode
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
    }
  }

  // 1. SIMULATED SCRAPER: Fetches specific agricultural news
  Future<List<String>> fetchAgHeadlines() async {
    // In a production backend, this would use a Python 'feedparser' worker.
    // For this Flutter POC, we simulate the latency of hitting these specific endpoints.

    print("Agent A: Initiating scrape of ${NewsSources.targetSources.length} target feeds...");
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real implementation, you would loop through NewsSources.targetSources
    // and parse the RSS XML. For the POC, we return a simulated "Live" extraction.
    return [
      "[AgWeb] Kansas winter wheat ratings drop to historic lows due to persistent drought",
      "[Reuters] Brazil soy harvest accelerates, putting pressure on US export premiums",
      "[Food Business News] Fertilizer prices stabilizing as natural gas costs retreat",
      "[USDA] Avian Flu detection in commercial layer flocks expands to 3 new states",
      "[Western Producer] Canadian canola crush capacity set to double by 2027"
    ];
  }

  // 2. THE SYNTHESIZER: Sends data to GPT-4 for "Divergence" calculation
  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {

    // DEMO SAFEGUARD: If no key is set, return mock data immediately
    if (apiKey.contains("YOUR_")) {
      return _getFallbackData();
    }

    // 1. FETCH LIVE FACTS (The "Ingestion Engine")
    // This replaces hardcoded strings with real API data from AlphaVantage/BoC
    String facts;
    try {
      facts = await _dataService.getLiveFactsString();
    } catch (e) {
      print("Data Service Error: $e");
      facts = "Error fetching live data. Using cached baseline: Wheat \$5.80 (Stable).";
    }

    // 2. CONSTRUCT PROMPT (The "Harness")
    final systemPrompt = '''
    You are an Industrial Intelligence Analyst for NexThread.
    
    STEP 1: SOURCE ATTRIBUTION
    You are analyzing data extracted from the following verified sources:
    ${NewsSources.targetSources.map((s) => "- ${s['name']} (${s['type']})").join('\n')}
    
    STEP 2: ANALYZE FACTS vs. SENTIMENT
    
    [OFFICIAL DATA SOURCE (FACTS)]
    $facts
    
    [UNSTRUCTURED NEWS (SENTIMENT)]
    ${news.join('\n')}
    
    STEP 3: DETECT DIVERGENCE
    - Compare the Official Data Status (e.g., "Abundant", "Spiking") against the News Sentiment.
    - If Fact="Stable/Abundant" but News="Panic", tag as "Unjustified Panic".
    - If Fact="Spiking" and News="Panic", tag as "Confirmed Crisis".
    - If Fact="Crashing" but News="High Prices", tag as "Margin Padding".

    STEP 4: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (e.g. "311 Food"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100 based on Fact Status), sent_score (0-100 based on News Panic)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (array of 7 doubles)
    - headlines (array of strings used for this specific insight)
    ''';

    try {
      // 3. CALL LLM
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        responseFormat: {"type": "json_object"}, // Enforce JSON
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
            ],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      );

      final content = chatCompletion.choices.first.message.content?.first.text;
      if (content != null) {
        return json.decode(content);
      } else {
        throw Exception("Empty response from AI");
      }
    } catch (e) {
      print("AI Generation Error: $e");
      return _getFallbackData();
    }
  }

  // Fallback data so your demo never crashes
  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "311 Food",
          "title": "Demo Mode: API Key Missing",
          "summary": "Please update your OpenAI Key in lib/secrets.dart to see live generation. Showing demo data.",
          "severity": "Low",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Demo: Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Config Required"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8]
        }
      ]
    };
  }
}*/
/*
import 'dart:convert';
import 'dart:async'; // Required for TimeoutException
import 'package:dart_openai/dart_openai.dart';
import 'secrets.dart';
import 'news_sources.dart';
import 'market_data_service.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      print("AIService: Valid API Key format detected. Configuring OpenAI.");
      OpenAI.apiKey = apiKey;
    } else {
      print("AIService: Placeholder API Key detected. Will use fallback/demo mode.");
    }
  }

  Future<List<String>> fetchAgHeadlines() async {
    print("--- AIService: fetchAgHeadlines() called ---");
    print("Agent A: Initiating scrape of ${NewsSources.targetSources.length} target feeds...");

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final headlines = [
      "[AgWeb] Kansas winter wheat ratings drop to historic lows due to persistent drought",
      "[Reuters] Brazil soy harvest accelerates, putting pressure on US export premiums",
      "[Food Business News] Fertilizer prices stabilizing as natural gas costs retreat",
      "[USDA] Avian Flu detection in commercial layer flocks expands to 3 new states",
      "[Western Producer] Canadian canola crush capacity set to double by 2027"
    ];

    print("Agent A: Scrape complete. Found ${headlines.length} headlines.");
    return headlines;
  }

  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {
    print("--- AIService: generateIntelligence() called ---");

    // DEMO SAFEGUARD
    if (apiKey.contains("YOUR_")) {
      print("AIService: Demo Mode active (No API Key). Returning fallback data.");
      await Future.delayed(const Duration(seconds: 1)); // Fake loading delay
      return _getFallbackData();
    }

    String facts;
    try {
      // 1. FETCH LIVE FACTS
      print("Agent B: Requesting live facts from MarketDataService...");
      facts = await _dataService.getLiveFactsString();
      print("Agent B: Fact retrieval successful.");
      print("FACTS:\n$facts");
    } catch (e) {
      print("Agent B Error: Failed to fetch live data. $e");
      facts = "Error fetching live data. Using cached baseline: Wheat \$5.80 (Stable).";
      print("Agent B: Using cached baseline facts.");
    }

    // 2. CONSTRUCT PROMPT
    print("Agent D: Constructing System Prompt...");
    final systemPrompt = '''
    You are an Industrial Intelligence Analyst for NexThread.
    
    STEP 1: SOURCE ATTRIBUTION
    You are analyzing data extracted from the following verified sources:
    ${NewsSources.targetSources.map((s) => "- ${s['name']} (${s['type']})").join('\n')}
    
    STEP 2: ANALYZE FACTS vs. SENTIMENT
    [OFFICIAL DATA SOURCE (FACTS)]
    $facts
    
    [UNSTRUCTURED NEWS (SENTIMENT)]
    ${news.join('\n')}
    
    STEP 3: DETECT DIVERGENCE
    - Compare the Official Data Status (e.g., "Abundant", "Spiking") against the News Sentiment.
    - If Fact="Stable/Abundant" but News="Panic", tag as "Unjustified Panic".
    - If Fact="Spiking" and News="Panic", tag as "Confirmed Crisis".
    - If Fact="Crashing" but News="High Prices", tag as "Margin Padding".

    STEP 4: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (e.g. "311 Food"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100 based on Fact Status), sent_score (0-100 based on News Panic)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (array of 7 doubles)
    - headlines (array of strings used for this specific insight)
    ''';

    // Log the prompt size for debugging context window issues
    print("Agent D: System Prompt prepared (${systemPrompt.length} chars). Sending to OpenAI...");

    try {
      // 3. CALL LLM WITH TIMEOUT
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
            ],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      ).timeout(const Duration(seconds: 200)); // Increased timeout to 15s to be safe

      print("Agent D: Received response from OpenAI.");

      final content = chatCompletion.choices.first.message.content?.first.text;
      if (content != null) {
        print("Agent D: Valid content received. Length: ${content.length} chars.");
        // print("RAW JSON: $content"); // Uncomment if you need to see raw output
        try {
          final jsonOutput = json.decode(content);
          print("Agent D: JSON decoding successful.");
          return jsonOutput;
        } catch (jsonError) {
          print("Agent D Error: Failed to decode JSON. $jsonError");
          print("Raw Content that failed: $content");
          throw Exception("Invalid JSON received from AI");
        }
      } else {
        print("Agent D Error: Response content was null.");
        throw Exception("Empty response from AI");
      }
    } catch (e) {
      print("AIService Critical Error: $e");
      if (e is TimeoutException) {
        print("AIService: Operation timed out after 15 seconds.");
      }
      // Return fallback data so the UI doesn't hang
      print("AIService: Returning fallback data to prevent UI crash.");
      return _getFallbackData();
    }
  }

  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "311 Food",
          "title": "Simulation Mode (Offline)",
          "summary": "The AI service timed out or is unconfigured. Showing simulated data to demonstrate UI functionality.",
          "severity": "Low",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Demo: Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Network Timeout - Using Cached Data"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8]
        }
      ]
    };
  }
}*/

/*
import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart'; // Security
import 'news_sources.dart'; // Scraper Targets
import 'market_data_service.dart'; // Real-time Facts

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    // Only initialize if a real key is provided to avoid crashes in demo mode
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
    }
  }

  // 1. SIMULATED SCRAPER: Fetches specific agricultural news
  Future<List<String>> fetchAgHeadlines() async {
    // In a production backend, this would use a Python 'feedparser' worker.
    // For this Flutter POC, we simulate the latency of hitting these specific endpoints.

    print("Agent A: Initiating scrape of ${NewsSources.targetSources.length} target feeds...");
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real implementation, you would loop through NewsSources.targetSources
    // and parse the RSS XML. For the POC, we return a simulated "Live" extraction.
    return [
      "[AgWeb] Kansas winter wheat ratings drop to historic lows due to persistent drought",
      "[Reuters] Brazil soy harvest accelerates, putting pressure on US export premiums",
      "[Food Business News] Fertilizer prices stabilizing as natural gas costs retreat",
      "[USDA] Avian Flu detection in commercial layer flocks expands to 3 new states",
      "[Western Producer] Canadian canola crush capacity set to double by 2027"
    ];
  }

  // 2. THE SYNTHESIZER: Sends data to GPT-4 for "Divergence" calculation
  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {

    // DEMO SAFEGUARD: If no key is set, return mock data immediately
    if (apiKey.contains("YOUR_")) {
      return _getFallbackData();
    }

    // 1. FETCH LIVE FACTS (The "Ingestion Engine")
    // This replaces hardcoded strings with real API data from AlphaVantage/BoC
    String facts;
    try {
      facts = await _dataService.getLiveFactsString();
    } catch (e) {
      print("Data Service Error: $e");
      facts = "Error fetching live data. Using cached baseline: Wheat \$5.80 (Stable).";
    }

    // 2. CONSTRUCT PROMPT (The "Harness")
    final systemPrompt = '''
    You are an Industrial Intelligence Analyst for NexThread.
    
    STEP 1: SOURCE ATTRIBUTION
    You are analyzing data extracted from the following verified sources:
    ${NewsSources.targetSources.map((s) => "- ${s['name']} (${s['type']})").join('\n')}
    
    STEP 2: ANALYZE FACTS vs. SENTIMENT
    
    [OFFICIAL DATA SOURCE (FACTS)]
    $facts
    
    [UNSTRUCTURED NEWS (SENTIMENT)]
    ${news.join('\n')}
    
    STEP 3: DETECT DIVERGENCE
    - Compare the Official Data Status (e.g., "Abundant", "Spiking") against the News Sentiment.
    - If Fact="Stable/Abundant" but News="Panic", tag as "Unjustified Panic".
    - If Fact="Spiking" and News="Panic", tag as "Confirmed Crisis".
    - If Fact="Crashing" but News="High Prices", tag as "Margin Padding".

    STEP 4: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (e.g. "311 Food"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100 based on Fact Status), sent_score (0-100 based on News Panic)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (array of 7 doubles)
    - headlines (array of strings used for this specific insight)
    ''';

    // --- DEBUG: PRINT PROMPT TO CONSOLE ---
    print("=================================================================");
    print("🤖 AGENT D SYSTEM PROMPT (LIVE):");
    print("=================================================================");
    print(systemPrompt);
    print("=================================================================");

    try {
      // 3. CALL LLM
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        responseFormat: {"type": "json_object"}, // Enforce JSON
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
            ],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      );

      final content = chatCompletion.choices.first.message.content?.first.text;
      if (content != null) {
        return json.decode(content);
      } else {
        throw Exception("Empty response from AI");
      }
    } catch (e) {
      print("AI Generation Error: $e");
      return _getFallbackData();
    }
  }

  // Fallback data so your demo never crashes
  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "311 Food",
          "title": "Demo Mode: API Key Missing",
          "summary": "Please update your OpenAI Key in lib/secrets.dart to see live generation. Showing demo data.",
          "severity": "Low",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Demo: Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Config Required"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8]
        }
      ]
    };
  }
}
*/
/*
import 'dart:convert';
import 'dart:async'; // Required for TimeoutException
import 'dart:io';    // Required for SocketException
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart'; // Security
import 'news_sources.dart'; // Scraper Targets
import 'market_data_service.dart'; // Real-time Facts

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      print("AIService: Valid API Key format detected. Configuring OpenAI.");
      OpenAI.apiKey = apiKey;
    } else {
      print("AIService: Placeholder API Key detected. Will use fallback/demo mode.");
    }
  }

  // 1. SIMULATED SCRAPER: Fetches specific agricultural news
  Future<List<String>> fetchAgHeadlines() async {
    // In a production backend, this would use a Python 'feedparser' worker.
    // For this Flutter POC, we simulate the latency of hitting these specific endpoints.

    print("Agent A: Initiating scrape of ${NewsSources.targetSources.length} target feeds...");
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real implementation, you would loop through NewsSources.targetSources
    // and parse the RSS XML. For the POC, we return a simulated "Live" extraction.
    return [
      "[AgWeb] Kansas winter wheat ratings drop to historic lows due to persistent drought",
      "[Reuters] Brazil soy harvest accelerates, putting pressure on US export premiums",
      "[Food Business News] Fertilizer prices stabilizing as natural gas costs retreat",
      "[USDA] Avian Flu detection in commercial layer flocks expands to 3 new states",
      "[Western Producer] Canadian canola crush capacity set to double by 2027"
    ];
  }

  // 2. THE SYNTHESIZER: Sends data to GPT-4 for "Divergence" calculation
  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {

    print("--- AIService: generateIntelligence() called ---");

    // DEMO SAFEGUARD: If no key is set, return mock data immediately
    if (apiKey.contains("YOUR_")) {
      print("AIService: Demo Mode active (No API Key). Returning fallback data.");
      return _getFallbackData();
    }

    // 1. FETCH LIVE FACTS (The "Ingestion Engine")
    String facts;
    try {
      facts = await _dataService.getLiveFactsString();
    } catch (e) {
      print("Data Service Error: $e");
      facts = "Error fetching live data. Using cached baseline: Wheat \$5.80 (Stable).";
    }

    // 2. CONSTRUCT PROMPT (The "Harness")
    final systemPrompt = '''
    You are an Industrial Intelligence Analyst for NexThread.
    
    STEP 1: SOURCE ATTRIBUTION
    You are analyzing data extracted from the following verified sources:
    ${NewsSources.targetSources.map((s) => "- ${s['name']} (${s['type']})").join('\n')}
    
    STEP 2: ANALYZE FACTS vs. SENTIMENT
    
    [OFFICIAL DATA SOURCE (FACTS)]
    $facts
    
    [UNSTRUCTURED NEWS (SENTIMENT)]
    ${news.join('\n')}
    
    STEP 3: DETECT DIVERGENCE
    - Compare the Official Data Status (e.g., "Abundant", "Spiking") against the News Sentiment.
    - If Fact="Stable/Abundant" but News="Panic", tag as "Unjustified Panic".
    - If Fact="Spiking" and News="Panic", tag as "Confirmed Crisis".
    - If Fact="Crashing" but News="High Prices", tag as "Margin Padding".

    STEP 4: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (e.g. "311 Food"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100 based on Fact Status), sent_score (0-100 based on News Panic)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (array of 7 doubles)
    - headlines (array of strings used for this specific insight)
    ''';

    // --- DEBUG: PRINT PROMPT TO CONSOLE ---
    print("=================================================================");
    print("🤖 AGENT D: Sending Request to OpenAI...");
    print("   Model: gpt-4-turbo");
    print("   Prompt Length: ${systemPrompt.length} chars");
    print("=================================================================");

    try {
      // 3. CALL LLM WITH INCREASED TIMEOUT
      // GPT-4 Turbo can be slow with JSON schema generation. Increased to 60s.
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        responseFormat: {"type": "json_object"}, // Enforce JSON
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
            ],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      ).timeout(const Duration(seconds: 60));

      print("✅ Agent D: Response received!");

      final content = chatCompletion.choices.first.message.content?.first.text;
      if (content != null) {
        return json.decode(content);
      } else {
        throw Exception("Empty response from AI");
      }

    } on TimeoutException catch (_) {
      print("❌ AIService DIAGNOSIS: Timeout Error (60s Limit Reached)");
      print("   -> Cause: GPT-4-Turbo is taking too long to generate JSON.");
      print("   -> Fix: Check internet connection speed or try 'gpt-3.5-turbo' for speed.");
      return _getFallbackData();

    } on SocketException catch (e) {
      print("❌ AIService DIAGNOSIS: Network Error (SocketException)");
      print("   -> Cause: Device cannot reach OpenAI API. No internet or DNS failure.");
      print("   -> Details: $e");
      return _getFallbackData();

    } catch (e) {
      print("❌ AIService DIAGNOSIS: API Error");
      final errorStr = e.toString();

      if (errorStr.contains("401")) {
        print("   -> CRITICAL: 401 Unauthorized. Your API Key is invalid.");
      } else if (errorStr.contains("429")) {
        print("   -> CRITICAL: 429 Too Many Requests. You ran out of credits or hit a rate limit.");
      } else if (errorStr.contains("500") || errorStr.contains("503")) {
        print("   -> ISSUE: OpenAI Servers are down.");
      } else {
        print("   -> Details: $e");
      }

      return _getFallbackData();
    }
  }

  // Fallback data so your demo never crashes
  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "311 Food",
          "title": "Demo Mode: AI Service Unavailable",
          "summary": "The AI service encountered an error (Check Debug Console). Displaying simulated data to demonstrate UI functionality.",
          "severity": "Low",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Demo: Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Error Logged to Console", "Using Fallback Data"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8]
        }
      ]
    };
  }
}*/
/*
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';
import 'news_sources.dart';
import 'market_data_service.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      print("AIService: Valid API Key format detected. Configuring OpenAI.");
      OpenAI.apiKey = apiKey;
    } else {
      print("AIService: Placeholder API Key detected. Will use fallback/demo mode.");
    }
  }

  Future<List<String>> fetchAgHeadlines() async {
    print("Agent A: Initiating scrape of ${NewsSources.targetSources.length} target feeds...");
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      "[AgWeb] Kansas winter wheat ratings drop to historic lows due to persistent drought",
      "[Reuters] Brazil soy harvest accelerates, putting pressure on US export premiums",
      "[Food Business News] Fertilizer prices stabilizing as natural gas costs retreat",
      "[USDA] Avian Flu detection in commercial layer flocks expands to 3 new states",
      "[Western Producer] Canadian canola crush capacity set to double by 2027"
    ];
  }

  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {

    print("--- AIService: generateIntelligence() called ---");

    if (apiKey.contains("YOUR_")) {
      print("AIService: Demo Mode active (No API Key). Returning fallback data.");
      return _getFallbackData();
    }

    String facts;
    try {
      facts = await _dataService.getLiveFactsString();
    } catch (e) {
      print("Data Service Error: $e");
      facts = "Error fetching live data. Using cached baseline: Wheat \$5.80 (Stable).";
    }

    final systemPrompt = '''
    You are an Industrial Intelligence Analyst for NexThread.
    
    STEP 1: SOURCE ATTRIBUTION
    You are analyzing data extracted from the following verified sources:
    ${NewsSources.targetSources.map((s) => "- ${s['name']} (${s['type']})").join('\n')}
    
    STEP 2: ANALYZE FACTS vs. SENTIMENT
    [OFFICIAL DATA SOURCE (FACTS)]
    $facts
    
    [UNSTRUCTURED NEWS (SENTIMENT)]
    ${news.join('\n')}
    
    STEP 3: DETECT DIVERGENCE
    - Compare the Official Data Status (e.g., "Abundant", "Spiking") against the News Sentiment.
    - If Fact="Stable/Abundant" but News="Panic", tag as "Unjustified Panic".
    - If Fact="Spiking" and News="Panic", tag as "Confirmed Crisis".
    - If Fact="Crashing" but News="High Prices", tag as "Margin Padding".

    STEP 4: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (e.g. "311 Food"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100 based on Fact Status), sent_score (0-100 based on News Panic)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (array of 7 doubles)
    - headlines (array of strings used for this specific insight)
    - process_steps (array of objects: { "step": string, "desc": string }) describing your thought process.
    - sources (array of objects: { "name": string, "type": string, "reliability": "High/Med/Low" }) used for verification.
    - harness (string) The specific prompt logic you used for this sector.
    ''';

    print("=================================================================");
    print("🤖 AGENT D: Sending Request to OpenAI...");
    print("=================================================================");

    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
            ],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      ).timeout(const Duration(seconds: 60));

      print("✅ Agent D: Response received!");

      final content = chatCompletion.choices.first.message.content?.first.text;
      if (content != null) {
        return json.decode(content);
      } else {
        throw Exception("Empty response from AI");
      }

    } catch (e) {
      print("❌ AIService Critical Error: $e");
      return _getFallbackData();
    }
  }

  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "311 Food",
          "title": "Demo Mode: AI Service Unavailable",
          "summary": "The AI service encountered an error or is unconfigured. Displaying simulated data to demonstrate UI functionality.",
          "severity": "Low",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Demo: Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Network Timeout - Using Cached Data"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8],
          // NEW: Fallback Logic Data
          "process_steps": [
            {"step": "Data Ingestion", "desc": "Fetched 5 articles from AgWeb & Reuters."},
            {"step": "Verification", "desc": "Cross-referenced 'Drought' claims against USDA WASDE report."},
            {"step": "Sentiment Scoring", "desc": "Detected high anxiety keywords (Score: 20)."},
            {"step": "Divergence Calc", "desc": "Fact (85) >> Sentiment (20). Gap identified."}
          ],
          "sources": [
            {"name": "USDA WASDE", "type": "Government", "reliability": "High"},
            {"name": "AgWeb", "type": "Trade Journal", "reliability": "Medium"}
          ],
          "harness": "System Prompt: Monitor global sugar/palm oil. Correlate weather with 311 margins."
        }
      ]
    };
  }
}*/

import 'dart:convert';
import 'dart:async'; // Required for TimeoutException
import 'dart:io';    // Required for SocketException
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';
import 'news_sources.dart';
import 'market_data_service.dart';

/*
class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      print("AIService: Valid API Key format detected. Configuring OpenAI.");
      OpenAI.apiKey = apiKey;
    } else {
      print("AIService: Placeholder API Key detected. Will use fallback/demo mode.");
    }
  }

  // 1. SIMULATED SCRAPER: Fetches specific agricultural news
  Future<List<String>> fetchAgHeadlines() async {
    print("Agent A: Initiating scrape of ${NewsSources.targetSources.length} target feeds...");
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, we would check entry.publishedDate here.
    return [
      "[AgWeb - TODAY] Kansas winter wheat ratings drop to historic lows due to persistent drought",
      "[Reuters - YESTERDAY] Brazil soy harvest accelerates, putting pressure on US export premiums",
      "[Food Business News - 2 DAYS AGO] Fertilizer prices stabilizing as natural gas costs retreat",
      // Note: Stale items would be filtered out before returning this list in a real implementation
    ];
  }

  // 2. THE SYNTHESIZER: Sends data to GPT-4 for "Divergence" calculation
  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {

    print("--- AIService: generateIntelligence() called ---");

    if (apiKey.contains("YOUR_")) {
      print("AIService: Demo Mode active (No API Key). Returning fallback data.");
      return _getFallbackData();
    }

    String facts;
    try {
      facts = await _dataService.getLiveFactsString();
    } catch (e) {
      print("Data Service Error: $e");
      facts = "Error fetching live data. Using cached baseline: Wheat \$5.80 (Stable).";
    }

    // 2. CONSTRUCT PROMPT (The "Harness")
    // UPDATED: Added "Staleness Check" instruction
    final systemPrompt = '''
    You are an Industrial Intelligence Analyst for NexThread.
    
    STEP 0: STALENESS CHECK & SOURCE ATTRIBUTION
    - Analyze the provided news headlines. 
    - DISCARD any source dated older than 1 year.
    - PRIORITIZE sources from the last 30 days.
    - Analyzed Sources:
    ${NewsSources.targetSources.map((s) => "- ${s['name']} (${s['type']})").join('\n')}
    
    STEP 1: ANALYZE FACTS vs. SENTIMENT
    [OFFICIAL DATA SOURCE (FACTS)]
    $facts
    
    [UNSTRUCTURED NEWS (SENTIMENT)]
    ${news.join('\n')}
    
    STEP 2: DETECT DIVERGENCE
    - Compare the Official Data Status (e.g., "Abundant", "Spiking") against the News Sentiment.
    - If Fact="Stable/Abundant" but News="Panic", tag as "Unjustified Panic".
    - If Fact="Spiking" and News="Panic", tag as "Confirmed Crisis".
    - If Fact="Crashing" but News="High Prices", tag as "Margin Padding".

    STEP 3: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (e.g. "311 Food"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100 based on Fact Status), sent_score (0-100 based on News Panic)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (array of 7 doubles)
    - headlines (array of strings used for this specific insight)
    ''';

    print("=================================================================");
    print("🤖 AGENT D: Sending Request to OpenAI...");
    print("   Model: gpt-4-turbo");
    print("   Prompt Length: ${systemPrompt.length} chars");
    print("=================================================================");

    try {
      // 3. CALL LLM WITH INCREASED TIMEOUT
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
            ],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      ).timeout(const Duration(seconds: 60));

      print("✅ Agent D: Response received!");

      final content = chatCompletion.choices.first.message.content?.first.text;
      if (content != null) {
        return json.decode(content);
      } else {
        throw Exception("Empty response from AI");
      }

    } catch (e) {
      print("❌ AIService Critical Error: $e");
      return _getFallbackData();
    }
  }

  // Fallback data so your demo never crashes
  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "311 Food",
          "title": "Demo Mode: AI Service Unavailable",
          "summary": "The AI service encountered an error or is unconfigured. Displaying simulated data to demonstrate UI functionality.",
          "severity": "Low",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Demo: Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Network Timeout - Using Cached Data"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8],
          // NEW: Showing that filtering happened
          "process_steps": [
            {"step": "Ingestion", "desc": "Scraped 12 articles from AgWeb."},
            {"step": "Filter", "desc": "Discarded 4 articles older than 1 year (Stale)."},
            {"step": "Sentiment", "desc": "Analyzed 8 current articles for anxiety keywords."},
            {"step": "Divergence", "desc": "Calculated gap between Fact(85) and Sentiment(20)."}
          ],
          "sources": [
            {"name": "USDA WASDE", "type": "Government", "reliability": "High"},
            {"name": "AgWeb", "type": "Trade Journal", "reliability": "Medium"}
          ],
          "harness": "System Prompt: Monitor global sugar/palm oil. Correlate weather with 311 margins."
        }
      ]
    };
  }
}*/
// ... imports ...

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      print("AIService: Valid API Key format detected. Configuring OpenAI.");
      OpenAI.apiKey = apiKey;
    } else {
      print("AIService: Placeholder API Key detected. Will use fallback/demo mode.");
    }
  }

  // 1. SIMULATED SCRAPER: Fetches specific agricultural news
  Future<List<String>> fetchAgHeadlines() async {
    print("Agent A: Initiating scrape of ${NewsSources.targetSources.length} target feeds...");
    await Future.delayed(const Duration(milliseconds: 800));

    // In a real app, we would check entry.publishedDate here.
    return [
      "[AgWeb - TODAY] Kansas winter wheat ratings drop to historic lows due to persistent drought",
      "[Reuters - YESTERDAY] Brazil soy harvest accelerates, putting pressure on US export premiums",
      "[Food Business News - 2 DAYS AGO] Fertilizer prices stabilizing as natural gas costs retreat",
      // Note: Stale items would be filtered out before returning this list in a real implementation
    ];
  }

  // 2. THE SYNTHESIZER: Sends data to GPT-4 for "Divergence" calculation
  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {

    print("--- AIService: generateIntelligence() called ---");

    if (apiKey.contains("YOUR_")) {
      print("AIService: Demo Mode active (No API Key). Returning fallback data.");
      return _getFallbackData();
    }

    String facts;
    try {
      facts = await _dataService.getLiveFactsString();
    } catch (e) {
      print("Data Service Error: $e");
      facts = "Error fetching live data. Using cached baseline: Wheat \$5.80 (Stable).";
    }

    // 2. CONSTRUCT PROMPT (The "Harness")
    // UPDATED: Added "Staleness Check" instruction
    final systemPrompt = '''
    You are an Industrial Intelligence Analyst for NexThread.
    
    STEP 0: STALENESS CHECK & SOURCE ATTRIBUTION
    - Analyze the provided news headlines. 
    - DISCARD any source dated older than 1 year.
    - PRIORITIZE sources from the last 30 days.
    - Analyzed Sources:
    ${NewsSources.targetSources.map((s) => "- ${s['name']} (${s['type']})").join('\n')}
    
    STEP 1: ANALYZE FACTS vs. SENTIMENT
    [OFFICIAL DATA SOURCE (FACTS)]
    $facts
    
    [UNSTRUCTURED NEWS (SENTIMENT)]
    ${news.join('\n')}
    
    STEP 2: DETECT DIVERGENCE
    - Compare the Official Data Status (e.g., "Abundant", "Spiking") against the News Sentiment.
    - If Fact="Stable/Abundant" but News="Panic", tag as "Unjustified Panic".
    - If Fact="Spiking" and News="Panic", tag as "Confirmed Crisis".
    - If Fact="Crashing" but News="High Prices", tag as "Margin Padding".

    STEP 3: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (e.g. "311 Food"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100 based on Fact Status), sent_score (0-100 based on News Panic)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (array of 7 doubles)
    - headlines (array of strings used for this specific insight)
    ''';

    print("=================================================================");
    print("🤖 AGENT D: Sending Request to OpenAI...");
    print("   Model: gpt-4-turbo");
    print("   Prompt Length: ${systemPrompt.length} chars");
    print("=================================================================");

    try {
      // 3. CALL LLM WITH INCREASED TIMEOUT
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
            ],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      ).timeout(const Duration(seconds: 60));

      print("✅ Agent D: Response received!");

      final content = chatCompletion.choices.first.message.content?.first.text;
      if (content != null) {
        return json.decode(content);
      } else {
        throw Exception("Empty response from AI");
      }

    } catch (e) {
      print("❌ AIService Critical Error: $e");
      return _getFallbackData();
    }
  }

  // Fallback data so your demo never crashes
  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "311 Food",
          "title": "Demo Mode: AI Service Unavailable",
          "summary": "The AI service encountered an error or is unconfigured. Displaying simulated data to demonstrate UI functionality.",
          "severity": "Low",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Demo: Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Network Timeout - Using Cached Data"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8],
          // NEW: Showing that filtering happened
          "process_steps": [
            {"step": "Ingestion", "desc": "Scraped 12 articles from AgWeb."},
            {"step": "Filter", "desc": "Discarded 4 articles older than 1 year (Stale)."},
            {"step": "Sentiment", "desc": "Analyzed 8 current articles for anxiety keywords."},
            {"step": "Divergence", "desc": "Calculated gap between Fact(85) and Sentiment(20)."}
          ],
          "sources": [
            {"name": "USDA WASDE", "type": "Government", "reliability": "High"},
            {"name": "AgWeb", "type": "Trade Journal", "reliability": "Medium"}
          ],
          "harness": "System Prompt: Monitor global sugar/palm oil. Correlate weather with 311 margins."
        }
      ]
    };
  }
}

// Fallback data for the POC
Map<String, dynamic> _getFallbackData() {
  return {
    "briefs": [
      {
        "id": "1121",
        "subsector": "112 Animal Production",
        "title": "Avian Flu Bifurcation: Eggs vs. Broilers",
        "summary": "H5N1 outbreak has decimated layer flocks (Eggs) while broiler (Meat) stocks remain unaffected. Market sentiment is incorrectly applying 'Poultry Crisis' logic to plentiful meat stocks.",
        "severity": "High",
        "fact_score": 80,
        "sent_score": 18,
        "divergence_tag": "Sector Split",
        "divergence_desc": "Broiler meat is Abundant (Fact 80), but Sentiment (18) is dragged down by the Egg crisis. Opportunity in meat contracts.",
        "metrics": {"commodity": "Broiler Spot", "price": "\$1.12/lb", "trend": "-5.0% YoY"},
        "headlines": ["USDA: Layer flocks down 12%", "AgWeb: Broiler inventory stable"],
        "chart_data": [1.30, 1.28, 1.25, 1.20, 1.18, 1.15, 1.12],
        "process_steps": [
          {"step": "USDA Census", "desc": "Comparing layer vs broiler flock counts from monthly USDA reports."},
          {"step": "Sentiment NLP", "desc": "Analyzing procurement forums for generalized 'Chicken Shortage' discussions."}
        ],
        "sources": [
          {"name": "USDA Poultry Report", "type": "Gov", "reliability": "High", "uri": "https://www.usda.gov/topics/animals/poultry"}
        ],
        "harness": "SYSTEM PROMPT: Differentiate between biological impact on layers vs broilers.",
        "signals": ["Livestock contagion", "Panic Buying"],
        "sentimentMeta": { "sourceCount": 22, "errorMargin": 5, "confidence": "High" },
        "divergence": {
          "type": "Sector Split",
          "level": 62,
          "description": "Broiler meat is Abundant (Fact 80), but Sentiment (18) is dragged down by the Egg crisis.",
          "factScore": 80,
          "sentScore": 18
        },
        "sentiment_headlines": [
          { "text": "Egg prices triple as Avian Flu spreads", "source": "Poultry World", "polarity": "Negative" },
          { "text": "Broiler stocks actually up 4%", "source": "USDA Report", "polarity": "Positive" }
        ]
      },
      // ... You can add more mock items here ...
    ]
  };
}
