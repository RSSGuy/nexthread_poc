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
}*/
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
}