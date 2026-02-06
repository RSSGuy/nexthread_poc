/*
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../core/models.dart';
import '../../core/market_data_provider.dart';
import '../../core/local_feed_service.dart';
import '../../core/ai_service.dart';

class GlobalTrendsView extends StatefulWidget {
  const GlobalTrendsView({super.key});

  @override
  State<GlobalTrendsView> createState() => _GlobalTrendsViewState();
}

class _GlobalTrendsViewState extends State<GlobalTrendsView> {
  final LocalFeedService _localFeedService = LocalFeedService();
  final AIService _aiService = AIService();

  // Available Historical Feeds
  final Map<String, String> _availableFeeds = {
    'Agriculture Headlines (Jan)': 'assets/feeds/agricultural_headlines_jan.xml',
    'Construction News (Jan)': 'assets/feeds/construction_news_jan.xml',
    'Global Trade Logistics': 'assets/feeds/global_trade_logistics_volatility.xml',
    'Manufacturing Innovation': 'assets/feeds/manufacturing_supplychain_innovation.xml',
    'Crisis News': 'assets/feeds/crisis_news.xml',
  };

  // State
  late Future<MarketFact> _marketDataFuture;
  final Set<String> _selectedFeeds = {};
  bool _isAnalyzing = false;
  String? _analysisResult;

  @override
  void initState() {
    super.initState();
    _marketDataFuture = MarketDataProvider().getGlobalBenchmarks();
  }

  void _toggleFeed(String key) {
    setState(() {
      if (_selectedFeeds.contains(key)) {
        _selectedFeeds.remove(key);
      } else {
        _selectedFeeds.add(key);
      }
    });
  }

  void _runAnalysis(MarketFact globalData) async {
    if (_selectedFeeds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one news source.")),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      List<String> aggregatedNews = [];
      for (var key in _selectedFeeds) {
        final path = _availableFeeds[key]!;
        final news = await _localFeedService.getHeadlinesFromPath(path, []);
        aggregatedNews.addAll(news.map((n) => "[$key] $n"));
      }

      final result = await _aiService.analyzeGlobalTrends(aggregatedNews, globalData);

      if (mounted) {
        setState(() {
          _analysisResult = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // MAIN LAYOUT: Row (Left Panel + Right Content)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LEFT COLUMN: CONTROLS & INDICES (Fixed Width 320px) ---
        SizedBox(
          width: 500,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Global Indices Card
                _buildSectionTitle("Market Benchmarks"),
                const SizedBox(height: 8),
                FutureBuilder<MarketFact>(
                  future: _marketDataFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    final facts = snapshot.data!.subFacts;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: facts.map((f) => _buildIndexRow(f)).toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 2. Data Sources Selector
                _buildSectionTitle("Data Sources"),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: _availableFeeds.keys.map((key) {
                      return CheckboxListTile(
                        title: Text(key, style: const TextStyle(fontSize: 13)),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        value: _selectedFeeds.contains(key),
                        activeColor: const Color(0xFF6366F1),
                        onChanged: (val) => _toggleFeed(key),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Action Button
                SizedBox(
                  width: double.infinity,
                  child: FutureBuilder<MarketFact>(
                      future: _marketDataFuture,
                      builder: (context, snapshot) {
                        return ElevatedButton.icon(
                          onPressed: (_isAnalyzing || !snapshot.hasData)
                              ? null
                              : () => _runAnalysis(snapshot.data!),
                          icon: _isAnalyzing
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.auto_awesome, size: 18),
                          label: Text(_isAnalyzing ? "Analyzing..." : "Generate Analysis"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- RIGHT COLUMN: ANALYSIS CONTENT (Expanded) ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Global Trends Executive Summary",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),

                // Content Area
                Expanded(
                  child: _analysisResult == null
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Container(
                      padding: const EdgeInsets.all(32), // Paper-like padding
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8), // Slight rounding
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: MarkdownBody(
                        data: _analysisResult!,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.5),
                          h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.5, color: Color(0xFF1E293B)),
                          h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
                          p: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF334155)),
                          blockquote: const TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(left: BorderSide(color: Color(0xFF6366F1), width: 4)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Ready to Analyze",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select data sources from the left panel\nand generate a global executive summary.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexRow(MarketFact fact) {
    final isUp = !fact.trend.startsWith('-');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(fact.name, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fact.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isUp ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  fact.trend,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUp ? const Color(0xFF166534) : const Color(0xFF991B1B)
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}*/

