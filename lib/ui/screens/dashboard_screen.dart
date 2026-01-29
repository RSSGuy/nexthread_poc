

/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';

// NEW WIDGETS
import '../widgets/topic_filter_bar.dart';
import '../widgets/market_pulse_card.dart';

// TOPIC IMPORTS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/agriculture/beef/beef_config.dart';
import '../../topics/agriculture/agtech/agtech_config.dart';
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();

  // REGISTRY
  final List<TopicConfig> _allTopics = [
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
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

  // --- LOGIC ---

  void _initLoad() async {
    setState(() => _loading = true);
    final fact = await _currentTopic.fetchMarketPulse();
    final history = StorageService.getHistory(_currentTopic.id);

    if (mounted) {
      setState(() {
        _marketFact = fact;
        _briefings = history;
        _loading = false;
      });
    }
  }

  void _generateNewBriefing(MarketFact? fact) async {
    GenerationLoader.show(context);
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      await _aiService.generateBriefing(_currentTopic);
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
      if (mounted) setState(() => _loading = false);
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() {
      _briefings = [];
      _marketFact = null;
    });
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
        _initLoad();
      } else {
        _marketFact = null;
        _briefings = [];
      }
    });
  }

  void _onTopicChanged(TopicConfig newTopic) {
    if (newTopic != _currentTopic) {
      setState(() {
        _currentTopic = newTopic;
        _marketFact = null;
      });
      _initLoad();
    }
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
          IconButton(
              icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
              tooltip: "Generate New Report",
              onPressed: _loading ? null : () => _generateNewBriefing(_marketFact)
          ),
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
          // 1. MODULAR FILTER BAR
          TopicFilterBar(
            industries: availableIndustries,
            selectedIndustry: _selectedIndustry,
            onSelected: _onIndustrySelected,
          ),

          // 2. MODULAR MARKET PULSE
          if (_filteredTopics.isNotEmpty)
            MarketPulseCard(
              topics: _filteredTopics,
              currentTopic: _currentTopic,
              marketFact: _marketFact,
              isLoading: _loading,
              onTopicChanged: _onTopicChanged,
            ),

          // 3. BRIEFING LIST
          Expanded(
            child: _loading && _briefings.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : _briefings.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("No Reports Found", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Tap '+' to generate new intelligence.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) => BriefingCard(
                brief: _briefings[index],
                industryTag: _currentTopic.industry.label.split(',')[0],
                topicId: _currentTopic.id,
              ),
            ),
          ),
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
import '../widgets/generation_loader.dart';

// WIDGETS
import '../widgets/topic_filter_bar.dart';
import '../widgets/market_pulse_card.dart';
import '../dialogs/fallback_selector_dialog.dart'; // NEW IMPORT

// TOPIC IMPORTS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/agriculture/beef/beef_config.dart';
import '../../topics/agriculture/agtech/agtech_config.dart';
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
    BeefConfig(),
    AgTechConfig(),
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

  // --- LOGIC ---

  void _initLoad() async {
    setState(() => _loading = true);
    final fact = await _currentTopic.fetchMarketPulse();
    final history = StorageService.getHistory(_currentTopic.id);

    if (mounted) {
      setState(() {
        _marketFact = fact;
        _briefings = history;
        _loading = false;
      });
    }
  }

  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath}) async {
    GenerationLoader.show(context);
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      await _aiService.generateBriefing(_currentTopic, manualFeedPath: manualFeedPath);
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
      if (mounted) setState(() => _loading = false);
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() {
      _briefings = [];
      _marketFact = null;
    });
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
        _initLoad();
      } else {
        _marketFact = null;
        _briefings = [];
      }
    });
  }

  void _onTopicChanged(TopicConfig newTopic) {
    if (newTopic != _currentTopic) {
      setState(() {
        _currentTopic = newTopic;
        _marketFact = null;
      });
      _initLoad();
    }
  }

  // --- NEW: HANDLER FOR FALLBACK SELECTION ---
  void _onFallbackSelected() async {
    // Show dialog and wait for result
    final String? selectedPath = await FallbackSelectorDialog.show(context);

    // If user made a selection, trigger generation
    if (selectedPath != null) {
      _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
    }
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
          // GENERATE MENU
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            tooltip: "Generate Intelligence",
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected(); // Call new handler
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'poll',
                child: Row(
                  children: [
                    Icon(Icons.rss_feed, size: 20, color: Color(0xFF6366F1)),
                    SizedBox(width: 12),
                    Text('Poll RSS Feeds'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'fallback',
                child: Row(
                  children: [
                    Icon(Icons.upload_file, size: 20, color: Color(0xFF64748B)),
                    SizedBox(width: 12),
                    Text('Use Fallback Data'),
                  ],
                ),
              ),
            ],
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
          TopicFilterBar(
            industries: availableIndustries,
            selectedIndustry: _selectedIndustry,
            onSelected: _onIndustrySelected,
          ),

          // 2. MARKET PULSE
          if (_filteredTopics.isNotEmpty)
            MarketPulseCard(
              topics: _filteredTopics,
              currentTopic: _currentTopic,
              marketFact: _marketFact,
              isLoading: _loading,
              onTopicChanged: _onTopicChanged,
            ),

          // 3. BRIEFING LIST
          Expanded(
            child: _loading && _briefings.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : _briefings.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("No Reports Found", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Tap '+' to generate new intelligence.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) => BriefingCard(
                brief: _briefings[index],
                industryTag: _currentTopic.industry.label.split(',')[0],
                topicId: _currentTopic.id,
              ),
            ),
          ),
        ],
      ),
    );
  }
}