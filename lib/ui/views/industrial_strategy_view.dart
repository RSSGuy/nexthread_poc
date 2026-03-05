/*
import 'package:flutter/material.dart';

class IndustrialStrategyView extends StatelessWidget {
  const IndustrialStrategyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Industrial Strategy Consultant\n(Cross-Sector Analysis coming soon)",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}*/

// lib/ui/views/industrial_strategy_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/strategy_consultant_service.dart';

class IndustrialStrategyView extends StatefulWidget {
  const IndustrialStrategyView({super.key});

  @override
  State<IndustrialStrategyView> createState() => _IndustrialStrategyViewState();
}

class _IndustrialStrategyViewState extends State<IndustrialStrategyView> {
  final StrategyConsultantService _strategyService = StrategyConsultantService();

  bool _isLoading = false;
  Map<String, dynamic>? _reportData;

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);

    final result = await _strategyService.generateIndustrialStrategyReport();

    if (mounted) {
      setState(() {
        _reportData = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. EMPTY / LOADING STATE
    if (_reportData == null && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree_outlined, size: 64, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              "Senior Industrial Strategy Consultant",
              style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Synthesize cross-sector intelligence from Cubeler Industrial News.",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateReport,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generate Intelligence Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text("Consultant is analyzing 10 sectors...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // 2. REPORT LOADED STATE
    final title = _reportData?['report_title'] ?? "Intelligence Report";
    final conclusion = _reportData?['synthesis_conclusion'] ?? "";
    final List sectors = _reportData?['sectors'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              OutlinedButton.icon(
                onPressed: _generateReport,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Regenerate"),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
              )
            ],
          ),
          const SizedBox(height: 24),

          // Sectors Grid/List
          ...sectors.map((sector) => _buildSectorCard(sector)).toList(),

          const SizedBox(height: 32),

          // Synthesis Conclusion
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text("Synthesis Conclusion & Meta-Trend", style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  conclusion,
                  style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectorCard(Map<String, dynamic> sector) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sector Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.domain, color: Color(0xFF6366F1)),
                ),
                const SizedBox(width: 12),
                Text(
                  sector['sector_name'] ?? "Unknown Sector",
                  style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32),

            // Data Points
            _buildDataRow("Development:", sector['synthesized_development']),
            const SizedBox(height: 12),
            _buildDataRow("Strategic Insight:", sector['strategic_insight'], isHighlight: true),
            const SizedBox(height: 12),
            _buildDataRow("Opportunity:", sector['opportunity'], icon: Icons.trending_up, iconColor: Colors.green),
            const SizedBox(height: 12),
            _buildDataRow("Visual Suggestion:", sector['visual_suggestion'], icon: Icons.image_outlined, iconColor: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String? text, {bool isHighlight = false, IconData? icon, Color? iconColor}) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5),
              children: [
                TextSpan(text: "$label ", style: TextStyle(fontWeight: FontWeight.bold, color: isHighlight ? const Color(0xFF6366F1) : const Color(0xFF0F172A))),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}