/*
// lib/ui/views/global_trends_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../core/models.dart';
import '../../core/market_data_provider.dart';
import '../../core/local_feed_service.dart';
import '../../core/ai_service.dart';
import '../dialogs/fallback_selector_dialog.dart';

class GlobalTrendsView extends StatefulWidget {
  const GlobalTrendsView({super.key});

  @override
  State<GlobalTrendsView> createState() => _GlobalTrendsViewState();
}

class _GlobalTrendsViewState extends State<GlobalTrendsView> {
  final LocalFeedService _localFeedService = LocalFeedService();
  final AIService _aiService = AIService();

  // State
  late Future<MarketFact> _marketDataFuture;
  List<String> _selectedPaths = [];
  bool _isAnalyzing = false;
  String? _analysisResult;

  @override
  void initState() {
    super.initState();
    _marketDataFuture = MarketDataProvider().getGlobalBenchmarks();
  }

  // Open the FallbackSelectorDialog
  void _openFeedSelector() async {
    final List<String>? paths = await FallbackSelectorDialog.show(context);
    if (paths != null) {
      setState(() {
        _selectedPaths = paths;
      });
    }
  }

  void _runAnalysis(MarketFact globalData) async {
    if (_selectedPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one news source.")),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      List<String> aggregatedNews = [];

      // Iterate through selected paths
      for (var path in _selectedPaths) {
        final fileName = path.split('/').last;
        final sourceTag = fileName.replaceAll('.xml', '').replaceAll('_', ' ').toUpperCase();

        final news = await _localFeedService.getHeadlinesFromPath(path, []);
        aggregatedNews.addAll(news.map((n) => "[$sourceTag] $n"));
      }

      final result = await _aiService.analyzeGlobalTrends(aggregatedNews, globalData);

      if (mounted) {
        setState(() {
          _analysisResult = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // MAIN LAYOUT: Row (Left Panel + Right Content)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LEFT COLUMN: CONTROLS & INDICES (Fixed Width 320px) ---
        SizedBox(
          width: 320,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 1. Data Sources Selection Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openFeedSelector,
                    icon: const Icon(Icons.playlist_add),
                    label: Text(_selectedPaths.isEmpty
                        ? "Select Feed Sources"
                        : "${_selectedPaths.length} Sources Selected"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: const Color(0xFF64748B),
                    ),
                  ),
                ),

                // Selected files list (Small text)
                if (_selectedPaths.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                    child: Text(
                      _selectedPaths.map((p) => p.split('/').last.replaceAll('.xml', '')).join(', '),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const SizedBox(height: 16),

                // 2. Action Button (MOVED TO TOP)
                SizedBox(
                  width: double.infinity,
                  child: FutureBuilder<MarketFact>(
                      future: _marketDataFuture,
                      builder: (context, snapshot) {
                        return ElevatedButton.icon(
                          onPressed: (_isAnalyzing || !snapshot.hasData)
                              ? null
                              : () => _runAnalysis(snapshot.data!),
                          icon: _isAnalyzing
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.auto_awesome, size: 18),
                          label: Text(_isAnalyzing ? "Analyzing..." : "Generate Analysis"), // Explicit Text
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        );
                      }
                  ),
                ),

                const SizedBox(height: 32),

                // 3. Global Indices Card
                _buildSectionTitle("Market Benchmarks"),
                const SizedBox(height: 8),
                FutureBuilder<MarketFact>(
                  future: _marketDataFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    final facts = snapshot.data!.subFacts;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: facts.map((f) => _buildIndexRow(f)).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // --- RIGHT COLUMN: ANALYSIS CONTENT (Expanded) ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Global Trends Executive Summary",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 16),

                // Content Area
                Expanded(
                  child: _analysisResult == null
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: MarkdownBody(
                        data: _analysisResult!,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.5),
                          h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.5, color: Color(0xFF1E293B)),
                          h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
                          p: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF334155)),
                          blockquote: const TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(left: BorderSide(color: Color(0xFF6366F1), width: 4)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Ready to Analyze",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select data sources from the left panel\nand generate a global executive summary.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexRow(MarketFact fact) {
    final isUp = !fact.trend.startsWith('-');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(fact.name, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fact.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isUp ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  fact.trend,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUp ? const Color(0xFF166534) : const Color(0xFF991B1B)
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}*/

