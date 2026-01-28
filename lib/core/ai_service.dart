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
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart'; // RSS/Atom Parser
import 'models.dart';
import 'topic_config.dart';
import 'storage_service.dart';
import 'news_registry.dart';
import 'local_feed_service.dart'; // <--- NEW: Integrates your JSON file

// Import secrets from the parent directory
import '../secrets.dart';

class AIService {
  // ---------------------------------------------------------
  // CONFIGURATION
  // ---------------------------------------------------------



  // Replace this with your actual key or use a secure environment variable
  static const String _apiKey = Secrets.openAiApiKey;

  static const String _baseUrl = "https://api.openai.com/v1/chat/completions";

  // ---------------------------------------------------------
  // METHOD 1: GENERATE BRIEFING (The Orchestrator)
  // ---------------------------------------------------------
  Future<void> generateBriefing(TopicConfig topic) async {
    print("--- AIService: Generating Report for ${topic.name} ---");

    // 1. Fetch Live News (RSS/Atom)
    final List<String> liveHeadlines = await fetchHeadlines(topic.sources, topic.keywords);

    // 2. Fetch Local JSON Data (Passing keywords for smarter matching)
    final List<String> jsonHeadlines = await LocalFeedService.getRelevantItems(topic.name, topic.keywords);

    // Check if we actually found JSON data (to trigger the UI badge later)
    bool hasJsonData = jsonHeadlines.isNotEmpty;

    // 3. Merge Context (Live + Local)
    final List<String> allHeadlines = [...liveHeadlines, ...jsonHeadlines];

    // 4. Prepare Context for AI
    String newsContext = allHeadlines.isEmpty
        ? "No specific recent news found. Analyze general market conditions based on standard industry risks."
        : allHeadlines.join("\n- ");

    print("AIService: Analyzed ${liveHeadlines.length} live and ${jsonHeadlines.length} local headlines.");

    // 5. Construct Prompt
    final String prompt = """
    You are a strategic supply chain analyst for the ${topic.name} industry.
    
    CONTEXT:
    Recent News/Headlines:
    $newsContext

    RISK PROTOCOLS:
    ${topic.riskRules}

    TASK:
    Generate a JSON intelligence briefing.
    
    JSON FORMAT:
    {
      "summary": "High-level executive summary (max 2 sentences).",
      "score": 0-100 (Risk Score, where 100 is critical risk),
      "briefs": [
        {
          "title": "Impact Event 1",
          "severity": "High" | "Medium" | "Low",
          "impact": "Description of supply chain impact...",
          "recommendation": "Actionable advice..."
        },
        {
           "title": "Impact Event 2",
           "severity": "...",
           "impact": "...",
           "recommendation": "..."
        }
      ]
    }
    
    Return ONLY raw JSON. No markdown formatting.
    """;

    // 6. Call OpenAI API
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o", // Use "gpt-3.5-turbo" if you need to save costs
          "messages": [
            {"role": "system", "content": "You are a JSON-only API. Never output Markdown blocks."},
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.4,
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];

        // Clean markdown artifacts (e.g. ```json ... ```)
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();

        final Map<String, dynamic> jsonResult = jsonDecode(content);

        // --- INJECT SOURCE TAG FOR UI ---
        // If we found local data, mark the object so the UI shows "FROM JSON SOURCE"
        if (hasJsonData) {
          jsonResult['is_json_sourced'] = true;
        }

        // 7. Save Result to Hive
        await StorageService.saveBriefing(topic.id, jsonResult);
        print("AIService: Success. Report saved.");
      } else {
        throw Exception("OpenAI API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("AIService Critical Failure: $e");
      rethrow; // Pass error up to UI
    }
  }

