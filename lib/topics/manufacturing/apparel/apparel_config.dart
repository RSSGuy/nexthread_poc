import '../../../core/topic_config.dart';
import '../../../core/models.dart';
import '../../../core/news_registry.dart';
import 'apparel_service.dart';
import 'apparel_risk_rules.dart';

class ApparelConfig implements TopicConfig {
  final _service = ApparelService();

  @override
  String get id => "apparel";

  @override
  String get name => "Apparel Mfg";

  @override
  Naics get industry => Naics.manufacturing;

  @override
  List<NewsSourceConfig> get sources => [
    NewsRegistry.reutersCommodities, // For Cotton/Oil
    NewsRegistry.sourcingJournal,
    NewsRegistry.justStyle,
    NewsRegistry.wwd,
    NewsRegistry.constructionDive, // Often covers factory builds
    // Add specific supply chain feeds if available
  ];

  @override
  List<String> get keywords => [
    "apparel", "textile", "garment", "cotton", "polyester", "fashion supply chain",
    "inventory", "sourcing", "factory", "Vietnam", "Bangladesh", "sweatshop"
  ];

  @override
  String get riskRules => ApparelRiskRules.rules;

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await _service.getApparelFact();
  }
}