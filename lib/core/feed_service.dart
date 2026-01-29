import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'models.dart';

class FeedService {
  /// Fetches and parses headlines from multiple sources, filtering by keywords.
  /// Handles CORS proxies and RSS/Atom format detection automatically.
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    await Future.wait(sources.map((source) async {
      try {
        // 1. Try Primary Proxy (AllOrigins)
        var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
        var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));

        // 2. Fallback Proxy (CorsProxy)
        if (response.statusCode != 200) {
          proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
          response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 10));
        }

        if (response.statusCode == 200) {
          final body = response.body;
          List<String> items = [];

          // 3. Parse (Try RSS, then Atom)
          try {
            final rss = RssFeed.parse(body);
            if (rss.items != null) {
              items = rss.items!.map((item) => item.title ?? "").toList();
            }
          } catch (e) {
            try {
              final atom = AtomFeed.parse(body);
              if (atom.items != null) {
                items = atom.items!.map((item) => item.title ?? "").toList();
              }
            } catch (e2) {
              print("FeedService Parse Error (${source.name}): Not valid RSS or Atom");
            }
          }

          // 4. Filter & Format
          for (var title in items) {
            final t = title.replaceAll(RegExp(r'\s+'), ' ').trim();
            if (t.isEmpty) continue;

            // Case-insensitive keyword check
            if (keywords.any((k) => t.toLowerCase().contains(k.toLowerCase()))) {
              headlines.add("[${source.name}] $t");
            }
          }
        }
      } catch (e) {
        print("FeedService Error (${source.name}): $e");
      }
    }));

    // 5. Dedup & Limit
    headlines = headlines.toSet().toList();
    headlines.sort();
    if (headlines.length > 15) headlines = headlines.sublist(0, 15);

    return headlines;
  }
}