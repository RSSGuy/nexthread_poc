/*
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../secrets.dart';
import 'models.dart';
import 'topic_config.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;

  AIService() {
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
      OpenAI.requestsTimeOut = const Duration(seconds: 60);
    }
  }

  // --- GENERIC SCRAPER ---
  // Now accepts specific sources and keywords from the TopicConfig
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    await Future.wait(sources.map((source) async {
      try {
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
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

              // Generic Keyword Filtering
              if (keywords.any((k) => t.contains(k.toLowerCase()))) {
                headlines.add("[${source.name}] $title");
              }
            }
          }
        }
      } catch (e) {
        // Silent fail for individual feeds
      }
    }));

    headlines = headlines.toSet().toList(); // Dedup
    headlines.sort(); // Stabilize
    if (headlines.length > 15) headlines = headlines.sublist(0, 15);

    return headlines;
  }

  // --- GENERIC INTELLIGENCE ---
  Future<Map<String, dynamic>> generateBriefing(TopicConfig topic) async {
    if (apiKey.contains("YOUR_")) return _getFallbackData(topic);

    try {
      // 1. Fetch Topic Data
      final marketFact = await topic.fetchMarketPulse();

      // 2. Fetch Topic News
      final news = await fetchHeadlines(topic.sources, topic.keywords);
      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

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

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        temperature: 0.0,
        seed: 42,
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

      // Inject Real History
      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
        }
      }

      return jsonResponse;

    } catch (e) {
      print("AI Error: $e");
      return _getFallbackData(topic);
    }
  }

  Map<String, dynamic> _getFallbackData(TopicConfig topic) {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": topic.name,
          "title": "Simulated Alert: ${topic.name} Volatility",
          "summary": "This is fallback data because the AI service is unreachable.",
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
}*/
/*
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../secrets.dart';
import 'models.dart';
import 'topic_config.dart';
import 'news_registry.dart'; // Ensure this is imported for the scraper

// --- CACHE HELPER ---
class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _CacheEntry(this.data, this.timestamp);

  bool get isValid => DateTime.now().difference(timestamp).inMinutes < 10;
}

class AIService {
  final String apiKey = Secrets.openAiApiKey;

  // --- CENTRAL MEMORY CACHE ---
  // Maps Topic ID ("wheat", "lumber") -> JSON Response
  static final Map<String, _CacheEntry> _cache = {};

  AIService() {
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
      OpenAI.requestsTimeOut = const Duration(seconds: 60);
    }
  }

  // --- GENERIC SCRAPER ---
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    await Future.wait(sources.map((source) async {
      try {
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
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

              if (keywords.any((k) => t.contains(k.toLowerCase()))) {
                headlines.add("[${source.name}] $title");
              }
            }
          }
        }
      } catch (e) {
        // Silent fail
      }
    }));

    headlines = headlines.toSet().toList();
    headlines.sort();
    if (headlines.length > 15) headlines = headlines.sublist(0, 15);

    return headlines;
  }

  // --- GENERIC INTELLIGENCE ---
  Future<Map<String, dynamic>> generateBriefing(TopicConfig topic) async {
    // 1. CHECK CACHE
    if (_cache.containsKey(topic.id)) {
      final entry = _cache[topic.id]!;
      if (entry.isValid) {
        print("AIService: Returning CACHED Briefing for ${topic.id}");
        return entry.data;
      } else {
        _cache.remove(topic.id); // Expired
      }
    }

    if (apiKey.contains("YOUR_")) return _getFallbackData(topic);

    try {
      print("AIService: Generating LIVE Intelligence for ${topic.id}...");

      final marketFact = await topic.fetchMarketPulse();

      final news = await fetchHeadlines(topic.sources, topic.keywords);
      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

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

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        temperature: 0.0,
        seed: 42,
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

      // Inject Real History
      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
        }
      }

      // 2. SAVE TO CACHE
      _cache[topic.id] = _CacheEntry(jsonResponse, DateTime.now());

      return jsonResponse;

    } catch (e) {
      print("AI Error: $e");
      return _getFallbackData(topic);
    }
  }

  Map<String, dynamic> _getFallbackData(TopicConfig topic) {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": topic.name,
          "title": "Simulated Alert: ${topic.name} Volatility",
          "summary": "This is fallback data because the AI service is unreachable.",
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
}*/

