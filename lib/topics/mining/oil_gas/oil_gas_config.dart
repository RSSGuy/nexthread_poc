import '../../../core/topic_config.dart';
import '../../../core/models.dart';
import 'oil_gas_risk_rules.dart';
import 'oil_gas_service.dart'; // IMPORT SERVICE

class OilGasConfig implements TopicConfig {
  // Initialize the specific service
  final _service = OilGasService();

  @override
  String get id => "oil_gas";

  @override
  String get name => "Oil & Gasoline";

  @override
  Naics get industry => Naics.mining; // Tags this topic as Mining

  @override
  List<String> get keywords => [
    "crude oil",
    "gasoline",
    "petroleum",
    "OPEC",
    "drilling",
    "refinery",
    "natural gas",
    "pipeline",
    "shale",
    "offshore",
    "energy sector",
    "carbon capture"
  ];

  @override
  String get riskRules => oilGasRiskRules;

  @override
  List<NewsSourceConfig> get sources => [
    const NewsSourceConfig(
      name: "OilPrice.com",
      url: "https://oilprice.com/rss/main",
      type: "Industry Specific",
      tags: [Naics.mining],
    ),
    const NewsSourceConfig(
      name: "CNBC Energy",
      url: "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=19836768",
      type: "Global Finance",
      tags: [Naics.mining, Naics.utilities],
    ),
    const NewsSourceConfig(
      name: "Energy.gov News",
      url: "https://www.energy.gov/news/rss",
      type: "Government/Regulatory",
      tags: [Naics.mining, Naics.utilities],
    ),
  ];

  @override
  Future<MarketFact> fetchMarketPulse() async {
    // Delegate to the service
    return await _service.getFacts();
  }
}