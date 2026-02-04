/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/models.dart'; // UPDATED RELATIVE IMPORT

class BriefingCard extends StatefulWidget {
  final Briefing brief;

  const BriefingCard({super.key, required this.brief});

  @override
  State<BriefingCard> createState() => _BriefingCardState();
}

class _BriefingCardState extends State<BriefingCard> {
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

  List<double> _getFilteredData() {
    final fullData = widget.brief.chartData;
    if (fullData.isEmpty) return [];

    int count;
    switch (_selectedRange) {
      case '5D': count = 5; break;
      case '1M': count = 21; break;
      case '3M': count = 63; break;
      default: count = 5;
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
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _getFilteredData();
    double minVal = 0, maxVal = 0;
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
                              Row(children: [_buildRangeButton('5D'), _buildRangeButton('1M'), _buildRangeButton('3M')])
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 50,
                                child: LineChart(
                                  LineChartData(
                                    minY: minVal * 0.99, maxY: maxVal * 1.01,
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: displayData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                        isCurved: true, color: const Color(0xFF6366F1), barWidth: 2, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (displayData.isNotEmpty)
                                Text("Low: \$${minVal.toStringAsFixed(2)}  High: \$${maxVal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(factScore: widget.brief.factScore, sentScore: widget.brief.sentScore, tag: widget.brief.divergenceTag, desc: widget.brief.divergenceDesc),
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
import '../../core/models.dart';

class BriefingCard extends StatefulWidget {
  final Briefing brief;
  final String industryTag; // NEW: Tag to display (e.g. "Agriculture")

  const BriefingCard({
    super.key,
    required this.brief,
    required this.industryTag,
  });

  @override
  State<BriefingCard> createState() => _BriefingCardState();
}

class _BriefingCardState extends State<BriefingCard> {
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

  List<double> _getFilteredData() {
    final fullData = widget.brief.chartData;
    if (fullData.isEmpty) return [];

    int count;
    switch (_selectedRange) {
      case '5D': count = 5; break;
      case '1M': count = 21; break;
      case '3M': count = 63; break;
      default: count = 5;
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
          Text("SIMULATED", style: TextStyle(color: Colors.amber.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // NEW: Industry Badge Builder
  Widget _buildIndustryBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate-100
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)), // Slate-300
      ),
      child: Text(
        widget.industryTag.toUpperCase(),
        style: const TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _getFilteredData();
    double minVal = 0, maxVal = 0;
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.brief.subsector.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                      const SizedBox(height: 4),
                      Text(widget.brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ],
                  ),
                ),
                // UPDATED: Added Industry Badge to the row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildIndustryBadge(),
                        if (widget.brief.isFallback) _buildFallbackBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildSeverityBadge(widget.brief.severity),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),
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
                              Row(children: [_buildRangeButton('5D'), _buildRangeButton('1M'), _buildRangeButton('3M')])
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 50,
                                child: LineChart(
                                  LineChartData(
                                    minY: minVal * 0.99, maxY: maxVal * 1.01,
                                    gridData: const FlGridData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: displayData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                        isCurved: true, color: const Color(0xFF6366F1), barWidth: 2, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (displayData.isNotEmpty)
                                Text("Low: \$${minVal.toStringAsFixed(2)}  High: \$${maxVal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(factScore: widget.brief.factScore, sentScore: widget.brief.sentScore, tag: widget.brief.divergenceTag, desc: widget.brief.divergenceDesc),
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
import '../../core/models.dart'; // Imports the updated Briefing model with generatedAt

class BriefingCard extends StatefulWidget {
  final Briefing brief;
  final String industryTag; // e.g. "Agriculture", "Manufacturing"

  const BriefingCard({
    super.key,
    required this.brief,
    required this.industryTag,
  });

  @override
  State<BriefingCard> createState() => _BriefingCardState();
}

class _BriefingCardState extends State<BriefingCard> {
  // Sparkline Range State: '5D', '1M', '3M'
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

  // --- SPARKLINE SLICING ---
  List<double> _getFilteredData() {
    final fullData = widget.brief.chartData;
    if (fullData.isEmpty) return [];

    int count;
    switch (_selectedRange) {
      case '5D': count = 5; break;
      case '1M': count = 21; break; // Approx trading days
      case '3M': count = 63; break;
      default: count = 5;
    }

    if (fullData.length <= count) return fullData;
    return fullData.sublist(fullData.length - count);
  }

  // --- UI HELPERS ---

  String _formatTimestamp(DateTime dt) {
    // Format: "10:30 AM • Jan 28"
    final time = "${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    final date = "${dt.month}/${dt.day}";
    return "$time • $date";
  }

  Widget _buildFallbackBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.amber.shade200)
      ),
      child: Text(
          "SIMULATED",
          style: TextStyle(color: Colors.amber.shade800, fontSize: 9, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildIndustryBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate-100
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)), // Slate-300
      ),
      child: Text(
        widget.industryTag.toUpperCase(),
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
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
              color: isSelected ? Colors.white : const Color(0xFF94A3B8)
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _getFilteredData();
    double minVal = 0, maxVal = 0;
    if (displayData.isNotEmpty) {
      minVal = displayData.reduce(math.min);
      maxVal = displayData.reduce(math.max);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timestamp & Subsector
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 10, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(widget.brief.generatedAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                              widget.brief.subsector.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(widget.brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ],
                  ),
                ),
                // Badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildIndustryBadge(),
                        if (widget.brief.isFallback) _buildFallbackBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
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
                                  Text(
                                      widget.brief.metrics.trend,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(children: [_buildRangeButton('5D'), _buildRangeButton('1M'), _buildRangeButton('3M')])
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 50,
                                child: LineChart(
                                  LineChartData(
                                    minY: minVal * 0.99, maxY: maxVal * 1.01,
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
                              if (displayData.isNotEmpty)
                                Text("Low: \$${minVal.toStringAsFixed(2)}  High: \$${maxVal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
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
                        desc: widget.brief.divergenceDesc
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // LOGIC MODAL TRIGGER
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
import '../../core/models.dart'; // Imports the updated Briefing model with generatedAt
import '../../core/storage_service.dart'; // Import Storage

class BriefingCard extends StatefulWidget {
  final Briefing brief;
  final String industryTag; // e.g. "Agriculture", "Manufacturing"
  final String topicId; // NEW: Required to link comments

  const BriefingCard({
    super.key,
    required this.brief,
    required this.industryTag,
    required this.topicId,
  });

  @override
  State<BriefingCard> createState() => _BriefingCardState();
}

class _BriefingCardState extends State<BriefingCard> {
  // Sparkline Range State: '5D', '1M', '3M'
  String _selectedRange = '5D';
  List<Comment> _comments = []; // Local state for comment count/display

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    final comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

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

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => _CommentsModalContent(
            brief: widget.brief,
            topicId: widget.topicId,
            initialComments: _comments,
            scrollController: scrollController,
            onCommentAdded: _loadComments, // Refresh parent state
          ),
        ),
      ),
    );
  }

  // --- SPARKLINE SLICING ---
  List<double> _getFilteredData() {
    final fullData = widget.brief.chartData;
    if (fullData.isEmpty) return [];

    int count;
    switch (_selectedRange) {
      case '5D': count = 5; break;
      case '1M': count = 21; break; // Approx trading days
      case '3M': count = 63; break;
      default: count = 5;
    }

    if (fullData.length <= count) return fullData;
    return fullData.sublist(fullData.length - count);
  }

  // --- UI HELPERS ---

  String _formatTimestamp(DateTime dt) {
    // Format: "10:30 AM • Jan 28"
    final time = "${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    final date = "${dt.month}/${dt.day}";
    return "$time • $date";
  }

  Widget _buildFallbackBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.amber.shade200)
      ),
      child: Text(
          "SIMULATED",
          style: TextStyle(color: Colors.amber.shade800, fontSize: 9, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildIndustryBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate-100
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)), // Slate-300
      ),
      child: Text(
        widget.industryTag.toUpperCase(),
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
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
              color: isSelected ? Colors.white : const Color(0xFF94A3B8)
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _getFilteredData();
    double minVal = 0, maxVal = 0;
    if (displayData.isNotEmpty) {
      minVal = displayData.reduce(math.min);
      maxVal = displayData.reduce(math.max);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timestamp & Subsector
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 10, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(widget.brief.generatedAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                              widget.brief.subsector.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(widget.brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ],
                  ),
                ),
                // Badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildIndustryBadge(),
                        if (widget.brief.isFallback) _buildFallbackBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
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
                                  Text(
                                      widget.brief.metrics.trend,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(children: [_buildRangeButton('5D'), _buildRangeButton('1M'), _buildRangeButton('3M')])
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 50,
                                child: LineChart(
                                  LineChartData(
                                    minY: minVal * 0.99, maxY: maxVal * 1.01,
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
                              if (displayData.isNotEmpty)
                                Text("Low: \$${minVal.toStringAsFixed(2)}  High: \$${maxVal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
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
                        desc: widget.brief.divergenceDesc
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                // AI LOGIC BUTTON
                InkWell(
                  onTap: () => _showLogicModal(context),
                  child: Row(
                    children: [
                      const Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                      const SizedBox(width: 4),
                      const Text("LOGIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ],
                  ),
                ),

                const Spacer(),

                // COMMENTS BUTTON
                InkWell(
                  onTap: () => _showCommentsModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          _comments.isEmpty ? "Comment" : "${_comments.length} Comments",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
          const Text("Verified Sources:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...brief.headlines.map((h) => Padding(padding: const EdgeInsets.all(4), child: Text("• $h", style: const TextStyle(fontSize: 12))))
        ],
      ),
    );
  }
}

// --- NEW: COMMENTS MODAL WIDGET ---
class _CommentsModalContent extends StatefulWidget {
  final Briefing brief;
  final String topicId;
  final List<Comment> initialComments;
  final ScrollController scrollController;
  final VoidCallback onCommentAdded;

  const _CommentsModalContent({
    required this.brief,
    required this.topicId,
    required this.initialComments,
    required this.scrollController,
    required this.onCommentAdded,
  });

  @override
  State<_CommentsModalContent> createState() => _CommentsModalContentState();
}

class _CommentsModalContentState extends State<_CommentsModalContent> {
  late List<Comment> _comments;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
  }

  void _submitComment() async {
    if (_textController.text.trim().isEmpty) return;

    final text = _textController.text.trim();
    _textController.clear();
    FocusScope.of(context).unfocus();

    await StorageService.addComment(widget.topicId, widget.brief.generatedAt, text);

    // Reload local list
    setState(() {
      _comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
    });

    // Notify parent to update count
    widget.onCommentAdded();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          Text("Intelligence Discussion", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.brief.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          Expanded(
            child: _comments.isEmpty
                ? Center(child: Text("No comments yet.\nStart the discussion.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400)))
                : ListView.separated(
              controller: widget.scrollController,
              itemCount: _comments.length,
              separatorBuilder: (c, i) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final c = _comments[index];
                // Simple relative time format
                final diff = DateTime.now().difference(c.createdAt);
                String timeStr = "just now";
                if (diff.inMinutes > 0) timeStr = "${diff.inMinutes}m ago";
                if (diff.inHours > 0) timeStr = "${diff.inHours}h ago";
                if (diff.inDays > 0) timeStr = "${diff.inDays}d ago";

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF6366F1),
                      child: Text("U", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("Analyst", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.text, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          // Input Area
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "Add your insight...",
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _submitComment,
                style: IconButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ],
          )
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
import '../../core/models.dart';
import '../../core/storage_service.dart';
import '../../core/ai_service.dart';

class BriefingCard extends StatefulWidget {
  final Briefing brief;
  final String industryTag;
  final String topicId;

  const BriefingCard({
    super.key,
    required this.brief,
    required this.industryTag,
    required this.topicId,
  });

  @override
  State<BriefingCard> createState() => _BriefingCardState();
}

class _BriefingCardState extends State<BriefingCard> {
  String _selectedRange = '5D';
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    final comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

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

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => _CommentsModalContent(
            brief: widget.brief,
            topicId: widget.topicId,
            initialComments: _comments,
            scrollController: scrollController,
            onCommentAdded: _loadComments,
          ),
        ),
      ),
    );
  }

  List<double> _getFilteredData() {
    final fullData = widget.brief.chartData;
    if (fullData.isEmpty) return [];

    int count;
    switch (_selectedRange) {
      case '5D': count = 5; break;
      case '1M': count = 21; break;
      case '3M': count = 63; break;
      default: count = 5;
    }

    if (fullData.length <= count) return fullData;
    return fullData.sublist(fullData.length - count);
  }

  String _formatTimestamp(DateTime dt) {
    final time = "${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    final date = "${dt.month}/${dt.day}";
    return "$time • $date";
  }

  Widget _buildFallbackBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.amber.shade200)
      ),
      child: Text(
          "SIMULATED",
          style: TextStyle(color: Colors.amber.shade800, fontSize: 9, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildIndustryBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        widget.industryTag.toUpperCase(),
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
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
              color: isSelected ? Colors.white : const Color(0xFF94A3B8)
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _getFilteredData();
    double minVal = 0, maxVal = 0;
    if (displayData.isNotEmpty) {
      minVal = displayData.reduce(math.min);
      maxVal = displayData.reduce(math.max);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 10, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(widget.brief.generatedAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                              widget.brief.subsector.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(widget.brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildIndustryBadge(),
                        if (widget.brief.isFallback) _buildFallbackBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildSeverityBadge(widget.brief.severity),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(widget.brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

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
                                  Text(
                                      widget.brief.metrics.trend,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(children: [_buildRangeButton('5D'), _buildRangeButton('1M'), _buildRangeButton('3M')])
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 50,
                                child: LineChart(
                                  LineChartData(
                                    minY: minVal * 0.99, maxY: maxVal * 1.01,
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
                              if (displayData.isNotEmpty)
                                Text("Low: \$${minVal.toStringAsFixed(2)}  High: \$${maxVal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                        factScore: widget.brief.factScore,
                        sentScore: widget.brief.sentScore,
                        tag: widget.brief.divergenceTag,
                        desc: widget.brief.divergenceDesc
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                InkWell(
                  onTap: () => _showLogicModal(context),
                  child: Row(
                    children: [
                      const Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                      const SizedBox(width: 4),
                      const Text("LOGIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ],
                  ),
                ),

                const Spacer(),

                InkWell(
                  onTap: () => _showCommentsModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          _comments.isEmpty ? "Comment" : "${_comments.length} Comments",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
          const Text("Verified Sources:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...brief.headlines.map((h) => Padding(padding: const EdgeInsets.all(4), child: Text("• $h", style: const TextStyle(fontSize: 12))))
        ],
      ),
    );
  }
}

class _CommentsModalContent extends StatefulWidget {
  final Briefing brief;
  final String topicId;
  final List<Comment> initialComments;
  final ScrollController scrollController;
  final VoidCallback onCommentAdded;

  const _CommentsModalContent({
    required this.brief,
    required this.topicId,
    required this.initialComments,
    required this.scrollController,
    required this.onCommentAdded,
  });

  @override
  State<_CommentsModalContent> createState() => _CommentsModalContentState();
}

class _CommentsModalContentState extends State<_CommentsModalContent> {
  late List<Comment> _comments;
  final TextEditingController _textController = TextEditingController();
  final AIService _aiService = AIService();

  bool _isAskAiMode = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
  }

  void _submitComment() async {
    if (_textController.text.trim().isEmpty) return;

    final text = _textController.text.trim();
    _textController.clear();
    FocusScope.of(context).unfocus();

    // 1. If AI Mode is ON, check COST FIRST (100 pts)
    if (_isAskAiMode) {
      bool paid = await StorageService.deductPoints(100);
      if (!paid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Insufficient Points (Need 100 for AI)."),
                backgroundColor: Colors.red,
              )
          );
        }
        return; // Don't post user comment either if intent failed
      }
    }

    // 2. Add User Comment
    setState(() => _isProcessing = true);
    await StorageService.addComment(widget.topicId, widget.brief.generatedAt, text);

    // Update Local View
    setState(() {
      _comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
    });
    widget.onCommentAdded();

    // 3. Trigger AI Response
    if (_isAskAiMode) {
      try {
        final aiAnswer = await _aiService.askAboutBriefing(widget.brief, text);

        await StorageService.addComment(
            widget.topicId,
            widget.brief.generatedAt,
            aiAnswer,
            isAi: true
        );

        if (mounted) {
          setState(() {
            _comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
          });
          widget.onCommentAdded();
        }
      } on IrrelevantScenarioException catch (e) {
        // REFUND & ALERT
        await StorageService.addPoints(100);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text("Blocked: ${e.message}")),
                    const Text("+100 REFUND", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
              )
          );
        }
      } catch (e) {
        print("AI Reply Failed: $e");
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          Text("Intelligence Discussion", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.brief.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          Expanded(
            child: _comments.isEmpty
                ? Center(child: Text("No comments yet.\nStart the discussion.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400)))
                : ListView.separated(
              controller: widget.scrollController,
              itemCount: _comments.length,
              separatorBuilder: (c, i) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final c = _comments[index];
                final diff = DateTime.now().difference(c.createdAt);
                String timeStr = "just now";
                if (diff.inMinutes > 0) timeStr = "${diff.inMinutes}m ago";
                if (diff.inHours > 0) timeStr = "${diff.inHours}h ago";
                if (diff.inDays > 0) timeStr = "${diff.inDays}d ago";

                final bool isAi = c.isAi;
                final avatarColor = isAi ? Colors.black : const Color(0xFF6366F1);
                final avatarLabel = isAi ? "AI" : "U";
                final nameLabel = isAi ? "NexThread AI" : "Analyst";

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: avatarColor,
                      child: isAi
                          ? const Icon(Icons.auto_awesome, size: 16, color: Colors.white)
                          : Text(avatarLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(nameLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.text, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1)),
            ),

          const SizedBox(height: 16),

          Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  Text("Ask AI (100pts)", style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _isAskAiMode ? const Color(0xFF6366F1) : Colors.grey
                  )),
                  Switch(
                    value: _isAskAiMode,
                    activeColor: const Color(0xFF6366F1),
                    onChanged: (val) => setState(() => _isAskAiMode = val),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_isProcessing,
                      decoration: InputDecoration(
                        hintText: _isAskAiMode ? "Ask about this report..." : "Add your insight...",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: _isAskAiMode ? const Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 18) : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isProcessing ? null : _submitComment,
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/models.dart';
import '../../core/storage_service.dart';
import '../../core/ai_service.dart';

class BriefingCard extends StatefulWidget {
  final Briefing brief;
  final String industryTag;
  final String topicId;
  final VoidCallback onPointsUpdated; // NEW

  const BriefingCard({
    super.key,
    required this.brief,
    required this.industryTag,
    required this.topicId,
    required this.onPointsUpdated, // NEW
  });

  @override
  State<BriefingCard> createState() => _BriefingCardState();
}

class _BriefingCardState extends State<BriefingCard> {
  String _selectedRange = '5D';
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    final comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

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

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => _CommentsModalContent(
            brief: widget.brief,
            topicId: widget.topicId,
            initialComments: _comments,
            scrollController: scrollController,
            onCommentAdded: _loadComments,
            onPointsUpdated: widget.onPointsUpdated, // Pass it down
          ),
        ),
      ),
    );
  }

  // ... [Charts and Badge Helpers Remain Unchanged] ...
  List<double> _getFilteredData() {
    final fullData = widget.brief.chartData;
    if (fullData.isEmpty) return [];

    int count;
    switch (_selectedRange) {
      case '5D': count = 5; break;
      case '1M': count = 21; break;
      case '3M': count = 63; break;
      default: count = 5;
    }

    if (fullData.length <= count) return fullData;
    return fullData.sublist(fullData.length - count);
  }

  String _formatTimestamp(DateTime dt) {
    final time = "${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    final date = "${dt.month}/${dt.day}";
    return "$time • $date";
  }

  Widget _buildFallbackBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.amber.shade200)
      ),
      child: Text(
          "SIMULATED",
          style: TextStyle(color: Colors.amber.shade800, fontSize: 9, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildIndustryBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        widget.industryTag.toUpperCase(),
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
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
              color: isSelected ? Colors.white : const Color(0xFF94A3B8)
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _getFilteredData();
    double minVal = 0, maxVal = 0;
    if (displayData.isNotEmpty) {
      minVal = displayData.reduce(math.min);
      maxVal = displayData.reduce(math.max);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 10, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(widget.brief.generatedAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                              widget.brief.subsector.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(widget.brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildIndustryBadge(),
                        if (widget.brief.isFallback) _buildFallbackBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildSeverityBadge(widget.brief.severity),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

            // CHART AREA
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
                                  Text(
                                      widget.brief.metrics.trend,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(children: [_buildRangeButton('5D'), _buildRangeButton('1M'), _buildRangeButton('3M')])
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 50,
                                child: LineChart(
                                  LineChartData(
                                    minY: minVal * 0.99, maxY: maxVal * 1.01,
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
                              if (displayData.isNotEmpty)
                                Text("Low: \$${minVal.toStringAsFixed(2)}  High: \$${maxVal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                        factScore: widget.brief.factScore,
                        sentScore: widget.brief.sentScore,
                        tag: widget.brief.divergenceTag,
                        desc: widget.brief.divergenceDesc
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                InkWell(
                  onTap: () => _showLogicModal(context),
                  child: Row(
                    children: [
                      const Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                      const SizedBox(width: 4),
                      const Text("LOGIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ],
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _showCommentsModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          _comments.isEmpty ? "Comment" : "${_comments.length} Comments",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ... [DivergenceMeter and _LogicModalContent Remain Unchanged] ...
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
          const Text("Verified Sources:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...brief.headlines.map((h) => Padding(padding: const EdgeInsets.all(4), child: Text("• $h", style: const TextStyle(fontSize: 12))))
        ],
      ),
    );
  }
}

// --- COMMENTS MODAL ---
class _CommentsModalContent extends StatefulWidget {
  final Briefing brief;
  final String topicId;
  final List<Comment> initialComments;
  final ScrollController scrollController;
  final VoidCallback onCommentAdded;
  final VoidCallback onPointsUpdated; // NEW

  const _CommentsModalContent({
    required this.brief,
    required this.topicId,
    required this.initialComments,
    required this.scrollController,
    required this.onCommentAdded,
    required this.onPointsUpdated,
  });

  @override
  State<_CommentsModalContent> createState() => _CommentsModalContentState();
}

class _CommentsModalContentState extends State<_CommentsModalContent> {
  late List<Comment> _comments;
  final TextEditingController _textController = TextEditingController();
  final AIService _aiService = AIService();

  bool _isAskAiMode = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
  }

  void _submitComment() async {
    if (_textController.text.trim().isEmpty) return;

    final text = _textController.text.trim();
    _textController.clear();
    FocusScope.of(context).unfocus();

    // 1. DEDUCT POINTS IF AI MODE
    if (_isAskAiMode) {
      bool paid = await StorageService.deductPoints(100);
      if (!paid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Insufficient Points (Need 100 for AI)."),
                backgroundColor: Colors.red,
              )
          );
        }
        return;
      }
      // UPDATE UI IMMEDIATELY
      widget.onPointsUpdated();
    }

    // 2. Add User Comment
    setState(() => _isProcessing = true);
    await StorageService.addComment(widget.topicId, widget.brief.generatedAt, text);

    // Update Local View
    setState(() {
      _comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
    });
    widget.onCommentAdded();

    // 3. Trigger AI Response
    if (_isAskAiMode) {
      try {
        final aiAnswer = await _aiService.askAboutBriefing(widget.brief, text);

        await StorageService.addComment(
            widget.topicId,
            widget.brief.generatedAt,
            aiAnswer,
            isAi: true
        );

        if (mounted) {
          setState(() {
            _comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
          });
          widget.onCommentAdded();
        }
      } catch (e) {
        print("AI Reply Failed: $e");

        // REFUND POINTS ON ERROR
        await StorageService.addPoints(100);
        widget.onPointsUpdated();

        if (mounted) {
          // Distinguish between Blocked (Guardrail) vs System Error
          String msg = "System Error: Points Refunded.";
          if (e is IrrelevantScenarioException) {
            msg = "Blocked: ${e.message} (+100 Refund)";
          }

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Colors.red.shade700,
              )
          );
        }
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          Text("Intelligence Discussion", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.brief.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          Expanded(
            child: _comments.isEmpty
                ? Center(child: Text("No comments yet.\nStart the discussion.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400)))
                : ListView.separated(
              controller: widget.scrollController,
              itemCount: _comments.length,
              separatorBuilder: (c, i) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final c = _comments[index];
                final diff = DateTime.now().difference(c.createdAt);
                String timeStr = "just now";
                if (diff.inMinutes > 0) timeStr = "${diff.inMinutes}m ago";
                if (diff.inHours > 0) timeStr = "${diff.inHours}h ago";
                if (diff.inDays > 0) timeStr = "${diff.inDays}d ago";

                final bool isAi = c.isAi;
                final avatarColor = isAi ? Colors.black : const Color(0xFF6366F1);
                final avatarLabel = isAi ? "AI" : "U";
                final nameLabel = isAi ? "NexThread AI" : "Analyst";

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: avatarColor,
                      child: isAi
                          ? const Icon(Icons.auto_awesome, size: 16, color: Colors.white)
                          : Text(avatarLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(nameLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.text, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1)),
            ),

          const SizedBox(height: 16),

          Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  Text("Ask AI (100pts)", style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _isAskAiMode ? const Color(0xFF6366F1) : Colors.grey
                  )),
                  Switch(
                    value: _isAskAiMode,
                    activeColor: const Color(0xFF6366F1),
                    onChanged: (val) => setState(() => _isAskAiMode = val),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_isProcessing,
                      decoration: InputDecoration(
                        hintText: _isAskAiMode ? "Ask about this report..." : "Add your insight...",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: _isAskAiMode ? const Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 18) : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isProcessing ? null : _submitComment,
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import '../../core/models.dart';
import '../../core/storage_service.dart';
import '../../core/ai_service.dart';

class BriefingCard extends StatefulWidget {
  final Briefing brief;
  final String industryTag;
  final String topicId;
  final VoidCallback onPointsUpdated;

  const BriefingCard({
    super.key,
    required this.brief,
    required this.industryTag,
    required this.topicId,
    required this.onPointsUpdated,
  });

  @override
  State<BriefingCard> createState() => _BriefingCardState();
}

class _BriefingCardState extends State<BriefingCard> {
  String _selectedRange = '5D';
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    final comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
    if (mounted) {
      setState(() {
        _comments = comments;
      });
    }
  }

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

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => _CommentsModalContent(
            brief: widget.brief,
            topicId: widget.topicId,
            initialComments: _comments,
            scrollController: scrollController,
            onCommentAdded: _loadComments,
            onPointsUpdated: widget.onPointsUpdated,
          ),
        ),
      ),
    );
  }

  List<double> _getFilteredData() {
    final fullData = widget.brief.chartData;
    if (fullData.isEmpty) return [];

    int count;
    switch (_selectedRange) {
      case '5D': count = 5; break;
      case '1M': count = 21; break;
      case '3M': count = 63; break;
      default: count = 5;
    }

    if (fullData.length <= count) return fullData;
    return fullData.sublist(fullData.length - count);
  }

  String _formatTimestamp(DateTime dt) {
    final time = "${dt.hour > 12 ? dt.hour - 12 : dt.hour}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    final date = "${dt.month}/${dt.day}";
    return "$time • $date";
  }

  Widget _buildFallbackBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.amber.shade200)
      ),
      child: Text(
          "SIMULATED",
          style: TextStyle(color: Colors.amber.shade800, fontSize: 9, fontWeight: FontWeight.bold)
      ),
    );
  }

  Widget _buildIndustryBadge() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        widget.industryTag.toUpperCase(),
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold),
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
              color: isSelected ? Colors.white : const Color(0xFF94A3B8)
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _getFilteredData();
    double minVal = 0, maxVal = 0;
    if (displayData.isNotEmpty) {
      minVal = displayData.reduce(math.min);
      maxVal = displayData.reduce(math.max);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 10, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimestamp(widget.brief.generatedAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                              widget.brief.subsector.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(widget.brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        _buildIndustryBadge(),
                        if (widget.brief.isFallback) _buildFallbackBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildSeverityBadge(widget.brief.severity),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

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
                                  Text(
                                      widget.brief.metrics.trend,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: widget.brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(children: [_buildRangeButton('5D'), _buildRangeButton('1M'), _buildRangeButton('3M')])
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 50,
                                child: LineChart(
                                  LineChartData(
                                    minY: minVal * 0.99, maxY: maxVal * 1.01,
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
                              if (displayData.isNotEmpty)
                                Text("Low: \$${minVal.toStringAsFixed(2)}  High: \$${maxVal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                        factScore: widget.brief.factScore,
                        sentScore: widget.brief.sentScore,
                        tag: widget.brief.divergenceTag,
                        desc: widget.brief.divergenceDesc
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                InkWell(
                  onTap: () => _showLogicModal(context),
                  child: Row(
                    children: [
                      const Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                      const SizedBox(width: 4),
                      const Text("LOGIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ],
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => _showCommentsModal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          _comments.isEmpty ? "Comment" : "${_comments.length} Comments",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
          const Text("Verified Sources:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...brief.headlines.map((h) => Padding(padding: const EdgeInsets.all(4), child: Text("• $h", style: const TextStyle(fontSize: 12)))),

          // --- NEW: Display Polled Sources ---
          const SizedBox(height: 24),
          const Text("Feeds Polled:", style: TextStyle(fontWeight: FontWeight.bold)),
          if (brief.sources.isEmpty)
            const Padding(padding: EdgeInsets.all(4), child: Text("No specific feeds recorded.", style: TextStyle(fontSize: 12, color: Colors.grey)))
          else
            ...brief.sources.map((s) => Padding(padding: const EdgeInsets.all(4), child: Text("• $s", style: const TextStyle(fontSize: 12)))),
        ],
      ),
    );
  }
}

class _CommentsModalContent extends StatefulWidget {
  final Briefing brief;
  final String topicId;
  final List<Comment> initialComments;
  final ScrollController scrollController;
  final VoidCallback onCommentAdded;
  final VoidCallback onPointsUpdated;

  const _CommentsModalContent({
    required this.brief,
    required this.topicId,
    required this.initialComments,
    required this.scrollController,
    required this.onCommentAdded,
    required this.onPointsUpdated,
  });

  @override
  State<_CommentsModalContent> createState() => _CommentsModalContentState();
}

class _CommentsModalContentState extends State<_CommentsModalContent> {
  late List<Comment> _comments;
  final TextEditingController _textController = TextEditingController();
  final AIService _aiService = AIService();

  bool _isAskAiMode = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
  }

  void _submitComment() async {
    if (_textController.text.trim().isEmpty) return;

    final text = _textController.text.trim();
    _textController.clear();
    FocusScope.of(context).unfocus();

    if (_isAskAiMode) {
      bool paid = await StorageService.deductPoints(100);
      if (!paid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Insufficient Points (Need 100 for AI)."),
                backgroundColor: Colors.red,
              )
          );
        }
        return;
      }
      widget.onPointsUpdated();
    }

    setState(() => _isProcessing = true);
    await StorageService.addComment(widget.topicId, widget.brief.generatedAt, text);

    setState(() {
      _comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
    });
    widget.onCommentAdded();

    if (_isAskAiMode) {
      try {
        final aiAnswer = await _aiService.askAboutBriefing(widget.brief, text);

        await StorageService.addComment(
            widget.topicId,
            widget.brief.generatedAt,
            aiAnswer,
            isAi: true
        );

        if (mounted) {
          setState(() {
            _comments = StorageService.getComments(widget.topicId, widget.brief.generatedAt);
          });
          widget.onCommentAdded();
        }
      } catch (e) {
        print("AI Reply Failed: $e");
        await StorageService.addPoints(100);
        widget.onPointsUpdated();

        if (mounted) {
          String msg = "System Error: Points Refunded.";
          if (e is IrrelevantScenarioException) {
            msg = "Blocked: ${e.message} (+100 Refund)";
          }
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700)
          );
        }
      }
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          Text("Intelligence Discussion", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.brief.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          Expanded(
            child: _comments.isEmpty
                ? Center(child: Text("No comments yet.\nStart the discussion.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400)))
                : ListView.separated(
              controller: widget.scrollController,
              itemCount: _comments.length,
              separatorBuilder: (c, i) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final c = _comments[index];
                final diff = DateTime.now().difference(c.createdAt);
                String timeStr = "just now";
                if (diff.inMinutes > 0) timeStr = "${diff.inMinutes}m ago";
                if (diff.inHours > 0) timeStr = "${diff.inHours}h ago";
                if (diff.inDays > 0) timeStr = "${diff.inDays}d ago";

                final bool isAi = c.isAi;
                final avatarColor = isAi ? Colors.black : const Color(0xFF6366F1);
                final avatarLabel = isAi ? "AI" : "U";
                final nameLabel = isAi ? "NexThread AI" : "Analyst";

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: avatarColor,
                      child: isAi
                          ? const Icon(Icons.auto_awesome, size: 16, color: Colors.white)
                          : Text(avatarLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(nameLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 8),
                              Text(timeStr, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(c.text, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1)),
            ),

          const SizedBox(height: 16),

          Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  Text("Ask AI (100pts)", style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _isAskAiMode ? const Color(0xFF6366F1) : Colors.grey
                  )),
                  Switch(
                    value: _isAskAiMode,
                    activeColor: const Color(0xFF6366F1),
                    onChanged: (val) => setState(() => _isAskAiMode = val),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_isProcessing,
                      decoration: InputDecoration(
                        hintText: _isAskAiMode ? "Ask about this report..." : "Add your insight...",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: _isAskAiMode ? const Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 18) : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isProcessing ? null : _submitComment,
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}