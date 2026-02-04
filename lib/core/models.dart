

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
}*/

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
  final String name; // This will now hold the Label (e.g. "Energy Sector")
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

  // UPDATED: Now recursively prints subFacts so the AI Analysis sees the breakdown
  @override
  String toString() {
    String base = '$category - $name: $value ($trend). Status: $status';
    if (subFacts.isNotEmpty) {
      base += "\n  Benchmarks: [${subFacts.map((f) => f.toString()).join(', ')}]";
    }
    return base;
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
}*/

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

  // RESTORED: Supports multi-benchmark sectors (e.g. Energy + Metals)
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

  // Recursive string so AI sees all benchmarks
  @override
  String toString() {
    String base = '$category - $name: $value ($trend). Status: $status';
    if (subFacts.isNotEmpty) {
      base += "\n  Benchmarks: [${subFacts.map((f) => f.toString()).join(', ')}]";
    }
    return base;
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

  // --- HELPER TO PREVENT CRASHES ---
  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) return value.join(', '); // Handle ["Tag"] case
    return value.toString(); // Handle numbers/bools
  }

  factory Briefing.fromJson(Map<String, dynamic> json, DateTime timestamp) {
    return Briefing(
      id: _safeString(json['id']),
      subsector: _safeString(json['subsector']),
      title: _safeString(json['title']),
      summary: _safeString(json['summary']),
      severity: _safeString(json['severity']), // Default handled in usage if empty
      factScore: (json['fact_score'] as num?)?.toInt() ?? 0,
      sentScore: (json['sent_score'] as num?)?.toInt() ?? 0,
      divergenceTag: _safeString(json['divergence_tag']),
      divergenceDesc: _safeString(json['divergence_desc']),
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

  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) return value.join(', ');
    return value.toString();
  }

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      commodity: _safeString(json['commodity']),
      price: _safeString(json['price']),
      trend: _safeString(json['trend']),
    );
  }
}

// --- COMMENT MODEL ---
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
}*/

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
  String toString() {
    String base = '$category - $name: $value ($trend). Status: $status';
    if (subFacts.isNotEmpty) {
      base += "\n  Benchmarks: [${subFacts.map((f) => f.toString()).join(', ')}]";
    }
    return base;
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

  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) return value.join(', ');
    return value.toString();
  }

  factory Briefing.fromJson(Map<String, dynamic> json, DateTime timestamp) {
    return Briefing(
      id: _safeString(json['id']),
      subsector: _safeString(json['subsector']),
      title: _safeString(json['title']),
      summary: _safeString(json['summary']),
      severity: _safeString(json['severity']),
      factScore: (json['fact_score'] as num?)?.toInt() ?? 0,
      sentScore: (json['sent_score'] as num?)?.toInt() ?? 0,
      divergenceTag: _safeString(json['divergence_tag']),
      divergenceDesc: _safeString(json['divergence_desc']),
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

  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) return value.join(', ');
    return value.toString();
  }

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      commodity: _safeString(json['commodity']),
      price: _safeString(json['price']),
      trend: _safeString(json['trend']),
    );
  }
}

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

// --- FEED TESTER MODEL (NEW) ---
class FeedHealthResult {
  final String sourceName;
  final String url;
  final bool isSuccess;
  final int latencyMs;
  final int itemsFound;
  final String statusMessage; // e.g., "Direct (200 OK)" or "Proxy (RSS)"
  final String? error;

  FeedHealthResult({
    required this.sourceName,
    required this.url,
    required this.isSuccess,
    required this.latencyMs,
    required this.itemsFound,
    required this.statusMessage,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'sourceName': sourceName,
    'url': url,
    'isSuccess': isSuccess,
    'latencyMs': latencyMs,
    'itemsFound': itemsFound,
    'statusMessage': statusMessage,
    'error': error,
  };

  factory FeedHealthResult.fromJson(Map<String, dynamic> json) {
    return FeedHealthResult(
      sourceName: json['sourceName'] ?? 'Unknown',
      url: json['url'] ?? '',
      isSuccess: json['isSuccess'] ?? false,
      latencyMs: json['latencyMs'] ?? 0,
      itemsFound: json['itemsFound'] ?? 0,
      statusMessage: json['statusMessage'] ?? 'Unknown',
      error: json['error'],
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
  String toString() {
    String base = '$category - $name: $value ($trend). Status: $status';
    if (subFacts.isNotEmpty) {
      base += "\n  Benchmarks: [${subFacts.map((f) => f.toString()).join(', ')}]";
    }
    return base;
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
  final Metrics metrics;
  final List<double> chartData;
  final List<String> headlines;
  final List<String> sources; // NEW: Stores list of feeds polled
  final bool isFallback;
  final DateTime generatedAt;

  Briefing({
    required this.id, required this.subsector, required this.title, required this.summary,
    required this.severity, required this.factScore, required this.sentScore,
    required this.divergenceTag, required this.divergenceDesc, required this.metrics,
    required this.chartData, required this.headlines, required this.sources, // NEW
    required this.isFallback, required this.generatedAt,
  });

  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) return value.join(', ');
    return value.toString();
  }

  factory Briefing.fromJson(Map<String, dynamic> json, DateTime timestamp) {
    return Briefing(
      id: _safeString(json['id']),
      subsector: _safeString(json['subsector']),
      title: _safeString(json['title']),
      summary: _safeString(json['summary']),
      severity: _safeString(json['severity']),
      factScore: (json['fact_score'] as num?)?.toInt() ?? 0,
      sentScore: (json['sent_score'] as num?)?.toInt() ?? 0,
      divergenceTag: _safeString(json['divergence_tag']),
      divergenceDesc: _safeString(json['divergence_desc']),
      metrics: Metrics.fromJson(json['metrics'] ?? {}),
      chartData: (json['chart_data'] as List<dynamic>? ?? [])
          .where((x) => x != null && x is num).map((x) => (x as num).toDouble()).toList(),
      headlines: List<String>.from(json['headlines'] ?? []),
      sources: List<String>.from(json['sources'] ?? []), // NEW
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

  static String _safeString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) return value.join(', ');
    return value.toString();
  }

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      commodity: _safeString(json['commodity']),
      price: _safeString(json['price']),
      trend: _safeString(json['trend']),
    );
  }
}

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

// --- FEED TESTER MODEL ---
class FeedHealthResult {
  final String sourceName;
  final String url;
  final bool isSuccess;
  final int latencyMs;
  final int itemsFound;
  final String statusMessage;
  final String? error;

  FeedHealthResult({
    required this.sourceName,
    required this.url,
    required this.isSuccess,
    required this.latencyMs,
    required this.itemsFound,
    required this.statusMessage,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'sourceName': sourceName,
    'url': url,
    'isSuccess': isSuccess,
    'latencyMs': latencyMs,
    'itemsFound': itemsFound,
    'statusMessage': statusMessage,
    'error': error,
  };

  factory FeedHealthResult.fromJson(Map<String, dynamic> json) {
    return FeedHealthResult(
      sourceName: json['sourceName'] ?? 'Unknown',
      url: json['url'] ?? '',
      isSuccess: json['isSuccess'] ?? false,
      latencyMs: json['latencyMs'] ?? 0,
      itemsFound: json['itemsFound'] ?? 0,
      statusMessage: json['statusMessage'] ?? 'Unknown',
      error: json['error'],
    );
  }
}