/*
// lib/ui/views/global_trends_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../core/models.dart';
import '../../core/market_data_provider.dart';
import '../../core/local_feed_service.dart';
import '../../core/ai_service.dart';
import '../../core/storage_service.dart'; // Added StorageService
import '../dialogs/fallback_selector_dialog.dart';

class GlobalTrendsView extends StatefulWidget {
  const GlobalTrendsView({super.key});

  @override
  State<GlobalTrendsView> createState() => _GlobalTrendsViewState();
}

class _GlobalTrendsViewState extends State<GlobalTrendsView> {
  final LocalFeedService _localFeedService = LocalFeedService();
  final AIService _aiService = AIService();

  // State
  late Future<MarketFact> _marketDataFuture;
  List<String> _selectedPaths = [];
  bool _isAnalyzing = false;
  String? _analysisResult;
  DateTime? _lastUpdated; // Added timestamp state

  @override
  void initState() {
    super.initState();
    _marketDataFuture = MarketDataProvider().getGlobalBenchmarks();
    _loadSavedAnalysis(); // Load from Hive on startup
  }

  // Load persisted analysis from StorageService
  void _loadSavedAnalysis() {
    final data = StorageService.getGlobalAnalysis();
    if (data != null) {
      setState(() {
        _analysisResult = data['content'];
        if (data['timestamp'] != null) {
          _lastUpdated = DateTime.parse(data['timestamp']);
        }
      });
    }
  }

  // Open the FallbackSelectorDialog
  void _openFeedSelector() async {
    final List<String>? paths = await FallbackSelectorDialog.show(context);
    if (paths != null) {
      setState(() {
        _selectedPaths = paths;
      });
    }
  }

  void _runAnalysis(MarketFact globalData) async {
    if (_selectedPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one news source.")),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      List<String> aggregatedNews = [];

      // Iterate through selected paths
      for (var path in _selectedPaths) {
        final fileName = path.split('/').last;
        final sourceTag = fileName.replaceAll('.xml', '').replaceAll('_', ' ').toUpperCase();

        final news = await _localFeedService.getHeadlinesFromPath(path, []);
        aggregatedNews.addAll(news.map((n) => "[$sourceTag] $n"));
      }

      final result = await _aiService.analyzeGlobalTrends(aggregatedNews, globalData);

      // Save to Hive
      await StorageService.saveGlobalAnalysis(result);

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _lastUpdated = DateTime.now(); // Update timestamp locally
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LEFT COLUMN: CONTROLS & INDICES (Fixed Width 320px) ---
        SizedBox(
          width: 320,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 1. Data Sources Selection Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openFeedSelector,
                    icon: const Icon(Icons.playlist_add),
                    label: Text(_selectedPaths.isEmpty
                        ? "Select Feed Sources"
                        : "${_selectedPaths.length} Sources Selected"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: const Color(0xFF64748B),
                    ),
                  ),
                ),

                if (_selectedPaths.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                    child: Text(
                      _selectedPaths.map((p) => p.split('/').last.replaceAll('.xml', '')).join(', '),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const SizedBox(height: 16),

                // 2. Action Button (Top)
                SizedBox(
                  width: double.infinity,
                  child: FutureBuilder<MarketFact>(
                      future: _marketDataFuture,
                      builder: (context, snapshot) {
                        return ElevatedButton.icon(
                          onPressed: (_isAnalyzing || !snapshot.hasData)
                              ? null
                              : () => _runAnalysis(snapshot.data!),
                          icon: _isAnalyzing
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.auto_awesome, size: 18),
                          label: Text(_isAnalyzing ? "Analyzing..." : "Generate Analysis"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        );
                      }
                  ),
                ),

                const SizedBox(height: 32),

                // 3. Global Indices Card
                _buildSectionTitle("Market Benchmarks"),
                const SizedBox(height: 8),
                FutureBuilder<MarketFact>(
                  future: _marketDataFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    final facts = snapshot.data!.subFacts;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: facts.map((f) => _buildIndexRow(f)).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // --- RIGHT COLUMN: ANALYSIS CONTENT (Expanded) ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Global Trends Executive Summary",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    if (_lastUpdated != null)
                      Text(
                        "Report generated at: ${DateFormat('MMM d, h:mm a').format(_lastUpdated!)}",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Content Area
                Expanded(
                  child: _analysisResult == null
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: MarkdownBody(
                        data: _analysisResult!,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.5),
                          h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.5, color: Color(0xFF1E293B)),
                          h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
                          p: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF334155)),
                          blockquote: const TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(left: BorderSide(color: Color(0xFF6366F1), width: 4)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Ready to Analyze",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select data sources from the left panel\nand generate a global executive summary.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexRow(MarketFact fact) {
    final isUp = !fact.trend.startsWith('-');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(fact.name, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fact.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isUp ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  fact.trend,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUp ? const Color(0xFF166534) : const Color(0xFF991B1B)
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}*/

// lib/ui/views/global_trends_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:intl/intl.dart';
import '../../core/models.dart';
import '../../core/market_data_provider.dart';
import '../../core/local_feed_service.dart';
import '../../core/ai_service.dart';
import '../../core/storage_service.dart';
import '../dialogs/fallback_selector_dialog.dart';

class GlobalTrendsView extends StatefulWidget {
  const GlobalTrendsView({super.key});

  @override
  State<GlobalTrendsView> createState() => _GlobalTrendsViewState();
}

class _GlobalTrendsViewState extends State<GlobalTrendsView> {
  final LocalFeedService _localFeedService = LocalFeedService();
  final AIService _aiService = AIService();

