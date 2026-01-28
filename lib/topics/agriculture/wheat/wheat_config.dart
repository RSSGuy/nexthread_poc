/*
// UPDATED IMPORTS: Jump up 3 levels
import '../../../core/topic_config.dart';
import '../../../core/models.dart';
import 'wheat_service.dart';

class WheatConfig implements TopicConfig {
  final _service = WheatService();

  @override
  String get id => "wheat";

  @override
  String get name => "Global Wheat";

  @override
  List<NewsSourceConfig> get sources => const [
    NewsSourceConfig(name: "AgWeb", url: "https://www.agweb.com/rss/all", type: "Trade"),
    NewsSourceConfig(name: "Reuters", url: "https://www.reutersagency.com/feed/?best-topics=commodities&post_type=best", type: "Global"),
    NewsSourceConfig(name: "USDA", url: "https://www.usda.gov/rss/latest-releases.xml", type: "Government"),
    NewsSourceConfig(name: "Western Producer", url: "https://www.producer.com/feed/", type: "Regional"),
    NewsSourceConfig(name: "Food Business", url: "https://www.foodbusinessnews.net/rss/articles", type: "Mfg"),
    NewsSourceConfig(name: "Biofuels News", url: "https://biofuels-news.com/feed/", type: "Energy"),
  ];

  @override
  List<String> get keywords => [
    "wheat", "corn", "sugar", "fuel", "food", "soy", "grain", "rail", "port", "harvest", "drought"
  ];

  @override
  String get riskRules => '''
    1. GEOPOLITICAL (Weight -8 to -10): War, Export Bans, Sanctions, Black Sea conflict.
    2. BIO-THREAT (Weight -9 to -10): Avian Flu, Swine Fever, Rust fungus.
    3. INFRASTRUCTURE (Weight -6 to -8): Rail Stoppage, Bridge Collapse, Canal Blockage.
    4. SUPPLY/CLIMATE (Weight -5 to -7): Drought, Flooding, Yield Failure, Planting Delays.
    5. ENERGY/INPUTS (Weight -3 to -5): Fertilizer Spike, Diesel Shortage.
  ''';

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await _service.getWheatFact();
  }
}*/
import '../../../core/topic_config.dart';
import '../../../core/models.dart';
import '../../../core/news_registry.dart';
import 'wheat_service.dart';
import 'wheat_risk_rules.dart';

class WheatConfig implements TopicConfig {
  final _service = WheatService();

  @override
  String get id => "wheat";

  @override
  String get name => "Global Wheat";

  @override
  // NEW: Primary Industry Tag
  Naics get industry => Naics.agriculture;

/*  @override
  List<NewsSourceConfig> get sources => [
    NewsRegistry.reutersCommodities,
    NewsRegistry.usdaGeneral,
    NewsRegistry.agWeb,
    NewsRegistry.westernProducer,
    NewsRegistry.foodBusinessNews,
    NewsRegistry.biofuelsNews,
  ];*/

  @override
  // DYNAMIC SOURCE LOADING
  List<NewsSourceConfig> get sources {
    return NewsRegistry.all.where((s) => s.tags.contains(industry)).toList();
  }

  @override
  List<String> get keywords => [
    "wheat", "corn", "sugar", "fuel", "food", "soy", "grain", "rail", "port", "harvest", "drought"
  ];

  @override
  String get riskRules => WheatRiskRules.rules;

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await _service.getWheatFact();
  }
}