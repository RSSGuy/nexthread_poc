/*
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
}*/
/*
import 'dart:async';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'models.dart';

class FeedService {
  /// Fetches headlines using a "Race Strategy" to mitigate timeouts.
  /// 1. If Mobile/Desktop: Tries Direct fetch first.
  /// 2. If Web (or Direct fails): Races multiple proxies simultaneously.
  ///    The first one to return 200 OK wins.
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    // Process all sources in parallel
    await Future.wait(sources.map((source) async {
      try {
        final body = await _fetchContentRobustly(source.url);

        if (body != null && body.isNotEmpty) {
          final items = _parseFeed(body, source.name);

          // Filter & Add
          for (var title in items) {
            final t = title.replaceAll(RegExp(r'\s+'), ' ').trim();
            if (t.length < 5) continue;

            if (keywords.any((k) => t.toLowerCase().contains(k.toLowerCase()))) {
              headlines.add("[${source.name}] $t");
            }
          }
        }
      } catch (e) {
        // Log but don't crash - allows other sources to succeed
        // print("FeedService Source Failure (${source.name}): $e");
      }
    }));

    // Dedup & Limit
    headlines = headlines.toSet().toList();
    headlines.sort();
    if (headlines.length > 20) headlines = headlines.sublist(0, 20);

    return headlines;
  }

  // --- CORE FETCH LOGIC ---

  Future<String?> _fetchContentRobustly(String url) async {
    // STRATEGY 1: Direct Fetch (Mobile/Desktop only)
    // CORS proxies are only needed for Web browsers.
    if (!kIsWeb) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) return response.body;
      } catch (e) {
        // Fallthrough to proxies if direct fails (rare, but possible with firewalls)
      }
    }

    // STRATEGY 2: Proxy Race (Web & Fallback)
    // We fire multiple requests at once. First valid 200 OK wins.
    final proxies = [
      "https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}",
      "https://corsproxy.io/?${Uri.encodeComponent(url)}",
      // "https://thingproxy.freeboard.io/fetch/${Uri.encodeComponent(url)}", // Optional backup
    ];

    try {
      // Create a list of futures that return the body IF status is 200, else throw
      final futures = proxies.map((proxyUrl) async {
        final response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception("Status ${response.statusCode}");
        }
      });

      // Future.any returns the first value to complete (if we wrapped errors correctly).
      // However, Future.any throws if the *first* one fails.
      // We need a robust "first successful" implementation.
      return await _raceToSuccess(futures);
    } catch (e) {
      // All proxies failed
      print("FeedService: All proxies failed for $url");
      return null;
    }
  }

  // Helper: Returns the first Future to complete successfully.
  // Ignores failures unless ALL fail.
  Future<T> _raceToSuccess<T>(Iterable<Future<T>> futures) {
    final completer = Completer<T>();
    int pendingCount = futures.length;

    if (pendingCount == 0) {
      completer.completeError(Exception("No futures to race"));
      return completer.future;
    }

    for (final future in futures) {
      future.then((value) {
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      }).catchError((e) {
        pendingCount--;
        if (pendingCount == 0 && !completer.isCompleted) {
          completer.completeError(Exception("All candidates failed"));
        }
      });
    }

    return completer.future;
  }

  // --- PARSING LOGIC (RSS -> Atom -> Regex) ---

  List<String> _parseFeed(String body, String sourceName) {
    List<String> items = [];

    // 1. RSS
    try {
      final rss = RssFeed.parse(body);
      if (rss.items != null) {
        return rss.items!.map((item) => item.title ?? "").toList();
      }
    } catch (_) {}

    // 2. Atom
    try {
      final atom = AtomFeed.parse(body);
      if (atom.items != null) {
        return atom.items!.map((item) => item.title ?? "").toList();
      }
    } catch (_) {}

    // 3. Regex Fallback (Dirty Read)
    try {
      final regExp = RegExp(r'<title.*?>(.*?)</title>', caseSensitive: false, dotAll: true);
      final matches = regExp.allMatches(body);

      for (final match in matches) {
        var rawTitle = match.group(1) ?? "";
        // Basic cleanup
        rawTitle = rawTitle.replaceAll('<![CDATA[', '').replaceAll(']]>', '');
        rawTitle = rawTitle.replaceAll(RegExp(r'<[^>]*>'), ''); // Remove HTML
        rawTitle = rawTitle.replaceAll(RegExp(r'\s+'), ' ').trim();

        if (rawTitle.isNotEmpty && rawTitle.toLowerCase() != 'home') {
          items.add(rawTitle);
        }
      }
      if (items.isNotEmpty) {
        print("FeedService: Recovered ${items.length} items via Regex for $sourceName");
      }
    } catch (_) {}

    return items;
  }
}*/

