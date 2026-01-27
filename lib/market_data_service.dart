/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets.dart';

/// Represents a raw fact fetched from a Tier 1/2 API
class MarketFact {
  final String category; // e.g., "Commodity", "Macro"
  final String name;     // e.g., "Wheat", "10Y Treasury"
  final String value;    // e.g., "$5.80/bu"
  final String trend;    // e.g., "+2.1%"
  final String status;   // Derived status e.g., "High", "Normal"

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
  });

  @override
  String toString() {
    return '$category - $name: $value ($trend). Status: $status';
  }
}

class MarketDataService {

  // --- ALPHA VANTAGE (Commodities) ---
  Future<MarketFact> fetchWheatPrice() async {
    if (Secrets.alphaVantageKey.contains("YOUR")) return _getMockWheat();

    try {
      final url = Uri.parse(
          'https://www.alphavantage.co/query?function=WHEAT&interval=monthly&apikey=${Secrets.alphaVantageKey}'
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return _getMockWheat();

        // Parse latest data point
        final latest = data['data'][0];
        final prev = data['data'][1];

        // Convert $/Metric Ton to $/Bushel (~36.74 bu/ton)
        final price = double.parse(latest['value']) / 36.74;
        final prevPrice = double.parse(prev['value']) / 36.74;
        final change = ((price - prevPrice) / prevPrice) * 100;

        return MarketFact(
          category: "Agriculture",
          name: "Wheat Futures",
          value: "\$${price.toStringAsFixed(2)}/bu",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% MoM",
          status: change > 5 ? "Spiking" : change < -5 ? "Crashing" : "Stable",
        );
      }
    } catch (e) {
      print("AV Error: $e");
    }
    return _getMockWheat();
  }

  // --- BANK OF CANADA (Macro Economics) ---
  // Replaces FRED. Uses Valet API: https://www.bankofcanada.ca/valet/docs
  // No API Key required for standard usage.
  Future<MarketFact> fetchInterestRate() async {
    try {
      // V122544: 10-year Government of Canada benchmark bond yield
      // JSON format: ?recent=2 gives us the last 2 days for trend calculation
      final url = Uri.parse(
          'https://www.bankofcanada.ca/valet/observations/V122544/json?recent=2'
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final observations = data['observations'];

        if (observations != null && observations.length >= 2) {
          // BoC structure: { "d": "2023-01-01", "V122544": { "v": "3.15" } }
          final latest = double.parse(observations[1]['V122544']['v']);
          final prev = double.parse(observations[0]['V122544']['v']);

          final change = ((latest - prev) / prev) * 100;

          return MarketFact(
            category: "Macro",
            name: "10Y Can Bond",
            value: "$latest%",
            trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
            status: latest > 3.5 ? "Restrictive" : "Neutral",
          );
        }
      }
    } catch (e) {
      print("BoC Error: $e");
    }
    return _getMockRates();
  }

  // --- BANK OF CANADA (Forex) ---
  Future<MarketFact> fetchCadExchangeRate() async {
    try {
      // FXUSDCAD: US Dollar to Canadian Dollar daily exchange rate
      final url = Uri.parse(
          'https://www.bankofcanada.ca/valet/observations/FXUSDCAD/json?recent=2'
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final observations = data['observations'];

        if (observations != null && observations.length >= 2) {
          final latest = double.parse(observations[1]['FXUSDCAD']['v']);
          final prev = double.parse(observations[0]['FXUSDCAD']['v']);
          final change = ((latest - prev) / prev) * 100;

          return MarketFact(
            category: "Forex",
            name: "USD/CAD",
            value: "\$${latest.toStringAsFixed(4)}",
            trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
            status: "Live",
          );
        }
      }
    } catch (e) {
      print("BoC FX Error: $e");
    }
    // Fallback if API fails
    return MarketFact(category: "Forex", name: "USD/CAD", value: "1.3500", trend: "0.0%", status: "Offline");
  }

  // --- AGGREGATOR ---
  Future<String> getLiveFactsString() async {
    final results = await Future.wait([
      fetchWheatPrice(),
      fetchInterestRate(), // Now pulls Canadian 10Y Bond
      fetchCadExchangeRate(),
    ]);

    return results.map((f) => f.toString()).join('\n');
  }

  // --- MOCK FALLBACKS ---
  MarketFact _getMockWheat() => MarketFact(
    category: "Agriculture",
    name: "Wheat (Simulated)",
    value: "\$5.80/bu",
    trend: "-2.1% MoM",
    status: "Abundant",
  );

  MarketFact _getMockRates() => MarketFact(
    category: "Macro",
    name: "10Y Can Bond (Sim)",
    value: "3.25%",
    trend: "+0.02%",
    status: "Neutral",
  );
}*//*

