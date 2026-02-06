
import '../../../core/topic_config.dart';
import '../../../core/models.dart';
import '../../../core/news_registry.dart';
import 'lumber_service.dart';
import 'lumber_risk_rules.dart';

class LumberConfig implements TopicConfig {
  final _service = LumberService();

  @override
  String get id => "lumber";

  @override
  String get name => "Timber & Lumber";

  @override
  // NEW: Primary Industry Tag (Forestry falls under NAICS Agriculture)
  Naics get industry => Naics.agriculture;

  @override
  List<NewsSourceConfig> get sources => [
    NewsRegistry.reutersCommodities,
    NewsRegistry.usdaGeneral,
    NewsRegistry.usdaForestService,
    NewsRegistry.lbmJournal,
    NewsRegistry.constructionDive,
    NewsRegistry.madisonsReport,
  ];

  @override
  List<String> get keywords => [
    "lumber", "timber", "wood", "forestry", "sawmill", "housing starts", "construction", "softwood", "logging", "plywood"
  ];

  @override
  String get riskRules => LumberRiskRules.rules;

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await _service.getLumberFact();
  }
}