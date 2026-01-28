/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'ai_service.dart'; // Required for Briefing model

class BriefingCard extends StatelessWidget {
  final Briefing brief;

  const BriefingCard({super.key, required this.brief});

  void _showLogicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _LogicModalContent(brief: brief, controller: scrollController),
      ),
    );
  }

  Widget _buildFallbackBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.amber.shade300)),
      child: Row(
        children: [
          Icon(Icons.science, size: 10, color: Colors.amber.shade800),
          const SizedBox(width: 4),
          Text("SIMULATED DATA", style: TextStyle(color: Colors.amber.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(brief.subsector.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
                Row(
                  children: [
                    if (brief.isFallback) _buildFallbackBadge(),
                    _buildSeverityBadge(brief.severity),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

            // VISUALIZATION BLOCK
            Container(
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('MARKET PATH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                              const SizedBox(height: 4),
                              Text(brief.metrics.commodity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Row(
                                children: [
                                  Text(brief.metrics.price, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Text(brief.metrics.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                ],
                              )
                            ],
                          ),
                        ),
                        // Tiny Sparkline Chart
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: brief.chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: true,
                                    color: const Color(0xFF6366F1),
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // DIVERGENCE METER
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                      factScore: brief.factScore,
                      sentScore: brief.sentScore,
                      tag: brief.divergenceTag,
                      desc: brief.divergenceDesc,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showLogicModal(context),
              child: const Row(
                children: [
                  Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text("AI LOGIC & VERIFICATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color bg = severity == 'High' ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    Color text = severity == 'High' ? const Color(0xFFBE123C) : const Color(0xFF047857);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(severity.toUpperCase(), style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class DivergenceMeter extends StatelessWidget {
  final int factScore;
  final int sentScore;
  final String tag;
  final String desc;

  const DivergenceMeter({super.key, required this.factScore, required this.sentScore, required this.tag, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFF43F5E)),
              SizedBox(width: 4),
              Text("Scarcity / Crisis", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E))),
            ]),
            Row(children: [
              Text("Abundance / Glut", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              SizedBox(width: 4),
              Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final factPos = (factScore / 100) * w;
            final sentPos = (sentScore / 100) * w;
            final left = math.min(factPos, sentPos);
            final width = (factPos - sentPos).abs();

            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(width: w, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFFFFE4E6), Color(0xFFF1F5F9), Color(0xFFD1FAE5)]))),
                  Positioned(left: left, width: width, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.3), borderRadius: BorderRadius.circular(4)))),
                  Positioned(left: factPos, top: -24, child: _buildMarker("FACT", const Color(0xFF6366F1), true)),
                  Positioned(left: sentPos, bottom: -24, child: _buildMarker("SENTIMENT", const Color(0xFFF43F5E), false)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.analytics, size: 14, color: Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
          ],
        ),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildMarker(String label, Color color, bool top) {
    return FractionalTranslation(
      translation: const Offset(-0.5, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (top) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
            const SizedBox(height: 2),
            Container(width: 2, height: 8, color: color),
          ] else ...[
            Container(width: 2, height: 8, color: color),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
          ],
        ],
      ),
    );
  }
}

