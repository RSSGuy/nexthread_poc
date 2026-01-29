/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models.dart';
import '../../../secrets.dart';

class BeefService {
  static const Duration _apiTimeout = Duration(seconds: 20);

  // --- CACHE VARIABLES ---
  static MarketFact? _cachedBeef;
  static DateTime? _lastBeefFetch;

  Future<MarketFact> getBeefFact() async {
    // 1. Check Cache
    if (_cachedBeef != null &&
        _lastBeefFetch != null &&
        DateTime.now().difference(_lastBeefFetch!).inMinutes < 5) {
      print("BeefService: Returning CACHED Data");
      return _cachedBeef!;
    }

    if (!Secrets.eodhdApiKey.contains("66") && Secrets.eodhdApiKey.length < 10) {
      return _getMockBeef();
    }

    try {
      // Using COW.US (iPath Series B Bloomberg Livestock Subindex Total Return ETN)
      final symbol = "COW.US";

      final rtUrl = 'https://eodhd.com/api/real-time/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json';
      final rtProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(rtUrl)}");

      // Fetch 90 days history
      final fromDate = DateTime.now().subtract(const Duration(days: 90));
      final fromStr = "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}";
      final histUrl = 'https://eodhd.com/api/eod/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json&from=$fromStr&period=d';
      final histProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(histUrl)}");

      print("BeefService: Fetching $symbol...");

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
          return _getMockBeef();
        }
        final data = rtJson as Map<String, dynamic>;
        final double price = (data['close'] as num).toDouble();
        final double changeP = (data['change_p'] as num?)?.toDouble() ?? 0.0;
        final String valueStr = "\$${price.toStringAsFixed(2)}";

        String status = "Stable";
        if (changeP > 1.5) status = "Rising";
        if (changeP < -1.5) status = "Cooling";

        // Parse History
        List<dynamic> histList = json.decode(histResponse.body);
        List<double> history = histList.map((e) => (e['close'] as num).toDouble()).toList();

        final fact = MarketFact(
          category: "Agriculture",
          name: "Livestock (ETF)",
          value: valueStr,
          trend: "${changeP >= 0 ? '+' : ''}${changeP.toStringAsFixed(2)}%",
          status: status,
          lineData: history,
        );

        _cachedBeef = fact;
        _lastBeefFetch = DateTime.now();
        return fact;
      }
    } catch (e) {
      print("BeefService Error: $e");
    }

    return _getMockBeef();
  }

  MarketFact _getMockBeef() => MarketFact(
    category: "Agriculture",
    name: "Live Cattle (Sim)",
    value: "\$185.40",
    trend: "+0.4% (Sim)",
    status: "Stable",
    lineData: [182.0, 183.5, 184.0, 183.8, 184.5, 185.0, 185.4],
  );
}*/
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models.dart';
import '../../../secrets.dart';

class BeefService {
  static const Duration _apiTimeout = Duration(seconds: 20);

  // --- CACHE VARIABLES ---
  static MarketFact? _cachedBeef;
  static DateTime? _lastBeefFetch;

  Future<MarketFact> getBeefFact() async {
    // 1. Check Cache
    if (_cachedBeef != null &&
        _lastBeefFetch != null &&
        DateTime.now().difference(_lastBeefFetch!).inMinutes < 5) {
      print("BeefService: Returning CACHED Data");
      return _cachedBeef!;
    }

    if (!Secrets.eodhdApiKey.contains("66") && Secrets.eodhdApiKey.length < 10) {
      return _getMockBeef();
    }

    try {
      // User Request: Use Canadian Proxy COW.TO (iShares Global Agriculture)
      const symbol = "COW.TO";

      final rtUrl = 'https://eodhd.com/api/real-time/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json';
      final rtProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(rtUrl)}");

      // Fetch 90 days history
      final fromDate = DateTime.now().subtract(const Duration(days: 90));
      final fromStr = "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}";
      final histUrl = 'https://eodhd.com/api/eod/$symbol?api_token=${Secrets.eodhdApiKey}&fmt=json&from=$fromStr&period=d';
      final histProxy = Uri.parse("https://corsproxy.io/?${Uri.encodeComponent(histUrl)}");

      print("BeefService: Fetching $symbol...");

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
          return _getMockBeef();
        }
        final data = rtJson as Map<String, dynamic>;
        final double price = (data['close'] as num).toDouble();
        final double changeP = (data['change_p'] as num?)?.toDouble() ?? 0.0;

        // Note: COW.TO is in CAD
        final String valueStr = "C\$${price.toStringAsFixed(2)}";

        String status = "Stable";
        if (changeP > 1.5) status = "Rising";
        if (changeP < -1.5) status = "Cooling";

        // Parse History
        List<dynamic> histList = json.decode(histResponse.body);
        List<double> history = histList.map((e) => (e['close'] as num).toDouble()).toList();

        final fact = MarketFact(
          category: "Agriculture",
          name: "iShares Ag (COW.TO)", // UPDATED NAME
          value: valueStr,
          trend: "${changeP >= 0 ? '+' : ''}${changeP.toStringAsFixed(2)}%",
          status: status,
          lineData: history,
        );

        _cachedBeef = fact;
        _lastBeefFetch = DateTime.now();
        return fact;
      }
    } catch (e) {
      print("BeefService Error: $e");
    }

    return _getMockBeef();
  }

  MarketFact _getMockBeef() => MarketFact(
    category: "Agriculture",
    name: "Live Cattle (Sim)",
    value: "C\$65.40", // Adjusted to typical COW.TO range
    trend: "+0.4% (Sim)",
    status: "Stable",
    lineData: [64.0, 64.5, 65.0, 64.8, 65.2, 65.4, 65.4],
  );
}