/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../widgets/briefing_card.dart';

// TOPIC IMPORTS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();

  // --- TOPIC REGISTRY ---
  final List<TopicConfig> _allTopics = [
    WheatConfig(),
    LumberConfig(),
    ApparelConfig(),
    ChemicalConfig(),
  ];

  // STATE
  late Naics _selectedIndustry; // Non-nullable now
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Default to the industry of the first topic (e.g., Agriculture)
    _selectedIndustry = _allTopics.first.industry;
    _currentTopic = _filteredTopics.first;
    _loadData();
  }

  // --- FILTER LOGIC ---
  List<TopicConfig> get _filteredTopics {
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
  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;

    setState(() {
      _selectedIndustry = industry;

      // Auto-select the first topic in the new industry
      final newTopics = _filteredTopics;
      if (newTopics.isNotEmpty) {
        _currentTopic = newTopics.first;
        _marketFact = null;
        _loadData();
      } else {
        _marketFact = null;
        _briefings = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get unique industries from available topics
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
          // 1. DYNAMIC FILTER BAR (No "All" Option)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: availableIndustries.map((industry) {
                // Smart Truncation
                String shortName = industry.label.split(',')[0];
                if(shortName.length > 15) shortName = shortName.substring(0, 15) + "...";

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(shortName),
                    selected: _selectedIndustry == industry,
                    onSelected: (bool selected) {
                      if (selected) _onIndustrySelected(industry);
                    },
                    selectedColor: const Color(0xFFEEF2FF),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: _selectedIndustry == industry ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0))
                    ),
                    labelStyle: TextStyle(
                        color: _selectedIndustry == industry ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                );
              }).toList(),
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

import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart'; // Import Storage
import '../widgets/briefing_card.dart';

// TOPIC IMPORTS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();
  final List<TopicConfig> _allTopics = [
    WheatConfig(),
    LumberConfig(),
    ApparelConfig(),
    ChemicalConfig(),
  ];

  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = []; // Now represents HISTORY
  MarketFact? _marketFact;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedIndustry = _allTopics.first.industry;
    _currentTopic = _filteredTopics.first;
    _initLoad();
  }

  List<TopicConfig> get _filteredTopics {
    return _allTopics.where((t) => t.industry == _selectedIndustry).toList();
  }

  // --- LOADING LOGIC ---

  // 1. Initial Load: Check History first
  void _initLoad() async {
    setState(() => _loading = true);

    // Load Market Data (Always fresh/cached by service)
    final fact = await _currentTopic.fetchMarketPulse();

    // Load History from Hive
    final history = StorageService.getHistory(_currentTopic.id);

    if (history.isNotEmpty) {
      // Show History
      if (mounted) {
        setState(() {
          _marketFact = fact;
          _briefings = history;
          _loading = false;
        });
      }
    } else {
      // No History? Generate Fresh
      _generateNewBriefing(fact);
    }
  }

  // 2. Generate New (Used by Init if empty, or by Refresh button)
  void _generateNewBriefing(MarketFact? fact) async {
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      // Call AI (which saves to Hive internally)
      await _aiService.generateBriefing(_currentTopic);

      // Reload History from Hive to get the update
      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error generating: $e");
      setState(() => _loading = false);
    }
  }

  // 3. System Reset
  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() {
      _briefings = [];
      _marketFact = null;
    });
    // Trigger fresh load for current topic
    _initLoad();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("System Cache Cleared")),
      );
    }
  }

  // --- UI HELPERS ---
  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;
    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;
      if (newTopics.isNotEmpty) {
        _currentTopic = newTopics.first;
        _initLoad(); // Switch topic -> Load history
      } else {
        _marketFact = null;
        _briefings = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // REFRESH BUTTON (Forces New Generation)
          IconButton(
              icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
              tooltip: "Generate New Report",
              onPressed: _loading ? null : () => _generateNewBriefing(_marketFact)
          ),
          // SYSTEM RESET BUTTON
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF94A3B8)),
            tooltip: "System Reset (Clear Cache)",
            onPressed: _loading ? null : _performSystemReset,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. FILTER BAR
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: availableIndustries.map((industry) {
                String shortName = industry.label.split(',')[0];
                if(shortName.length > 15) shortName = shortName.substring(0, 15) + "...";

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(shortName),
                    selected: _selectedIndustry == industry,
                    onSelected: (bool selected) {
                      if (selected) _onIndustrySelected(industry);
                    },
                    selectedColor: const Color(0xFFEEF2FF),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _selectedIndustry == industry ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0))),
                    labelStyle: TextStyle(
                        color: _selectedIndustry == industry ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. TOPIC & PULSE
          if (_filteredTopics.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF8FAFC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            _initLoad(); // Switch Topic
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_marketFact != null)
                    _buildPulseItem(_marketFact!)
                  else if (_loading)
                    const LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1))
                ],
              ),
            ),

          // 3. BRIEFING LIST (HISTORY)
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
    // (Keep existing pulse item code)
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

