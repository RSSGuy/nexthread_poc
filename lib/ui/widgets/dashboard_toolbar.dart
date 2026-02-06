import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardToolbar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final int userPoints;
  final bool loading;
  final String currentProviderName;
  final VoidCallback onPollFeeds;
  final VoidCallback onFallback;
  final VoidCallback onModelSelect;
  final VoidCallback onSystemReset;
  final VoidCallback onFeedTester;

  const DashboardToolbar({
    super.key,
    required this.tabController,
    required this.userPoints,
    required this.loading,
    required this.currentProviderName,
    required this.onPollFeeds,
    required this.onFallback,
    required this.onModelSelect,
    required this.onSystemReset,
    required this.onFeedTester,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48.0); // AppBar + TabBar

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.grain, color: Color(0xFF6366F1)),
          const SizedBox(width: 8),
          Text(
            'NexThread',
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      bottom: TabBar(
        controller: tabController,
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: const Color(0xFF6366F1),
        tabs: const [
          Tab(text: "Standard Industry Analytics"),
          Tab(text: "Global Trends"),
        ],
      ),
      actions: [
        // Points Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                "$userPoints",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),

        // Feed Tester Button
        IconButton(
          icon: const Icon(Icons.network_check, color: Color(0xFF64748B)),
          tooltip: "Test Feed Health",
          onPressed: onFeedTester,
        ),

        // Action Menu
        PopupMenuButton<String>(
          icon: Icon(
            Icons.add_circle_outline,
            color: loading ? Colors.grey : const Color(0xFF6366F1),
          ),
          enabled: !loading,
          onSelected: (value) {
            if (value == 'poll') onPollFeeds();
            else if (value == 'fallback') onFallback();
            else if (value == 'model') onModelSelect();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'poll', child: Text('Poll RSS Feeds')),
            const PopupMenuItem(value: 'fallback', child: Text('Use Fallback Data')),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'model',
              child: Text('Model: ${currentProviderName.split(' ')[0]}'),
            ),
          ],
        ),

        // Reset Button
        IconButton(
          icon: const Icon(Icons.delete_forever, color: Color(0xFF94A3B8)),
          onPressed: loading ? null : onSystemReset,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}