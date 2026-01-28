/*


import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'secrets.dart';
import 'news_sources.dart';
import 'market_data_service.dart';
import 'signal_data.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
    }
  }

  // 1. FILTERED SCRAPER: Returns relevant Ag headlines
  Future<List<String>> fetchAgHeadlines() async {
    print("Agent A: Scanning for WHEAT-SPECIFIC news...");

    List<String> headlines = [];

    await Future.wait(NewsSources.targetSources.map((source) async {
      try {
        final originalUrl = source['url']!;
        // Try Primary Proxy
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(originalUrl)}";
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        // Try Backup Proxy if needed
        if (response.statusCode != 200) {
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}";
          response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));
        }

        if (response.statusCode == 200) {
          final document = XmlDocument.parse(response.body);
          final items = document.findAllElements('item').followedBy(document.findAllElements('entry'));

          for (var item in items) {
            final titleNode = item.findElements('title').firstOrNull;
            if (titleNode != null) {
              final title = titleNode.innerText.replaceAll(RegExp(r'\s+'), ' ').trim();

              // --- STRICT WHEAT FILTER ---
              // Accepting wheat, corn, soy, energy, logistics to catch signals defined in SignalData
              final t = title.toLowerCase();
              if (t.contains('wheat') || t.contains('corn') || t.contains('sugar') ||
                  t.contains('fuel') || t.contains('food') || t.contains('soy') ||
                  t.contains('grain') || t.contains('rail') || t.contains('port')) {
                headlines.add("[${source['name']}] $title");
              }
            }
          }
        }
      } catch (e) {
        print("Agent A: Skip ${source['name']} - $e");
      }
    }));

    if (headlines.isEmpty) {
      print("Agent A: No news found. Using cached wheat fallback.");
      return [
        "[AgWeb - CACHED] Kansas winter wheat ratings drop to historic lows",
        "[Reuters - CACHED] Global wheat stocks tighten as harvest delays hit",
        "[Bloomberg - CACHED] Rail stoppage threatens fertilizer shipments in Western Canada"
      ];
    }

    // Limit to top 15 headlines to prevent Token limit issues
    if (headlines.length > 15) {
      headlines = headlines.sublist(0, 15);
    }

    return headlines;
  }

  // 2. INTELLIGENCE GENERATOR
  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {
    if (apiKey.contains("YOUR_")) return _getFallbackData();

    String facts;
    try {
      facts = await _dataService.getLiveFactsString();
    } catch (e) {
      facts = "Wheat: \$5.80 (Stable)";
    }

    // --- COMPRESSED PROMPT (Solves the "Request too large" error) ---
    // Instead of injecting 30,000+ tokens of permutations, we inject the RULES.
    const riskLogic = '''
    [RISK WEIGHTING RULES]
    Apply these weights to the headlines provided:
    1. GEOPOLITICAL (Weight -8 to -10): War, Export Bans, Sanctions, Port Strikes, Canal Blockages.
    2. BIO-THREAT (Weight -9 to -10): Avian Flu, Swine Fever, Contagion.
    3. INFRASTRUCTURE (Weight -6 to -8): Rail Stoppage, Bridge Collapse, Grid Failure.
    4. SUPPLY/CLIMATE (Weight -5 to -7): Drought, Flooding, Yield Failure, Stockpile Depletion.
    5. ENERGY/INPUTS (Weight -3 to -5): Fertilizer Spike, Diesel Shortage, Gas volatility.
    ''';

    final systemPrompt = '''
    You are a Commodity Intelligence Analyst.
    
    STEP 1: ANALYZE FACTS vs. SENTIMENT
    [REAL-TIME MARKET DATA]
    $facts
    
    [NEWS WIRE STREAM]
    ${news.join('\n')}

    $riskLogic
    
    STEP 2: DETECT DIVERGENCE & OPPORTUNITY
    - Compare Official Data (Status/Trend) against News Sentiment.
    - Check if any headline matches a "Risk Weighting Rule" above. If so, increase Severity.
    - LOOK FOR:
      1. "Unjustified Panic": Data is Stable, but News is Negative (Buy Opportunity).
      2. "Silent Crisis": Data is Crashing, but News is Quiet (Risk).
      3. "Sector Split": One commodity is up, another is down (Arbitrage).

    STEP 3: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (e.g. "Wheat", "Energy"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100), sent_score (0-100)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (array of 7 doubles for a simulated trendline)
    - headlines (list of strings used)
    - signals (list of strings matching the Risk Rules found)
    - is_fallback (boolean, set to false)
    ''';

    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      ).timeout(const Duration(seconds: 60));

      final content = chatCompletion.choices.first.message.content?.first.text;
      return json.decode(content ?? "{}");

    } catch (e) {
      print("AI Generation Error: $e");
      return _getFallbackData();
    }
  }

  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "Wheat",
          "title": "Kansas Wheat Drought",
          "summary": "Severe drought in Kansas is driving sentiment down, but global stocks remain sufficient.",
          "severity": "High",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Kansas winter wheat ratings drop"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8],
          "process_steps": [],
          "sources": [],
          "harness": "Prompt: Analyze wheat drought impact.",
          "signals": ["Aquifer Depletion (Ogallala)"],
          "is_fallback": true
        }
      ]
    };
  }
}

// --- DATA MODELS ---

class Briefing {
  final String id;
  final String subsector;
  final String title;
  final String summary;
  final String severity;
  final int factScore;
  final int sentScore;
  final String divergenceTag;
  final String divergenceDesc;
  final Metrics metrics;
  final List<String> signals;
  final List<double> chartData;
  final List<ProcessStep> processSteps;
  final List<Source> sources;
  final String harness;
  final List<SentimentHeadline> sentimentHeadlines;
  final List<String> headlines;
  final bool isFallback;

  Briefing({
    required this.id,
    required this.subsector,
    required this.title,
    required this.summary,
    required this.severity,
    required this.factScore,
    required this.sentScore,
    required this.divergenceTag,
    required this.divergenceDesc,
    required this.metrics,
    required this.signals,
    required this.chartData,
    required this.processSteps,
    required this.sources,
    required this.harness,
    required this.sentimentHeadlines,
    required this.headlines,
    required this.isFallback,
  });

  factory Briefing.fromJson(Map<String, dynamic> json) {
    return Briefing(
      id: json['id']?.toString() ?? '',
      subsector: json['subsector'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      severity: json['severity'] ?? 'Low',
      factScore: (json['fact_score'] as num?)?.toInt() ?? 0,
      sentScore: (json['sent_score'] as num?)?.toInt() ?? 0,
      divergenceTag: json['divergence_tag'] ?? '',
      divergenceDesc: json['divergence_desc'] ?? '',
      metrics: Metrics.fromJson(json['metrics'] ?? {}),
      signals: List<String>.from(json['signals'] ?? []),
      chartData: (json['chart_data'] as List<dynamic>? ?? [])
          .where((x) => x != null && x is num)
          .map((x) => (x as num).toDouble())
          .toList(),
      processSteps: (json['process_steps'] as List?)?.map((x) => ProcessStep.fromJson(x)).toList() ?? [],
      sources: (json['sources'] as List?)?.map((x) => Source.fromJson(x)).toList() ?? [],
      harness: json['harness']?.toString() ?? '',
      sentimentHeadlines: (json['sentiment_headlines'] as List?)?.map((x) => SentimentHeadline.fromJson(x)).toList() ?? [],
      headlines: List<String>.from(json['headlines'] ?? []),
      isFallback: json['is_fallback'] ?? false,
    );
  }
}

class Metrics {
  final String commodity;
  final String price;
  final String trend;

  Metrics({required this.commodity, required this.price, required this.trend});

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      commodity: json['commodity'] ?? '',
      price: json['price']?.toString() ?? '',
      trend: json['trend']?.toString() ?? '',
    );
  }
}

class ProcessStep {
  final String step;
  final String desc;

  ProcessStep({required this.step, required this.desc});

  factory ProcessStep.fromJson(Map<String, dynamic> json) {
    return ProcessStep(
      step: json['step']?.toString() ?? '',
      desc: json['desc'] ?? '',
    );
  }
}

class Source {
  final String name;
  final String type;
  final String reliability;
  final String uri;

  Source({required this.name, required this.type, required this.reliability, this.uri = ''});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      reliability: json['reliability'] ?? '',
      uri: json['uri'] ?? '',
    );
  }
}

class SentimentHeadline {
  final String text;
  final String source;
  final String polarity;

  SentimentHeadline({required this.text, required this.source, required this.polarity});

  factory SentimentHeadline.fromJson(Map<String, dynamic> json) {
    return SentimentHeadline(
      text: json['text'] ?? '',
      source: json['source'] ?? '',
      polarity: json['polarity'] ?? '',
    );
  }
}*/
/*

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'secrets.dart';
import 'news_sources.dart';
import 'market_data_service.dart';
import 'signal_data.dart';
import 'models.dart'; // IMPORT ADDED

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
    }
  }

  // 1. FILTERED SCRAPER
  Future<List<String>> fetchAgHeadlines() async {
    print("Agent A: Scanning for WHEAT-SPECIFIC news...");
    List<String> headlines = [];

    await Future.wait(NewsSources.targetSources.map((source) async {
      try {
        final originalUrl = source['url']!;
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(originalUrl)}";
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}";
          response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));
        }

        if (response.statusCode == 200) {
          final document = XmlDocument.parse(response.body);
          final items = document.findAllElements('item').followedBy(document.findAllElements('entry'));

          for (var item in items) {
            final titleNode = item.findElements('title').firstOrNull;
            if (titleNode != null) {
              final title = titleNode.innerText.replaceAll(RegExp(r'\s+'), ' ').trim();
              final t = title.toLowerCase();
              if (t.contains('wheat') || t.contains('corn') || t.contains('sugar') ||
                  t.contains('fuel') || t.contains('food') || t.contains('soy') ||
                  t.contains('grain') || t.contains('rail') || t.contains('port')) {
                headlines.add("[${source['name']}] $title");
              }
            }
          }
        }
      } catch (e) {
        print("Agent A: Skip ${source['name']} - $e");
      }
    }));

    if (headlines.isEmpty) {
      return [
        "[AgWeb - CACHED] Kansas winter wheat ratings drop to historic lows",
        "[Reuters - CACHED] Global wheat stocks tighten as harvest delays hit",
      ];
    }
    if (headlines.length > 15) headlines = headlines.sublist(0, 15);
    return headlines;
  }

  // 2. INTELLIGENCE GENERATOR
  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {
    if (apiKey.contains("YOUR_")) return _getFallbackData();

    // 1. Fetch Real Data + History
    MarketFact wheatFact = await _dataService.getWheatFact();
    String facts = wheatFact.toString();

    // COMPRESSED PROMPT RULES
    const riskLogic = '''
    [RISK WEIGHTING RULES]
    Apply these weights to the headlines provided:
    1. GEOPOLITICAL (Weight -8 to -10): War, Export Bans, Sanctions.
    2. BIO-THREAT (Weight -9 to -10): Avian Flu, Swine Fever.
    3. INFRASTRUCTURE (Weight -6 to -8): Rail Stoppage, Bridge Collapse.
    4. SUPPLY/CLIMATE (Weight -5 to -7): Drought, Flooding.
    ''';

    final systemPrompt = '''
    You are a Commodity Intelligence Analyst.
    
    STEP 1: ANALYZE FACTS vs. SENTIMENT
    [REAL-TIME MARKET DATA]
    $facts
    
    [NEWS WIRE STREAM]
    ${news.join('\n')}

    $riskLogic
    
    STEP 2: DETECT DIVERGENCE
    - Compare Official Data (Status/Trend) against News Sentiment.
    - LOOK FOR: Unjustified Panic, Silent Crisis, or Sector Split.

    STEP 3: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (e.g. "Wheat"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100), sent_score (0-100)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (placeholder array, will be overwritten)
    - headlines (list of strings used)
    - signals (list of strings matching Risk Rules)
    - is_fallback (false)
    ''';

    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      ).timeout(const Duration(seconds: 60));

      final content = chatCompletion.choices.first.message.content?.first.text;
      Map<String, dynamic> jsonResponse = json.decode(content ?? "{}");

      // OVERWRITE CHART DATA WITH REAL HISTORY
      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (wheatFact.lineData.isNotEmpty) {
            brief['chart_data'] = wheatFact.lineData;
          }
        }
      }

      return jsonResponse;

    } catch (e) {
      print("AI Generation Error: $e");
      return _getFallbackData();
    }
  }

  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "Wheat",
          "title": "Kansas Wheat Drought",
          "summary": "Severe drought in Kansas is driving sentiment down, but global stocks remain sufficient.",
          "severity": "High",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Kansas winter wheat ratings drop"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8],
          "process_steps": [],
          "sources": [],
          "harness": "Prompt: Analyze wheat drought impact.",
          "signals": ["Aquifer Depletion (Ogallala)"],
          "is_fallback": true
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
import 'package:xml/xml.dart';
import 'secrets.dart';
import 'news_sources.dart';
import 'market_data_service.dart';
import 'signal_data.dart';
import 'models.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
      // FIX: Increase the internal HTTP client timeout to 60 seconds
      // to prevent "TimeoutException after 0:00:30.000000"
      OpenAI.requestsTimeOut = const Duration(seconds: 60);
    }
  }

  // 1. FILTERED SCRAPER
  Future<List<String>> fetchAgHeadlines() async {
    print("Agent A: Scanning for WHEAT-SPECIFIC news...");
    List<String> headlines = [];

    await Future.wait(NewsSources.targetSources.map((source) async {
      try {
        final originalUrl = source['url']!;
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(originalUrl)}";
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}";
          response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));
        }

        if (response.statusCode == 200) {
          final document = XmlDocument.parse(response.body);
          final items = document.findAllElements('item').followedBy(document.findAllElements('entry'));

          for (var item in items) {
            final titleNode = item.findElements('title').firstOrNull;
            if (titleNode != null) {
              final title = titleNode.innerText.replaceAll(RegExp(r'\s+'), ' ').trim();
              final t = title.toLowerCase();
              if (t.contains('wheat') || t.contains('corn') || t.contains('sugar') ||
                  t.contains('fuel') || t.contains('food') || t.contains('soy') ||
                  t.contains('grain') || t.contains('rail') || t.contains('port')) {
                headlines.add("[${source['name']}] $title");
              }
            }
          }
        }
      } catch (e) {
        print("Agent A: Skip ${source['name']} - $e");
      }
    }));

    if (headlines.isEmpty) {
      return [
        "[AgWeb - CACHED] Kansas winter wheat ratings drop to historic lows",
        "[Reuters - CACHED] Global wheat stocks tighten as harvest delays hit",
      ];
    }

    // --- STRICT STABILIZATION ---
    // 1. Deduplicate
    headlines = headlines.toSet().toList();
    // 2. Sort
    headlines.sort();
    // 3. Limit
    if (headlines.length > 15) headlines = headlines.sublist(0, 15);

    print("Agent A: Stabilized input with ${headlines.length} unique headlines.");
    return headlines;
  }

  // 2. INTELLIGENCE GENERATOR
  Future<Map<String, dynamic>> generateIntelligence(List<String> news) async {
    if (apiKey.contains("YOUR_")) return _getFallbackData();

    try {
      // 1. Fetch Real Data + History (Moved inside try/catch)
      MarketFact wheatFact = await _dataService.getWheatFact();
      String facts = wheatFact.toString();

      const riskLogic = '''
      [RISK WEIGHTING RULES]
      Apply these weights to the headlines provided:
      1. GEOPOLITICAL (Weight -8 to -10): War, Export Bans, Sanctions.
      2. BIO-THREAT (Weight -9 to -10): Avian Flu, Swine Fever.
      3. INFRASTRUCTURE (Weight -6 to -8): Rail Stoppage, Bridge Collapse.
      4. SUPPLY/CLIMATE (Weight -5 to -7): Drought, Flooding.
      ''';

      final systemPrompt = '''
      You are a Commodity Intelligence Analyst.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [REAL-TIME MARKET DATA]
      $facts
      
      [NEWS WIRE STREAM]
      ${news.join('\n')}

      $riskLogic
      
      STEP 2: DETECT DIVERGENCE
      - Compare Official Data (Status/Trend) against News Sentiment.
      - LOOK FOR: Unjustified Panic, Silent Crisis, or Sector Split.

      STEP 3: OUTPUT JSON
      Return a JSON object with a "briefs" array. Each brief must have:
      - id, subsector (e.g. "Wheat"), title, summary
      - severity (High/Medium/Low)
      - fact_score (0-100), sent_score (0-100)
      - divergence_tag, divergence_desc
      - metrics (commodity, price, trend)
      - chart_data (placeholder array, will be overwritten)
      - headlines (list of strings used)
      - signals (list of strings matching Risk Rules)
      - is_fallback (false)
      ''';

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        // --- STABILIZATION FIXES ---
        temperature: 0.0, // Absolute Zero Creativity
        seed: 42,         // Deterministic Seed
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      ).timeout(const Duration(seconds: 60)); // Future timeout matches internal config

      final content = chatCompletion.choices.first.message.content?.first.text;
      Map<String, dynamic> jsonResponse = json.decode(content ?? "{}");

      // OVERWRITE CHART DATA WITH REAL HISTORY
      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (wheatFact.lineData.isNotEmpty) {
            brief['chart_data'] = wheatFact.lineData;
          }
        }
      }

      return jsonResponse;

    } catch (e) {
      print("AI Generation Error: $e");
      return _getFallbackData();
    }
  }

  Map<String, dynamic> _getFallbackData() {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": "Wheat",
          "title": "Kansas Wheat Drought",
          "summary": "Severe drought in Kansas is driving sentiment down, but global stocks remain sufficient.",
          "severity": "High",
          "fact_score": 85,
          "sent_score": 20,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Supply High (85) vs Fear (20).",
          "metrics": {"commodity": "Wheat", "price": "\$5.80/bu", "trend": "-2% YoY"},
          "headlines": ["Kansas winter wheat ratings drop"],
          "chart_data": [5.0, 5.2, 5.1, 5.5, 5.8, 5.9, 5.8],
          "process_steps": [],
          "sources": [],
          "harness": "Prompt: Analyze wheat drought impact.",
          "signals": ["Aquifer Depletion (Ogallala)"],
          "is_fallback": true
        }
      ]
    };
  }
}*/
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../secrets.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart'; // REQUIRED: To save history

