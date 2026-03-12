
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:intl/intl.dart';
import '../../core/models.dart';
import '../../core/market_data_provider.dart';
import '../../core/local_feed_service.dart';
import '../../core/ai_service.dart';
import '../../core/storage_service.dart';
import '../dialogs/fallback_selector_dialog.dart';
import '../widgets/market_pulse_row.dart'; // Import the reusable widget

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

  // Analysis Data
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
        if (data['content'] is Map) {
          _analysisResult = Map<String, dynamic>.from(data['content']);
        } else if (data['content'] is String) {
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

  // UPDATED: Robust Analysis Method (Handles String/Map return types)
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

      // 1. Get raw result (handles both String and Map returns from Service)
      final dynamic rawResult = await _aiService.analyzeGlobalTrends(aggregatedNews, globalData);

      // 2. Normalize to Map
      Map<String, dynamic> structuredResult;
      if (rawResult is String) {
        structuredResult = {
          'summary': rawResult,
          'expansions': []
        };
      } else {
        structuredResult = Map<String, dynamic>.from(rawResult as Map);
      }

      // 3. Inject Debug Info
      structuredResult['debug_headlines'] = aggregatedNews;
      structuredResult['debug_sources'] = _selectedPaths;
      structuredResult['timestamp'] = DateTime.now().toIso8601String();

      // 4. Save
      await StorageService.saveGlobalAnalysis(structuredResult);

      if (mounted) {
        setState(() {
          _analysisResult = structuredResult;
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

  void _showLogicModal(BuildContext context) {
    if (_analysisResult == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _LogicModalContent(
            data: _analysisResult!,
            controller: scrollController
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LEFT COLUMN (Fixed Width 500px) ---
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

                // UPDATED: Now uses MarketPulseRow for each benchmark
                FutureBuilder<MarketFact>(
                  future: _marketDataFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    final facts = snapshot.data!.subFacts;
                    return Column(
                      children: facts.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: MarketPulseRow(fact: f),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // --- RIGHT COLUMN: ANALYSIS CONTENT ---
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Generated: ${DateFormat('MMM d, h:mm a').format(_lastUpdated!)}",
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: () => _showLogicModal(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFC7D2FE)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                                  SizedBox(width: 4),
                                  Text("LOGIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                                ],
                              ),
                            ),
                          ),
                        ],
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
}

class _LogicModalContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final ScrollController controller;
  const _LogicModalContent({required this.data, required this.controller});

  @override Widget build(BuildContext context) {
    final sources = (data['debug_sources'] as List?) ?? [];
    final headlines = (data['debug_headlines'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: ListView(
        controller: controller,
        children: [
          const Text("AI Logic Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("This panel shows the exact data fed into the Global Strategy AI.", style: TextStyle(fontSize: 13, color: Colors.grey)),
          const Divider(height: 32),

          const Text("Active Feed Sources:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (sources.isEmpty)
            const Text("No sources recorded.", style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sources.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                child: Text(s.toString().split('/').last, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
              )).toList(),
            ),

          const SizedBox(height: 24),
          Row(
            children: [
              const Text("Aggregated Headlines", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(12)),
                child: Text("${headlines.length}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
              )
            ],
          ),
          const SizedBox(height: 8),
          if (headlines.isEmpty)
            const Text("No headlines available.", style: TextStyle(fontSize: 13, color: Colors.grey))
          else
            ...headlines.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text("• $h", style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4))
            )),
        ],
      ),
    );
  }
}