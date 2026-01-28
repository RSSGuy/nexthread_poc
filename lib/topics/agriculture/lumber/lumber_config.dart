/*
import '../../../core/topic_config.dart';
import '../../../core/models.dart';
import 'lumber_service.dart';

class LumberConfig implements TopicConfig {
  final _service = LumberService();

  @override
  String get id => "lumber";

  @override
  String get name => "Timber & Lumber";

  @override
  List<NewsSourceConfig> get sources => const [
    NewsSourceConfig(name: "LBM Journal", url: "https://lbmjournal.com/feed/", type: "Trade"),
    NewsSourceConfig(name: "Construction Dive", url: "https://www.constructiondive.com/feeds/news/", type: "Demand"),
    NewsSourceConfig(name: "Madison's Report", url: "https://madisonsreport.com/feed/", type: "Industry"),
    NewsSourceConfig(name: "Reuters", url: "https://www.reutersagency.com/feed/?best-topics=commodities&post_type=best", type: "Global"),
    NewsSourceConfig(name: "USDA Forest Svc", url: "https://www.usda.gov/rss/latest-releases.xml", type: "Gov"),
  ];

  @override
  List<String> get keywords => [
    "lumber", "timber", "wood", "forestry", "sawmill", "housing starts", "construction", "softwood", "logging", "plywood"
  ];

  @override
  String get riskRules => '''
    1. HOUSING/DEMAND (Weight -8 to -10): Housing Starts Crash, High Interest Rates, Mortgage Rates.
    2. SUPPLY/CLIMATE (Weight -7 to -9): Wildfires (Canada/US), Pine Beetle infestation, Flooding in logging zones.
    3. TRADE (Weight -6 to -8): Softwood Lumber Agreement, Tariffs, Export restrictions.
    4. LABOR/LOGISTICS (Weight -4 to -6): Mill closures, Rail car shortages, Trucking costs.
  ''';

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await _service.getLumberFact();
  }
}*/
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