*/
/*
import 'dart:convert';
import 'dart:async'; // Required for TimeoutException
import 'package:http/http.dart' as http;
import '../secrets.dart';

class MarketFact {
  final String category;
  final String name;
  final String value;
  final String trend;
  final String status;

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
  });

  @override
  String toString() {
    return '$category - $name: $value ($trend). Status: $status';
  }
}

class MarketDataService {

  // Define a strict timeout for all API calls
  static const Duration _apiTimeout = Duration(seconds: 4);

  // --- ALPHA VANTAGE (Commodities) ---
  Future<MarketFact> fetchWheatPrice() async {
    if (Secrets.alphaVantageKey.contains("YOUR")) return _getMockWheat();

    try {
      final url = Uri.parse(
          'https://www.alphavantage.co/query?function=WHEAT&interval=monthly&apikey=${Secrets.alphaVantageKey}'
      );

      // ADDED TIMEOUT
      final response = await http.get(url).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return _getMockWheat();

        final latest = data['data'][0];
        final prev = data['data'][1];

        // Convert $/Metric Ton to $/Bushel (~36.74 bu/ton)
        final price = double.parse(latest['value']) / 36.74;
        final prevPrice = double.parse(prev['value']) / 36.74;
        final change = ((price - prevPrice) / prevPrice) * 100;

        return MarketFact(
          category: "Agriculture",
          name: "Wheat Futures",
          value: "\$${price.toStringAsFixed(2)}/bu",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% MoM",
          status: change > 5 ? "Spiking" : change < -5 ? "Crashing" : "Stable",
        );
      }
    } catch (e) {
      print("AV Error/Timeout: $e");
    }
    return _getMockWheat();
  }

  // --- BANK OF CANADA (Macro Economics) ---
  Future<MarketFact> fetchInterestRate() async {
    try {
      final url = Uri.parse(
          'https://www.bankofcanada.ca/valet/observations/V122544/json?recent=2'
      );

      // ADDED TIMEOUT
      final response = await http.get(url).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final observations = data['observations'];

        if (observations != null && observations.length >= 2) {
          final latest = double.parse(observations[1]['V122544']['v']);
          final prev = double.parse(observations[0]['V122544']['v']);
          final change = ((latest - prev) / prev) * 100;

          return MarketFact(
            category: "Macro",
            name: "10Y Can Bond",
            value: "$latest%",
            trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
            status: latest > 3.5 ? "Restrictive" : "Neutral",
          );
        }
      }
    } catch (e) {
      print("BoC Error/Timeout: $e");
    }
    return _getMockRates();
  }

  // --- BANK OF CANADA (Forex) ---
  Future<MarketFact> fetchCadExchangeRate() async {
    try {
      final url = Uri.parse(
          'https://www.bankofcanada.ca/valet/observations/FXUSDCAD/json?recent=2'
      );

      // ADDED TIMEOUT
      final response = await http.get(url).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final observations = data['observations'];

        if (observations != null && observations.length >= 2) {
          final latest = double.parse(observations[1]['FXUSDCAD']['v']);
          final prev = double.parse(observations[0]['FXUSDCAD']['v']);
          final change = ((latest - prev) / prev) * 100;

          return MarketFact(
            category: "Forex",
            name: "USD/CAD",
            value: "\$${latest.toStringAsFixed(4)}",
            trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
            status: "Live",
          );
        }
      }
    } catch (e) {
      print("BoC FX Error/Timeout: $e");
    }
    // Fallback if API fails
    return MarketFact(category: "Forex", name: "USD/CAD", value: "1.3500", trend: "0.0%", status: "Offline");
  }

  // --- AGGREGATOR ---
  Future<String> getLiveFactsString() async {
    // We catch errors here to ensure one slow API doesn't kill the whole process
    try {
      final results = await Future.wait([
        fetchWheatPrice(),
        fetchInterestRate(),
        fetchCadExchangeRate(),
      ]).timeout(const Duration(seconds: 6)); // Global timeout for all data

      return results.map((f) => f.toString()).join('\n');
    } catch (e) {
      print("Global Data Timeout: Reverting to defaults.");
      return "Wheat: \$5.80 (Stable)\nInterest Rate: 3.25% (Neutral)\nUSD/CAD: 1.35 (Offline)";
    }
  }

  // --- MOCK FALLBACKS ---
  MarketFact _getMockWheat() => MarketFact(
    category: "Agriculture",
    name: "Wheat (Simulated)",
    value: "\$5.80/bu",
    trend: "-2.1% MoM",
    status: "Abundant",
  );

  MarketFact _getMockRates() => MarketFact(
    category: "Macro",
    name: "10Y Can Bond (Sim)",
    value: "3.25%",
    trend: "+0.02%",
    status: "Neutral",
  );
}*//*


*/
/*
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class MarketFact {
  final String category;
  final String name;
  final String value;
  final String trend;
  final String status;

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
  });

  @override
  String toString() => '$category - $name: $value ($trend). Status: $status';
}

class MarketDataService {
  static const Duration _apiTimeout = Duration(seconds: 6);
  final http.Client _client = http.Client();
  final String _apiKey = Secrets.alphaVantageKey;

  // --- 1. DIRECT COMMODITIES (Monthly Data) ---

  Future<MarketFact> fetchWheatPrice() async {
    return _fetchCommodity(
      symbol: "WHEAT",
      name: "Wheat",
      divisor: 36.74, // $/ton -> $/bu
      displayUnit: "bu",
      // CACHED FALLBACK (Used if API limit hit or CORS fails)
      fallback: MarketFact(category: "Agriculture", name: "Wheat", value: "\$5.72/bu", trend: "-1.5%", status: "Stable"),
    );
  }

  Future<MarketFact> fetchCornPrice() async {
    return _fetchCommodity(
      symbol: "CORN",
      name: "Corn",
      divisor: 39.36,
      displayUnit: "bu",
      fallback: MarketFact(category: "Agriculture", name: "Corn", value: "\$4.85/bu", trend: "+0.2%", status: "Normal"),
    );
  }

  // --- 2. ETF PROXIES (Live Global Quotes) ---

  Future<MarketFact> fetchSoybeanPrice() async {
    return _fetchEtfProxy(
      "SOYB", "Soybean (Fund)", "Agriculture",
      fallback: MarketFact(category: "Agriculture", name: "Soybean", value: "\$26.15", trend: "-0.4%", status: "Soft"),
    );
  }

  Future<MarketFact> fetchLumberPrice() async {
    return _fetchEtfProxy(
      "WOOD", "Timber (Index)", "Materials",
      fallback: MarketFact(category: "Materials", name: "Timber", value: "\$74.20", trend: "+1.2%", status: "Recovering"),
    );
  }

  Future<MarketFact> fetchLivestockPrice() async {
    return _fetchEtfProxy(
      "COW", "Livestock (Index)", "Animal",
      fallback: MarketFact(category: "Animal", name: "Livestock", value: "\$62.45", trend: "+3.5%", status: "Spiking"),
    );
  }

  Future<MarketFact> fetchCanolaPrice() async {
    return _fetchEtfProxy(
      "DBA", "Ag. Basket", "Agriculture",
      fallback: MarketFact(category: "Agriculture", name: "Ag Basket", value: "\$21.30", trend: "-0.1%", status: "Stable"),
    );
  }

  Future<MarketFact> fetchFaoIndexProxy() async {
    return _fetchEtfProxy(
      "MOO", "Agri-Business", "Index",
      fallback: MarketFact(category: "Index", name: "Agri-Biz", value: "\$75.10", trend: "+0.8%", status: "Rising"),
    );
  }

  // --- 3. MACRO DATA ---

  Future<MarketFact> fetchInterestRate() async {
    return _fetchFromUrl(
      uri: 'https://www.bankofcanada.ca/valet/observations/V122544/json?recent=2',
      fallback: MarketFact(category: "Macro", name: "10Y Bond", value: "3.25%", trend: "+0.0%", status: "Neutral"),
      parser: (data) {
        final observations = data['observations'];
        if (observations == null || observations.length < 2) throw Exception("No Data");
        final latest = double.parse(observations[1]['V122544']['v']);
        final prev = double.parse(observations[0]['V122544']['v']);
        final change = ((latest - prev) / prev) * 100;
        return MarketFact(
          category: "Macro", name: "10Y Bond", value: "$latest%",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
          status: latest > 3.5 ? "Restrictive" : "Neutral",
        );
      },
    );
  }

  Future<MarketFact> fetchCadExchangeRate() async {
    return _fetchFromUrl(
      uri: 'https://www.bankofcanada.ca/valet/observations/FXUSDCAD/json?recent=2',
      fallback: MarketFact(category: "Forex", name: "USD/CAD", value: "1.352", trend: "+0.01%", status: "Live"),
      parser: (data) {
        final observations = data['observations'];
        if (observations == null || observations.length < 2) throw Exception("No Data");
        final latest = double.parse(observations[1]['FXUSDCAD']['v']);
        final prev = double.parse(observations[0]['FXUSDCAD']['v']);
        final change = ((latest - prev) / prev) * 100;
        return MarketFact(
          category: "Forex", name: "USD/CAD", value: "\$${latest.toStringAsFixed(3)}",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
          status: "Live",
        );
      },
    );
  }

  // --- HELPERS ---

  Future<MarketFact> _fetchCommodity({required String symbol, required String name, required double divisor, required String displayUnit, required MarketFact fallback}) async {
    if (_apiKey.contains("YOUR")) return fallback;

    return _fetchFromUrl(
      uri: 'https://www.alphavantage.co/query?function=$symbol&interval=monthly&apikey=$_apiKey',
      fallback: fallback,
      parser: (data) {
        if (data.containsKey("Information")) throw Exception("Rate Limit Hit");
        if (data['data'] == null || (data['data'] as List).isEmpty) throw Exception("Empty Data");

        final latest = data['data'][0];
        final prev = data['data'][1];
        final price = double.parse(latest['value']) / divisor;
        final prevPrice = double.parse(prev['value']) / divisor;
        final change = ((price - prevPrice) / prevPrice) * 100;

        return MarketFact(
          category: "Agriculture",
          name: name,
          value: "\$${price.toStringAsFixed(2)}/$displayUnit",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% MoM",
          status: change.abs() < 2 ? "Stable" : (change > 0 ? "Rising" : "Falling"),
        );
      },
    );
  }

  Future<MarketFact> _fetchEtfProxy(String ticker, String name, String category, {required MarketFact fallback}) async {
    if (_apiKey.contains("YOUR")) return fallback;

    return _fetchFromUrl(
      uri: 'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$ticker&apikey=$_apiKey',
      fallback: fallback,
      parser: (data) {
        if (data.containsKey("Information")) throw Exception("Rate Limit Hit");
        final quote = data['Global Quote'];
        if (quote == null || quote.isEmpty) throw Exception("No Quote Data");

        final price = double.tryParse(quote['05. price'] ?? '0') ?? 0.0;
        final changeStr = quote['10. change percent'] ?? '0%';
        final change = double.tryParse(changeStr.replaceAll('%', '')) ?? 0.0;

        return MarketFact(
          category: category,
          name: name,
          value: "\$${price.toStringAsFixed(2)}",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
          status: change.abs() < 1 ? "Stable" : (change > 0 ? "Bullish" : "Bearish"),
        );
      },
    );
  }

  Future<MarketFact> _fetchFromUrl({
    required String uri,
    required MarketFact fallback,
    required MarketFact Function(Map<String, dynamic>) parser
  }) async {
    try {
      final response = await _client.get(Uri.parse(uri)).timeout(_apiTimeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return parser(data);
      } else {
        print("API Error [${response.statusCode}]: $uri");
      }
    } catch (e) {
      // print("Exception fetching $uri: $e");
    }
    return fallback;
  }

  // --- AGGREGATOR ---

  // Method 1: Get list for UI PulseBar
  Future<List<MarketFact>> getAllFacts() async {
    List<MarketFact> facts = [];

    // Sequential fetching to be gentle on API limits
    facts.add(await fetchWheatPrice());
    facts.add(await fetchCornPrice());
    facts.add(await fetchInterestRate());
    facts.add(await fetchCadExchangeRate());
    facts.add(await fetchSoybeanPrice());
    facts.add(await fetchLivestockPrice());
    facts.add(await fetchLumberPrice());
    facts.add(await fetchCanolaPrice());
    facts.add(await fetchFaoIndexProxy());

    return facts;
  }

  // Method 2: Get String for AI Context (The missing method)
  Future<String> getLiveFactsString() async {
    try {
      // Re-use getAllFacts to ensure consistency
      final facts = await getAllFacts();
      return facts.map((f) => f.toString()).join('\n');
    } catch (e) {
      return "Wheat: \$5.72 (Stable)\nCorn: \$4.85 (Normal)\nSoybean: \$26.15 (Soft)";
    }
  }
}*//*

*/
/*


import 'dart:convert';
import 'dart:async'; // Required for TimeoutException
import 'package:http/http.dart' as http;
import '../secrets.dart';

class MarketFact {
  final String category;
  final String name;
  final String value;
  final String trend;
  final String status;

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
  });

  // Helper to check if the data is marked pending
  bool get isPending => status == 'Pending Update';

  @override
  String toString() {
    return '$category - $name: $value ($trend). Status: $status';
  }
}

class MarketDataService {

  // Define a strict timeout for all API calls
  static const Duration _apiTimeout = Duration(seconds: 4);

  // --- ALPHA VANTAGE (Commodities) ---
  Future<MarketFact> fetchWheatPrice() async {
    if (Secrets.alphaVantageKey.contains("YOUR")) return _getMockWheat();

    try {
      final url = Uri.parse(
          'https://www.alphavantage.co/query?function=WHEAT&interval=monthly&apikey=${Secrets.alphaVantageKey}'
      );

      final response = await http.get(url).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return _getPendingFact("Agriculture", "Wheat Futures");

        final latest = data['data'][0];
        final prev = data['data'][1];

        // Convert $/Metric Ton to $/Bushel (~36.74 bu/ton)
        final price = double.parse(latest['value']) / 36.74;
        final prevPrice = double.parse(prev['value']) / 36.74;
        final change = ((price - prevPrice) / prevPrice) * 100;

        return MarketFact(
          category: "Agriculture",
          name: "Wheat Futures",
          value: "\$${price.toStringAsFixed(2)}/bu",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% MoM",
          status: change > 5 ? "Spiking" : change < -5 ? "Crashing" : "Stable",
        );
      }
    } catch (e) {
      print("AV Error/Timeout: $e");
    }
    return _getPendingFact("Agriculture", "Wheat Futures");
  }

  // --- BANK OF CANADA (Macro Economics) ---
  Future<MarketFact> fetchInterestRate() async {
    try {
      final url = Uri.parse(
          'https://www.bankofcanada.ca/valet/observations/V122544/json?recent=2'
      );

      final response = await http.get(url).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final observations = data['observations'];

        if (observations != null && observations.length >= 2) {
          final latest = double.parse(observations[1]['V122544']['v']);
          final prev = double.parse(observations[0]['V122544']['v']);
          final change = ((latest - prev) / prev) * 100;

          return MarketFact(
            category: "Macro",
            name: "10Y Can Bond",
            value: "$latest%",
            trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
            status: latest > 3.5 ? "Restrictive" : "Neutral",
          );
        }
      }
    } catch (e) {
      print("BoC Error/Timeout: $e");
    }
    return _getPendingFact("Macro", "10Y Can Bond");
  }

  // --- BANK OF CANADA (Forex) ---
  Future<MarketFact> fetchCadExchangeRate() async {
    try {
      final url = Uri.parse(
          'https://www.bankofcanada.ca/valet/observations/FXUSDCAD/json?recent=2'
      );

      final response = await http.get(url).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final observations = data['observations'];

        if (observations != null && observations.length >= 2) {
          final latest = double.parse(observations[1]['FXUSDCAD']['v']);
          final prev = double.parse(observations[0]['FXUSDCAD']['v']);
          final change = ((latest - prev) / prev) * 100;

          return MarketFact(
            category: "Forex",
            name: "USD/CAD",
            value: "\$${latest.toStringAsFixed(4)}",
            trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
            status: "Live",
          );
        }
      }
    } catch (e) {
      print("BoC FX Error/Timeout: $e");
    }
    return _getPendingFact("Forex", "USD/CAD");
  }

  // --- AGGREGATOR ---

  /// Returns all market facts as a list.
  /// Used by the UI to display individual Pulse items.
  Future<List<MarketFact>> getAllFacts() async {
    try {
      return await Future.wait([
        fetchWheatPrice(),
        fetchInterestRate(),
        fetchCadExchangeRate(),
      ]).timeout(const Duration(seconds: 6));
    } catch (e) {
      print("Global Data Timeout/Error: Reverting to defaults. $e");
      // Return defaults if the whole batch fails
      return [
        _getMockWheat(),
        _getMockRates(),
        MarketFact(category: "Forex", name: "USD/CAD", value: "1.3500", trend: "0.0%", status: "Offline")
      ];
    }
  }

  /// Returns a string representation of all facts.
  /// Used by the AI Service for prompt generation.
  Future<String> getLiveFactsString() async {
    final facts = await getAllFacts();
    return facts.map((f) => f.toString()).join('\n');
  }

  // --- ASYNC UPDATE LOGIC ---

  /// If some data is marked pending, update the data when it is permissible.
  Future<MarketFact> updatePendingFact(MarketFact fact) async {
    if (!fact.isPending) {
      return fact;
    }

    switch (fact.name) {
      case "Wheat Futures":
        return await fetchWheatPrice();
      case "10Y Can Bond":
        return await fetchInterestRate();
      case "USD/CAD":
        return await fetchCadExchangeRate();
      default:
        return fact;
    }
  }

  // --- HELPERS & FALLBACKS ---

  MarketFact _getPendingFact(String category, String name) => MarketFact(
    category: category,
    name: name,
    value: "--",
    trend: "--",
    status: "Pending Update",
  );

  MarketFact _getMockWheat() => MarketFact(
    category: "Agriculture",
    name: "Wheat (Simulated)",
    value: "\$5.80/bu",
    trend: "-2.1% MoM",
    status: "Abundant",
  );

  MarketFact _getMockRates() => MarketFact(
    category: "Macro",
    name: "10Y Can Bond (Sim)",
    value: "3.25%",
    trend: "+0.02%",
    status: "Neutral",
  );
}*//*

*/
/*
import 'dart:convert';
import 'dart:async'; // Required for TimeoutException
import 'package:http/http.dart' as http;
import '../secrets.dart';

class MarketFact {
  final String category;
  final String name;
  final String value;
  final String trend;
  final String status;

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
  });

  // Helper to check if the data is marked pending
  bool get isPending => status == 'Pending Update';

  @override
  String toString() {
    return '$category - $name: $value ($trend). Status: $status';
  }
}

class MarketDataService {

  // Define a strict timeout for all API calls
  static const Duration _apiTimeout = Duration(seconds: 4);

  // --- ALPHA VANTAGE (Commodities) ---
  Future<MarketFact> fetchWheatPrice() async {
    // If using placeholder key, return mock immediately
    if (Secrets.alphaVantageKey.contains("YOUR")) return _getMockWheat();

    try {
      final url = Uri.parse(
          'https://www.alphavantage.co/query?function=WHEAT&interval=monthly&apikey=${Secrets.alphaVantageKey}'
      );

      final response = await http.get(url).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] == null) return _getPendingFact("Agriculture", "Wheat Futures");

        final latest = data['data'][0];
        final prev = data['data'][1];

        // Convert $/Metric Ton to $/Bushel (~36.74 bu/ton)
        final price = double.parse(latest['value']) / 36.74;
        final prevPrice = double.parse(prev['value']) / 36.74;
        final change = ((price - prevPrice) / prevPrice) * 100;

        return MarketFact(
          category: "Agriculture",
          name: "Wheat Futures",
          value: "\$${price.toStringAsFixed(2)}/bu",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% MoM",
          status: change > 5 ? "Spiking" : change < -5 ? "Crashing" : "Stable",
        );
      }
    } catch (e) {
      print("AV Error/Timeout: $e");
    }
    // CHANGED: Return Pending instead of Mock on error
    return _getPendingFact("Agriculture", "Wheat Futures");
  }

  // --- BANK OF CANADA (Macro Economics) ---
  Future<MarketFact> fetchInterestRate() async {
    try {
      final url = Uri.parse(
          'https://www.bankofcanada.ca/valet/observations/V122544/json?recent=2'
      );

      final response = await http.get(url).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final observations = data['observations'];

        if (observations != null && observations.length >= 2) {
          final latest = double.parse(observations[1]['V122544']['v']);
          final prev = double.parse(observations[0]['V122544']['v']);
          final change = ((latest - prev) / prev) * 100;

          return MarketFact(
            category: "Macro",
            name: "10Y Can Bond",
            value: "$latest%",
            trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
            status: latest > 3.5 ? "Restrictive" : "Neutral",
          );
        }
      }
    } catch (e) {
      print("BoC Error/Timeout: $e");
    }
    return _getPendingFact("Macro", "10Y Can Bond");
  }

  // --- BANK OF CANADA (Forex) ---
  Future<MarketFact> fetchCadExchangeRate() async {
    try {
      final url = Uri.parse(
          'https://www.bankofcanada.ca/valet/observations/FXUSDCAD/json?recent=2'
      );

      final response = await http.get(url).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final observations = data['observations'];

        if (observations != null && observations.length >= 2) {
          final latest = double.parse(observations[1]['FXUSDCAD']['v']);
          final prev = double.parse(observations[0]['FXUSDCAD']['v']);
          final change = ((latest - prev) / prev) * 100;

          return MarketFact(
            category: "Forex",
            name: "USD/CAD",
            value: "\$${latest.toStringAsFixed(4)}",
            trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%",
            status: "Live",
          );
        }
      }
    } catch (e) {
      print("BoC FX Error/Timeout: $e");
    }
    return _getPendingFact("Forex", "USD/CAD");
  }

  // --- AGGREGATOR ---
  Future<String> getLiveFactsString() async {
    try {
      final results = await Future.wait([
        fetchWheatPrice(),
        fetchInterestRate(),
        fetchCadExchangeRate(),
      ]).timeout(const Duration(seconds: 6));

      return results.map((f) => f.toString()).join('\n');
    } catch (e) {
      print("Global Data Timeout: Reverting to defaults.");
      return "Wheat: \$5.80 (Stable)\nInterest Rate: 3.25% (Neutral)\nUSD/CAD: 1.35 (Offline)";
    }
  }

  // --- NEW: Helper to Retry Updates ---
  Future<MarketFact> updatePendingFact(MarketFact fact) async {
    if (!fact.isPending) return fact;

    // Retry specific logic based on name
    switch (fact.name) {
      case "Wheat Futures": return await fetchWheatPrice();
      case "10Y Can Bond": return await fetchInterestRate();
      case "USD/CAD": return await fetchCadExchangeRate();
      default: return fact;
    }
  }

  // --- HELPERS & FALLBACKS ---

  MarketFact _getPendingFact(String category, String name) => MarketFact(
    category: category,
    name: name,
    value: "--",
    trend: "--",
    status: "Pending Update",
  );

  MarketFact _getMockWheat() => MarketFact(
    category: "Agriculture",
    name: "Wheat (Simulated)",
    value: "\$5.80/bu",
    trend: "-2.1% MoM",
    status: "Abundant",
  );

  MarketFact _getMockRates() => MarketFact(
    category: "Macro",
    name: "10Y Can Bond (Sim)",
    value: "3.25%",
    trend: "+0.02%",
    status: "Neutral",
  );
}*/
/*

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class MarketFact {
  final String category;
  final String name;
  final String value;
  final String trend;
  final String status;

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
  });

  bool get isPending => status == 'Pending Update';

  @override
  String toString() {
    return '$category - $name: $value ($trend). Status: $status';
  }
}

class MarketDataService {
  static const Duration _apiTimeout = Duration(seconds: 20);

  // --- CACHE VARIABLES ---
  static MarketFact? _cachedWheat;
  static DateTime? _lastWheatFetch;

  // --- WHEAT (Active) ---
  Future<MarketFact> fetchWheatPrice() async {
    // 1. Check Cache (Valid for 5 minutes)
    if (_cachedWheat != null &&
        _lastWheatFetch != null &&
        DateTime.now().difference(_lastWheatFetch!).inMinutes < 5) {
      print("MarketData: Returning CACHED Wheat Data (Saving API Quota)");
      return _cachedWheat!;
    }

    if (Secrets.alphaVantageKey.contains("YOUR")) {
      print("MarketData: Using Mock Data (Placeholder Key)");
      return _getMockWheat();
    }

    try {
      final originalUrl = 'https://www.alphavantage.co/query?function=WHEAT&interval=monthly&apikey=${Secrets.alphaVantageKey}';
      final proxyUrl = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}");

      print("MarketData: Fetching Wheat via corsproxy.io...");
      final response = await http.get(proxyUrl).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // 2. DEBUG: Detect Rate Limit
        if (data.containsKey('Information') || data.containsKey('Note')) {
          print("MarketData: RATE LIMIT HIT (5 calls/min). Reverting to Mock.");
          // If we have old cache, return it instead of mock!
          if (_cachedWheat != null) return _cachedWheat!;
          return _getMockWheat();
        }

        if (data.containsKey('Error Message')) {
          print("MarketData: API ERROR. Reverting to Mock.");
          return _getMockWheat();
        }

        if (data['data'] == null) {
          print("MarketData: Unexpected structure. Reverting to Mock.");
          return _getMockWheat();
        }

        final latest = data['data'][0];
        final prev = data['data'][1];
        final price = double.parse(latest['value']) / 36.74;
        final prevPrice = double.parse(prev['value']) / 36.74;
        final change = ((price - prevPrice) / prevPrice) * 100;

        final fact = MarketFact(
          category: "Agriculture",
          name: "Wheat Futures",
          value: "\$${price.toStringAsFixed(2)}/bu",
          trend: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}% MoM",
          status: change > 5 ? "Spiking" : change < -5 ? "Crashing" : "Stable",
        );

        // 3. Save to Cache
        _cachedWheat = fact;
        _lastWheatFetch = DateTime.now();
        print("MarketData: SUCCESS. Caching result.");

        return fact;
      }
    } catch (e) {
      print("MarketData Error: $e");
    }

    return _getPendingFact("Agriculture", "Wheat Futures");
  }

  // --- UNUSED METHODS ---
  Future<MarketFact> fetchInterestRate() async => _getPendingFact("Macro", "10Y Bond");
  Future<MarketFact> fetchCadExchangeRate() async => _getPendingFact("Forex", "USD/CAD");

  Future<String> getLiveFactsString() async {
    try {
      final wheat = await fetchWheatPrice();
      return wheat.toString();
    } catch (e) {
      return "Wheat: \$5.80 (Stable)";
    }
  }

  Future<MarketFact> updatePendingFact(MarketFact fact) async {
    if (!fact.isPending) return fact;
    if (fact.name == "Wheat Futures") return await fetchWheatPrice();
    return fact;
  }

  // --- HELPERS ---
  MarketFact _getPendingFact(String category, String name) => MarketFact(
    category: category,
    name: name,
    value: "--",
    trend: "--",
    status: "Pending Update",
  );

  MarketFact _getMockWheat() => MarketFact(
    category: "Agriculture",
    name: "Wheat (Simulated)",
    value: "\$5.80/bu",
    trend: "-2.1% MoM",
    status: "Abundant",
  );
}*/
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class MarketFact {
  final String category;
  final String name;
  final String value;
  final String trend;
  final String status;

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
  });

  bool get isPending => status == 'Pending Update';

  @override
  String toString() {
    return '$category - $name: $value ($trend). Status: $status';
  }
}

