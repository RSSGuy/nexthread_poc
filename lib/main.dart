
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/ai_service.dart';
import 'core/topic_config.dart';
import 'core/models.dart';
import 'ui/widgets/briefing_card.dart';

// --- TOPIC IMPORTS ---
import 'topics/agriculture/wheat/wheat_config.dart';
import 'topics/agriculture/lumber/lumber_config.dart';
import 'topics/manufacturing/apparel/apparel_config.dart'; // NEW IMPORT

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

  // --- TOPIC REGISTRY ---
  // Adding ApparelConfig here automatically creates the "Manufacturing" filter
  final List<TopicConfig> _allTopics = [
    WheatConfig(),
    LumberConfig(),
    ApparelConfig(),
  ];

  // STATE
  Naics? _selectedIndustry; // Null means "All"
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentTopic = _allTopics.first;
    _loadData();
  }

  // --- FILTER LOGIC ---
  List<TopicConfig> get _filteredTopics {
    if (_selectedIndustry == null) return _allTopics;
    return _allTopics.where((t) => t.industry == _selectedIndustry).toList();
  }

  // --- LOADER ---
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

  // --- UI HELPERS ---
  void _onIndustrySelected(Naics? industry) {
    setState(() {
      _selectedIndustry = industry;

      // If current topic is hidden by filter, switch to first visible one
      if (!_filteredTopics.contains(_currentTopic)) {
        if (_filteredTopics.isNotEmpty) {
          _currentTopic = _filteredTopics.first;
          _marketFact = null;
          _loadData();
        } else {
          _marketFact = null;
          _briefings = [];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Filter Generation:
    // This scans _allTopics and finds unique industries (Agriculture, Manufacturing, etc.)
    final Set<Naics> availableIndustries = _allTopics.map((t) => t.industry).toSet();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text('NexThread', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. DYNAMIC FILTER BAR
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // "ALL" CHIP
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text("All"),
                    selected: _selectedIndustry == null,
                    onSelected: (bool selected) => _onIndustrySelected(null),
                    selectedColor: const Color(0xFFEEF2FF),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _selectedIndustry == null ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0))),
                    labelStyle: TextStyle(
                        color: _selectedIndustry == null ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                // INDUSTRY CHIPS
                ...availableIndustries.map((industry) {
                  // Smart Truncation: "Agriculture, forestry..." -> "Agriculture"
                  String shortName = industry.label.split(',')[0];
                  if(shortName.length > 15) shortName = shortName.substring(0, 15) + "...";

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(shortName),
                      selected: _selectedIndustry == industry,
                      onSelected: (bool selected) => _onIndustrySelected(selected ? industry : null),
                      selectedColor: const Color(0xFFEEF2FF),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _selectedIndustry == industry ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0))),
                      labelStyle: TextStyle(
                          color: _selectedIndustry == industry ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // 2. TOPIC SELECTOR & MARKET PULSE
          if (_filteredTopics.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF8FAFC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TopicConfig>(
                        value: _currentTopic,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1)),
                        items: _filteredTopics.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
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
                  ),

                  const SizedBox(height: 12),

                  // Market Pulse
                  if (_marketFact != null)
                    _buildPulseItem(_marketFact!)
                  else if (_loading)
                    const LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1))
                ],
              ),
            ),

          // 3. BRIEFING CARDS
          Expanded(
            child: _loading && _briefings.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : _briefings.isEmpty
                ? const Center(child: Text("No Intelligence Available", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) => BriefingCard(
                brief: _briefings[index],
                industryTag: _currentTopic.industry.label.split(',')[0],
              ),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
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
            child: Text(fact.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fact.status == "Stable" ? const Color(0xFF64748B) : const Color(0xFFEF4444))),
          )
        ],
      ),
    );
  }
}*/
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the new screen location
import 'ui/screens/dashboard_screen.dart';

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
}*/
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/screens/dashboard_screen.dart';
import 'core/storage_service.dart'; // IMPORT STORAGE

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await StorageService.init();

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
}*/
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ui/screens/dashboard_screen.dart';
import 'core/storage_service.dart'; // IMPORT STORAGE

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (This is CRITICAL for persistent storage)
  await StorageService.init();

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