  // State
  late Future<MarketFact> _marketDataFuture;
  List<String> _selectedPaths = [];
  bool _isAnalyzing = false;

  // Changed to Map to hold structured data
  Map<String, dynamic>? _analysisResult;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _marketDataFuture = MarketDataProvider().getGlobalBenchmarks();
    _loadSavedAnalysis();
  }

  void _loadSavedAnalysis() {
    final data = StorageService.getGlobalAnalysis();
    if (data != null) {
      setState(() {
        // Ensure type safety
        if (data['content'] is Map) {
          _analysisResult = Map<String, dynamic>.from(data['content']);
        } else if (data['content'] is String) {
          // Legacy string support
          _analysisResult = {'summary': data['content'], 'expansions': []};
        }

        if (data['timestamp'] != null) {
          _lastUpdated = DateTime.parse(data['timestamp']);
        }
      });
    }
  }

  void _openFeedSelector() async {
    final List<String>? paths = await FallbackSelectorDialog.show(context);
    if (paths != null) {
      setState(() {
        _selectedPaths = paths;
      });
    }
  }

  void _runAnalysis(MarketFact globalData) async {
    if (_selectedPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one news source.")),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      List<String> aggregatedNews = [];
      for (var path in _selectedPaths) {
        final fileName = path.split('/').last;
        final sourceTag = fileName.replaceAll('.xml', '').replaceAll('_', ' ').toUpperCase();
        final news = await _localFeedService.getHeadlinesFromPath(path, []);
        aggregatedNews.addAll(news.map((n) => "[$sourceTag] $n"));
      }

      // Result is now a Map
      final result = await _aiService.analyzeGlobalTrends(aggregatedNews, globalData);

      await StorageService.saveGlobalAnalysis(result);

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _lastUpdated = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LEFT COLUMN (Unchanged) ---
        SizedBox(
          width: 500,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openFeedSelector,
                    icon: const Icon(Icons.playlist_add),
                    label: Text(_selectedPaths.isEmpty
                        ? "Select Feed Sources"
                        : "${_selectedPaths.length} Sources Selected"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: const Color(0xFF64748B),
                    ),
                  ),
                ),
                if (_selectedPaths.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                    child: Text(
                      _selectedPaths.map((p) => p.split('/').last.replaceAll('.xml', '')).join(', '),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: FutureBuilder<MarketFact>(
                      future: _marketDataFuture,
                      builder: (context, snapshot) {
                        return ElevatedButton.icon(
                          onPressed: (_isAnalyzing || !snapshot.hasData)
                              ? null
                              : () => _runAnalysis(snapshot.data!),
                          icon: _isAnalyzing
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.auto_awesome, size: 18),
                          label: Text(_isAnalyzing ? "Analyzing..." : "Generate Analysis"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        );
                      }
                  ),
                ),

                const SizedBox(height: 32),
                _buildSectionTitle("Market Benchmarks"),
                const SizedBox(height: 8),
                FutureBuilder<MarketFact>(
                  future: _marketDataFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    final facts = snapshot.data!.subFacts;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: facts.map((f) => _buildIndexRow(f)).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // --- RIGHT COLUMN: ANALYSIS CONTENT (Updated) ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Global Trends Executive Summary",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    if (_lastUpdated != null)
                      Text(
                        "Report generated at: ${DateFormat('MMM d, h:mm a').format(_lastUpdated!)}",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: _analysisResult == null
                      ? _buildEmptyState()
                      : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      children: [
                        // MAIN SUMMARY CARD
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: MarkdownBody(
                            data: _analysisResult!['summary'] ?? "",
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.5),
                              h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.5, color: Color(0xFF1E293B)),
                              h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
                              p: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF334155)),
                              blockquote: const TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                              blockquoteDecoration: BoxDecoration(border: Border(left: BorderSide(color: Color(0xFF6366F1), width: 4))),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // EXPANSION TILES
                        if (_analysisResult!['expansions'] != null)
                          ...(_analysisResult!['expansions'] as List).map((exp) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  title: Text(
                                    exp['title'] ?? "Details",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                  leading: const Icon(Icons.analytics_outlined, color: Color(0xFF6366F1)),
                                  childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    MarkdownBody(
                                      data: exp['content'] ?? "",
                                      styleSheet: MarkdownStyleSheet(
                                        p: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF475569)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Ready to Analyze", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          const Text("Select data sources from the left panel\nand generate a global executive summary.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildIndexRow(MarketFact fact) {
    final isUp = !fact.trend.startsWith('-');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(fact.name, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fact.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: isUp ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(3)),
                child: Text(fact.trend, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isUp ? const Color(0xFF166534) : const Color(0xFF991B1B))),
              ),
            ],
          ),
        ],
      ),
    );
  }
}