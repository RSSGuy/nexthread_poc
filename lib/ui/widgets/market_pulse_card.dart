

import 'package:flutter/material.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../dialogs/simulation_dialog.dart';
import '../dialogs/global_indices_dialog.dart';

class MarketPulseCard extends StatelessWidget {
  final List<TopicConfig> topics;
  final TopicConfig currentTopic;
  final MarketFact? marketFact;
  final bool isLoading;
  final Function(TopicConfig) onTopicChanged;
  final Function(String) onSimulation;
  final int userPoints;

  const MarketPulseCard({
    super.key,
    required this.topics,
    required this.currentTopic,
    required this.marketFact,
    required this.isLoading,
    required this.onTopicChanged,
    required this.onSimulation,
    required this.userPoints,
  });

  void _handleSimulationTap(BuildContext context) async {
    final String? scenario = await SimulationDialog.show(context, userPoints);
    if (scenario != null && scenario.isNotEmpty) {
      onSimulation(scenario);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TopicConfig>(
                      value: currentTopic,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1)),
                      items: topics.map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                      )).toList(),
                      onChanged: (newTopic) {
                        if (newTopic != null && newTopic != currentTopic) {
                          onTopicChanged(newTopic);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // GLOBAL INDICES BUTTON
              InkWell(
                onTap: () => GlobalIndicesDialog.show(context, topics), // FIXED: Added 'topics' argument
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                      Icons.public, // World Icon
                      color: Color(0xFF6366F1)
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // SIMULATION BUTTON
              InkWell(
                onTap: isLoading ? null : () => _handleSimulationTap(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Icon(
                      Icons.science,
                      color: userPoints >= 1000 ? const Color(0xFF6366F1) : Colors.grey
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (marketFact != null)
            _buildContent(marketFact!)
          else if (isLoading)
            const LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1))
        ],
      ),
    );
  }

  Widget _buildContent(MarketFact fact) {
    if (fact.subFacts.isNotEmpty) {
      return Column(
        children: fact.subFacts.map((sub) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildPulseRow(sub),
        )).toList(),
      );
    } else {
      return _buildPulseRow(fact);
    }
  }

  Widget _buildPulseRow(MarketFact fact) {
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
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
              Row(
                children: [
                  Icon(icon, size: 14, color: trendColor),
                  const SizedBox(width: 2),
                  Text(fact.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor)),
                ],
              ),
              const SizedBox(width: 12),
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
}