class AIService {
  final String apiKey = Secrets.openAiApiKey;

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
      // Increased timeout to prevent early termination during complex analysis
      OpenAI.requestsTimeOut = const Duration(seconds: 60);
    }
  }

  // --- GENERIC SCRAPER ---
  // Fetches RSS feeds defined in the TopicConfig
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    await Future.wait(sources.map((source) async {
      try {
        // 1. Try AllOrigins Proxy (Reliable for text)
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        // 2. Fallback to CorsProxy.io (Reliable for binary/strict CORS)
        if (response.statusCode != 200) {
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
          response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));
        }

        if (response.statusCode == 200) {
          final document = XmlDocument.parse(response.body);
          // Support both RSS <item> and Atom <entry>
          final items = document.findAllElements('item').followedBy(document.findAllElements('entry'));

          for (var item in items) {
            final titleNode = item.findElements('title').firstOrNull;
            if (titleNode != null) {
              final title = titleNode.innerText.replaceAll(RegExp(r'\s+'), ' ').trim();
              final t = title.toLowerCase();

              // Filter by Topic Keywords
              if (keywords.any((k) => t.contains(k.toLowerCase()))) {
                headlines.add("[${source.name}] $title");
              }
            }
          }
        }
      } catch (e) {
        // Silent fail for individual feeds to keep the process moving
        print("Scraper Error (${source.name}): $e");
      }
    }));

    // deduplicate and sort for consistency
    headlines = headlines.toSet().toList();
    headlines.sort();

    // Cap at 15 headlines to manage token costs
    if (headlines.length > 15) headlines = headlines.sublist(0, 15);

    return headlines;
  }

  // --- GENERIC INTELLIGENCE GENERATOR ---
  // 1. Fetches Market Data
  // 2. Fetches News
  // 3. Calls GPT-4
  // 4. SAVES result to Hive History
  Future<void> generateBriefing(TopicConfig topic) async {

    // FALLBACK MODE (If no API Key)
    if (apiKey.contains("YOUR_")) {
      final fallback = _getFallbackData(topic);
      await StorageService.saveBriefing(topic.id, fallback);
      return;
    }

    try {
      print("AIService: Generating LIVE Intelligence for ${topic.id}...");

      // A. Fetch Live Data
      final marketFact = await topic.fetchMarketPulse();

      // B. Fetch News
      final news = await fetchHeadlines(topic.sources, topic.keywords);
      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      // C. Construct Prompt
      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [RISK RULES]
      ${topic.riskRules}
      
      STEP 2: DETECT DIVERGENCE
      - Compare Data (Status/Trend) against News Sentiment.
      - Look for: Unjustified Panic, Silent Crisis, or Sector Split.

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

      // D. Call OpenAI
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        temperature: 0.0, // Strict deterministic output
        seed: 42,         // Seed for reproducibility
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      ).timeout(const Duration(seconds: 60));

      final content = chatCompletion.choices.first.message.content?.first.text;
      Map<String, dynamic> jsonResponse = json.decode(content ?? "{}");

      // E. Inject Real Market History into the AI Response
      // (The AI cannot generate accurate sparklines, so we overwrite them with real data)
      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
        }
      }

      // F. SAVE TO STORAGE (Appends to History)
      await StorageService.saveBriefing(topic.id, jsonResponse);

    } catch (e) {
      print("AI Generation Error: $e");
      // Save fallback data so the user sees an error state in the history
      await StorageService.saveBriefing(topic.id, _getFallbackData(topic));
    }
  }

  Map<String, dynamic> _getFallbackData(TopicConfig topic) {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": topic.name,
          "title": "Simulated Alert: ${topic.name} Volatility",
          "summary": "This is fallback data because the AI service is unreachable or the API key is missing.",
          "severity": "Low",
          "fact_score": 50,
          "sent_score": 50,
          "divergence_tag": "Simulation",
          "divergence_desc": "No live analysis available.",
          "metrics": {"commodity": topic.name, "price": "--", "trend": "0%"},
          "headlines": ["System Offline"],
          "chart_data": [1.0, 2.0, 1.5, 2.5, 2.0],
          "is_fallback": true
        }
      ]
    };
  }
}