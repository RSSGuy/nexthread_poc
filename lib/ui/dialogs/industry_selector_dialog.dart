/*
import 'package:flutter/material.dart';
import '../../core/models.dart';

class IndustrySelectorDialog extends StatelessWidget {
  final Set<Naics> availableIndustries;
  final Naics currentIndustry;

  const IndustrySelectorDialog({
    super.key,
    required this.availableIndustries,
    required this.currentIndustry,
  });

  /// Helper to show the dialog from anywhere
  static Future<Naics?> show(BuildContext context, Set<Naics> industries, Naics current) {
    return showModalBottomSheet<Naics>(
      context: context,
      isScrollControlled: true, // Allows the sheet to take up more screen space
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: IndustrySelectorDialog(
              availableIndustries: industries,
              currentIndustry: current,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort industries alphabetically by their label for easier finding
    final sortedIndustries = availableIndustries.toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return Column(
      children: [
        // HEADER
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.domain, color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Select Industry Sector",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),

        // LIST
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sortedIndustries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = sortedIndustries[index];
              final isSelected = item == currentIndustry;

              return InkWell(
                onTap: () => Navigator.pop(context, item),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selection Indicator
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFCBD5E1),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Label
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF475569),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}*/

import 'package:flutter/material.dart';
import '../../core/models.dart';
import '../../core/industry_provider.dart';

class IndustrySelectorDialog extends StatelessWidget {
  final Naics selectedIndustry;
  final IndustryProvider _provider = IndustryProvider();

  IndustrySelectorDialog({
    super.key,
    required this.selectedIndustry,
  });

  static Future<Naics?> show(BuildContext context, Naics current) {
    return showDialog<Naics>(
      context: context,
      builder: (context) => IndustrySelectorDialog(selectedIndustry: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get ALL industries (sorted)
    final allIndustries = _provider.getAllIndustriesSorted();

    // 2. Get the set of ACTIVE industries
    final activeSet = _provider.getActiveIndustries();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.domain, color: Color(0xFF6366F1), size: 24),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Select Industry",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // LIST
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: allIndustries.length,
                itemBuilder: (context, index) {
                  final industry = allIndustries[index];
                  final isSupported = activeSet.contains(industry);
                  final isSelected = industry == selectedIndustry;

                  return InkWell(
                    onTap: isSupported
                        ? () => Navigator.pop(context, industry)
                        : null, // Disable tap for inactive
                    child: Container(
                      color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          // RADIO / ICON
                          if (isSelected)
                            const Icon(Icons.radio_button_checked, color: Color(0xFF6366F1), size: 20)
                          else if (isSupported)
                            const Icon(Icons.radio_button_unchecked, color: Color(0xFFCBD5E1), size: 20)
                          else
                            const Icon(Icons.lock_outline, color: Color(0xFFE2E8F0), size: 20),

                          const SizedBox(width: 16),

                          // TEXT & LABEL
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  industry.label,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSupported
                                        ? const Color(0xFF334155) // Normal
                                        : const Color(0xFF94A3B8), // Greyed out
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // STATUS BADGE
                          if (!isSupported)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Text(
                                "SOON",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const Divider(height: 1),

          // FOOTER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}