  // ---------------------------------------------------------
  // METHOD 2: FETCH HEADLINES (Robust Scraper)
  // ---------------------------------------------------------
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    await Future.wait(sources.map((source) async {
      try {
        // A. Network Request (with Proxy Fallback)
        String body = "";
        try {
          // Try AllOrigins first (better for text)
          var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
          var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));

          // Fallback to CorsProxy (better for binary/strict XML)
          if (response.statusCode != 200) {
            proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
            response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
          }

          if (response.statusCode == 200) {
            body = response.body;
          } else {
            return; // Skip this source if connection fails
          }
        } catch (e) {
          print("Connection failed for ${source.name}: $e");
          return;
        }

        // B. Parse Logic (RSS -> Atom -> Regex)
        bool parsed = false;

        // Try RSS 2.0
        try {
          final rss = RssFeed.parse(body);
          if (rss.items != null) {
            for (var item in rss.items!) {
              if (item.title != null) _addIfKeywordMatch(headlines, source.name, item.title!, keywords);
            }
            parsed = true;
          }
        } catch (_) {}

        // Try Atom 1.0
        if (!parsed) {
          try {
            final atom = AtomFeed.parse(body);
            if (atom.items != null) {
              for (var item in atom.items!) {
                if (item.title != null) _addIfKeywordMatch(headlines, source.name, item.title!, keywords);
              }
              parsed = true;
            }
          } catch (_) {}
        }

        // Fallback: Dirty Regex (for broken XML or HTML pages)
        if (!parsed) {
          final titleRegex = RegExp(r'<title>(.*?)</title>', caseSensitive: false, dotAll: true);
          final matches = titleRegex.allMatches(body);
          for (var match in matches) {
            final rawTitle = match.group(1) ?? "";
            final cleanTitle = rawTitle
                .replaceAll('<![CDATA[', '')
                .replaceAll(']]>', '')
                .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
                .trim();

            // Ignore generic titles like "Home" or "Login"
            if (cleanTitle.length > 15 && !cleanTitle.toLowerCase().contains(source.name.toLowerCase())) {
              _addIfKeywordMatch(headlines, source.name, cleanTitle, keywords);
            }
          }
        }

      } catch (e) {
        print("Scraper Error (${source.name}): $e");
      }
    }));

    // Deduplicate and Sort
    headlines = headlines.toSet().toList();
    if (headlines.length > 20) headlines = headlines.sublist(0, 20);

    return headlines;
  }

  // ---------------------------------------------------------
  // HELPER METHOD
  // ---------------------------------------------------------
  void _addIfKeywordMatch(List<String> list, String sourceName, String title, List<String> keywords) {
    final t = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (keywords.any((k) => t.toLowerCase().contains(k.toLowerCase()))) {
      list.add("[$sourceName] $t");
    }
  }
}*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'models.dart';
import 'topic_config.dart';
import 'storage_service.dart';
import 'news_registry.dart';
import 'local_feed_service.dart';

// Import the secrets file
import '../secrets.dart';

class AIService {
  // ---------------------------------------------------------
  // CONFIGURATION
  // ---------------------------------------------------------

  // ✅ UPDATED: Accessing the key via the static class property
  static const String _apiKey = Secrets.openAiApiKey;

  static const String _baseUrl = "https://api.openai.com/v1/chat/completions";