/*
import 'dart:async';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'models.dart';

/// Result object for the tester utility
class FeedHealthResult {
  final String sourceName;
  final String url;
  final bool isSuccess;
  final int latencyMs;
  final int itemsFound;
  final String statusMessage; // e.g., "Direct (200 OK)" or "Proxy (RSS)"
  final String? error;

  FeedHealthResult({
    required this.sourceName,
    required this.url,
    required this.isSuccess,
    required this.latencyMs,
    required this.itemsFound,
    required this.statusMessage,
    this.error,
  });
}

class FeedService {
  /// Fetches headlines using a "Race Strategy" to mitigate timeouts.
  /// 1. If Mobile/Desktop: Tries Direct fetch first.
  /// 2. If Web (or Direct fails): Races multiple proxies simultaneously.
  ///    The first one to return 200 OK wins.
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    // Process all sources in parallel
    await Future.wait(sources.map((source) async {
      try {
        final body = await _fetchContentRobustly(source.url);

        if (body != null && body.isNotEmpty) {
          final items = _parseFeed(body, source.name);

          // Filter & Add
          for (var title in items) {
            final t = title.replaceAll(RegExp(r'\s+'), ' ').trim();
            if (t.length < 5) continue;

            if (keywords.any((k) => t.toLowerCase().contains(k.toLowerCase()))) {
              headlines.add("[${source.name}] $t");
            }
          }
        }
      } catch (e) {
        // Log but don't crash - allows other sources to succeed
        // print("FeedService Source Failure (${source.name}): $e");
      }
    }));

    // Dedup & Limit
    headlines = headlines.toSet().toList();
    headlines.sort();
    if (headlines.length > 20) headlines = headlines.sublist(0, 20);

    return headlines;
  }

  /// Diagnostic method for the Feed Tester Utility
  /// Returns detailed metadata about the connection attempt rather than just the content.
  Future<FeedHealthResult> diagnoseFeed(NewsSourceConfig source) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Reuse the robust fetching logic (Direct -> Proxy Race)
      final body = await _fetchContentRobustly(source.url);
      stopwatch.stop();

      if (body == null || body.isEmpty) {
        return FeedHealthResult(
          sourceName: source.name,
          url: source.url,
          isSuccess: false,
          latencyMs: stopwatch.elapsedMilliseconds,
          itemsFound: 0,
          statusMessage: "Connection Failed",
          error: "All fetch strategies (Direct & Proxy) returned empty/null.",
        );
      }

      // Diagnose Parser
      final items = _parseFeed(body, source.name);
      final parseType = _detectFeedType(body);

      return FeedHealthResult(
        sourceName: source.name,
        url: source.url,
        isSuccess: items.isNotEmpty,
        latencyMs: stopwatch.elapsedMilliseconds,
        itemsFound: items.length,
        statusMessage: items.isNotEmpty
            ? "OK ($parseType)"
            : "Empty ($parseType detected but no items)",
        error: items.isEmpty ? "Parsed content but found 0 items." : null,
      );

    } catch (e) {
      stopwatch.stop();
      return FeedHealthResult(
        sourceName: source.name,
        url: source.url,
        isSuccess: false,
        latencyMs: stopwatch.elapsedMilliseconds,
        itemsFound: 0,
        statusMessage: "Exception",
        error: e.toString(),
      );
    }
  }

  String _detectFeedType(String body) {
    if (body.contains('<rss') || body.contains('<channel')) return 'RSS';
    if (body.contains('<feed') && body.contains('xmlns="http://www.w3.org/2005/Atom"')) return 'Atom';
    if (body.contains('<html')) return 'HTML (Scraping needed)';
    return 'Unknown';
  }

  // --- CORE FETCH LOGIC ---

  Future<String?> _fetchContentRobustly(String url) async {
    // STRATEGY 1: Direct Fetch (Mobile/Desktop only)
    // CORS proxies are only needed for Web browsers.
    if (!kIsWeb) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) return response.body;
      } catch (e) {
        // Fallthrough to proxies if direct fails (rare, but possible with firewalls)
      }
    }

    // STRATEGY 2: Proxy Race (Web & Fallback)
    // We fire multiple requests at once. First valid 200 OK wins.
    final proxies = [
      "https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}",
      "https://corsproxy.io/?${Uri.encodeComponent(url)}",
      // "https://thingproxy.freeboard.io/fetch/${Uri.encodeComponent(url)}", // Optional backup
    ];

    try {
      // Create a list of futures that return the body IF status is 200, else throw
      final futures = proxies.map((proxyUrl) async {
        final response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception("Status ${response.statusCode}");
        }
      });

      // Future.any returns the first value to complete (if we wrapped errors correctly).
      // However, Future.any throws if the *first* one fails.
      // We need a robust "first successful" implementation.
      return await _raceToSuccess(futures);
    } catch (e) {
      // All proxies failed
      // print("FeedService: All proxies failed for $url");
      return null;
    }
  }

  // Helper: Returns the first Future to complete successfully.
  // Ignores failures unless ALL fail.
  Future<T> _raceToSuccess<T>(Iterable<Future<T>> futures) {
    final completer = Completer<T>();
    int pendingCount = futures.length;

    if (pendingCount == 0) {
      completer.completeError(Exception("No futures to race"));
      return completer.future;
    }

    for (final future in futures) {
      future.then((value) {
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      }).catchError((e) {
        pendingCount--;
        if (pendingCount == 0 && !completer.isCompleted) {
          completer.completeError(Exception("All candidates failed"));
        }
      });
    }

    return completer.future;
  }

  // --- PARSING LOGIC (RSS -> Atom -> Regex) ---

  List<String> _parseFeed(String body, String sourceName) {
    List<String> items = [];

    // 1. RSS
    try {
      final rss = RssFeed.parse(body);
      if (rss.items != null) {
        return rss.items!.map((item) => item.title ?? "").toList();
      }
    } catch (_) {}

    // 2. Atom
    try {
      final atom = AtomFeed.parse(body);
      if (atom.items != null) {
        return atom.items!.map((item) => item.title ?? "").toList();
      }
    } catch (_) {}

    // 3. Regex Fallback (Dirty Read)
    try {
      final regExp = RegExp(r'<title.*?>(.*?)</title>', caseSensitive: false, dotAll: true);
      final matches = regExp.allMatches(body);

      for (final match in matches) {
        var rawTitle = match.group(1) ?? "";
        // Basic cleanup
        rawTitle = rawTitle.replaceAll('<![CDATA[', '').replaceAll(']]>', '');
        rawTitle = rawTitle.replaceAll(RegExp(r'<[^>]*>'), ''); // Remove HTML
        rawTitle = rawTitle.replaceAll(RegExp(r'\s+'), ' ').trim();

        if (rawTitle.isNotEmpty && rawTitle.toLowerCase() != 'home') {
          items.add(rawTitle);
        }
      }
      if (items.isNotEmpty) {
        // print("FeedService: Recovered ${items.length} items via Regex for $sourceName");
      }
    } catch (_) {}

    return items;
  }
}*/
import 'dart:async';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'models.dart';

