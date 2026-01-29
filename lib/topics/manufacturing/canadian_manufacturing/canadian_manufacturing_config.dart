import '../../../../core/topic_config.dart';
import '../../../../core/models.dart';
import '../../../../core/news_registry.dart'; // Import Registry
import 'canadian_manufacturing_service.dart';
import 'canadian_manufacturing_risk_rules.dart';

class CanadianManufacturingConfig implements TopicConfig {
  final _service = CanadianManufacturingService();

  @override
  String get id => "cdn_mfg";

  @override
  String get name => "Canadian Mfg.";

  @override
  Naics get industry => Naics.manufacturing;

  @override
  List<NewsSourceConfig> get sources => [
    NewsRegistry.canadianMfg,      // Primary Industry News
    NewsRegistry.plantMagazine,    // Machinery & Process
    NewsRegistry.industryWest,     // Western Region Context
    NewsRegistry.reutersCommodities, // Macro Economic Context (Reused)
  ];

  @override
  List<String> get keywords => [
    "Manufacturing", "Automotive", "Supply Chain", "Export",
    "Labor", "Steel", "Energy", "Tariff", "Invest", "EV", "Battery"
  ];

  @override
  String get riskRules => CanadianManufacturingRiskRules.rules;

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await _service.getPulse();
  }
}