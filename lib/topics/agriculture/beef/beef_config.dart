import '../../../core/topic_config.dart';
import '../../../core/models.dart';
import '../../../core/news_registry.dart';
import 'beef_service.dart';
import 'beef_risk_rules.dart';

class BeefConfig implements TopicConfig {
  final _service = BeefService();

  @override
  String get id => "beef";

  @override
  String get name => "Live Cattle";

  @override
  Naics get industry => Naics.agriculture;

  @override
  List<NewsSourceConfig> get sources => [
    NewsRegistry.farmsBeef,          // Primary: Farms.com Beef
    NewsRegistry.farmsFeaturedBeeph, // Featured Beef
    NewsRegistry.usdaGeneral,        // Regulatory
    NewsRegistry.westernProducer,    // Regional context
    NewsRegistry.agWeb,              // General Ag
    NewsRegistry.reutersCommodities, // Macro
  ];

  @override
  List<String> get keywords => [
    "cattle", "beef", "livestock", "feedlot", "herd", "cow", "meat", "slaughter", "packer"
  ];

  @override
  String get riskRules => BeefRiskRules.rules;

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await _service.getBeefFact();
  }
}