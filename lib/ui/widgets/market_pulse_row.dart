/*
import 'package:flutter/material.dart';
import '../../core/models.dart';

class MarketPulseRow extends StatelessWidget {
  final MarketFact fact;

  const MarketPulseRow({super.key, required this.fact});

  @override
  Widget build(BuildContext context) {
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
              Text(fact.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),

              // Trend Indicator
              Row(
                children: [
                  Icon(icon, size: 14, color: trendColor),
                  const SizedBox(width: 2),
                  Text(
                      fact.trend,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor)
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: fact.status == "Stable" ? const Color(0xFFF1F5F9) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  fact.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: fact.status == "Stable" ? const Color(0xFF64748B) : const Color(0xFFEF4444),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}*/

// lib/ui/widgets/market_pulse_row.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models.dart';

class MarketPulseRow extends StatefulWidget {
  final MarketFact fact;

  const MarketPulseRow({super.key, required this.fact});

  @override
  State<MarketPulseRow> createState() => _MarketPulseRowState();
}

class _MarketPulseRowState extends State<MarketPulseRow> {
  // Default range
  String _selectedRange = '1M';

  final List<String> _ranges = ['5D', '1M', '3M', '6M', '1Y'];

  @override
  Widget build(BuildContext context) {
    final isUp = !widget.fact.trend.startsWith('-');
    final trendColor = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    // Get data for selected range, fallback to empty list
    final sparkData = widget.fact.history[_selectedRange] ?? widget.fact.lineData;

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
          // Header Row: Name & Icon
          Row(
            children: [
              const Icon(Icons.show_chart, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.fact.name,
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

          const SizedBox(height: 12),

          // Data Row: Value, Sparkline, Trend
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Value
              Text(widget.fact.value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

              const SizedBox(width: 16),

              // Sparkline Chart (Takes available space)
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: sparkData.isNotEmpty
                      ? LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: sparkData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          color: trendColor,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: trendColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  )
                      : const SizedBox.shrink(),
                ),
              ),

              const SizedBox(width: 16),

              // Trend & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 14, color: trendColor),
                      const SizedBox(width: 2),
                      Text(
                          widget.fact.trend,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor)
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Range Selector (Bottom Row)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: _ranges.map((range) => _buildRangeButton(range)).toList(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.fact.status == "Stable" ? const Color(0xFFF1F5F9) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.fact.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9, // Slightly smaller
                    fontWeight: FontWeight.bold,
                    color: widget.fact.status == "Stable" ? const Color(0xFF64748B) : const Color(0xFFEF4444),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRangeButton(String range) {
    final isSelected = range == _selectedRange;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRange = range;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          range,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}