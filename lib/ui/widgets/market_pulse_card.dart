/*
import 'package:flutter/material.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';

class MarketPulseCard extends StatelessWidget {
  final List<TopicConfig> topics;
  final TopicConfig currentTopic;
  final MarketFact? marketFact;
  final bool isLoading;
  final Function(TopicConfig) onTopicChanged;

  const MarketPulseCard({
    super.key,
    required this.topics,
    required this.currentTopic,
    required this.marketFact,
    required this.isLoading,
    required this.onTopicChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOPIC DROPDOWN
          Container(
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

          const SizedBox(height: 12),

          // 2. MARKET DATA ROW (The "Pulse")
          if (marketFact != null)
            _buildPulseRow(marketFact!)
          else if (isLoading)
            const LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1))
        ],
      ),
    );
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
      child: Row(
        children: [
          const Icon(Icons.show_chart, size: 16, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(fact.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const Spacer(),
          Text(fact.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, size: 14, color: trendColor),
          Text(fact.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor)),
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
    );
  }
}*/
/*

import 'package:flutter/material.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';

class MarketPulseCard extends StatelessWidget {
  final List<TopicConfig> topics;
  final TopicConfig currentTopic;
  final MarketFact? marketFact;
  final bool isLoading;
  final Function(TopicConfig) onTopicChanged;

  const MarketPulseCard({
    super.key,
    required this.topics,
    required this.currentTopic,
    required this.marketFact,
    required this.isLoading,
    required this.onTopicChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOPIC DROPDOWN
          Container(
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

          const SizedBox(height: 12),

          // 2. MARKET DATA ROW (The "Pulse")
          if (marketFact != null)
            _buildPulseRow(marketFact!)
          else if (isLoading)
            const LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1))
        ],
      ),
    );
  }

  Widget _buildPulseRow(MarketFact fact) {
    final isUp = !fact.trend.startsWith('-');
    final trendColor = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    // Dynamic Icon based on Industry
    final industryIcon = _getIndustryIcon(currentTopic.industry);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(industryIcon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(fact.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const Spacer(),
          Text(fact.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, size: 14, color: trendColor),
          Text(fact.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor)),
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
    );
  }

  IconData _getIndustryIcon(Naics industry) {
    return switch (industry) {
      Naics.agriculture => Icons.grass,
      Naics.mining => Icons.terrain,
      Naics.utilities => Icons.lightbulb_outline,
      Naics.construction => Icons.construction,
      Naics.manufacturing => Icons.precision_manufacturing,
      Naics.wholesaleTrade => Icons.warehouse,
      Naics.retailTrade => Icons.shopping_cart,
      Naics.transportation => Icons.local_shipping,
      Naics.information => Icons.wifi,
      Naics.finance => Icons.account_balance,
      Naics.realEstate => Icons.home,
      Naics.professionalServices => Icons.business_center,
      Naics.management => Icons.supervisor_account,
      Naics.adminSupport => Icons.support_agent,
      Naics.education => Icons.school,
      Naics.healthCare => Icons.local_hospital,
      Naics.arts => Icons.theater_comedy,
      Naics.accommodation => Icons.hotel,
      Naics.publicAdmin => Icons.gavel,
      _ => Icons.category,
    };
  }
}*/
/*

import 'package:flutter/material.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';

class MarketPulseCard extends StatelessWidget {
  final List<TopicConfig> topics;
  final TopicConfig currentTopic;
  final MarketFact? marketFact;
  final bool isLoading;
  final Function(TopicConfig) onTopicChanged;

  // NEW: Callback for simulation
  final Function(String) onSimulation;

  const MarketPulseCard({
    super.key,
    required this.topics,
    required this.currentTopic,
    required this.marketFact,
    required this.isLoading,
    required this.onTopicChanged,
    required this.onSimulation, // NEW
  });

  void _showSimulationDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.science, color: Color(0xFF6366F1)),
              SizedBox(width: 8),
              Text("Run Simulation"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Inject a hypothetical scenario to test market resilience.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "e.g., 'A rail strike halts all grain shipments for 2 weeks.'",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  Navigator.pop(context);
                  onSimulation(_controller.text);
                }
              },
              child: const Text("Simulate"),
            ),
          ],
        );
      },
    );
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
          // 1. HEADER ROW (Dropdown + Sim Button)
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
              // SIMULATION BUTTON
              InkWell(
                onTap: isLoading ? null : () => _showSimulationDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.science, color: Color(0xFF6366F1)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. MARKET DATA ROW
          if (marketFact != null)
            _buildPulseRow(marketFact!)
          else if (isLoading)
            const LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1))
        ],
      ),
    );
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
      child: Row(
        children: [
          const Icon(Icons.show_chart, size: 16, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(fact.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const Spacer(),
          Text(fact.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, size: 14, color: trendColor),
          Text(fact.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor)),
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
    );
  }
}*/

import 'package:flutter/material.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';

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

  void _showSimulationDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final int cost = 1000;
    final bool canAfford = userPoints >= cost;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.science, color: Color(0xFF6366F1)),
              SizedBox(width: 8),
              Text("Run Simulation"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COST INDICATOR
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: canAfford ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: canAfford ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                        canAfford ? Icons.check_circle : Icons.error,
                        size: 16,
                        color: canAfford ? const Color(0xFF16A34A) : const Color(0xFFDC2626)
                    ),
                    const SizedBox(width: 8),
                    Text(
                      canAfford
                          ? "Cost: $cost pts (You have $userPoints)"
                          : "Insufficient Points ($userPoints/$cost)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: canAfford ? const Color(0xFF166534) : const Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                "Inject a hypothetical scenario to test market resilience.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "e.g., 'A rail strike halts all grain shipments for 2 weeks.'",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? const Color(0xFF6366F1) : Colors.grey,
                foregroundColor: Colors.white,
              ),
              onPressed: canAfford ? () {
                if (_controller.text.isNotEmpty) {
                  Navigator.pop(context);
                  onSimulation(_controller.text);
                }
              } : null,
              child: const Text("Simulate (-1000)"),
            ),
          ],
        );
      },
    );
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
          // 1. TOPIC DROPDOWN ROW
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
                  // FIX: Properly passing 'child' to DropdownButtonHideUnderline
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
              // SIMULATION BUTTON
              InkWell(
                onTap: isLoading ? null : () => _showSimulationDialog(context),
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

          // 2. MARKET DATA ROW (The "Pulse")
          if (marketFact != null)
            _buildPulseRow(marketFact!)
          else if (isLoading)
            const LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1))
        ],
      ),
    );
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
      child: Row(
        children: [
          const Icon(Icons.show_chart, size: 16, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(fact.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const Spacer(),
          Text(fact.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, size: 14, color: trendColor),
          Text(fact.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: trendColor)),
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
    );
  }
}