class FeedService {
  /// Fetches headlines using a "Race Strategy" to mitigate timeouts.
  Future<List<String>> fetchHeadlines(List<NewsSourceConfig> sources, List<String> keywords) async {
    List<String> headlines = [];

    // Process all sources in parallel
    await Future.wait(sources.map((source) async {
      try {
        final body = await _fetchContentRobustly(source.url);

        if (body != null && body.isNotEmpty) {
          final items = _parseFeed(body, source.name);

          // Filter & Add
          for (var title in items) {
            final t = title.replaceAll(RegExp(r'\s+'), ' ').trim();
            if (t.length < 5) continue;

            if (keywords.any((k) => t.toLowerCase().contains(k.toLowerCase()))) {
              headlines.add("[${source.name}] $t");
            }
          }
        }
      } catch (e) {
        // Log but don't crash
      }
    }));

    // Dedup & Limit
    headlines = headlines.toSet().toList();
    headlines.sort();
    if (headlines.length > 20) headlines = headlines.sublist(0, 20);

    return headlines;
  }

  /// Diagnostic method for the Feed Tester Utility
  Future<FeedHealthResult> diagnoseFeed(NewsSourceConfig source) async {
    final stopwatch = Stopwatch()..start();

    try {
      final body = await _fetchContentRobustly(source.url);
      stopwatch.stop();

      if (body == null || body.isEmpty) {
        return FeedHealthResult(
          sourceName: source.name,
          url: source.url,
          isSuccess: false,
          latencyMs: stopwatch.elapsedMilliseconds,
          itemsFound: 0,
          statusMessage: "Connection Failed",
          error: "All fetch strategies (Direct & Proxy) returned empty/null.",
        );
      }

      // Diagnose Parser
      final items = _parseFeed(body, source.name);
      final parseType = _detectFeedType(body);

      return FeedHealthResult(
        sourceName: source.name,
        url: source.url,
        isSuccess: items.isNotEmpty,
        latencyMs: stopwatch.elapsedMilliseconds,
        itemsFound: items.length,
        statusMessage: items.isNotEmpty
            ? "OK ($parseType)"
            : "Empty ($parseType detected but no items)",
        error: items.isEmpty ? "Parsed content but found 0 items." : null,
      );

    } catch (e) {
      stopwatch.stop();
      return FeedHealthResult(
        sourceName: source.name,
        url: source.url,
        isSuccess: false,
        latencyMs: stopwatch.elapsedMilliseconds,
        itemsFound: 0,
        statusMessage: "Exception",
        error: e.toString(),
      );
    }
  }