/*
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../secrets.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
      OpenAI.requestsTimeOut = const Duration(seconds: 60);
    }
  }

  // --- GENERIC SCRAPER ---
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    await Future.wait(sources.map((source) async {
      try {
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
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

              if (keywords.any((k) => t.contains(k.toLowerCase()))) {
                headlines.add("[${source.name}] $title");
              }
            }
          }
        }
      } catch (e) {
        // Silent fail
        print("Scraper Error (${source.name}): $e");
      }
    }));

    headlines = headlines.toSet().toList();
    headlines.sort();
    if (headlines.length > 15) headlines = headlines.sublist(0, 15);

    return headlines;
  }

  // --- GENERIC INTELLIGENCE GENERATOR ---
  Future<void> generateBriefing(TopicConfig topic) async {
    // FIX: Removed the check for StorageService.getBriefing()
    // The UI now handles checking history. If we are here, we are forcing a new generation.

    if (apiKey.contains("YOUR_")) {
      final fallback = _getFallbackData(topic);
      await StorageService.saveBriefing(topic.id, fallback);
      return;
    }

    try {
      print("AIService: Generating LIVE Intelligence for ${topic.id}...");

      final marketFact = await topic.fetchMarketPulse();

      final news = await fetchHeadlines(topic.sources, topic.keywords);
      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

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

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        temperature: 0.0,
        seed: 42,
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

      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
        }
      }

      // SAVE TO STORAGE (Appends to History)
      await StorageService.saveBriefing(topic.id, jsonResponse);

    } catch (e) {
      print("AI Generation Error: $e");
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
          "summary": "This is fallback data because the AI service is unreachable.",
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
}*/
/*
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../../secrets.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
      OpenAI.requestsTimeOut = const Duration(seconds: 60);
    }
  }

  // --- GENERIC SCRAPER ---
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    await Future.wait(sources.map((source) async {
      try {
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
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

              if (keywords.any((k) => t.contains(k.toLowerCase()))) {
                headlines.add("[${source.name}] $title");
              }
            }
          }
        }
      } catch (e) {
        print("Scraper Error (${source.name}): $e");
      }
    }));

    headlines = headlines.toSet().toList();
    headlines.sort();
    if (headlines.length > 15) headlines = headlines.sublist(0, 15);

    return headlines;
  }

  // --- GENERIC INTELLIGENCE GENERATOR ---
  Future<void> generateBriefing(TopicConfig topic) async {
    if (apiKey.contains("YOUR_")) {
      final fallback = _getFallbackData(topic);
      await StorageService.saveBriefing(topic.id, fallback);
      return;
    }

    try {
      print("AIService: Generating LIVE Intelligence for ${topic.id}...");

      final marketFact = await topic.fetchMarketPulse();

      final news = await fetchHeadlines(topic.sources, topic.keywords);
      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      STEP 2: DETECT DIVERGENCE & TRENDS
      - Compare Data (Status/Trend) against News Sentiment.
      - Look for: RISKS (Panic, Crisis) AND EMERGING TRENDS (Opportunities, Shifts).
      - If a positive trend is found, mark Divergence Tag as "Opportunity" or "Growth".

      STEP 3: OUTPUT JSON
      Return a JSON object with a "briefs" array. Each brief must have:
      - id, subsector (e.g. "${topic.name}"), title, summary
      - severity (High/Medium/Low) -> Use "Low" for positive trends unless impact is massive.
      - fact_score (0-100), sent_score (0-100)
      - divergence_tag, divergence_desc
      - metrics (commodity, price, trend)
      - chart_data (placeholder array)
      - headlines (list of strings used)
      - is_fallback (false)
      ''';

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        temperature: 0.0,
        seed: 42,
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

      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } catch (e) {
      print("AI Generation Error: $e");
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
          "summary": "This is fallback data because the AI service is unreachable.",
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
}*/
/*
import 'dart:convert';
import 'dart:async';
import 'package:dart_openai/dart_openai.dart';
import '../../secrets.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart'; // NEW IMPORT

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final FeedService _feedService = FeedService(); // INJECT SERVICE

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
      OpenAI.requestsTimeOut = const Duration(seconds: 60);
    }
  }

  // --- GENERIC INTELLIGENCE GENERATOR ---
  Future<void> generateBriefing(TopicConfig topic) async {
    if (apiKey.contains("YOUR_")) {
      final fallback = _getFallbackData(topic);
      await StorageService.saveBriefing(topic.id, fallback);
      return;
    }

    try {
      print("AIService: Generating LIVE Intelligence for ${topic.id}...");

      // 1. Fetch Data Parallel (Market + News)
      final results = await Future.wait([
        topic.fetchMarketPulse(),
        _feedService.fetchHeadlines(topic.sources, topic.keywords)
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;

      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      // 2. Build Prompt
      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      STEP 2: DETECT DIVERGENCE & TRENDS
      - Compare Data (Status/Trend) against News Sentiment.
      - Look for: RISKS (Panic, Crisis) AND EMERGING TRENDS (Opportunities, Shifts).
      - If a positive trend is found, mark Divergence Tag as "Opportunity" or "Growth".

      STEP 3: OUTPUT JSON
      Return a JSON object with a "briefs" array. Each brief must have:
      - id, subsector (e.g. "${topic.name}"), title, summary
      - severity (High/Medium/Low) -> Use "Low" for positive trends unless impact is massive.
      - fact_score (0-100), sent_score (0-100)
      - divergence_tag, divergence_desc
      - metrics (commodity, price, trend)
      - chart_data (placeholder array)
      - headlines (list of strings used)
      - is_fallback (false)
      ''';

      // 3. Call AI
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        temperature: 0.0,
        seed: 42,
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
            role: OpenAIChatMessageRole.system,
          ),
        ],
      ).timeout(const Duration(seconds: 60));

      // 4. Parse & Save
      final content = chatCompletion.choices.first.message.content?.first.text;
      Map<String, dynamic> jsonResponse = json.decode(content ?? "{}");

      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } catch (e) {
      print("AI Generation Error: $e");
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
          "summary": "This is fallback data because the AI service is unreachable.",
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
}*/
/*

import 'dart:convert';
import 'dart:async';
import 'package:dart_openai/dart_openai.dart';
import '../../secrets.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final FeedService _feedService = FeedService();
  final LocalFeedService _localFeedService = LocalFeedService();

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
      OpenAI.requestsTimeOut = const Duration(seconds: 60);
    }
  }

  // --- GENERIC INTELLIGENCE GENERATOR ---
  Future<void> generateBriefing(TopicConfig topic, {String? manualFeedPath}) async {
    // 1. FORCE FALLBACK if API Key is missing (simulated environment)
    if (apiKey.contains("YOUR_") && manualFeedPath == null) {
      print("AIService: No API Key, defaulting to standard fallback.");
      manualFeedPath = 'assets/feeds/fallback_news.xml';
    }

    try {
      print("AIService: Generating Intelligence for ${topic.id}...");

      // Determine News Source
      Future<List<String>> newsFuture;
      if (manualFeedPath != null) {
        print("AIService: Reading from Local File -> $manualFeedPath");
        newsFuture = _localFeedService.getHeadlinesFromPath(manualFeedPath, topic.keywords);
      } else {
        print("AIService: Polling Live RSS Feeds...");
        newsFuture = _feedService.fetchHeadlines(topic.sources, topic.keywords);
      }

      final results = await Future.wait([
        topic.fetchMarketPulse(),
        newsFuture
      ]);

      final MarketFact marketFact = results[0] as MarketFact;
      final List<String> news = results[1] as List<String>;

      if (news.isEmpty) news.add("No recent news found for ${topic.name}.");

      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
      STEP 2: DETECT DIVERGENCE & TRENDS
      - Compare Data (Status/Trend) against News Sentiment.
      - Look for: RISKS (Panic, Crisis) AND EMERGING TRENDS (Opportunities, Shifts).
      - If a positive trend is found, mark Divergence Tag as "Opportunity" or "Growth".

      STEP 3: OUTPUT JSON
      Return a JSON object with a "briefs" array. Each brief must have:
      - id, subsector (e.g. "${topic.name}"), title, summary
      - severity (High/Medium/Low) -> Use "Low" for positive trends unless impact is massive.
      - fact_score (0-100), sent_score (0-100)
      - divergence_tag, divergence_desc
      - metrics (commodity, price, trend)
      - chart_data (placeholder array)
      - headlines (list of strings used)
      - is_fallback (false)
      ''';

      // If we are offline/simulating (no API Key), return dummy data wrapped in the structure
      if (apiKey.contains("YOUR_")) {
        await StorageService.saveBriefing(topic.id, _getDummyResponse(topic, news));
        return;
      }

      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        temperature: 0.0,
        seed: 42,
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

      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } catch (e) {
      print("AI Generation Error: $e");
      // On error, save a clear error state
      final errorData = _getDummyResponse(topic, ["System Error: $e"]);
      await StorageService.saveBriefing(topic.id, errorData);
    }
  }

  // Helper for when OpenAI is unreachable/disabled
  Map<String, dynamic> _getDummyResponse(TopicConfig topic, List<String> headlines) {
    return {
      "briefs": [
        {
          "id": "1",
          "subsector": topic.name,
          "title": "Simulated Report: ${topic.name}",
          "summary": "This report was generated using fallback data because the AI service is disabled or unreachable.",
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
import 'package:dart_openai/dart_openai.dart'; // Keeping for type safety if needed, but logic moved
import '../../secrets.dart';
import 'gemini_provider.dart';
import 'topic_config.dart';
import 'models.dart';
import 'storage_service.dart';
import 'feed_service.dart';
import 'local_feed_service.dart';

// NEW IMPORTS
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'ollama_provider.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final FeedService _feedService = FeedService();
  final LocalFeedService _localFeedService = LocalFeedService();

  // --- PROVIDER MANAGEMENT ---
  AIProvider _activeProvider = OpenAIProvider(); // Default

  // Method to switch providers dynamically
  */
