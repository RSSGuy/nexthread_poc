import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models.dart';
import '../../../secrets.dart';

class AgTechService {
  static const Duration _apiTimeout = Duration(seconds: 20);

  // --- CACHE VARIABLES ---
  static MarketFact? _cachedAgTech;
  static DateTime? _lastAgTechFetch;

  Future<MarketFact> getAgTechFact() async {
    // 1. Check Cache
    if (_cachedAgTech != null &&
        _lastAgTechFetch != null &&
        DateTime.now().difference(_lastAgTechFetch!).inMinutes < 5) {
      print("AgTechService: Returning CACHED Data");
      return _cachedAgTech!;
    }

    if (!Secrets.eodhdApiKey.contains("66") && Secrets.eodhdApiKey.length < 10) {
      return _getMockAgTech();
    }

    try {
      // MOO.US (VanEck Agribusiness) covers Machinery, Chemicals, and Animal Health
      const symbol = "MOO.US";

      final rtUrl = 'https://eodhd.com/api/real-time/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json';
      final rtProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(rtUrl)}");

      // Fetch 90 days history
      final fromDate = DateTime.now().subtract(const Duration(days: 90));
      final fromStr = "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}";
      final histUrl = 'https://eodhd.com/api/eod/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json&from=$fromStr&period=d';
      final histProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(histUrl)}");

      print("AgTechService: Fetching $symbol...");

      final results = await Future.wait([
        http.get(rtProxy).timeout(_apiTimeout),
        http.get(histProxy).timeout(_apiTimeout),
      ]);

      final rtResponse = results[0];
      final histResponse = results[1];

      if (rtResponse.statusCode == 200 && histResponse.statusCode == 200) {
        // Parse RT
        final dynamic rtJson = json.decode(rtResponse.body);
        if (rtJson is Map && (rtJson.containsKey('status') || rtJson.containsKey('message'))) {
          return _getMockAgTech();
        }
        final data = rtJson as Map<String, dynamic>;
        final double price = (data['close'] as num).toDouble();
        final double changeP = (data['change_p'] as num?)?.toDouble() ?? 0.0;
        final String valueStr = "\$${price.toStringAsFixed(2)}";

        String status = "Stable";
        if (changeP > 1.5) status = "Heated";
        if (changeP < -1.5) status = "Cooling";

        // Parse History
        List<dynamic> histList = json.decode(histResponse.body);
        List<double> history = histList.map((e) => (e['close'] as num).toDouble()).toList();

        final fact = MarketFact(
          category: "Agriculture",
          name: "AgTech (MOO ETF)",
          value: valueStr,
          trend: "${changeP >= 0 ? '+' : ''}${changeP.toStringAsFixed(2)}%",
          status: status,
          lineData: history,
        );

        _cachedAgTech = fact;
        _lastAgTechFetch = DateTime.now();
        return fact;
      }
    } catch (e) {
      print("AgTechService Error: $e");
    }

    return _getMockAgTech();
  }

  MarketFact _getMockAgTech() => MarketFact(
    category: "Agriculture",
    name: "AgTech (Sim)",
    value: "\$72.40",
    trend: "+1.1% (Sim)",
    status: "Rising",
    lineData: [70.0, 70.5, 71.2, 71.0, 71.8, 72.0, 72.4],
  );
}