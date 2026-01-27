import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/ai_service.dart';
import 'core/topic_config.dart';
import 'core/models.dart';

// NEW IMPORT PATH
import 'ui/widgets/briefing_card.dart';

// UPDATED IMPORT: Point to the new agriculture folder
import 'topics/agriculture/wheat/wheat_config.dart';

void main() {
  runApp(const NexThreadApp());
}

class NexThreadApp extends StatelessWidget {
  const NexThreadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexThread POC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate-100
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF10B981), // Emerald
          error: const Color(0xFFEF4444), // Rose
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();

  final List<TopicConfig> _topics = [
    WheatConfig(),
  ];

  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentTopic = _topics.first;
    _loadData();
  }

  void _loadData() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _briefings = [];
    });

    try {
      final fact = await _currentTopic.fetchMarketPulse();

      setState(() {
        _marketFact = fact;
      });

      final jsonMap = await _aiService.generateBriefing(_currentTopic);
      final List<dynamic> briefsJson = jsonMap['briefs'];

      if (mounted) {
        setState(() {
          _briefings = briefsJson.map((json) => Briefing.fromJson(json)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: DropdownButtonHideUnderline(
          child: DropdownButton<TopicConfig>(
            value: _currentTopic,
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1)),
            borderRadius: BorderRadius.circular(12),
            items: _topics.map((t) => DropdownMenuItem(
              value: t,
              child: Row(
                children: [
                  const Icon(Icons.grid_view, size: 18, color: Color(0xFF0F172A)),
                  const SizedBox(width: 8),
                  Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                ],
              ),
            )).toList(),
            onChanged: (newTopic) {
              if (newTopic != null && newTopic != _currentTopic) {
                setState(() {
                  _currentTopic = newTopic;
                  _marketFact = null;
                });
                _loadData();
              }
            },
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.refresh, color: _loading ? Colors.grey : const Color(0xFF64748B)),
              onPressed: _loading ? null : _loadData
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (_marketFact != null)
            Container(
              height: 50,
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E7FF)))
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildPulseItem(_marketFact!),
                ],
              ),
            ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : _briefings.isEmpty
                ? const Center(child: Text("No Intelligence Available", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) => BriefingCard(brief: _briefings[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseItem(MarketFact fact) {
    final isUp = !fact.trend.startsWith('-');
    final trendColor = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      children: [
        Text(fact.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        const SizedBox(width: 8),
        Text(fact.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Icon(icon, size: 12, color: trendColor),
        Text(fact.trend, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: trendColor)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300)
          ),
          child: Text(fact.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }
}