import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';
import '../widgets/briefing_card.dart';

// TOPIC IMPORTS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';
import '../widgets/generation_loader.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();
  final List<TopicConfig> _allTopics = [
    WheatConfig(),
    LumberConfig(),
    ApparelConfig(),
    ChemicalConfig(),
  ];

  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedIndustry = _allTopics.first.industry;
    _currentTopic = _filteredTopics.first;
    _initLoad();
  }

  List<TopicConfig> get _filteredTopics {
    return _allTopics.where((t) => t.industry == _selectedIndustry).toList();
  }

  // --- LOADING LOGIC ---

  // 1. Initial Load: ONLY Check History. Do NOT Auto-Generate.
  void _initLoad() async {
    setState(() => _loading = true);

    // Load Market Data (Fast/Cached)
    final fact = await _currentTopic.fetchMarketPulse();

    // Load History from Hive
    final history = StorageService.getHistory(_currentTopic.id);

    if (mounted) {
      setState(() {
        _marketFact = fact;
        _briefings = history; // If empty, list is just empty.
        _loading = false;
      });
    }
  }

  // 2. Generate New (Only called by Refresh Button)
*/
/*  void _generateNewBriefing(MarketFact? fact) async {
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      // Call AI (saves to Hive internally)
      await _aiService.generateBriefing(_currentTopic);

      // Reload History to get the new item
      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error generating: $e");
      setState(() => _loading = false);
    }
  }*/