class MarketDataService {
  // Timeout for API calls
  static const Duration _apiTimeout = Duration(seconds: 20);

  // --- CACHE VARIABLES ---
  static MarketFact? _cachedWheat;
  static DateTime? _lastWheatFetch;

  // --- WHEAT (Active) ---
  Future<MarketFact> fetchWheatPrice() async {
    // 1. Check Cache (Valid for 5 minutes)
    if (_cachedWheat != null &&
        _lastWheatFetch != null &&
        DateTime.now().difference(_lastWheatFetch!).inMinutes < 5) {
      print("MarketData: Returning CACHED Wheat Data (EODHD)");
      return _cachedWheat!;
    }

    // Check for missing key (assuming you added eodhdApiKey to secrets.dart)
    // If you haven't renamed the variable in secrets.dart yet, you might need to update this check.
    if (!Secrets.eodhdApiKey.contains("66") && Secrets.eodhdApiKey.length < 10) {
      print("MarketData: Invalid EODHD Key detected. Using Mock.");
      return _getMockWheat();
    }

    try {
      // 2. EODHD ENDPOINT (Real-Time for US Tickers)
      // We use WEAT.US (Teucrium Wheat Fund) as a proxy for Wheat Futures
      // because it is available on standard EODHD plans.
      final symbol = "WEAT.US";
      final originalUrl = 'https://eodhd.com/api/real-time/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json';

      // 3. Use CORS Proxy (EODHD supports CORS, but Proxy is safer for web POCs)
      final proxyUrl = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}");

      print("MarketData: Fetching $symbol via EODHD...");
      final response = await http.get(proxyUrl).timeout(_apiTimeout);

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        // EODHD returns a single object for one ticker: {"code": "WEAT.US", "close": 5.45, ...}
        // Check if we got an error message
        if (jsonResponse is Map && (jsonResponse.containsKey('status') || jsonResponse.containsKey('message'))) {
          print("MarketData: EODHD Error - ${jsonResponse['message']}");
          return _getMockWheat();
        }

        final data = jsonResponse as Map<String, dynamic>;

        // Parse EODHD Real-Time Fields
        final double price = (data['close'] as num).toDouble();
        final double changeP = (data['change_p'] as num?)?.toDouble() ?? 0.0;

        // EODHD price is in $, e.g., 5.45
        final String valueStr = "\$${price.toStringAsFixed(2)}";

        // Determine Status based on % Change
        String status = "Stable";
        if (changeP > 2.0) status = "Spiking";
        if (changeP < -2.0) status = "Crashing";

        final fact = MarketFact(
          category: "Agriculture",
          name: "Wheat (ETF)", // Labeled as ETF for accuracy
          value: valueStr,
          trend: "${changeP >= 0 ? '+' : ''}${changeP.toStringAsFixed(2)}%",
          status: status,
        );

        // 4. Save to Cache
        _cachedWheat = fact;
        _lastWheatFetch = DateTime.now();
        print("MarketData: SUCCESS. Caching EODHD result.");

        return fact;
      } else {
        print("MarketData: HTTP Error ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("MarketData Error: $e");
    }

    // On failure, return Mock (or Pending)
    return _getMockWheat();
  }

  // --- UNUSED METHODS (Stubs) ---
  Future<MarketFact> fetchInterestRate() async => _getPendingFact("Macro", "10Y Bond");
  Future<MarketFact> fetchCadExchangeRate() async => _getPendingFact("Forex", "USD/CAD");

  Future<String> getLiveFactsString() async {
    try {
      final wheat = await fetchWheatPrice();
      return wheat.toString();
    } catch (e) {
      return "Wheat: \$5.80 (Stable)";
    }
  }

  Future<MarketFact> updatePendingFact(MarketFact fact) async {
    if (!fact.isPending) return fact;
    if (fact.name.contains("Wheat")) return await fetchWheatPrice();
    return fact;
  }

  // --- HELPERS ---
  MarketFact _getPendingFact(String category, String name) => MarketFact(
    category: category,
    name: name,
    value: "--",
    trend: "--",
    status: "Pending Update",
  );

  MarketFact _getMockWheat() => MarketFact(
    category: "Agriculture",
    name: "Wheat (Simulated)",
    value: "\$5.80",
    trend: "-1.2% (Sim)",
    status: "Abundant",
  );
}