import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart'; // Uses the robust parser
import 'package:google_fonts/google_fonts.dart';
import '../../core/models.dart';
import '../../core/news_registry.dart';

class FeedDebugScreen extends StatefulWidget {
  const FeedDebugScreen({super.key});

  @override
  State<FeedDebugScreen> createState() => _FeedDebugScreenState();
}

class _FeedDebugScreenState extends State<FeedDebugScreen> {
  // Store test results mapped by Source Name
  final Map<String, _TestResult> _results = {};
  bool _testing = false;
  int _successCount = 0;
  int _failCount = 0;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _testing = true;
      _results.clear();
      _successCount = 0;
      _failCount = 0;
    });

    // Test all sources in registry
    final sources = NewsRegistry.all;

    for (var source in sources) {
      // Mark as loading initially
      setState(() {
        _results[source.name] = _TestResult(status: _Status.loading, message: "Connecting...");
      });

      // Run the test
      final result = await _testSingleSource(source);

      // Update UI with result
      if (mounted) {
        setState(() {
          _results[source.name] = result;
          if (result.status == _Status.success || result.status == _Status.warning) {
            _successCount++;
          } else {
            _failCount++;
          }
        });
      }
    }

    if (mounted) {
      setState(() => _testing = false);
    }
  }

  Future<_TestResult> _testSingleSource(NewsSourceConfig source) async {
    try {
      // 1. Try AllOrigins Proxy (Best for Text/HTML scraping)
      var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
      var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));

      // 2. Fallback to CorsProxy (Better for binary/strict XML)
      if (response.statusCode != 200) {
        proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
        response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
      }

      if (response.statusCode == 200) {
        final body = response.body;
        int itemsFound = 0;

        // STRATEGY A: Try Standard RSS 2.0
        try {
          final rss = RssFeed.parse(body);
          itemsFound = rss.items?.length ?? 0;
          if (itemsFound > 0) {
            return _TestResult(status: _Status.success, message: "OK (RSS: $itemsFound)");
          }
        } catch (_) {
          // Not RSS, ignore and try Atom
        }

        // STRATEGY B: Try Atom 1.0 (Common for Gov/Tech feeds)
        try {
          final atom = AtomFeed.parse(body);
          itemsFound = atom.items?.length ?? 0;
          if (itemsFound > 0) {
            return _TestResult(status: _Status.success, message: "OK (Atom: $itemsFound)");
          }
        } catch (_) {
          // Not Atom, ignore and try Fallback
        }

        // STRATEGY C: Dirty Regex Fallback
        // If strict parsing failed, scan for <title> tags to see if data exists
        // This usually catches HTML pages or broken XML feeds.
        final titleRegex = RegExp(r'<title>(.*?)</title>', caseSensitive: false);
        final matches = titleRegex.allMatches(body);

        // We look for >2 matches because web pages usually have at least 1 title tag (the page title)
        if (matches.length > 2) {
          return _TestResult(
              status: _Status.warning,
              message: "Unstable (Regex found ${matches.length})"
          );
        }

        return _TestResult(status: _Status.error, message: "Empty / Invalid Fmt");
      } else {
        return _TestResult(status: _Status.error, message: "HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      return _TestResult(status: _Status.error, message: "Timeout / Network Fail");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feed Health Monitor", style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testing ? null : _runDiagnostics,
          )
        ],
      ),
      body: Column(
        children: [
          // SUMMARY DASHBOARD
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("Total", NewsRegistry.all.length, Colors.black),
                _buildSummaryItem("Active", _successCount, const Color(0xFF10B981)), // Green
                _buildSummaryItem("Broken", _failCount, const Color(0xFFEF4444)),    // Red
              ],
            ),
          ),
          const Divider(height: 1),

          // DETAILED LIST
          Expanded(
            child: ListView.separated(
              itemCount: NewsRegistry.all.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final source = NewsRegistry.all[index];
                final result = _results[source.name] ?? _TestResult(status: _Status.pending, message: "Waiting...");

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: _buildStatusIcon(result.status),
                  title: Text(source.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      source.url,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  trailing: Text(
                      result.message,
                      style: TextStyle(
                          color: _getColor(result.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12
                      )
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStatusIcon(_Status status) {
    switch (status) {
      case _Status.loading:
        return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
      case _Status.success:
        return const Icon(Icons.check_circle, color: Color(0xFF10B981));
      case _Status.warning:
        return const Icon(Icons.warning_amber_rounded, color: Colors.orange);
      case _Status.error:
        return const Icon(Icons.error_outline, color: Color(0xFFEF4444));
      case _Status.pending:
        return const Icon(Icons.circle_outlined, color: Colors.grey);
    }
  }

  Color _getColor(_Status status) {
    switch (status) {
      case _Status.success: return const Color(0xFF10B981);
      case _Status.warning: return Colors.orange;
      case _Status.error: return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }
}

enum _Status { pending, loading, success, warning, error }

class _TestResult {
  final _Status status;
  final String message;
  _TestResult({required this.status, required this.message});
}