class _LogicModalContent extends StatelessWidget {
  final Briefing brief;
  final ScrollController controller;
  const _LogicModalContent({required this.brief, required this.controller});
  @override Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: ListView(
        controller: controller,
        children: [
          Text("AI Logic Analysis", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(brief.harness, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          const SizedBox(height: 16),
          const Text("Verified Sources:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...brief.headlines.map((h) => Padding(padding: const EdgeInsets.all(4), child: Text("• $h", style: const TextStyle(fontSize: 12))))
        ],
      ),
    );
  }
}*/
/*

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'models.dart'; // UPDATED IMPORT

class BriefingCard extends StatelessWidget {
  final Briefing brief;

  const BriefingCard({super.key, required this.brief});

  void _showLogicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _LogicModalContent(brief: brief, controller: scrollController),
      ),
    );
  }

  Widget _buildFallbackBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.amber.shade300)),
      child: Row(
        children: [
          Icon(Icons.science, size: 10, color: Colors.amber.shade800),
          const SizedBox(width: 4),
          Text("SIMULATED DATA", style: TextStyle(color: Colors.amber.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(brief.subsector.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
                Row(
                  children: [
                    if (brief.isFallback) _buildFallbackBadge(),
                    _buildSeverityBadge(brief.severity),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

            // VISUALIZATION BLOCK
            Container(
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('MARKET PATH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                              const SizedBox(height: 4),
                              Text(brief.metrics.commodity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Row(
                                children: [
                                  Text(brief.metrics.price, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Text(brief.metrics.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                ],
                              )
                            ],
                          ),
                        ),
                        // Tiny Sparkline Chart
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: brief.chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: true,
                                    color: const Color(0xFF6366F1),
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // DIVERGENCE METER
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                      factScore: brief.factScore,
                      sentScore: brief.sentScore,
                      tag: brief.divergenceTag,
                      desc: brief.divergenceDesc,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showLogicModal(context),
              child: const Row(
                children: [
                  Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text("AI LOGIC & VERIFICATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color bg = severity == 'High' ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    Color text = severity == 'High' ? const Color(0xFFBE123C) : const Color(0xFF047857);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(severity.toUpperCase(), style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class DivergenceMeter extends StatelessWidget {
  final int factScore;
  final int sentScore;
  final String tag;
  final String desc;

  const DivergenceMeter({super.key, required this.factScore, required this.sentScore, required this.tag, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFF43F5E)),
              SizedBox(width: 4),
              Text("Scarcity / Crisis", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E))),
            ]),
            Row(children: [
              Text("Abundance / Glut", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              SizedBox(width: 4),
              Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final factPos = (factScore / 100) * w;
            final sentPos = (sentScore / 100) * w;
            final left = math.min(factPos, sentPos);
            final width = (factPos - sentPos).abs();

            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(width: w, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFFFFE4E6), Color(0xFFF1F5F9), Color(0xFFD1FAE5)]))),
                  Positioned(left: left, width: width, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.3), borderRadius: BorderRadius.circular(4)))),
                  Positioned(left: factPos, top: -24, child: _buildMarker("FACT", const Color(0xFF6366F1), true)),
                  Positioned(left: sentPos, bottom: -24, child: _buildMarker("SENTIMENT", const Color(0xFFF43F5E), false)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.analytics, size: 14, color: Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
          ],
        ),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildMarker(String label, Color color, bool top) {
    return FractionalTranslation(
      translation: const Offset(-0.5, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (top) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
            const SizedBox(height: 2),
            Container(width: 2, height: 8, color: color),
          ] else ...[
            Container(width: 2, height: 8, color: color),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
          ],
        ],
      ),
    );
  }
}

class _LogicModalContent extends StatelessWidget {
  final Briefing brief;
  final ScrollController controller;
  const _LogicModalContent({required this.brief, required this.controller});
  @override Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: ListView(
        controller: controller,
        children: [
          Text("AI Logic Analysis", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(brief.harness, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          const SizedBox(height: 16),
          const Text("Verified Sources:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...brief.headlines.map((h) => Padding(padding: const EdgeInsets.all(4), child: Text("• $h", style: const TextStyle(fontSize: 12))))
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'models.dart';

class BriefingCard extends StatefulWidget {
  final Briefing brief;

  const BriefingCard({super.key, required this.brief});

  @override
  State<BriefingCard> createState() => _BriefingCardState();
}

class _BriefingCardState extends State<BriefingCard> {
  // Range State: '5D', '1M', '3M'
  String _selectedRange = '5D';

  void _showLogicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _LogicModalContent(brief: widget.brief, controller: scrollController),
      ),
    );
  }

  // --- SLICING LOGIC ---
  List<double> _getFilteredData() {
    final fullData = widget.brief.chartData;
    if (fullData.isEmpty) return [];

    int count;
    switch (_selectedRange) {
      case '5D':
        count = 5;
        break;
      case '1M':
        count = 21; // Approx trading days in a month
        break;
      case '3M':
        count = 63; // Approx trading days in 3 months
        break;
      default:
        count = 5;
    }

    if (fullData.length <= count) return fullData;
    return fullData.sublist(fullData.length - count);
  }

  Widget _buildFallbackBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.amber.shade300)),
      child: Row(
        children: [
          Icon(Icons.science, size: 10, color: Colors.amber.shade800),
          const SizedBox(width: 4),
          Text("SIMULATED DATA", style: TextStyle(color: Colors.amber.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRangeButton(String label) {
    final bool isSelected = _selectedRange == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedRange = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _getFilteredData();

    // Calculate Min/Max for Scale based on CURRENT selection
    double minVal = 0;
    double maxVal = 0;
    if (displayData.isNotEmpty) {
      minVal = displayData.reduce(math.min);
      maxVal = displayData.reduce(math.max);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.brief.subsector.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(widget.brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
                Row(
                  children: [
                    if (widget.brief.isFallback) _buildFallbackBadge(),
                    _buildSeverityBadge(widget.brief.severity),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

            // VISUALIZATION BLOCK
            Container(
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('MARKET PATH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                              const SizedBox(height: 4),
                              Text(widget.brief.metrics.commodity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Row(
                                children: [
                                  Text(widget.brief.metrics.price, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Text(widget.brief.metrics.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // RANGE SELECTOR
                              Row(
                                children: [
                                  _buildRangeButton('5D'),
                                  _buildRangeButton('1M'),
                                  _buildRangeButton('3M'),
                                ],
                              )
                            ],
                          ),
                        ),
                        // Sparkline Chart with Scale Indicators
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 50, // Increased slightly
                                child: LineChart(
                                  LineChartData(
                                    minY: minVal * 0.99,
                                    maxY: maxVal * 1.01,
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: displayData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                        isCurved: true,
                                        color: const Color(0xFF6366F1),
                                        barWidth: 2,
                                        dotData: const FlDotData(show: false),
                                        belowBarData: BarAreaData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // SCALE INDICATOR (Dynamic)
                              if (displayData.isNotEmpty)
                                Text(
                                  "Low: \$${minVal.toStringAsFixed(2)}  High: \$${maxVal.toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // DIVERGENCE METER
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                      factScore: widget.brief.factScore,
                      sentScore: widget.brief.sentScore,
                      tag: widget.brief.divergenceTag,
                      desc: widget.brief.divergenceDesc,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showLogicModal(context),
              child: const Row(
                children: [
                  Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text("AI LOGIC & VERIFICATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color bg = severity == 'High' ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    Color text = severity == 'High' ? const Color(0xFFBE123C) : const Color(0xFF047857);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(severity.toUpperCase(), style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class DivergenceMeter extends StatelessWidget {
  final int factScore;
  final int sentScore;
  final String tag;
  final String desc;

  const DivergenceMeter({super.key, required this.factScore, required this.sentScore, required this.tag, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFF43F5E)),
              SizedBox(width: 4),
              Text("Scarcity / Crisis", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E))),
            ]),
            Row(children: [
              Text("Abundance / Glut", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              SizedBox(width: 4),
              Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final factPos = (factScore / 100) * w;
            final sentPos = (sentScore / 100) * w;
            final left = math.min(factPos, sentPos);
            final width = (factPos - sentPos).abs();

            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(width: w, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFFFFE4E6), Color(0xFFF1F5F9), Color(0xFFD1FAE5)]))),
                  Positioned(left: left, width: width, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.3), borderRadius: BorderRadius.circular(4)))),
                  Positioned(left: factPos, top: -24, child: _buildMarker("FACT", const Color(0xFF6366F1), true)),
                  Positioned(left: sentPos, bottom: -24, child: _buildMarker("SENTIMENT", const Color(0xFFF43F5E), false)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.analytics, size: 14, color: Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
          ],
        ),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildMarker(String label, Color color, bool top) {
    return FractionalTranslation(
      translation: const Offset(-0.5, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (top) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
            const SizedBox(height: 2),
            Container(width: 2, height: 8, color: color),
          ] else ...[
            Container(width: 2, height: 8, color: color),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
          ],
        ],
      ),
    );
  }
}

class _LogicModalContent extends StatelessWidget {
  final Briefing brief;
  final ScrollController controller;
  const _LogicModalContent({required this.brief, required this.controller});
  @override Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: ListView(
        controller: controller,
        children: [
          Text("AI Logic Analysis", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(brief.harness, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          const SizedBox(height: 16),
          const Text("Verified Sources:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...brief.headlines.map((h) => Padding(padding: const EdgeInsets.all(4), child: Text("• $h", style: const TextStyle(fontSize: 12))))
        ],
      ),
    );
  }
}