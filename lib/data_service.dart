/*

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'dart:convert';

class Metric {
  final String commodity;
  final String price;
  final String trend;

  Metric({required this.commodity, required this.price, required this.trend});

  factory Metric.fromJson(Map<String, dynamic> json) {
    return Metric(
      commodity: (json['commodity'] ?? 'Unknown').toString(),
      price: (json['price'] ?? '0.00').toString(),
      trend: (json['trend'] ?? 'Flat').toString(),
    );
  }
}

class ProcessStep {
  final String step;
  final String desc;

  ProcessStep({required this.step, required this.desc});

  factory ProcessStep.fromJson(Map<String, dynamic> json) {
    return ProcessStep(
      step: (json['step'] ?? 'Step').toString(),
      desc: (json['desc'] ?? '').toString(),
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
      name: (json['name'] ?? 'Unknown Source').toString(),
      type: (json['type'] ?? 'General').toString(),
      reliability: (json['reliability'] ?? 'Medium').toString(),
      uri: (json['uri'] ?? '').toString(),
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
      text: (json['text'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      polarity: (json['polarity'] ?? 'Neutral').toString(),
    );
  }
}

class SentimentMeta {
  final int sourceCount;
  final int errorMargin;
  final String confidence;

  SentimentMeta({required this.sourceCount, required this.errorMargin, required this.confidence});

  factory SentimentMeta.fromJson(Map<String, dynamic> json) {
    return SentimentMeta(
      sourceCount: (json['sourceCount'] as num?)?.toInt() ?? 0,
      errorMargin: (json['errorMargin'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] ?? 'Low').toString(),
    );
  }
}

class Divergence {
  final String type;
  final int level;
  final String description;
  final int factScore;
  final int sentScore;

  Divergence({
    required this.type,
    required this.level,
    required this.description,
    required this.factScore,
    required this.sentScore,
  });

  factory Divergence.fromJson(Map<String, dynamic> json) {
    return Divergence(
      type: (json['type'] ?? 'Stable').toString(),
      level: (json['level'] as num?)?.toInt() ?? 0,
      description: (json['description'] ?? '').toString(),
      factScore: (json['factScore'] as num?)?.toInt() ?? 50,
      sentScore: (json['sentScore'] as num?)?.toInt() ?? 50,
    );
  }
}

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
  final Metric metrics;
  final List<String> headlines;
  final List<double> chartData;

  // AI Logic Fields
  final List<ProcessStep> processSteps;
  final List<Source> sources;
  final String harness;
  final List<SentimentHeadline> sentimentHeadlines;
  final SentimentMeta? sentimentMeta;
  final Divergence? divergence;
  final List<String> signals;

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
    required this.headlines,
    required this.chartData,
    required this.processSteps,
    required this.sources,
    required this.harness,
    required this.sentimentHeadlines,
    this.sentimentMeta,
    this.divergence,
    required this.signals,
  });

  factory Briefing.fromJson(Map<String, dynamic> json) {
    return Briefing(
      id: (json['id'] ?? '0').toString(),
      subsector: (json['subsector'] ?? 'General').toString(),
      title: (json['title'] ?? 'No Title').toString(),
      summary: (json['summary'] ?? 'No Summary').toString(),
      severity: (json['severity'] ?? 'Low').toString(),

      // Safe Number Parsing
      factScore: (json['fact_score'] as num?)?.toInt() ?? 50,
      sentScore: (json['sent_score'] as num?)?.toInt() ?? 50,

      divergenceTag: (json['divergence_tag'] ?? 'Stable').toString(),
      divergenceDesc: (json['divergence_desc'] ?? '').toString(),

      metrics: Metric.fromJson(json['metrics'] ?? {}),

      headlines: (json['headlines'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],

      chartData: (json['chart_data'] as List<dynamic>?)
          ?.where((e) => e != null && e is num)
          .map((e) => (e as num).toDouble())
          .toList() ?? [],

      processSteps: (json['process_steps'] as List<dynamic>?)
          ?.map((e) => ProcessStep.fromJson(e))
          .toList() ?? [],

      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => Source.fromJson(e))
          .toList() ?? [],

      harness: (json['harness'] ?? 'Standard Industrial Analyst Prompt v4.1').toString(),

      sentimentHeadlines: (json['sentiment_headlines'] as List<dynamic>?)
          ?.map((e) => SentimentHeadline.fromJson(e))
          .toList() ?? [],

      sentimentMeta: json['sentimentMeta'] != null
          ? SentimentMeta.fromJson(json['sentimentMeta'])
          : null,

      divergence: json['divergence'] != null
          ? Divergence.fromJson(json['divergence'])
          : null,

      signals: (json['signals'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}*/

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class MarketFact {
  final String category;
  final String name;
  final String value;
  final String trend;
  final String status;

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
  });

  @override
  String toString() => '$category - $name: $value ($trend). Status: $status';
}

