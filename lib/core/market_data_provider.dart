

/*

import 'dart:math';
import 'models.dart';
import 'sector_benchmarks.dart';

import '../../secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketDataProvider {
  static final MarketDataProvider _instance = MarketDataProvider._internal();
  factory MarketDataProvider() => _instance;
  MarketDataProvider._internal();

  final Map<String, MarketFact> _cache = {};

  Future<MarketFact> getFact(String ticker, Naics industry, {String? label}) async {
    if (_cache.containsKey(ticker)) {
      var cached = _cache[ticker]!;
      if (label != null) {
        return MarketFact(
          category: cached.category,
          name: label,
          value: cached.value,
          trend: cached.trend,
          status: cached.status,
          lineData: cached.lineData,
          subFacts: cached.subFacts,
        );
      }
      return cached;
    }

    try {
      final fact = await _fetchFromApi(ticker, industry);
      _cache[ticker] = fact;

      if (label != null) {
        return MarketFact(
          category: fact.category,
          name: label,
          value: fact.value,
          trend: fact.trend,
          status: fact.status,
          lineData: fact.lineData,
        );
      }
      return fact;
    } catch (e) {
      return _generateSimulatedFact(ticker, industry, label: label);
    }
  }

  Future<MarketFact> getSectorBenchmarks(Naics industry) async {
    final benchmarkMap = SectorBenchmarks.getBenchmarks(industry);

    if (benchmarkMap.isEmpty) {
      return getFact("ARKK", industry);
    } else if (benchmarkMap.length == 1) {
      var entry = benchmarkMap.entries.first;
      return getFact(entry.value, industry, label: entry.key);
    } else {
      List<MarketFact> facts = [];
      for (var entry in benchmarkMap.entries) {
        facts.add(await getFact(entry.value, industry, label: entry.key));
      }

      return MarketFact(
          category: industry.label,
          name: "Sector Pulse",
          value: "",
          trend: "",
          status: "Multiple",
          subFacts: facts
      );
    }
  }

  Future<MarketFact> getGlobalBenchmarks() async {
    List<MarketFact> facts = [];
    for (var entry in SectorBenchmarks.globalIndices.entries) {
      facts.add(await getFact(entry.value, Naics.finance, label: entry.key));
    }

    return MarketFact(
      category: "Global Markets",
      name: "World Indices",
      value: "",
      trend: "",
      status: "Updated",
      subFacts: facts,
    );
  }

  Future<MarketFact> _fetchFromApi(String ticker, Naics industry) async {
    throw UnimplementedError("API implementation placeholder");
  }

  MarketFact _generateSimulatedFact(String ticker, Naics industry, {String? label}) {
    final random = Random();
    final isTech = ticker == "ARKK" || ticker.contains("TECH") || ticker == "^IXIC";

    double basePrice = isTech ? 15000.0 : 4000.0;
    if (ticker.contains("X")) basePrice = 100.0;

    double current = basePrice + random.nextDouble() * 50;
    double change = (random.nextDouble() * 4) - 1.5;

    return MarketFact(
      category: industry.label,
      name: label ?? "$ticker Index",
      value: "\$${current.toStringAsFixed(2)}",
      trend: "${change > 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
      status: change.abs() > 2.0 ? "Volatile" : "Stable",
      lineData: List.generate(10, (_) => basePrice + random.nextDouble() * 50),
    );
  }
}*/

// lib/core/market_data_provider.dart

import 'dart:math';
import 'models.dart';
import 'sector_benchmarks.dart';

import '../../secrets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketDataProvider {
  static final MarketDataProvider _instance = MarketDataProvider._internal();
  factory MarketDataProvider() => _instance;
  MarketDataProvider._internal();

  final Map<String, MarketFact> _cache = {};

  Future<MarketFact> getFact(String ticker, Naics industry, {String? label}) async {
    if (_cache.containsKey(ticker)) {
      var cached = _cache[ticker]!;
      if (label != null) {
        return MarketFact(
          category: cached.category,
          name: label,
          value: cached.value,
          trend: cached.trend,
          status: cached.status,
          lineData: cached.lineData,
          history: cached.history, // Pass history
          subFacts: cached.subFacts,
        );
      }
      return cached;
    }

    try {
      final fact = await _fetchFromApi(ticker, industry);
      _cache[ticker] = fact;

      if (label != null) {
        return MarketFact(
          category: fact.category,
          name: label,
          value: fact.value,
          trend: fact.trend,
          status: fact.status,
          lineData: fact.lineData,
          history: fact.history, // Pass history
        );
      }
      return fact;
    } catch (e) {
      return _generateSimulatedFact(ticker, industry, label: label);
    }
  }

  Future<MarketFact> getSectorBenchmarks(Naics industry) async {
    final benchmarkMap = SectorBenchmarks.getBenchmarks(industry);

    if (benchmarkMap.isEmpty) {
      return getFact("ARKK", industry);
    } else if (benchmarkMap.length == 1) {
      var entry = benchmarkMap.entries.first;
      return getFact(entry.value, industry, label: entry.key);
    } else {
      List<MarketFact> facts = [];
      for (var entry in benchmarkMap.entries) {
        facts.add(await getFact(entry.value, industry, label: entry.key));
      }

      return MarketFact(
          category: industry.label,
          name: "Sector Pulse",
          value: "",
          trend: "",
          status: "Multiple",
          subFacts: facts
      );
    }
  }

  Future<MarketFact> getGlobalBenchmarks() async {
    List<MarketFact> facts = [];
    for (var entry in SectorBenchmarks.globalIndices.entries) {
      facts.add(await getFact(entry.value, Naics.finance, label: entry.key));
    }

    return MarketFact(
      category: "Global Markets",
      name: "World Indices",
      value: "",
      trend: "",
      status: "Updated",
      subFacts: facts,
    );
  }

  Future<MarketFact> _fetchFromApi(String ticker, Naics industry) async {
    throw UnimplementedError("API implementation placeholder");
  }

  MarketFact _generateSimulatedFact(String ticker, Naics industry, {String? label}) {
    final random = Random();
    final isTech = ticker == "ARKK" || ticker.contains("TECH") || ticker == "^IXIC";

    double basePrice = isTech ? 15000.0 : 4000.0;
    if (ticker.contains("X")) basePrice = 100.0;

    double current = basePrice + random.nextDouble() * 50;
    double change = (random.nextDouble() * 4) - 1.5;

    // Helper to generate a random walk
    List<double> generateWalk(int count, double start) {
      List<double> data = [start];
      for (int i = 0; i < count; i++) {
        double next = data.last + (random.nextDouble() * 10 - 5);
        if (next < 0) next = 0;
        data.add(next);
      }
      return data;
    }

    // Generate histories for different timeframes
    Map<String, List<double>> history = {
      '5D': generateWalk(5, basePrice),
      '1M': generateWalk(20, basePrice),
      '3M': generateWalk(60, basePrice),
      '6M': generateWalk(120, basePrice),
      '1Y': generateWalk(240, basePrice),
    };

    return MarketFact(
      category: industry.label,
      name: label ?? "$ticker Index",
      value: "\$${current.toStringAsFixed(2)}",
      trend: "${change > 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
      status: change.abs() > 2.0 ? "Volatile" : "Stable",
      lineData: history['1M']!, // Default to 1M for legacy support
      history: history,
    );
  }
}