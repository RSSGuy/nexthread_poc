import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models.dart';
import '../../../secrets.dart';

class ChemicalService {
  static const Duration _apiTimeout = Duration(seconds: 20);

  static MarketFact? _cachedChemicals;
  static DateTime? _lastChemicalsFetch;

  Future<MarketFact> getChemicalFact() async {
    // 1. Check Cache
    if (_cachedChemicals != null &&
        _lastChemicalsFetch != null &&
        DateTime.now().difference(_lastChemicalsFetch!).inMinutes < 5) {
      return _cachedChemicals!;
    }

    // Check Key
    if (!Secrets.eodhdApiKey.contains("66") && Secrets.eodhdApiKey.length < 10) {
      return _getMockChemicals();
    }

    try {
      // PROXY: Dow Inc. (DOW.US) - Represents Industrial Chemicals/Plastics
      final symbol = "DOW.US";

      final rtUrl = 'https://eodhd.com/api/real-time/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json';
      final rtProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(rtUrl)}");

      final fromDate = DateTime.now().subtract(const Duration(days: 90));
      final fromStr = "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}";
      final histUrl = 'https://eodhd.com/api/eod/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json&from=$fromStr&period=d';
      final histProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(histUrl)}");

      print("ChemicalService: Fetching $symbol...");

      final results = await Future.wait([
        http.get(rtProxy).timeout(_apiTimeout),
        http.get(histProxy).timeout(_apiTimeout),
      ]);

      if (results[0].statusCode == 200 && results[1].statusCode == 200) {
        final dynamic rtJson = json.decode(results[0].body);

        if (rtJson is Map && (rtJson.containsKey('status') || rtJson.containsKey('message'))) {
          return _getMockChemicals();
        }

        final data = rtJson as Map<String, dynamic>;
        final double price = (data['close'] as num).toDouble();
        final double changeP = (data['change_p'] as num?)?.toDouble() ?? 0.0;

        String status = "Stable";
        // Chemicals are highly sensitive to energy prices
        if (changeP < -2.0) status = "Margin Squeeze";
        if (changeP > 2.0) status = "Strong Spread";

        List<dynamic> histList = json.decode(results[1].body);
        List<double> history = histList.map((e) => (e['close'] as num).toDouble()).toList();

        final fact = MarketFact(
          category: "Manufacturing",
          name: "Chemicals (DOW)",
          value: "\$${price.toStringAsFixed(2)}",
          trend: "${changeP >= 0 ? '+' : ''}${changeP.toStringAsFixed(2)}%",
          status: status,
          lineData: history,
        );

        _cachedChemicals = fact;
        _lastChemicalsFetch = DateTime.now();
        return fact;
      }
    } catch (e) {
      print("ChemicalService Error: $e");
    }

    return _getMockChemicals();
  }

  MarketFact _getMockChemicals() => MarketFact(
    category: "Manufacturing",
    name: "Chemicals (Sim)",
    value: "\$54.20",
    trend: "+0.5%",
    status: "Stable",
    lineData: [53.5, 53.8, 54.0, 54.1, 53.9, 54.0, 54.2],
  );
}