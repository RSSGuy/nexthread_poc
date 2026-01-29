import 'package:flutter/material.dart';
import '../../core/models.dart';

class TopicFilterBar extends StatelessWidget {
  final Set<Naics> industries;
  final Naics selectedIndustry;
  final Function(Naics) onSelected;

  const TopicFilterBar({
    super.key,
    required this.industries,
    required this.selectedIndustry,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: industries.map((industry) {
          // Smart Truncation: "Agriculture, forestry..." -> "Agriculture"
          String shortName = industry.label.split(',')[0];
          if (shortName.length > 15) shortName = "${shortName.substring(0, 15)}...";

          final isSelected = selectedIndustry == industry;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(shortName),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) onSelected(industry);
              },
              selectedColor: const Color(0xFFEEF2FF),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}