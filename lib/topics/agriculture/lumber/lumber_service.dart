import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models.dart';
import '../../../secrets.dart';

class LumberService {
  // Timeout for API calls
  static const Duration _apiTimeout = Duration(seconds: 20);

  // --- CACHE VARIABLES ---
  static MarketFact? _cachedLumber;
  static DateTime? _lastLumberFetch;

  Future<MarketFact> getLumberFact() async {
    // 1. Check Cache (Valid for 5 minutes)
    if (_cachedLumber != null &&
        _lastLumberFetch != null &&
        DateTime.now().difference(_lastLumberFetch!).inMinutes < 5) {
      print("LumberService: Returning CACHED Data");
      return _cachedLumber!;
    }

    // Check Key
    if (!Secrets.eodhdApiKey.contains("66") && Secrets.eodhdApiKey.length < 10) {
      return _getMockLumber();
    }

    try {
      // Using "WOOD" (iShares Global Timber & Forestry ETF) as proxy
      final symbol = "WOOD.US";

      // A. REAL-TIME URL
      final rtUrl = 'https://eodhd.com/api/real-time/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json';
      final rtProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(rtUrl)}");

      // B. HISTORY URL (90 Days)
      final fromDate = DateTime.now().subtract(const Duration(days: 90));
      final fromStr = "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}";
      final histUrl = 'https://eodhd.com/api/eod/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json&from=$fromStr&period=d';
      final histProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(histUrl)}");

      print("LumberService: Fetching $symbol...");

      final results = await Future.wait([
        http.get(rtProxy).timeout(_apiTimeout),
        http.get(histProxy).timeout(_apiTimeout),
      ]);

      final rtResponse = results[0];
      final histResponse = results[1];

      if (rtResponse.statusCode == 200 && histResponse.statusCode == 200) {
        // 1. Parse Real-Time
        final dynamic rtJson = json.decode(rtResponse.body);

        if (rtJson is Map && (rtJson.containsKey('status') || rtJson.containsKey('message'))) {
          return _getMockLumber();
        }

        final data = rtJson as Map<String, dynamic>;
        final double price = (data['close'] as num).toDouble();
        final double changeP = (data['change_p'] as num?)?.toDouble() ?? 0.0;
        final String valueStr = "\$${price.toStringAsFixed(2)}";

        // Determine Status
        String status = "Stable";
        if (changeP > 1.5) status = "Rising";
        if (changeP < -1.5) status = "Cooling";

        // 2. Parse History
        List<dynamic> histList = json.decode(histResponse.body);
        List<double> history = histList.map((e) => (e['close'] as num).toDouble()).toList();

        final fact = MarketFact(
          category: "Construction",
          name: "Timber (ETF)",
          value: valueStr,
          trend: "${changeP >= 0 ? '+' : ''}${changeP.toStringAsFixed(2)}%",
          status: status,
          lineData: history,
        );

        _cachedLumber = fact;
        _lastLumberFetch = DateTime.now();
        return fact;
      }
    } catch (e) {
      print("LumberService Error: $e");
    }

    return _getMockLumber();
  }

  MarketFact _getMockLumber() => MarketFact(
    category: "Construction",
    name: "Lumber (Sim)",
    value: "\$74.50",
    trend: "+0.8% (Sim)",
    status: "Recovering",
    lineData: [72.0, 72.5, 73.0, 72.8, 73.5, 74.0, 74.5],
  );
}