import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import '../../core/models.dart';
import '../../core/market_data_provider.dart';
import '../../core/topic_config.dart';
import '../../core/ai_service.dart';
import '../../core/storage_service.dart';

class GlobalIndicesDialog extends StatefulWidget {
  final List<TopicConfig> topics;

  const GlobalIndicesDialog({
    super.key,
    required this.topics,
  });

  static void show(BuildContext context, List<TopicConfig> topics) {
    showDialog(
      context: context,
      builder: (context) => GlobalIndicesDialog(topics: topics),
    );
  }

  @override
  State<GlobalIndicesDialog> createState() => _GlobalIndicesDialogState();
}

class _GlobalIndicesDialogState extends State<GlobalIndicesDialog> {
  bool _isAnalyzing = false;
  String? _analysisResult;
  DateTime? _analysisTimestamp;

  late Future<MarketFact> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = MarketDataProvider().getGlobalBenchmarks();
    _loadSavedAnalysis();
  }

  // --- UPDATED: Handle Map or String content ---
  void _loadSavedAnalysis() {
    final data = StorageService.getGlobalAnalysis();
    if (data != null) {
      setState(() {
        final content = data['content'];

        // Handle the new Map structure or legacy String
        if (content is Map) {
          _analysisResult = content['summary'] as String?;
        } else if (content is String) {
          _analysisResult = content;
        }

        if (data['timestamp'] != null) {
          _analysisTimestamp = DateTime.parse(data['timestamp'] as String);
        }
      });
    }
  }

  void _runGlobalAnalysis(MarketFact globalData) async {
    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      // 1. Get String result from AI
      final result = await AIService().analyzeGlobalMarket(widget.topics, globalData);

      // 2. Wrap in Map to satisfy StorageService requirements
      final mapToSave = {
        'summary': result,
        'expansions': [], // Empty for this view
      };

      await StorageService.saveGlobalAnalysis(mapToSave);

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _analysisTimestamp = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analysisResult = "Analysis Failed: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width > 600 ? 600.0 : double.maxFinite;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.public, color: Color(0xFF6366F1)),
          SizedBox(width: 8),
          Text("Global Market Indices"),
        ],
      ),
      content: SizedBox(
        width: width,
        height: 500,
        child: FutureBuilder<MarketFact>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.subFacts.isEmpty) {
              return const Center(child: Text("No global data available."));
            }

            final marketFact = snapshot.data!;
            final indices = marketFact.subFacts;

            return Column(
              children: [
                Expanded(
                  flex: 4,
                  child: ListView.builder(
                    itemCount: indices.length,
                    itemBuilder: (context, index) {
                      final fact = indices[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildRow(fact),
                      );
                    },
                  ),
                ),

                const Divider(height: 24, thickness: 1),

                Expanded(
                  flex: 3,
                  child: _buildAnalysisSection(marketFact),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }

  Widget _buildAnalysisSection(MarketFact globalData) {
    if (_isAnalyzing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 12),
            Text("Analyzing global feeds..."),
          ],
        ),
      );
    }

    if (_analysisResult != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_analysisTimestamp != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "Analysis from ${_formatTime(_analysisTimestamp!)}",
                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _runGlobalAnalysis(globalData),
                      child: const Icon(Icons.refresh, size: 16, color: Color(0xFF6366F1)),
                    )
                  ],
                ),
              ),

            Expanded(
              child: SingleChildScrollView(
                child: MarkdownBody(
                  data: _analysisResult!,
                  styleSheet: MarkdownStyleSheet(
                    h2: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
                    p: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF334155)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _runGlobalAnalysis(globalData),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text("Analyze World Market State"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $period";
  }

  Widget _buildRow(MarketFact fact) {
    final isUp = !fact.trend.startsWith('-');
    final trendColor = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fact.name,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B)
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                  fact.value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(icon, size: 14, color: trendColor),
                  const SizedBox(width: 2),
                  Text(
                      fact.trend,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: trendColor
                      )
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}