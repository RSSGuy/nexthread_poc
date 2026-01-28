import '../../../core/topic_config.dart';
import '../../../core/models.dart';
import '../../../core/news_registry.dart';
import 'chemical_service.dart';
import 'chemical_risk_rules.dart';

class ChemicalConfig implements TopicConfig {
  final _service = ChemicalService();

  @override
  String get id => "chemicals";

  @override
  String get name => "Chemical Mfg";

  @override
  Naics get industry => Naics.manufacturing;

  @override
  List<NewsSourceConfig> get sources => [
    NewsRegistry.reutersCommodities, // Crucial for Oil/Gas inputs
    NewsRegistry.cenNews,
    NewsRegistry.chemicalWeek,
    NewsRegistry.epaNews,
    NewsRegistry.icis, // Market intelligence
    // Manufacturing generic sources
    const NewsSourceConfig(
        name: "IndustryWeek",
        url: "https://www.industryweek.com/rss/all",
        type: "Mfg",
        tags: [Naics.manufacturing]
    ),
  ];

  @override
  List<String> get keywords => [
    "chemical", "petrochemical", "plastic", "polymer", "Dow", "DuPont", "BASF",
    "PFAS", "feedstock", "natural gas", "ethanol", "fertilizer", "hazmat"
  ];

  @override
  String get riskRules => ChemicalRiskRules.rules;

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await _service.getChemicalFact();
  }
}