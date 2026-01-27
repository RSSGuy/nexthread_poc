import 'dart:convert';
import 'package:http/http.dart' as http;
// UPDATED IMPORTS: Jump up 3 levels to reach lib/core and lib/secrets.dart
import '../../../core/models.dart';
import '../../../secrets.dart';

class WheatService {
  // Timeout for API calls
  static const Duration _apiTimeout = Duration(seconds: 20);

  // --- CACHE VARIABLES ---
  static MarketFact? _cachedWheat;
  static DateTime? _lastWheatFetch;

  Future<MarketFact> getWheatFact() async {
    // 1. Check Cache (Valid for 5 minutes)
    if (_cachedWheat != null &&
        _lastWheatFetch != null &&
        DateTime.now().difference(_lastWheatFetch!).inMinutes < 5) {
      print("WheatService: Returning CACHED Data");
      return _cachedWheat!;
    }

    // Check Key (Basic validation)
    if (!Secrets.eodhdApiKey.contains("66") && Secrets.eodhdApiKey.length < 10) {
      print("WheatService: Invalid EODHD Key. Using Mock.");
      return _getMockWheat();
    }

    try {
      final symbol = "WEAT.US";

      // A. REAL-TIME URL
      final rtUrl = 'https://eodhd.com/api/real-time/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json';
      final rtProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(rtUrl)}");

      // B. HISTORY URL (90 Days)
      final fromDate = DateTime.now().subtract(const Duration(days: 90));
      final fromStr = "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}";
      final histUrl = 'https://eodhd.com/api/eod/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json&from=$fromStr&period=d';
      final histProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(histUrl)}");

      print("WheatService: Fetching $symbol (RT + History)...");

      // Fetch both in parallel
      final results = await Future.wait([
        http.get(rtProxy).timeout(_apiTimeout),
        http.get(histProxy).timeout(_apiTimeout),
      ]);

      final rtResponse = results[0];
      final histResponse = results[1];

      if (rtResponse.statusCode == 200 && histResponse.statusCode == 200) {
        // 1. Parse Real-Time
        final dynamic rtJson = json.decode(rtResponse.body);

        // EODHD Error Check
        if (rtJson is Map && (rtJson.containsKey('status') || rtJson.containsKey('message'))) {
          print("WheatService: EODHD Error - ${rtJson['message']}");
          return _getMockWheat();
        }

        final data = rtJson as Map<String, dynamic>;
        final double price = (data['close'] as num).toDouble();
        final double changeP = (data['change_p'] as num?)?.toDouble() ?? 0.0;
        final String valueStr = "\$${price.toStringAsFixed(2)}";

        // Determine Status
        String status = "Stable";
        if (changeP > 2.0) status = "Spiking";
        if (changeP < -2.0) status = "Crashing";

        // 2. Parse History
        List<dynamic> histList = json.decode(histResponse.body);
        List<double> history = histList.map((e) => (e['close'] as num).toDouble()).toList();

        final fact = MarketFact(
          category: "Agriculture",
          name: "Wheat (ETF)",
          value: valueStr,
          trend: "${changeP >= 0 ? '+' : ''}${changeP.toStringAsFixed(2)}%",
          status: status,
          lineData: history,
        );

        // Save to Cache
        _cachedWheat = fact;
        _lastWheatFetch = DateTime.now();
        print("WheatService: SUCCESS. Caching result.");

        return fact;
      } else {
        print("WheatService: HTTP Error RT:${rtResponse.statusCode} / Hist:${histResponse.statusCode}");
      }
    } catch (e) {
      print("WheatService Error: $e");
    }

    return _getMockWheat();
  }

  MarketFact _getMockWheat() => MarketFact(
    category: "Agriculture",
    name: "Wheat (Simulated)",
    value: "\$5.80",
    trend: "-1.2% (Sim)",
    status: "Abundant",
    lineData: [5.85, 5.82, 5.80, 5.78, 5.75, 5.79, 5.80, 5.82, 5.85, 5.88],
  );
}