/*void setProvider(String providerType) {
    if (providerType == 'ollama') {
      _activeProvider = OllamaProvider();
    } else {
      _activeProvider = OpenAIProvider();
    }
    print("AIService: Switched to ${_activeProvider.name}");
  }*/
/*

  void setProvider(String providerType) {
    if (providerType == 'ollama') {
      _activeProvider = OllamaProvider();
    } else if (providerType == 'gemini') {
      _activeProvider = GeminiProvider(); // <--- NEW CASE
    } else {
      _activeProvider = OpenAIProvider();
    }
    print("AIService: Switched to ${_activeProvider.name}");
  }

  String get currentProviderName => _activeProvider.name;

  // --- GENERATION LOGIC ---
  Future<void> generateBriefing(TopicConfig topic, {String? manualFeedPath}) async {
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
      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
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
      // We pass the prompt. The provider handles the specific API call.
      Map<String, dynamic> jsonResponse = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: "", // Can be used for "Chat" style history later
      );

      // 4. POST-PROCESSING
      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
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
import 'dart:convert';
import 'dart:async';
import 'package:dart_openai/dart_openai.dart';
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

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final FeedService _feedService = FeedService();
  final LocalFeedService _localFeedService = LocalFeedService();

  // --- PROVIDER MANAGEMENT ---
  AIProvider _activeProvider = OpenAIProvider(); // Default

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
      OpenAI.requestsTimeOut = const Duration(seconds: 60);
    }
  }

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
  Future<void> generateBriefing(TopicConfig topic, {String? manualFeedPath}) async {
    // 0. CONFIGURATION CHECK (Fail Fast)
    // If the topic has no sources (e.g. Stub/Placeholder) and no manual override is provided,
    // we fail immediately to prevent "hallucinated" analysis on empty data.
    if (topic.sources.isEmpty && manualFeedPath == null) {
      throw Exception("Analysis Failed: '${topic.name}' is not fully configured (No News Sources defined).");
    }

    // 1. FALLBACK for Missing API Key (Simulated Environment)
    if (_activeProvider is OpenAIProvider && apiKey.contains("YOUR_")) {
      print("AIService: No API Key, defaulting to standard fallback.");
      manualFeedPath = 'assets/feeds/fallback_news.xml';
    }

    try {
      print("AIService: Generating via ${_activeProvider.name} for ${topic.id}...");

      // 2. DATA INGESTION
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

      // 3. PROMPT CONSTRUCTION
      final systemPrompt = '''
      You are an Intelligence Analyst for the ${topic.name} sector.
      
      STEP 1: ANALYZE FACTS vs. SENTIMENT
      [MARKET DATA]
      ${marketFact.toString()}
      
      [NEWS STREAM]
      ${news.join('\n')}

      [ANALYSIS RULES]
      ${topic.riskRules}
      
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

      // 4. DELEGATE TO PROVIDER
      Map<String, dynamic> jsonResponse = await _activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: "",
      );

      // 5. POST-PROCESSING
      if (jsonResponse['briefs'] != null) {
        for (var brief in jsonResponse['briefs']) {
          if (marketFact.lineData.isNotEmpty) {
            brief['chart_data'] = marketFact.lineData;
          }
        }
      }

      await StorageService.saveBriefing(topic.id, jsonResponse);

    } catch (e) {
      print("AI Generation Error: $e");
      // On runtime error, save a "System Error" card to history
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