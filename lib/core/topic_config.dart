
import 'models.dart';

abstract class TopicConfig {
  String get id;              // Unique ID (e.g., 'wheat')
  String get name;            // Display Name (e.g., 'Wheat Futures')
  Naics get industry;         // NEW: Primary Industry Tag

  // News Settings
  List<NewsSourceConfig> get sources;
  List<String> get keywords;

  // AI Settings
  String get riskRules;

  // Market Data
  Future<MarketFact> fetchMarketPulse();
}