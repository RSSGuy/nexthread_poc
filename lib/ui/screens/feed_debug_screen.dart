import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models.dart';
import '../../core/news_registry.dart';

class FeedDebugScreen extends StatefulWidget {
  const FeedDebugScreen({super.key});

  @override
  State<FeedDebugScreen> createState() => _FeedDebugScreenState();
}

class _FeedDebugScreenState extends State<FeedDebugScreen> {
  // Store test results
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

      // Update UI
      if (mounted) {
        setState(() {
          _results[source.name] = result;
          if (result.status == _Status.success) {
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
      // 1. Try AllOrigins Proxy
      var proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(source.url)}";
      var response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));

      // 2. Fallback to CorsProxy
      if (response.statusCode != 200) {
        proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(source.url)}";
        response = await http.get(Uri.parse(proxyUrl)).timeout(const Duration(seconds: 8));
      }

      if (response.statusCode == 200) {
        // 3. Verify XML Parsing
        try {
          final document = XmlDocument.parse(response.body);
          final items = document.findAllElements('item').length + document.findAllElements('entry').length;

          if (items > 0) {
            return _TestResult(status: _Status.success, message: "OK ($items items found)");
          } else {
            return _TestResult(status: _Status.warning, message: "Empty Feed (0 items)");
          }
        } catch (e) {
          return _TestResult(status: _Status.error, message: "Invalid XML Format");
        }
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
          // SUMMARY BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("Total", NewsRegistry.all.length, Colors.black),
                _buildSummaryItem("Healthy", _successCount, Colors.green),
                _buildSummaryItem("Broken", _failCount, Colors.red),
              ],
            ),
          ),
          const Divider(height: 1),

          // LIST
          Expanded(
            child: ListView.builder(
              itemCount: NewsRegistry.all.length,
              itemBuilder: (context, index) {
                final source = NewsRegistry.all[index];
                final result = _results[source.name] ?? _TestResult(status: _Status.pending, message: "Pending...");

                return ListTile(
                  leading: _buildStatusIcon(result.status),
                  title: Text(source.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(source.url, style: TextStyle(fontSize: 10, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
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
        Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatusIcon(_Status status) {
    switch (status) {
      case _Status.loading: return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
      case _Status.success: return const Icon(Icons.check_circle, color: Colors.green);
      case _Status.warning: return const Icon(Icons.warning, color: Colors.orange);
      case _Status.error: return const Icon(Icons.error, color: Colors.red);
      case _Status.pending: return const Icon(Icons.circle_outlined, color: Colors.grey);
    }
  }

  Color _getColor(_Status status) {
    switch (status) {
      case _Status.success: return Colors.green;
      case _Status.warning: return Colors.orange;
      case _Status.error: return Colors.red;
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