  // ---------------------------------------------------------
  // METHOD 1: GENERATE BRIEFING (The Orchestrator)
  // ---------------------------------------------------------
  Future<void> generateBriefing(TopicConfig topic) async {
    print("--- AIService: Generating Report for ${topic.name} ---");

    // 1. Fetch Live News (RSS/Atom)
    final List<String> liveHeadlines = await fetchHeadlines(topic.sources, topic.keywords);

    // 2. Fetch Local JSON Data (Passing keywords for smart matching)
    final List<String> jsonHeadlines = await LocalFeedService.getRelevantItems(topic.name, topic.keywords);

    bool hasJsonData = jsonHeadlines.isNotEmpty;

    // 3. Merge & Cap Context (Token Hygiene)
    final List<String> allHeadlines = [...liveHeadlines, ...jsonHeadlines];

    // Safety Cap: Max 15 items to prevent 429 errors
    final List<String> safeHeadlines = allHeadlines.length > 15
        ? allHeadlines.sublist(0, 15)
        : allHeadlines;

    // 4. Format Context for AI
    String newsContext = safeHeadlines.isEmpty
        ? "No specific recent news found. Analyze general market conditions based on standard industry risks."
        : safeHeadlines.join("\n- ");

    print("AIService: Analyzed ${safeHeadlines.length} items (${liveHeadlines.length} live, ${jsonHeadlines.length} local).");

    // 5. Construct Prompt
    final String prompt = """
    You are a strategic supply chain analyst for the ${topic.name} industry.
    
    CONTEXT:
    Recent News/Headlines:
    $newsContext

    RISK PROTOCOLS:
    ${topic.riskRules}

    TASK:
    Generate a JSON intelligence briefing.
    
    JSON FORMAT:
    {
      "summary": "High-level executive summary (max 2 sentences).",
      "score": 0-100 (Risk Score, where 100 is critical risk),
      "briefs": [
        {
          "title": "Impact Event 1",
          "severity": "High" | "Medium" | "Low",
          "impact": "Description of supply chain impact...",
          "recommendation": "Actionable advice..."
        },
        {
           "title": "Impact Event 2",
           "severity": "...",
           "impact": "...",
           "recommendation": "..."
        }
      ]
    }
    
    Return ONLY raw JSON. No markdown formatting.
    """;

    // 6. Call OpenAI API
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "gpt-4o",
          "messages": [
            {"role": "system", "content": "You are a JSON-only API. Never output Markdown blocks."},
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.4,
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];

        // Clean markdown artifacts
        content = content.replaceAll('```json', '').replaceAll('```', '').trim();

        final Map<String, dynamic> jsonResult = jsonDecode(content);

        // --- INJECT SOURCE TAG ---
        if (hasJsonData) {
          jsonResult['is_json_sourced'] = true;
        }

        // 7. Save Result to Hive
        await StorageService.saveBriefing(topic.id, jsonResult);
        print("AIService: Success. Report saved.");
      } else {
        throw Exception("OpenAI API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("AIService Critical Failure: $e");
      rethrow;
    }
  }

  // ---------------------------------------------------------
  // METHOD 2: FETCH HEADLINES (Robust Scraper)
  // ---------------------------------------------------------
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    await Future.wait(sources.map((source) async {
      try {
        // A. Network Request
        String body = "";
        try {
          var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
          var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));

          if (response.statusCode != 200) {
            proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
            response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
          }

          if (response.statusCode == 200) {
            body = response.body;
          } else {
            return;
          }
        } catch (e) {
          print("Connection failed for ${source.name}: $e");
          return;
        }

        // B. Parse Logic
        bool parsed = false;

        // Try RSS 2.0
        try {
          final rss = RssFeed.parse(body);
          if (rss.items != null) {
            for (var item in rss.items!) {
              if (item.title != null) _addIfKeywordMatch(headlines, source.name, item.title!, keywords);
            }
            parsed = true;
          }
        } catch (_) {}

        // Try Atom 1.0
        if (!parsed) {
          try {
            final atom = AtomFeed.parse(body);
            if (atom.items != null) {
              for (var item in atom.items!) {
                if (item.title != null) _addIfKeywordMatch(headlines, source.name, item.title!, keywords);
              }
              parsed = true;
            }
          } catch (_) {}
        }

        // Fallback: Regex
        if (!parsed) {
          final titleRegex = RegExp(r'<title>(.*?)</title>', caseSensitive: false, dotAll: true);
          final matches = titleRegex.allMatches(body);
          for (var match in matches) {
            final rawTitle = match.group(1) ?? "";
            final cleanTitle = rawTitle
                .replaceAll('<![CDATA[', '')
                .replaceAll(']]>', '')
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .trim();

            if (cleanTitle.length > 15 && !cleanTitle.toLowerCase().contains(source.name.toLowerCase())) {
              _addIfKeywordMatch(headlines, source.name, cleanTitle, keywords);
            }
          }
        }

      } catch (e) {
        print("Scraper Error (${source.name}): $e");
      }
    }));

    headlines = headlines.toSet().toList();
    if (headlines.length > 20) headlines = headlines.sublist(0, 20);

    return headlines;
  }

  void _addIfKeywordMatch(List<String> list, String sourceName, String title, List<String> keywords) {
    final t = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (keywords.any((k) => t.toLowerCase().contains(k.toLowerCase()))) {
      list.add("[$sourceName] $t");
    }
  }
}