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
/*  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
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
  }*/
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    await Future.wait(sources.map((source) async {
      try {
        // 1. Try AllOrigins (Best for Text)
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        // 2. Fallback to CorsProxy (Best for Binary/Strict)
        if (response.statusCode != 200) {
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
          response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));
        }

        if (response.statusCode == 200) {
          final body = response.body;

          // STRATEGY A: Strict XML Parsing (Preferred)
          try {
            final document = XmlDocument.parse(body);
            final items = document.findAllElements('item').followedBy(document.findAllElements('entry'));

            for (var item in items) {
              final titleNode = item.findElements('title').firstOrNull;
              if (titleNode != null) {
                _addIfKeywordMatch(headlines, source.name, titleNode.innerText, keywords);
              }
            }
          } catch (e) {
            // STRATEGY B: "Dirty" Regex Fallback
            // If XML parsing fails (due to bad format or HTML response), scan for title tags manually.
            print("⚠️ XML Parse failed for ${source.name}, trying Regex fallback...");

            // Regex to find <title>...</title> content
            final titleRegex = RegExp(r'<title>(.*?)</title>', caseSensitive: false, dotAll: true);
            final matches = titleRegex.allMatches(body);

            for (var match in matches) {
              final rawTitle = match.group(1) ?? "";
              // Clean up CDATA and HTML tags
              final cleanTitle = rawTitle
                  .replaceAll('<![CDATA[', '')
                  .replaceAll(']]>', '')
                  .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
                  .trim();

              // Filter out generic titles like "Home" or the Site Name
              if (cleanTitle.length > 10 && !cleanTitle.toLowerCase().contains(source.name.toLowerCase())) {
                _addIfKeywordMatch(headlines, source.name, cleanTitle, keywords);
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

  // Helper to keep code clean
  void _addIfKeywordMatch(List<String> list, String sourceName, String title, List<String> keywords) {
    final t = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (keywords.any((k) => t.toLowerCase().contains(k.toLowerCase()))) {
      list.add("[$sourceName] $t");
    }
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
}