/*

  // 2. Generate New (Only called by Refresh Button)
  void _generateNewBriefing(MarketFact? fact) async {
    // Show the Blocking Modal
    GenerationLoader.show(context);

    // We still keep _loading = true to prevent other background interactions if needed
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      // Call AI (saves to Hive internally)
      await _aiService.generateBriefing(_currentTopic);

      // Reload History to get the new item
      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error generating: $e");
      if (mounted) {
        setState(() => _loading = false);
        // Optional: Show error snackbar here
      }
    } finally {
      // HIDE the Blocking Modal regardless of success/fail
      if (mounted) {
        GenerationLoader.hide(context);
      }
    }
  }

  // 3. System Reset
  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() {
      _briefings = [];
      _marketFact = null;
    });
    // Just load market pulse, do not generate report
    _initLoad();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("System Cache Cleared")),
      );
    }
  }

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;
    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;
      if (newTopics.isNotEmpty) {
        _currentTopic = newTopics.first;
        _initLoad(); // Switch topic -> Load history only
      } else {
        _marketFact = null;
        _briefings = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // GENERATE BUTTON
          IconButton(
              icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
              tooltip: "Generate New Report",
              // This is the ONLY place generation is triggered now
              onPressed: _loading ? null : () => _generateNewBriefing(_marketFact)
          ),
          // RESET BUTTON
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF94A3B8)),
            tooltip: "System Reset",
            onPressed: _loading ? null : _performSystemReset,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. FILTER BAR
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: availableIndustries.map((industry) {
                String shortName = industry.label.split(',')[0];
                if(shortName.length > 15) shortName = shortName.substring(0, 15) + "...";

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(shortName),
                    selected: _selectedIndustry == industry,
                    onSelected: (bool selected) {
                      if (selected) _onIndustrySelected(industry);
                    },
                    selectedColor: const Color(0xFFEEF2FF),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _selectedIndustry == industry ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0))),
                    labelStyle: TextStyle(
                        color: _selectedIndustry == industry ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. TOPIC & PULSE
          if (_filteredTopics.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF8FAFC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            _initLoad(); // Switch Topic
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_marketFact != null)
                    _buildPulseItem(_marketFact!)
                  else if (_loading)
                    const LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1))
                ],
              ),
            ),

          // 3. BRIEFING LIST (HISTORY)
          Expanded(
            child: _loading && _briefings.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : _briefings.isEmpty
            // UPDATED EMPTY STATE MESSAGE
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "No Reports Found",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tap '+' to generate new intelligence.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';
import '../widgets/briefing_card.dart';

// TOPIC IMPORTS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';
import '../widgets/generation_loader.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();
  final List<TopicConfig> _allTopics = [
    WheatConfig(),
    LumberConfig(),
    ApparelConfig(),
    ChemicalConfig(),
  ];

  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedIndustry = _allTopics.first.industry;
    _currentTopic = _filteredTopics.first;
    _initLoad();
  }

  List<TopicConfig> get _filteredTopics {
    return _allTopics.where((t) => t.industry == _selectedIndustry).toList();
  }

  // --- LOADING LOGIC ---

  // 1. Initial Load: ONLY Check History. Do NOT Auto-Generate.
  void _initLoad() async {
    setState(() => _loading = true);

    // Load Market Data (Fast/Cached)
    final fact = await _currentTopic.fetchMarketPulse();

    // Load History from Hive
    final history = StorageService.getHistory(_currentTopic.id);

    if (mounted) {
      setState(() {
        _marketFact = fact;
        _briefings = history; // If empty, list is just empty.
        _loading = false;
      });
    }
  }

  // 2. Generate New (Only called by Refresh Button)
  void _generateNewBriefing(MarketFact? fact) async {
    // Show the Blocking Modal
    GenerationLoader.show(context);

    // We still keep _loading = true to prevent other background interactions if needed
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      // Call AI (saves to Hive internally)
      await _aiService.generateBriefing(_currentTopic);

      // Reload History to get the new item
      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error generating: $e");
      if (mounted) {
        setState(() => _loading = false);
        // Optional: Show error snackbar here
      }
    } finally {
      // HIDE the Blocking Modal regardless of success/fail
      if (mounted) {
        GenerationLoader.hide(context);
      }
    }
  }

  // 3. System Reset
  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() {
      _briefings = [];
      _marketFact = null;
    });
    // Just load market pulse, do not generate report
    _initLoad();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("System Cache Cleared")),
      );
    }
  }

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;
    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;
      if (newTopics.isNotEmpty) {
        _currentTopic = newTopics.first;
        _initLoad(); // Switch topic -> Load history only
      } else {
        _marketFact = null;
        _briefings = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // GENERATE BUTTON
          IconButton(
              icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
              tooltip: "Generate New Report",
              // This is the ONLY place generation is triggered now
              onPressed: _loading ? null : () => _generateNewBriefing(_marketFact)
          ),
          // RESET BUTTON
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF94A3B8)),
            tooltip: "System Reset",
            onPressed: _loading ? null : _performSystemReset,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. FILTER BAR
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: availableIndustries.map((industry) {
                String shortName = industry.label.split(',')[0];
                if(shortName.length > 15) shortName = shortName.substring(0, 15) + "...";

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(shortName),
                    selected: _selectedIndustry == industry,
                    onSelected: (bool selected) {
                      if (selected) _onIndustrySelected(industry);
                    },
                    selectedColor: const Color(0xFFEEF2FF),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: _selectedIndustry == industry ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0))),
                    labelStyle: TextStyle(
                        color: _selectedIndustry == industry ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. TOPIC & PULSE
          if (_filteredTopics.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF8FAFC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            _initLoad(); // Switch Topic
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_marketFact != null)
                    _buildPulseItem(_marketFact!)
                  else if (_loading)
                    const LinearProgressIndicator(minHeight: 2, color: Color(0xFF6366F1))
                ],
              ),
            ),

          // 3. BRIEFING LIST (HISTORY)
          Expanded(
            child: _loading && _briefings.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : _briefings.isEmpty
            // UPDATED EMPTY STATE MESSAGE
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "No Reports Found",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tap '+' to generate new intelligence.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) => BriefingCard(
                brief: _briefings[index],
                industryTag: _currentTopic.industry.label.split(',')[0],
                topicId: _currentTopic.id, // NEW PARAMETER
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
}