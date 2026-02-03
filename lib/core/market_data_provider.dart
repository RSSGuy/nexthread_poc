// lib/core/market_data_provider.dart

import 'dart:math';
import 'models.dart';

import '../../secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketDataProvider {
  // Singleton
  static final MarketDataProvider _instance = MarketDataProvider._internal();
  factory MarketDataProvider() => _instance;
  MarketDataProvider._internal();

  // Cache to prevent spamming APIs
  final Map<String, MarketFact> _cache = {};

  /// The main method widgets will call.
  /// [ticker] is the symbol (e.g., "ARKK", "CORN").
  /// [industry] helps categorize the default fallback data.
  Future<MarketFact> getFact(String ticker, Naics industry) async {
    if (_cache.containsKey(ticker)) {
      return _cache[ticker]!;
    }

    // 1. Try Fetching Real Data
    try {
      final fact = await _fetchFromApi(ticker, industry);
      _cache[ticker] = fact;
      return fact;
    } catch (e) {
      // 2. Fallback to Simulation if API fails/is missing
      return _generateSimulatedFact(ticker, industry);
    }
  }

  Future<MarketFact> _fetchFromApi(String ticker, Naics industry) async {
    // Reusing your existing logic pattern here, but centralized
    // Implement your EODHD or other API calls here once
    throw UnimplementedError("API implementation placeholder");
  }

  MarketFact _generateSimulatedFact(String ticker, Naics industry) {
    // Generate a realistic looking "Innovation" score or Price based on industry
    final random = Random();
    final isTech = ticker == "ARKK" || ticker.contains("TECH");

    double basePrice = isTech ? 45.0 : 100.0;
    double current = basePrice + random.nextDouble() * 10;
    double change = (random.nextDouble() * 4) - 1.5; // -1.5% to +2.5%

    return MarketFact(
      category: industry.label,
      name: "$ticker Innovation Index",
      value: "\$${current.toStringAsFixed(2)}",
      trend: "${change > 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
      status: change.abs() > 2.0 ? "Volatile" : "Stable",
      lineData: List.generate(10, (_) => basePrice + random.nextDouble() * 10),
    );
  }
}