  String _detectFeedType(String body) {
    if (body.contains('<rss') || body.contains('<channel')) return 'RSS';
    if (body.contains('<feed') && body.contains('xmlns="http://www.w3.org/2005/Atom"')) return 'Atom';
    if (body.contains('<html')) return 'HTML (Scraping needed)';
    return 'Unknown';
  }

  // --- CORE FETCH LOGIC ---

  Future<String?> _fetchContentRobustly(String url) async {
    // STRATEGY 1: Direct Fetch (Mobile/Desktop only)
    if (!kIsWeb) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) return response.body;
      } catch (e) {
        // Fallthrough
      }
    }

    // STRATEGY 2: Proxy Race (Web & Fallback)
    final proxies = [
      "https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}",
      "https://corsproxy.io/?${Uri.encodeComponent(url)}",
    ];

    try {
      final futures = proxies.map((proxyUrl) async {
        final response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Exception("Status ${response.statusCode}");
        }
      });

      return await _raceToSuccess(futures);
    } catch (e) {
      return null;
    }
  }

  Future<T> _raceToSuccess<T>(Iterable<Future<T>> futures) {
    final completer = Completer<T>();
    int pendingCount = futures.length;

    if (pendingCount == 0) {
      completer.completeError(Exception("No futures to race"));
      return completer.future;
    }

    for (final future in futures) {
      future.then((value) {
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      }).catchError((e) {
        pendingCount--;
        if (pendingCount == 0 && !completer.isCompleted) {
          completer.completeError(Exception("All candidates failed"));
        }
      });
    }

    return completer.future;
  }

  List<String> _parseFeed(String body, String sourceName) {
    List<String> items = [];

    // 1. RSS
    try {
      final rss = RssFeed.parse(body);
      if (rss.items != null) {
        return rss.items!.map((item) => item.title ?? "").toList();
      }
    } catch (_) {}

    // 2. Atom
    try {
      final atom = AtomFeed.parse(body);
      if (atom.items != null) {
        return atom.items!.map((item) => item.title ?? "").toList();
      }
    } catch (_) {}

    // 3. Regex Fallback
    try {
      final regExp = RegExp(r'<title.*?>(.*?)</title>', caseSensitive: false, dotAll: true);
      final matches = regExp.allMatches(body);

      for (final match in matches) {
        var rawTitle = match.group(1) ?? "";
        rawTitle = rawTitle.replaceAll('<![CDATA[', '').replaceAll(']]>', '');
        rawTitle = rawTitle.replaceAll(RegExp(r'<[^>]*>'), ''); // Remove HTML
        rawTitle = rawTitle.replaceAll(RegExp(r'\s+'), ' ').trim();

        if (rawTitle.isNotEmpty && rawTitle.toLowerCase() != 'home') {
          items.add(rawTitle);
        }
      }
    } catch (_) {}

    return items;
  }
}