import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webfeed_plus/webfeed_plus.dart';

class LocalFeedService {

  /// Loads and parses a specific local XML file from assets.
  Future<List<String>> getHeadlinesFromPath(String filePath, List<String> keywords) async {
    try {
      // 1. Load string from assets
      final xmlString = await rootBundle.loadString(filePath);

      List<String> items = [];

      // 2. Parse (Try RSS then Atom)
      try {
        final rss = RssFeed.parse(xmlString);
        if (rss.items != null) {
          items = rss.items!.map((item) => item.title ?? "").toList();
        }
      } catch (_) {
        try {
          final atom = AtomFeed.parse(xmlString);
          if (atom.items != null) {
            items = atom.items!.map((item) => item.title ?? "").toList();
          }
        } catch (_) {
          // Basic Regex fallback
          final regExp = RegExp(r'<title.*?>(.*?)</title>', caseSensitive: false, dotAll: true);
          final matches = regExp.allMatches(xmlString);
          items = matches.map((m) => m.group(1) ?? "").toList();
        }
      }

      // 3. Filter by keywords
      List<String> relevant = [];
      for (var title in items) {
        final t = title.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (t.isEmpty) continue;

        // If keywords are provided, filter. If empty (generic fallback), return all.
        if (keywords.isEmpty || keywords.any((k) => t.toLowerCase().contains(k.toLowerCase()))) {
          relevant.add("[Local File] $t");
        }
      }

      return relevant;

    } catch (e) {
      print("LocalFeedService Error loading $filePath: $e");
      return ["[System] Unable to load selected archive."];
    }
  }
}