
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
  final List<double> lineData; // ADDED: Stores history for sparklines

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
    this.lineData = const [], // Default to empty
  });

  bool get isPending => status == 'Pending Update';

  @override
  String toString() {
    return '$category - $name: $value ($trend). Status: $status';
  }
}

class MarketDataService {
  static const Duration _apiTimeout = Duration(seconds: 20);

  // --- CACHE ---
  static MarketFact? _cachedWheat;
  static DateTime? _lastWheatFetch;

  // --- WHEAT (Active) ---
  Future<MarketFact> fetchWheatPrice() async {
    // 1. Check Cache (5 min)
    if (_cachedWheat != null &&
        _lastWheatFetch != null &&
        DateTime.now().difference(_lastWheatFetch!).inMinutes < 5) {
      print("MarketData: Returning CACHED Wheat Data");
      return _cachedWheat!;
    }

    if (!Secrets.eodhdApiKey.contains("66") && Secrets.eodhdApiKey.length < 10) {
      print("MarketData: Invalid Key. Using Mock.");
      return _getMockWheat();
    }

    try {
      // --- A. REAL-TIME PRICE ---
      final symbol = "WEAT.US";
      final rtUrl = 'https://eodhd.com/api/real-time/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json';
      final rtProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(rtUrl)}");

      print("MarketData: Fetching Real-Time $symbol...");
      final rtResponse = await http.get(rtProxy).timeout(_apiTimeout);

      // --- B. HISTORICAL DATA (For Sparkline) ---
      // Get last 14 days to ensure we have at least 7 trading days
      final fromDate = DateTime.now().subtract(const Duration(days: 14));
      final fromStr = "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}";

      final histUrl = 'https://eodhd.com/api/eod/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json&from=$fromStr&period=d';
      final histProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(histUrl)}");

      print("MarketData: Fetching History for $symbol...");
      final histResponse = await http.get(histProxy).timeout(_apiTimeout);

      if (rtResponse.statusCode == 200 && histResponse.statusCode == 200) {
        // Parse Real-Time
        final dynamic rtJson = json.decode(rtResponse.body);
        // EODHD RT returns {code, close, change_p...}
        final double price = (rtJson['close'] as num).toDouble();
        final double changeP = (rtJson['change_p'] as num?)?.toDouble() ?? 0.0;
        final String valueStr = "\$${price.toStringAsFixed(2)}";

        String status = "Stable";
        if (changeP > 2.0) status = "Spiking";
        if (changeP < -2.0) status = "Crashing";

        // Parse History
        List<dynamic> histList = json.decode(histResponse.body);
        // Take the last 7 closing prices
        List<double> history = histList.map((e) => (e['close'] as num).toDouble()).toList();
        if (history.length > 7) {
          history = history.sublist(history.length - 7);
        }

        final fact = MarketFact(
          category: "Agriculture",
          name: "Wheat (ETF)",
          value: valueStr,
          trend: "${changeP >= 0 ? '+' : ''}${changeP.toStringAsFixed(2)}%",
          status: status,
          lineData: history, // Store real history
        );

        _cachedWheat = fact;
        _lastWheatFetch = DateTime.now();
        return fact;
      }
    } catch (e) {
      print("MarketData Error: $e");
    }

    return _getMockWheat();
  }

  // --- STUBS ---
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

  // New helper to get the raw object (for AIService)
  Future<MarketFact> getWheatFact() async {
    return await fetchWheatPrice();
  }

  Future<MarketFact> updatePendingFact(MarketFact fact) async {
    if (!fact.isPending) return fact;
    if (fact.name.contains("Wheat")) return await fetchWheatPrice();
    return fact;
  }

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
    lineData: [5.85, 5.82, 5.80, 5.78, 5.75, 5.79, 5.80], // Consistent mock trend
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
  final List<double> lineData;

  MarketFact({
    required this.category,
    required this.name,
    required this.value,
    required this.trend,
    required this.status,
    this.lineData = const [],
  });

  bool get isPending => status == 'Pending Update';

  @override
  String toString() {
    return '$category - $name: $value ($trend). Status: $status';
  }
}

class MarketDataService {
  static const Duration _apiTimeout = Duration(seconds: 20);

  // --- CACHE ---
  static MarketFact? _cachedWheat;
  static DateTime? _lastWheatFetch;

  // --- WHEAT (Active) ---
  Future<MarketFact> fetchWheatPrice() async {
    // 1. Check Cache (5 min)
    if (_cachedWheat != null &&
        _lastWheatFetch != null &&
        DateTime.now().difference(_lastWheatFetch!).inMinutes < 5) {
      print("MarketData: Returning CACHED Wheat Data");
      return _cachedWheat!;
    }

    if (!Secrets.eodhdApiKey.contains("66") && Secrets.eodhdApiKey.length < 10) {
      print("MarketData: Invalid Key. Using Mock.");
      return _getMockWheat();
    }

    try {
      // --- A. REAL-TIME PRICE ---
      final symbol = "WEAT.US";
      final rtUrl = 'https://eodhd.com/api/real-time/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json';
      final rtProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(rtUrl)}");

      print("MarketData: Fetching Real-Time $symbol...");
      final rtResponse = await http.get(rtProxy).timeout(_apiTimeout);

      // --- B. HISTORICAL DATA (For Sparkline) ---
      // FETCH 90 DAYS (approx 3 months) instead of 14
      final fromDate = DateTime.now().subtract(const Duration(days: 90));
      final fromStr = "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}";

      final histUrl = 'https://eodhd.com/api/eod/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json&from=$fromStr&period=d';
      final histProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(histUrl)}");

      print("MarketData: Fetching History for $symbol...");
      final histResponse = await http.get(histProxy).timeout(_apiTimeout);

      if (rtResponse.statusCode == 200 && histResponse.statusCode == 200) {
        // Parse Real-Time
        final dynamic rtJson = json.decode(rtResponse.body);
        final double price = (rtJson['close'] as num).toDouble();
        final double changeP = (rtJson['change_p'] as num?)?.toDouble() ?? 0.0;
        final String valueStr = "\$${price.toStringAsFixed(2)}";

        String status = "Stable";
        if (changeP > 2.0) status = "Spiking";
        if (changeP < -2.0) status = "Crashing";

        // Parse History
        List<dynamic> histList = json.decode(histResponse.body);
        List<double> history = histList.map((e) => (e['close'] as num).toDouble()).toList();

        // REMOVED TRUNCATION: Passing full 90-day history to UI now

        final fact = MarketFact(
          category: "Agriculture",
          name: "Wheat (ETF)",
          value: valueStr,
          trend: "${changeP >= 0 ? '+' : ''}${changeP.toStringAsFixed(2)}%",
          status: status,
          lineData: history,
        );

        _cachedWheat = fact;
        _lastWheatFetch = DateTime.now();
        return fact;
      }
    } catch (e) {
      print("MarketData Error: $e");
    }

    return _getMockWheat();
  }

  // --- STUBS ---
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

  Future<MarketFact> getWheatFact() async {
    return await fetchWheatPrice();
  }

  Future<MarketFact> updatePendingFact(MarketFact fact) async {
    if (!fact.isPending) return fact;
    if (fact.name.contains("Wheat")) return await fetchWheatPrice();
    return fact;
  }

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
    lineData: [5.85, 5.82, 5.80, 5.78, 5.75, 5.79, 5.80, 5.82, 5.85, 5.88],
  );
}