

/*
import 'package:flutter/material.dart';

// --- NAICS INDUSTRY TAGS ---
enum Naics {
  agriculture("Agriculture, forestry, fishing and hunting"),
  mining("Mining, quarrying, and oil and gas extraction"),
  utilities("Utilities"),
  construction("Construction"),
  manufacturing("Manufacturing"),
  wholesaleTrade("Wholesale trade"),
  retailTrade("Retail trade"),
  transportation("Transportation and warehousing"),
  information("Information and cultural industries"),
  finance("Finance and insurance"),
  realEstate("Real estate and rental and leasing"),
  professionalServices("Professional, scientific and technical services"),
  management("Management of companies and enterprises"),
  adminSupport("Administrative and support, waste management and remediation services"),
  education("Educational services"),
  healthCare("Health care and social assistance"),
  arts("Arts, entertainment and recreation"),
  accommodation("Accommodation and food services"),
  otherServices("Other services (except public administration"),
  publicAdmin("Public administration");

  final String label;
  const Naics(this.label);
}

// --- CONFIG MODELS ---

class NewsSourceConfig {
  final String name;
  final String url;
  final String type;
  final List<Naics> tags;

  const NewsSourceConfig({
    required this.name,
    required this.url,
    required this.type,
    this.tags = const [],
  });
}

// --- DATA MODELS ---

class MarketFact {
  final String category;
  final String name;
  final String value;
  final String trend;
  final String status;
  final List<double> lineData;

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
    this.lineData = const [],
  });

  bool get isPending => status == 'Pending Update';

  @override
  String toString() => '$category - $name: $value ($trend). Status: $status';
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
  final Metrics metrics;
  final List<double> chartData;
  final List<String> headlines;
  final bool isFallback;
  final DateTime generatedAt;

  Briefing({
    required this.id, required this.subsector, required this.title, required this.summary,
    required this.severity, required this.factScore, required this.sentScore,
    required this.divergenceTag, required this.divergenceDesc, required this.metrics,
    required this.chartData, required this.headlines, required this.isFallback,
    required this.generatedAt,
  });

  factory Briefing.fromJson(Map<String, dynamic> json, DateTime timestamp) {
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
      chartData: (json['chart_data'] as List<dynamic>? ?? [])
          .where((x) => x != null && x is num).map((x) => (x as num).toDouble()).toList(),
      headlines: List<String>.from(json['headlines'] ?? []),
      isFallback: json['is_fallback'] ?? false,
      generatedAt: timestamp,
    );
  }
}

// --- COMMENT MODEL (UPDATED) ---
class Comment {
  final String text;
  final DateTime createdAt;
  final bool isAi; // NEW: Distinguishes User vs Bot

  Comment({
    required this.text,
    required this.createdAt,
    this.isAi = false
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'isAi': isAi,
  };

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      isAi: json['isAi'] ?? false,
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
}*/


import 'package:flutter/material.dart';

// --- NAICS INDUSTRY TAGS ---
enum Naics {
  agriculture("Agriculture, forestry, fishing and hunting"),
  mining("Mining, quarrying, and oil and gas extraction"),
  utilities("Utilities"),
  construction("Construction"),
  manufacturing("Manufacturing"),
  wholesaleTrade("Wholesale trade"),
  retailTrade("Retail trade"),
  transportation("Transportation and warehousing"),
  information("Information and cultural industries"),
  finance("Finance and insurance"),
  realEstate("Real estate and rental and leasing"),
  professionalServices("Professional, scientific and technical services"),
  management("Management of companies and enterprises"),
  adminSupport("Administrative and support, waste management and remediation services"),
  education("Educational services"),
  healthCare("Health care and social assistance"),
  arts("Arts, entertainment and recreation"),
  accommodation("Accommodation and food services"),
  otherServices("Other services (except public administration"),
  publicAdmin("Public administration");

  final String label;
  const Naics(this.label);
}

// --- CONFIG MODELS ---

class NewsSourceConfig {
  final String name;
  final String url;
  final String type;
  final List<Naics> tags;

  const NewsSourceConfig({
    required this.name,
    required this.url,
    required this.type,
    this.tags = const [],
  });
}

// --- DATA MODELS ---

class MarketFact {
  final String category;
  final String name;
  final String value;
  final String trend;
  final String status;
  final List<double> lineData;
  final List<MarketFact> subFacts;

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
    this.lineData = const [],
    this.subFacts = const [],
  });

  bool get isPending => status == 'Pending Update';

  @override
  String toString() => '$category - $name: $value ($trend). Status: $status';
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
  final Metrics metrics;
  final List<double> chartData;
  final List<String> headlines;
  final bool isFallback;
  final DateTime generatedAt;

  Briefing({
    required this.id, required this.subsector, required this.title, required this.summary,
    required this.severity, required this.factScore, required this.sentScore,
    required this.divergenceTag, required this.divergenceDesc, required this.metrics,
    required this.chartData, required this.headlines, required this.isFallback,
    required this.generatedAt,
  });

  factory Briefing.fromJson(Map<String, dynamic> json, DateTime timestamp) {
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
      chartData: (json['chart_data'] as List<dynamic>? ?? [])
          .where((x) => x != null && x is num).map((x) => (x as num).toDouble()).toList(),
      headlines: List<String>.from(json['headlines'] ?? []),
      isFallback: json['is_fallback'] ?? false,
      generatedAt: timestamp,
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

// --- NEW: COMMENT MODEL ---
class Comment {
  final String text;
  final DateTime createdAt;
  final bool isAi;

  Comment({
    required this.text,
    required this.createdAt,
    this.isAi = false,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'isAi': isAi,
  };

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      isAi: json['isAi'] ?? false,
    );
  }
}