class MarketDataService {
  static const Duration _apiTimeout = Duration(seconds: 4);
  final http.Client _client = http.Client();

  // --- GENERIC FETCH HELPER ---
  Future<MarketFact> _fetchData({
    required String uri,
    required MarketFact Function(Map<String, dynamic> data) parser,
    required MarketFact fallback,
  }) async {
    try {
      final response = await _client.get(Uri.parse(uri)).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return parser(data);
      } else {
        print("API Error [${response.statusCode}] for $uri");
      }
    } catch (e) {
      print("Exception fetching $uri: $e");
    }
    return fallback;
  }

  // --- IMPLEMENTATIONS ---

  Future<MarketFact> fetchWheatPrice() async {
    if (Secrets.alphaVantageKey.contains("YOUR")) return _getMockWheat();

    return _fetchData(
      uri: 'https://www.alphavantage.co/query?function=WHEAT&interval=monthly&apikey=${Secrets.alphaVantageKey}',
      fallback: _getMockWheat(),
      parser: (data) {
        if (data['data'] == null || (data['data'] as List).isEmpty) return _getMockWheat();

        final latest = data['data'][0];
        final prev = data['data'][1];

        // Convert $/Metric Ton to $/Bushel (~36.74 bu/ton)
        final price = double.parse(latest['value']) / 36.74;
        final prevPrice = double.parse(prev['value']) / 36.74;
        final change = ((price - prevPrice) / prevPrice) * 100;

        return MarketFact(
          category: "Agriculture",
          name: "Wheat Futures",
          value: "\$${price.toStringAsFixed(2)}/bu",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% MoM",
          status: change > 5 ? "Spiking" : change < -5 ? "Crashing" : "Stable",
        );
      },
    );
  }

  Future<MarketFact> fetchInterestRate() async {
    return _fetchData(
      uri: 'https://www.bankofcanada.ca/valet/observations/V122544/json?recent=2',
      fallback: _getMockRates(),
      parser: (data) {
        final observations = data['observations'];
        if (observations == null || observations.length < 2) return _getMockRates();

        final latest = double.parse(observations[1]['V122544']['v']);
        final prev = double.parse(observations[0]['V122544']['v']);
        final change = ((latest - prev) / prev) * 100;

        return MarketFact(
          category: "Macro",
          name: "10Y Can Bond",
          value: "$latest%",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
          status: latest > 3.5 ? "Restrictive" : "Neutral",
        );
      },
    );
  }

  Future<MarketFact> fetchCadExchangeRate() async {
    return _fetchData(
      uri: 'https://www.bankofcanada.ca/valet/observations/FXUSDCAD/json?recent=2',
      fallback: MarketFact(category: "Forex", name: "USD/CAD", value: "1.3500", trend: "0.0%", status: "Offline"),
      parser: (data) {
        final observations = data['observations'];
        if (observations == null || observations.length < 2) throw Exception("Insufficient data");

        final latest = double.parse(observations[1]['FXUSDCAD']['v']);
        final prev = double.parse(observations[0]['FXUSDCAD']['v']);
        final change = ((latest - prev) / prev) * 100;

        return MarketFact(
          category: "Forex",
          name: "USD/CAD",
          value: "\$${latest.toStringAsFixed(4)}",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
          status: "Live",
        );
      },
    );
  }

  Future<String> getLiveFactsString() async {
    // Uses Future.wait to fetch all in parallel, but catches individual failures via _fetchData
    final results = await Future.wait([
      fetchWheatPrice(),
      fetchInterestRate(),
      fetchCadExchangeRate(),
    ]);
    return results.map((f) => f.toString()).join('\n');
  }

  // --- MOCKS ---
  MarketFact _getMockWheat() => MarketFact(
      category: "Agriculture", name: "Wheat (Sim)", value: "\$5.80/bu", trend: "-2.1% MoM", status: "Abundant");

  MarketFact _getMockRates() => MarketFact(
      category: "Macro", name: "10Y Bond (Sim)", value: "3.25%", trend: "+0.02%", status: "Neutral");
}