

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
