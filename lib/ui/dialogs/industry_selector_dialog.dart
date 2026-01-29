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
}