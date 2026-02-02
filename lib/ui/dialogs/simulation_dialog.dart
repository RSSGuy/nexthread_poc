import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimulationDialog {
  static Future<String?> show(BuildContext context, int userPoints) {
    final TextEditingController controller = TextEditingController();
    const int cost = 1000;
    const int penalty = 500;
    final bool canAfford = userPoints >= cost;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science, color: Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              Text("Market Simulation", style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. GUIDANCE SECTION
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "INSTRUCTIONS",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      _buildBullet("Focus on supply chain, trade, or economic shocks."),
                      _buildBullet("Example: 'What if a rail strike halts grain for 2 weeks?'"),
                      _buildBullet("Example: 'Assume inflation rises to 5% next month.'"),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFD97706)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Irrelevant queries (sports, gossip) will be REJECTED and penalized $penalty pts.",
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. INPUT FIELD
                TextField(
                  controller: controller,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "Enter your 'What-If' scenario...",
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. COST INDICATOR
                Row(
                  children: [
                    Text(
                      canAfford ? "Available: $userPoints pts" : "Insufficient Funds ($userPoints pts)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? const Color(0xFF64748B) : const Color(0xFFEF4444),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "Cost: $cost pts",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? const Color(0xFF6366F1) : Colors.grey,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: canAfford ? () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context, controller.text.trim());
                }
              } : null,
              child: const Text("Simulate"),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Color(0xFF94A3B8))),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
        ],
      ),
    );
  }
}