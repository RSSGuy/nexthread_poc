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
}