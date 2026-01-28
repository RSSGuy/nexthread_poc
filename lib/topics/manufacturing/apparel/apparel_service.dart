import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models.dart';
import '../../../secrets.dart';

class ApparelService {
  static const Duration _apiTimeout = Duration(seconds: 20);

  static MarketFact? _cachedApparel;
  static DateTime? _lastApparelFetch;

  Future<MarketFact> getApparelFact() async {
    // 1. Check Cache
    if (_cachedApparel != null &&
        _lastApparelFetch != null &&
        DateTime.now().difference(_lastApparelFetch!).inMinutes < 5) {
      return _cachedApparel!;
    }

    // Check Key
    if (!Secrets.eodhdApiKey.contains("66") && Secrets.eodhdApiKey.length < 10) {
      return _getMockApparel();
    }

    try {
      // PROXY: VF Corporation (VFC) - Represents global apparel supply chain
      final symbol = "VFC.US";

      final rtUrl = 'https://eodhd.com/api/real-time/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json';
      final rtProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(rtUrl)}");

      final fromDate = DateTime.now().subtract(const Duration(days: 90));
      final fromStr = "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}";
      final histUrl = 'https://eodhd.com/api/eod/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json&from=$fromStr&period=d';
      final histProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(histUrl)}");

      print("ApparelService: Fetching $symbol...");

      final results = await Future.wait([
        http.get(rtProxy).timeout(_apiTimeout),
        http.get(histProxy).timeout(_apiTimeout),
      ]);

      if (results[0].statusCode == 200 && results[1].statusCode == 200) {
        final dynamic rtJson = json.decode(results[0].body);

        if (rtJson is Map && (rtJson.containsKey('status') || rtJson.containsKey('message'))) {
          return _getMockApparel();
        }

        final data = rtJson as Map<String, dynamic>;
        final double price = (data['close'] as num).toDouble();
        final double changeP = (data['change_p'] as num?)?.toDouble() ?? 0.0;

        String status = "Stable";
        if (changeP < -2.5) status = "Inventory Glut"; // Common issue in apparel
        if (changeP > 2.5) status = "High Demand";

        List<dynamic> histList = json.decode(results[1].body);
        List<double> history = histList.map((e) => (e['close'] as num).toDouble()).toList();

        final fact = MarketFact(
          category: "Manufacturing",
          name: "Apparel (VFC)",
          value: "\$${price.toStringAsFixed(2)}",
          trend: "${changeP >= 0 ? '+' : ''}${changeP.toStringAsFixed(2)}%",
          status: status,
          lineData: history,
        );

        _cachedApparel = fact;
        _lastApparelFetch = DateTime.now();
        return fact;
      }
    } catch (e) {
      print("ApparelService Error: $e");
    }

    return _getMockApparel();
  }

  MarketFact _getMockApparel() => MarketFact(
    category: "Manufacturing",
    name: "Apparel (Sim)",
    value: "\$16.45",
    trend: "-3.2%",
    status: "Oversupply",
    lineData: [17.0, 16.8, 16.5, 16.2, 16.0, 16.3, 16.45],
  );
}