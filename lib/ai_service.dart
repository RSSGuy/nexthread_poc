/*


import 'dart:convert';
import 'dart:async'; // Required for TimeoutException
import 'dart:io';    // Required for SocketException
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';
import 'news_sources.dart';
import 'market_data_service.dart';


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

*//*

*/
/*    try {
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
    }*//*

*/
/*

    // ... existing imports ...
// inside generateIntelligence method, replace the try/catch block with:

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
        // DEFENSIVE PARSING: Remove markdown code blocks if present
        String cleanContent = content;
        if (cleanContent.startsWith('```json')) {
          cleanContent = cleanContent.replaceAll('```json', '').replaceAll('```', '');
        } else if (cleanContent.startsWith('```')) {
          cleanContent = cleanContent.replaceAll('```', '');
        }

        return json.decode(cleanContent);
      } else {
        throw Exception("Empty response from AI");
      }

    } catch (e) {
      print("❌ AIService Critical Error: $e");
      // Consider logging 'content' here if available for debugging
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
*/
/*


import 'dart:convert';
import 'dart:async'; // Required for TimeoutException
import 'dart:io';    // Required for SocketException
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart'; // Required for RSS parsing
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

  // 1. REAL SCRAPER: Fetches RSS feeds from NewsSources
  Future<List<String>> fetchAgHeadlines() async {
    print("Agent A: Initiating REAL scrape of ${NewsSources.targetSources.length} target feeds...");

    List<String> headlines = [];

    // Attempt to fetch all sources in parallel
    await Future.wait(NewsSources.targetSources.map((source) async {
      try {
        final originalUrl = source['url']!;

        // Primary Proxy: AllOrigins
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(originalUrl)}";

        // INCREASED TIMEOUT to 10 seconds to account for Proxy latency
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        // Backup Proxy: If primary fails or returns empty, try corsproxy.io
        if (response.statusCode != 200) {
          print("Agent A: Primary proxy failed for ${source['name']}, trying backup...");
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}";
          response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));
        }

        if (response.statusCode == 200) {
          final document = XmlDocument.parse(response.body);

          // Support both RSS 2.0 (<item>) and Atom (<entry>)
          final items = document.findAllElements('item')
              .followedBy(document.findAllElements('entry'));

          // Extract top 2 headlines per source to manage token usage/relevance
          int count = 0;
          for (var item in items) {
            if (count >= 2) break;

            final titleNode = item.findElements('title').firstOrNull;
            if (titleNode != null) {
              // Clean up whitespace
              final title = titleNode.innerText.replaceAll(RegExp(r'\s+'), ' ').trim();
              if (title.isNotEmpty) {
                headlines.add("[${source['name']}] $title");
                count++;
              }
            }
          }
          print("Agent A: Scraped $count items from ${source['name']}");
        }
      } catch (e) {
        // This is common for CORS errors or Timeouts
        print("Agent A: Failed to scrape ${source['name']} - $e");
      }
    }));

    // Fallback if no real data could be fetched
    if (headlines.isEmpty) {
      print("Agent A: No headlines scraped (Network/CORS). Using cached fallback.");
      return [
        "[AgWeb - CACHED] Kansas winter wheat ratings drop to historic lows due to persistent drought",
        "[Reuters - CACHED] Brazil soy harvest accelerates, putting pressure on US export premiums",
        "[Food Business News - CACHED] Fertilizer prices stabilizing as natural gas costs retreat",
      ];
    }

    // Shuffle the results so we don't just see one source at the top
    headlines.shuffle();
    return headlines;
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
          "sentiment_headlines": [
            { "text": "Egg prices triple as Avian Flu spreads", "source": "Poultry World", "polarity": "Negative" },
            { "text": "Broiler stocks actually up 4%", "source": "USDA Report", "polarity": "Positive" }
          ]
        },
        {
          "id": "3112",
          "subsector": "311 Food Mfg",
          "title": "Wheat: Phantom Scarcity Alert",
          "summary": "While headlines scream 'Drought', global stockpiles are actually 4% above the 5-year average due to record Russian output. The panic premium is unjustified.",
          "severity": "Medium",
          "fact_score": 75,
          "sent_score": 30,
          "divergence_tag": "Unjustified Panic",
          "divergence_desc": "Market is pricing in a shortage that data does not support.",
          "metrics": {"commodity": "Wheat Futures", "price": "\$5.80/bu", "trend": "-2.1% MoM"},
          "headlines": ["Kansas drought concerns"],
          "chart_data": [6.10, 6.05, 5.95, 5.90, 5.85, 5.82, 5.80],
          "process_steps": [
            {"step": "Inventory Check", "desc": "Cross-referenced US drought maps with Global carryover stocks."},
          ],
          "sources": [
            {"name": "WASDE Report", "type": "Gov", "reliability": "High"}
          ],
          "harness": "SYSTEM PROMPT: Detect gap between local weather news and global stock levels.",
          "signals": ["Sovereign food security mandates"],
          "sentiment_headlines": []
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
  });

  factory Briefing.fromJson(Map<String, dynamic> json) {
    return Briefing(
      // FIXED: Strictly cast to String to handle numeric IDs from JSON
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
      // FIXED: Safely convert numbers to Strings
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
      // FIXED: Safely convert number steps (e.g., 1, 2) to Strings
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
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'secrets.dart';
import 'news_sources.dart';
import 'market_data_service.dart';

class AIService {
  final String apiKey = Secrets.openAiApiKey;
  final MarketDataService _dataService = MarketDataService();

  AIService() {
    print("--- AIService: Initializing ---");
    if (!apiKey.contains("YOUR_")) {
      OpenAI.apiKey = apiKey;
    }
  }

  // 1. FILTERED SCRAPER: Only returns Wheat headlines
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
              if (title.toLowerCase().contains('wheat')) {
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
      print("Agent A: No wheat news found. Using cached wheat fallback.");
      return [
        "[AgWeb - CACHED] Kansas winter wheat ratings drop to historic lows",
        "[Reuters - CACHED] Global wheat stocks tighten as harvest delays hit",
      ];
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

    final systemPrompt = '''
    You are a Wheat Futures Analyst.
    
    STEP 1: ANALYZE FACTS vs. SENTIMENT
    [WHEAT MARKET DATA]
    $facts
    
    [WHEAT NEWS STREAM]
    ${news.join('\n')}
    
    STEP 2: DETECT DIVERGENCE
    - Compare the Official Wheat Status against the News Sentiment.
    - If Status="Stable" but News="Panic", tag as "Unjustified Panic".
    - If Status="Spiking" and News="Panic", tag as "Confirmed Crisis".

    STEP 3: OUTPUT JSON
    Return a JSON object with a "briefs" array. Each brief must have:
    - id, subsector (use "Wheat"), title, summary
    - severity (High/Medium/Low)
    - fact_score (0-100), sent_score (0-100)
    - divergence_tag, divergence_desc
    - metrics (commodity, price, trend)
    - chart_data (array of 7 doubles)
    - headlines (array of strings used for this specific insight)
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
          "harness": "Prompt: Analyze wheat drought impact."
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

  // ADDED: The missing field
  final List<String> headlines;

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
    required this.headlines, // ADDED
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

      // ADDED: Parsing logic
      headlines: List<String>.from(json['headlines'] ?? []),
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
}