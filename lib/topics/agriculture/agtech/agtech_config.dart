import '../../../core/topic_config.dart';
import '../../../core/models.dart';
import '../../../core/news_registry.dart';
import 'agtech_service.dart';
import 'agtech_risk_rules.dart';

class AgTechConfig implements TopicConfig {
  final _service = AgTechService();

  @override
  String get id => "agtech";

  @override
  String get name => "Ag Tech & Machinery";

  @override
  // Grouping under Agriculture for UI cohesion, though it spans Mfg.
  Naics get industry => Naics.agriculture;

  @override
  List<NewsSourceConfig> get sources => [
    NewsRegistry.farmsMachinery,      // Specific Machinery Feed
    NewsRegistry.farmsIndustryNews,   // General Ag Industry
    NewsRegistry.agWeb,               // General Trade
    NewsRegistry.cenNews,             // Chemical & Engineering
    NewsRegistry.usdaGeneral,         // Regulatory
    NewsRegistry.westernProducer,     // Regional adoption
  ];

  @override
  List<String> get keywords => [
    "autonomous", "robotics", "drone", "AI", "precision ag",
    "John Deere", "CNH", "AGCO", "Bayer", "Corteva",
    "biologicals", "herbicide", "fungicide", "fertilizer",
    "gene editing", "CRISPR", "vaccine", "biosecurity",
    "electric tractor", "semiconductor", "supply chain"
  ];

  @override
  String get riskRules => AgTechRiskRules.rules;

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await _service.getAgTechFact();
  }
}