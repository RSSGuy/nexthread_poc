import 'models.dart';

abstract class TopicConfig {
  String get id;              // Unique ID (e.g., 'wheat')
  String get name;            // Display Name (e.g., 'Wheat Futures')

  // News Settings
  List<NewsSourceConfig> get sources; // The RSS feeds for this specific topic
  List<String> get keywords;          // Keywords to filter news (e.g., "grain", "bushel")

  // AI Settings
  String get riskRules;       // The specific prompt logic for this industry

  // Market Data
  Future<MarketFact> fetchMarketPulse(); // Logic to get the price
}