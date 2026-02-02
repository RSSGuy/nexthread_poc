

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
/*

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
}*/

/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/topic_filter_bar.dart';
import '../widgets/market_pulse_card.dart';
import '../dialogs/fallback_selector_dialog.dart';

// TOPIC CONFIGURATIONS
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
  // Service Instance
  final AIService _aiService = AIService();

  // Topic Registry
  final List<TopicConfig> _allTopics = [
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),
    ApparelConfig(),
    ChemicalConfig(),
  ];

  // State Variables
  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;
  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Default to the first industry and topic available
    _selectedIndustry = _allTopics.first.industry;
    _currentTopic = _filteredTopics.first;
    _initLoad();
  }

  // Helper to filter topics based on selected industry tab
  List<TopicConfig> get _filteredTopics {
    return _allTopics.where((t) => t.industry == _selectedIndustry).toList();
  }

  // --- DATA LOADING LOGIC ---

  void _initLoad() async {
    setState(() => _loading = true);

    // Fetch latest market data and local history in parallel
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

  // Core Generation Method
  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath}) async {
    GenerationLoader.show(context); // Show overlay loader
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      // Delegate to AIService (which uses the active provider)
      await _aiService.generateBriefing(_currentTopic, manualFeedPath: manualFeedPath);

      // Refresh history from storage
      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error generating briefing: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Generation Failed: $e")),
        );
      }
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  // System Reset (Clear Cache)
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

  // --- EVENT HANDLERS ---

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;
    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;
      // Reset to first topic of new industry
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
        _marketFact = null; // Clear old data while loading
      });
      _initLoad();
    }
  }

  // Handler: "Use Fallback Data"
  void _onFallbackSelected() async {
    // Open the Dialog to choose XML file
    final String? selectedPath = await FallbackSelectorDialog.show(context);

    if (selectedPath != null) {
      _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
    }
  }

  // Handler: "Select AI Model"
  void _showModelSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("Select AI Model"),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(16),
              onPressed: () {
                _aiService.setProvider('openai');
                Navigator.pop(context);
                setState(() {}); // Rebuild to update UI label
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Switched to OpenAI (GPT-4)")),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.cloud, color: Colors.blue),
                  SizedBox(width: 12),
                  Text("OpenAI (Cloud)"),
                ],
              ),
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(16),
              onPressed: () {
                _aiService.setProvider('ollama');
                Navigator.pop(context);
                setState(() {}); // Rebuild to update UI label
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Switched to Ollama (Local)")),
                );
              },
              child: const Row(
                children: [
                  Icon(Icons.computer, color: Colors.orange),
                  SizedBox(width: 12),
                  Text("Ollama (Localhost)"),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // --- UI BUILD ---

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
          // ACTION MENU (Generate & Settings)
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            tooltip: "Generate Intelligence",
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected();
              } else if (value == 'model') {
                _showModelSelector();
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
              const PopupMenuDivider(),
              // Dynamic Model Switcher Item
              PopupMenuItem<String>(
                value: 'model',
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest, size: 20, color: Colors.black54),
                    const SizedBox(width: 12),
                    // Display current provider name dynamically
                    Text('Model: ${_aiService.currentProviderName.split(' ')[0]}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
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
          // 1. FILTER BAR (Industry Selection)
          TopicFilterBar(
            industries: availableIndustries,
            selectedIndustry: _selectedIndustry,
            onSelected: _onIndustrySelected,
          ),

          // 2. MARKET PULSE (Topic Selection & Live Data)
          if (_filteredTopics.isNotEmpty)
            MarketPulseCard(
              topics: _filteredTopics,
              currentTopic: _currentTopic,
              marketFact: _marketFact,
              isLoading: _loading,
              onTopicChanged: _onTopicChanged,
            ),

          // 3. BRIEFING LIST (The Feed)
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
                industryTag: _currentTopic.industry.label.split(',')[0], // "Agriculture"
                topicId: _currentTopic.id,
              ),
            ),
          ),
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

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/topic_filter_bar.dart';
import '../widgets/market_pulse_card.dart';
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart'; // NEW IMPORT

// TOPIC CONFIGURATIONS
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
  // Service Instance
  final AIService _aiService = AIService();

  // Topic Registry
  final List<TopicConfig> _allTopics = [
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),
    ApparelConfig(),
    ChemicalConfig(),
  ];

  // State Variables
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

  // Helper to filter topics based on selected industry tab
  List<TopicConfig> get _filteredTopics {
    return _allTopics.where((t) => t.industry == _selectedIndustry).toList();
  }

  // --- DATA LOADING LOGIC ---

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

  // Core Generation Method
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
      print("Error generating briefing: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Generation Failed: $e")),
        );
      }
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

  // --- EVENT HANDLERS ---

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

  // Handler: "Use Fallback Data"
  void _onFallbackSelected() async {
    final String? selectedPath = await FallbackSelectorDialog.show(context);

    if (selectedPath != null) {
      _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
    }
  }

  // Handler: "Select AI Model" (REFACTORED)
  void _onModelSelect() async {
    // 1. Show the dialog and get the provider key ('openai', 'ollama', 'gemini')
    final String? providerKey = await ModelSelectorDialog.show(context);

    // 2. If a selection was made, update the service and UI
    if (providerKey != null) {
      _aiService.setProvider(providerKey);

      setState(() {}); // Rebuild to update the "Model: ..." label in the menu

      if (mounted) {
        // Map key to a friendly name for the snackbar
        String friendlyName = switch (providerKey) {
          'openai' => 'OpenAI (GPT-4)',
          'ollama' => 'Ollama (Local)',
          'gemini' => 'Google Gemini',
          _ => providerKey,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Switched to $friendlyName")),
        );
      }
    }
  }

  // --- UI BUILD ---

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
          // ACTION MENU
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            tooltip: "Generate Intelligence",
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected();
              } else if (value == 'model') {
                _onModelSelect(); // Uses the new handler
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
              const PopupMenuDivider(),
              // Dynamic Model Switcher Item
              PopupMenuItem<String>(
                value: 'model',
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest, size: 20, color: Colors.black54),
                    const SizedBox(width: 12),
                    // Display current provider name dynamically
                    Text('Model: ${_aiService.currentProviderName.split(' ')[0]}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
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
}*/

/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CORE SERVICES
import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/topic_filter_bar.dart';
import '../widgets/market_pulse_card.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';

// AGRICULTURE TOPICS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/agriculture/beef/beef_config.dart';
import '../../topics/agriculture/agtech/agtech_config.dart';

// MANUFACTURING TOPICS
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';
import '../../topics/manufacturing/canadian_manufacturing/canadian_manufacturing_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Service Instance
  final AIService _aiService = AIService();

  // Topic Registry - The Single Source of Truth for available sectors
  final List<TopicConfig> _allTopics = [
    // Agriculture
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),
    // Manufacturing
    ApparelConfig(),
    ChemicalConfig(),
    CanadianManufacturingConfig(),
  ];

  // State Variables
  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Initialize default selection (Agriculture -> First Topic)
    _selectedIndustry = _allTopics.first.industry;
    _currentTopic = _filteredTopics.first;

    // Initial Data Load
    _initLoad();
  }

  // Computed property to filter topics based on the selected industry tab
  List<TopicConfig> get _filteredTopics {
    return _allTopics.where((t) => t.industry == _selectedIndustry).toList();
  }

  // --- DATA LOADING LOGIC ---

  void _initLoad() async {
    setState(() => _loading = true);

    // Fetch latest market data and local history in parallel
    // This ensures the UI is responsive immediately upon launch
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

  // Core Generation Method
  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath}) async {
    GenerationLoader.show(context); // Show full-screen loader overlay
    setState(() => _loading = true);

    // If market fact is stale or null, re-fetch it
    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      // Delegate generation to the AI Service
      // This will use whatever provider is currently active (OpenAI/Ollama/Gemini)
      await _aiService.generateBriefing(_currentTopic, manualFeedPath: manualFeedPath);

      // Retrieve the newly saved briefing from local storage
      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error generating briefing: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Generation Failed: $e")),
        );
      }
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  // System Reset (Clear Cache)
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

  // --- EVENT HANDLERS ---

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;

    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;

      // Default to the first topic of the new industry
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
        _marketFact = null; // Clear old data to show loading state
      });
      _initLoad();
    }
  }

  // Handler: "Use Fallback Data"
  void _onFallbackSelected() async {
    // Open the Dialog to choose XML file from assets
    final String? selectedPath = await FallbackSelectorDialog.show(context);

    if (selectedPath != null) {
      _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
    }
  }

  // Handler: "Select AI Model"
  void _onModelSelect() async {
    // Open the standalone Dialog
    final String? providerKey = await ModelSelectorDialog.show(context);

    if (providerKey != null) {
      // Update Service Strategy
      _aiService.setProvider(providerKey);

      // Force UI rebuild to update the "Model: ..." label in the menu
      setState(() {});

      if (mounted) {
        String friendlyName = switch (providerKey) {
          'openai' => 'OpenAI (GPT-4)',
          'ollama' => 'Ollama (Local)',
          'gemini' => 'Google Gemini',
          _ => providerKey,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Switched to $friendlyName")),
        );
      }
    }
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    final Set<Naics> availableIndustries = _allTopics.map((t) => t.industry).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50 background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(
                'NexThread',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))
            ),
          ],
        ),
        actions: [
          // ACTION MENU (Generate & Settings)
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            tooltip: "Generate Intelligence",
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected();
              } else if (value == 'model') {
                _onModelSelect();
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
              const PopupMenuDivider(),
              // Dynamic Model Switcher Item
              PopupMenuItem<String>(
                value: 'model',
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest, size: 20, color: Colors.black54),
                    const SizedBox(width: 12),
                    // Display current provider name dynamically
                    Text(
                        'Model: ${_aiService.currentProviderName.split(' ')[0]}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87)
                    ),
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
          // 1. FILTER BAR (Industry Selection)
          TopicFilterBar(
            industries: availableIndustries,
            selectedIndustry: _selectedIndustry,
            onSelected: _onIndustrySelected,
          ),

          // 2. MARKET PULSE (Topic Selection & Live Data)
          if (_filteredTopics.isNotEmpty)
            MarketPulseCard(
              topics: _filteredTopics,
              currentTopic: _currentTopic,
              marketFact: _marketFact,
              isLoading: _loading,
              onTopicChanged: _onTopicChanged,
            ),

          // 3. BRIEFING LIST (The Feed)
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
                industryTag: _currentTopic.industry.label.split(',')[0], // e.g. "Agriculture"
                topicId: _currentTopic.id,
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CORE SERVICES
import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/topic_filter_bar.dart';
import '../widgets/market_pulse_card.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';

// AGRICULTURE TOPICS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/agriculture/beef/beef_config.dart';
import '../../topics/agriculture/agtech/agtech_config.dart';

// MANUFACTURING TOPICS
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';
import '../../topics/manufacturing/canadian_manufacturing/canadian_manufacturing_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Service Instance
  final AIService _aiService = AIService();

  // Topic Registry - The Single Source of Truth for available sectors
  final List<TopicConfig> _allTopics = [
    // --- Agriculture ---
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),

    // --- Manufacturing ---
    ApparelConfig(),
    ChemicalConfig(),
    CanadianManufacturingConfig(),

    // --- Rest of NAICS (Stubs) ---
    StubTopicConfig("mining_gen", "General Mining", Naics.mining),
    StubTopicConfig("util_grid", "Utilities & Grid", Naics.utilities),
    StubTopicConfig("const_cre", "Construction & RE", Naics.construction),
    StubTopicConfig("whole_log", "Wholesale Logistics", Naics.wholesaleTrade),
    StubTopicConfig("retail_cons", "Retail Sentiment", Naics.retailTrade),
    StubTopicConfig("trans_freight", "Freight & Transport", Naics.transportation),
    StubTopicConfig("info_tech", "Tech & Information", Naics.information),
    StubTopicConfig("fin_bank", "Finance & Banking", Naics.finance),
    StubTopicConfig("real_housing", "Housing Market", Naics.realEstate),
    StubTopicConfig("prof_svcs", "Professional Svcs", Naics.professionalServices),
    StubTopicConfig("mgmt_corp", "Corporate Mgmt", Naics.management),
    StubTopicConfig("admin_labor", "Admin & Support", Naics.adminSupport),
    StubTopicConfig("edu_high", "Higher Education", Naics.education),
    StubTopicConfig("health_pharma", "Health & Pharma", Naics.healthCare),
    StubTopicConfig("arts_ent", "Arts & Entertainment", Naics.arts),
    StubTopicConfig("accom_hosp", "Hospitality", Naics.accommodation),
    StubTopicConfig("other_svcs", "Other Services", Naics.otherServices),
    StubTopicConfig("pub_policy", "Public Policy", Naics.publicAdmin),
  ];

  // State Variables
  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Initialize default selection (Agriculture -> First Topic)
    _selectedIndustry = _allTopics.first.industry;
    _currentTopic = _filteredTopics.first;

    // Initial Data Load
    _initLoad();
  }

  // Computed property to filter topics based on the selected industry tab
  List<TopicConfig> get _filteredTopics {
    return _allTopics.where((t) => t.industry == _selectedIndustry).toList();
  }

  // --- DATA LOADING LOGIC ---

  void _initLoad() async {
    setState(() => _loading = true);

    // Fetch latest market data and local history in parallel
    // This ensures the UI is responsive immediately upon launch
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

  // Core Generation Method
  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath}) async {
    GenerationLoader.show(context); // Show full-screen loader overlay
    setState(() => _loading = true);

    // If market fact is stale or null, re-fetch it
    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      // Delegate generation to the AI Service
      // This will use whatever provider is currently active (OpenAI/Ollama/Gemini)
      await _aiService.generateBriefing(_currentTopic, manualFeedPath: manualFeedPath);

      // Retrieve the newly saved briefing from local storage
      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error generating briefing: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Generation Failed: $e")),
        );
      }
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  // System Reset (Clear Cache)
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

  // --- EVENT HANDLERS ---

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;

    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;

      // Default to the first topic of the new industry
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
        _marketFact = null; // Clear old data to show loading state
      });
      _initLoad();
    }
  }

  // Handler: "Use Fallback Data"
  void _onFallbackSelected() async {
    // Open the Dialog to choose XML file from assets
    final String? selectedPath = await FallbackSelectorDialog.show(context);

    if (selectedPath != null) {
      _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
    }
  }

  // Handler: "Select AI Model"
  void _onModelSelect() async {
    // Open the standalone Dialog
    final String? providerKey = await ModelSelectorDialog.show(context);

    if (providerKey != null) {
      // Update Service Strategy
      _aiService.setProvider(providerKey);

      // Force UI rebuild to update the "Model: ..." label in the menu
      setState(() {});

      if (mounted) {
        String friendlyName = switch (providerKey) {
          'openai' => 'OpenAI (GPT-4)',
          'ollama' => 'Ollama (Local)',
          'gemini' => 'Google Gemini',
          _ => providerKey,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Switched to $friendlyName")),
        );
      }
    }
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    final Set<Naics> availableIndustries = _allTopics.map((t) => t.industry).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50 background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(
                'NexThread',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))
            ),
          ],
        ),
        actions: [
          // ACTION MENU (Generate & Settings)
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            tooltip: "Generate Intelligence",
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected();
              } else if (value == 'model') {
                _onModelSelect();
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
              const PopupMenuDivider(),
              // Dynamic Model Switcher Item
              PopupMenuItem<String>(
                value: 'model',
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest, size: 20, color: Colors.black54),
                    const SizedBox(width: 12),
                    // Display current provider name dynamically
                    Text(
                        'Model: ${_aiService.currentProviderName.split(' ')[0]}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87)
                    ),
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
          // 1. FILTER BAR (Industry Selection)
          TopicFilterBar(
            industries: availableIndustries,
            selectedIndustry: _selectedIndustry,
            onSelected: _onIndustrySelected,
          ),

          // 2. MARKET PULSE (Topic Selection & Live Data)
          if (_filteredTopics.isNotEmpty)
            MarketPulseCard(
              topics: _filteredTopics,
              currentTopic: _currentTopic,
              marketFact: _marketFact,
              isLoading: _loading,
              onTopicChanged: _onTopicChanged,
            ),

          // 3. BRIEFING LIST (The Feed)
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
                industryTag: _currentTopic.industry.label.split(',')[0], // e.g. "Agriculture"
                topicId: _currentTopic.id,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER CONFIG FOR UNIMPLEMENTED INDUSTRIES ---
class StubTopicConfig implements TopicConfig {
  @override
  final String id;
  @override
  final String name;
  @override
  final Naics industry;

  StubTopicConfig(this.id, this.name, this.industry);

  @override
  List<NewsSourceConfig> get sources => [];

  @override
  List<String> get keywords => [];

  @override
  String get riskRules => "Standard risk assessment rules apply for the $name sector.";

  @override
  Future<MarketFact> fetchMarketPulse() async {
    // Return a dummy placeholder fact for the stub
    return MarketFact(
      category: industry.label.split(',')[0], // Brief category
      name: "$name Index",
      value: "105.20",
      trend: "+0.4%",
      status: "Stable",
      lineData: [102.0, 103.5, 104.0, 104.8, 105.2],
    );
  }
}*/
/*

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CORE SERVICES
import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/market_pulse_card.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';
import '../dialogs/industry_selector_dialog.dart'; // <--- NEW IMPORT

// AGRICULTURE TOPICS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/agriculture/beef/beef_config.dart';
import '../../topics/agriculture/agtech/agtech_config.dart';

// MANUFACTURING TOPICS
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';
import '../../topics/manufacturing/canadian_manufacturing/canadian_manufacturing_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Service Instance
  final AIService _aiService = AIService();

  // Topic Registry - The Single Source of Truth for available sectors
  final List<TopicConfig> _allTopics = [
    // --- Agriculture ---
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),

    // --- Manufacturing ---
    ApparelConfig(),
    ChemicalConfig(),
    CanadianManufacturingConfig(),

    // --- Rest of NAICS (Stubs) ---
    StubTopicConfig("mining_gen", "General Mining", Naics.mining),
    StubTopicConfig("util_grid", "Utilities & Grid", Naics.utilities),
    StubTopicConfig("const_cre", "Construction & RE", Naics.construction),
    StubTopicConfig("whole_log", "Wholesale Logistics", Naics.wholesaleTrade),
    StubTopicConfig("retail_cons", "Retail Sentiment", Naics.retailTrade),
    StubTopicConfig("trans_freight", "Freight & Transport", Naics.transportation),
    StubTopicConfig("info_tech", "Tech & Information", Naics.information),
    StubTopicConfig("fin_bank", "Finance & Banking", Naics.finance),
    StubTopicConfig("real_housing", "Housing Market", Naics.realEstate),
    StubTopicConfig("prof_svcs", "Professional Svcs", Naics.professionalServices),
    StubTopicConfig("mgmt_corp", "Corporate Mgmt", Naics.management),
    StubTopicConfig("admin_labor", "Admin & Support", Naics.adminSupport),
    StubTopicConfig("edu_high", "Higher Education", Naics.education),
    StubTopicConfig("health_pharma", "Health & Pharma", Naics.healthCare),
    StubTopicConfig("arts_ent", "Arts & Entertainment", Naics.arts),
    StubTopicConfig("accom_hosp", "Hospitality", Naics.accommodation),
    StubTopicConfig("other_svcs", "Other Services", Naics.otherServices),
    StubTopicConfig("pub_policy", "Public Policy", Naics.publicAdmin),
  ];

  // State Variables
  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Initialize default selection (Agriculture -> First Topic)
    _selectedIndustry = _allTopics.first.industry;
    _currentTopic = _filteredTopics.first;

    // Initial Data Load
    _initLoad();
  }

  // Computed property to filter topics based on the selected industry tab
  List<TopicConfig> get _filteredTopics {
    return _allTopics.where((t) => t.industry == _selectedIndustry).toList();
  }

  // --- DATA LOADING LOGIC ---

  void _initLoad() async {
    setState(() => _loading = true);

    // Fetch latest market data and local history in parallel
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

  // Core Generation Method
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
      print("Error generating briefing: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Generation Failed: $e")),
        );
      }
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

  // --- EVENT HANDLERS ---

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;

    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;

      // Default to the first topic of the new industry
      if (newTopics.isNotEmpty) {
        _currentTopic = newTopics.first;
        _initLoad();
      } else {
        _marketFact = null;
        _briefings = [];
      }
    });
  }

  // --- NEW: Handle Industry Button Click ---
  void _onIndustrySelectorClicked() async {
    final Set<Naics> availableIndustries = _allTopics.map((t) => t.industry).toSet();

    // Show the modal and wait for selection
    final Naics? selected = await IndustrySelectorDialog.show(
        context,
        availableIndustries,
        _selectedIndustry
    );

    if (selected != null) {
      _onIndustrySelected(selected);
    }
  }

  void _onTopicChanged(TopicConfig newTopic) {
    if (newTopic != _currentTopic) {
      setState(() {
        _currentTopic = newTopic;
        _marketFact = null; // Clear old data to show loading state
      });
      _initLoad();
    }
  }

  // Handler: "Use Fallback Data"
  void _onFallbackSelected() async {
    final String? selectedPath = await FallbackSelectorDialog.show(context);

    if (selectedPath != null) {
      _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
    }
  }

  // Handler: "Select AI Model"
  void _onModelSelect() async {
    final String? providerKey = await ModelSelectorDialog.show(context);

    if (providerKey != null) {
      _aiService.setProvider(providerKey);
      setState(() {});

      if (mounted) {
        String friendlyName = switch (providerKey) {
          'openai' => 'OpenAI (GPT-4)',
          'ollama' => 'Ollama (Local)',
          'gemini' => 'Google Gemini',
          _ => providerKey,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Switched to $friendlyName")),
        );
      }
    }
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50 background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(
                'NexThread',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))
            ),
          ],
        ),
        actions: [
          // ACTION MENU (Generate & Settings)
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            tooltip: "Generate Intelligence",
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected();
              } else if (value == 'model') {
                _onModelSelect();
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
              const PopupMenuDivider(),
              // Dynamic Model Switcher Item
              PopupMenuItem<String>(
                value: 'model',
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest, size: 20, color: Colors.black54),
                    const SizedBox(width: 12),
                    // Display current provider name dynamically
                    Text(
                        'Model: ${_aiService.currentProviderName.split(' ')[0]}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87)
                    ),
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
          // 1. INDUSTRY SELECTOR (Replaces Filter Bar)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InkWell(
              onTap: _onIndustrySelectorClicked,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.domain, size: 20, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "INDUSTRY SECTOR",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedIndustry.label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),

          // 2. MARKET PULSE (Topic Selection & Live Data)
          if (_filteredTopics.isNotEmpty)
            MarketPulseCard(
              topics: _filteredTopics,
              currentTopic: _currentTopic,
              marketFact: _marketFact,
              isLoading: _loading,
              onTopicChanged: _onTopicChanged,
            ),

          // 3. BRIEFING LIST (The Feed)
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
                industryTag: _currentTopic.industry.label.split(',')[0], // e.g. "Agriculture"
                topicId: _currentTopic.id,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER CONFIG FOR UNIMPLEMENTED INDUSTRIES ---
class StubTopicConfig implements TopicConfig {
  @override
  final String id;
  @override
  final String name;
  @override
  final Naics industry;

  StubTopicConfig(this.id, this.name, this.industry);

  @override
  List<NewsSourceConfig> get sources => [];

  @override
  List<String> get keywords => [];

  @override
  String get riskRules => "Standard risk assessment rules apply for the $name sector.";

  @override
  Future<MarketFact> fetchMarketPulse() async {
    // Return a dummy placeholder fact for the stub
    return MarketFact(
      category: industry.label.split(',')[0], // Brief category
      name: "$name Index",
      value: "105.20",
      trend: "+0.4%",
      status: "Stable",
      lineData: [102.0, 103.5, 104.0, 104.8, 105.2],
    );
  }
}*/
/*

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CORE SERVICES
import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/topic_filter_bar.dart';
import '../widgets/market_pulse_card.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';

// AGRICULTURE TOPICS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/agriculture/beef/beef_config.dart';
import '../../topics/agriculture/agtech/agtech_config.dart';

// MANUFACTURING TOPICS
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';
import '../../topics/manufacturing/canadian_manufacturing/canadian_manufacturing_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Service Instance
  final AIService _aiService = AIService();

  // Topic Registry
  final List<TopicConfig> _allTopics = [
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),
    ApparelConfig(),
    ChemicalConfig(),
    CanadianManufacturingConfig(),
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

  // MODIFIED: Accepts customScenario
  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath, String? customScenario}) async {
    GenerationLoader.show(context);
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      // Pass the scenario to the service
      await _aiService.generateBriefing(
        _currentTopic,
        manualFeedPath: manualFeedPath,
        customScenario: customScenario, // Inject here
      );

      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });

        if (customScenario != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Simulation Complete: Analysis Generated")),
          );
        }
      }
    } catch (e) {
      print("Error generating: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Generation Failed: $e")),
        );
      }
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

  void _onFallbackSelected() async {
    final String? selectedPath = await FallbackSelectorDialog.show(context);
    if (selectedPath != null) {
      _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
    }
  }

  void _onModelSelect() async {
    final String? providerKey = await ModelSelectorDialog.show(context);
    if (providerKey != null) {
      _aiService.setProvider(providerKey);
      setState(() {});
      if (mounted) {
        String friendlyName = switch (providerKey) {
          'openai' => 'OpenAI (GPT-4)',
          'ollama' => 'Ollama (Local)',
          'gemini' => 'Google Gemini',
          _ => providerKey,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Switched to $friendlyName")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Set<Naics> availableIndustries = _allTopics.map((t) => t.industry).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            tooltip: "Generate Intelligence",
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected();
              } else if (value == 'model') {
                _onModelSelect();
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
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'model',
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest, size: 20, color: Colors.black54),
                    const SizedBox(width: 12),
                    Text('Model: ${_aiService.currentProviderName.split(' ')[0]}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
            ],
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
          TopicFilterBar(
            industries: availableIndustries,
            selectedIndustry: _selectedIndustry,
            onSelected: _onIndustrySelected,
          ),
          if (_filteredTopics.isNotEmpty)
            MarketPulseCard(
              topics: _filteredTopics,
              currentTopic: _currentTopic,
              marketFact: _marketFact,
              isLoading: _loading,
              onTopicChanged: _onTopicChanged,
              // NEW: Handover to generation logic
              onSimulation: (scenario) => _generateNewBriefing(_marketFact, customScenario: scenario),
            ),
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

/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CORE SERVICES
import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/topic_filter_bar.dart';
import '../widgets/market_pulse_card.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';

// AGRICULTURE TOPICS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/agriculture/beef/beef_config.dart';
import '../../topics/agriculture/agtech/agtech_config.dart';

// MANUFACTURING TOPICS
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';
import '../../topics/manufacturing/canadian_manufacturing/canadian_manufacturing_config.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Service Instance
  final AIService _aiService = AIService();

  // Topic Registry - The Single Source of Truth for available sectors
  final List<TopicConfig> _allTopics = [
    // Agriculture
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),
    // Manufacturing
    ApparelConfig(),
    ChemicalConfig(),
    CanadianManufacturingConfig(),
  ];

  // State Variables
  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;
  int _userPoints = 0; // NEW: Track User Points

  @override
  void initState() {
    super.initState();
    // Initialize default selection (Agriculture -> First Topic)
    _selectedIndustry = _allTopics.first.industry;
    _currentTopic = _filteredTopics.first;

    // Initial Data Load
    _initLoad();
  }

  // Computed property to filter topics based on the selected industry tab
  List<TopicConfig> get _filteredTopics {
    return _allTopics.where((t) => t.industry == _selectedIndustry).toList();
  }

  // --- DATA LOADING LOGIC ---

  void _initLoad() async {
    setState(() => _loading = true);

    // Fetch latest market data, local history, and points in parallel
    // This ensures the UI is responsive immediately upon launch
    final fact = await _currentTopic.fetchMarketPulse();
    final history = StorageService.getHistory(_currentTopic.id);
    final points = StorageService.getPoints(); // NEW: Fetch Points

    if (mounted) {
      setState(() {
        _marketFact = fact;
        _briefings = history;
        _userPoints = points;
        _loading = false;
      });
    }
  }

  // Core Generation Method
  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath, String? customScenario}) async {

    // GUARDRAIL: Points Check for Simulations
    if (customScenario != null) {
      bool success = await StorageService.deductPoints(1000);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Insufficient Points. You need 1000 pts to run a simulation."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return; // Stop execution if cannot afford
      }
      // Update UI immediately to reflect deduction
      setState(() {
        _userPoints = StorageService.getPoints();
      });
    }

    GenerationLoader.show(context); // Show full-screen loader overlay
    setState(() => _loading = true);

    // If market fact is stale or null, re-fetch it
    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      // Delegate generation to the AI Service
      await _aiService.generateBriefing(
          _currentTopic,
          manualFeedPath: manualFeedPath,
          customScenario: customScenario // Pass the scenario
      );

      // Retrieve the newly saved briefing from local storage
      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });

        // Feedback for successful simulation
        if (customScenario != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Simulation Complete. Balance: $_userPoints pts"),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      print("Error generating briefing: $e");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Generation Failed: $e")),
        );
      }
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  // System Reset (Clear Cache)
  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() {
      _briefings = [];
      _marketFact = null;
    });
    _initLoad(); // Will reload default points (5000)

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("System Reset: Cache & Points Cleared")),
      );
    }
  }

  // --- EVENT HANDLERS ---

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;

    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;

      // Default to the first topic of the new industry
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
        _marketFact = null; // Clear old data to show loading state
      });
      _initLoad();
    }
  }

  // Handler: "Use Fallback Data"
  void _onFallbackSelected() async {
    // Open the Dialog to choose XML file from assets
    final String? selectedPath = await FallbackSelectorDialog.show(context);

    if (selectedPath != null) {
      _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
    }
  }

  // Handler: "Select AI Model"
  void _onModelSelect() async {
    // Open the standalone Dialog
    final String? providerKey = await ModelSelectorDialog.show(context);

    if (providerKey != null) {
      // Update Service Strategy
      _aiService.setProvider(providerKey);

      // Force UI rebuild to update the "Model: ..." label in the menu
      setState(() {});

      if (mounted) {
        String friendlyName = switch (providerKey) {
          'openai' => 'OpenAI (GPT-4)',
          'ollama' => 'Ollama (Local)',
          'gemini' => 'Google Gemini',
          _ => providerKey,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Switched to $friendlyName")),
        );
      }
    }
  }

  // --- UI BUILD ---

  @override
  Widget build(BuildContext context) {
    final Set<Naics> availableIndustries = _allTopics.map((t) => t.industry).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50 background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(
                'NexThread',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))
            ),
          ],
        ),
        actions: [
          // POINTS DISPLAY (Optional visual indicator)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text(
                      "$_userPoints",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ACTION MENU (Generate & Settings)
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            tooltip: "Generate Intelligence",
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected();
              } else if (value == 'model') {
                _onModelSelect();
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
              const PopupMenuDivider(),
              // Dynamic Model Switcher Item
              PopupMenuItem<String>(
                value: 'model',
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest, size: 20, color: Colors.black54),
                    const SizedBox(width: 12),
                    // Display current provider name dynamically
                    Text(
                        'Model: ${_aiService.currentProviderName.split(' ')[0]}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87)
                    ),
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
          // 1. FILTER BAR (Industry Selection)
          TopicFilterBar(
            industries: availableIndustries,
            selectedIndustry: _selectedIndustry,
            onSelected: _onIndustrySelected,
          ),

          // 2. MARKET PULSE (Topic Selection & Live Data)
          if (_filteredTopics.isNotEmpty)
            MarketPulseCard(
              topics: _filteredTopics,
              currentTopic: _currentTopic,
              marketFact: _marketFact,
              isLoading: _loading,
              onTopicChanged: _onTopicChanged,
              // NEW: Handover to generation logic with simulation support
              onSimulation: (scenario) => _generateNewBriefing(_marketFact, customScenario: scenario),
              userPoints: _userPoints, // Pass points for UI validation
            ),

          // 3. BRIEFING LIST (The Feed)
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
                industryTag: _currentTopic.industry.label.split(',')[0], // e.g. "Agriculture"
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

// CORE SERVICES
import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/topic_filter_bar.dart';
import '../widgets/market_pulse_card.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';

// AGRICULTURE TOPICS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/agriculture/beef/beef_config.dart';
import '../../topics/agriculture/agtech/agtech_config.dart';

// MANUFACTURING TOPICS
import '../../topics/manufacturing/apparel/apparel_config.dart';
import '../../topics/manufacturing/chemical/chemical_config.dart';
import '../../topics/manufacturing/canadian_manufacturing/canadian_manufacturing_config.dart';

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
    CanadianManufacturingConfig(),
  ];

  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;
  int _userPoints = 0;

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

  void _initLoad() async {
    setState(() => _loading = true);
    final fact = await _currentTopic.fetchMarketPulse();
    final history = StorageService.getHistory(_currentTopic.id);
    final points = StorageService.getPoints();

    if (mounted) {
      setState(() {
        _marketFact = fact;
        _briefings = history;
        _userPoints = points;
        _loading = false;
      });
    }
  }

  // NEW: Callback to refresh points from child widgets
  void _refreshPoints() {
    setState(() {
      _userPoints = StorageService.getPoints();
    });
  }

  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath, String? customScenario}) async {
    // 1. DEDUCT POINTS FIRST
    if (customScenario != null) {
      bool success = await StorageService.deductPoints(1000);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Insufficient Points. You need 1000 pts."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
      setState(() => _userPoints = StorageService.getPoints());
    }

    GenerationLoader.show(context);
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      // 2. CALL SERVICE
      await _aiService.generateBriefing(
          _currentTopic,
          manualFeedPath: manualFeedPath,
          customScenario: customScenario
      );

      // 3. SUCCESS: Update List
      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });

        if (customScenario != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Simulation Complete. Balance: $_userPoints pts"),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      }
    } on IrrelevantScenarioException catch (e) {
      // 4. GUARDRAIL BLOCKED: REFUND & TOAST
      await StorageService.addPoints(1000); // Refund

      if (mounted) {
        setState(() {
          _userPoints = StorageService.getPoints(); // Update Balance
          _loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.block, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text("Blocked: ${e.message}")),
                const Text("+1000 pts", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error generating briefing: $e");
      // Refund on system error too if it was a simulation
      if (customScenario != null) {
        await StorageService.addPoints(1000);
        if (mounted) setState(() => _userPoints = StorageService.getPoints());
      }

      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Generation Failed: $e")),
        );
      }
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
        const SnackBar(content: Text("System Reset: Cache & Points Cleared")),
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

  void _onFallbackSelected() async {
    final String? selectedPath = await FallbackSelectorDialog.show(context);
    if (selectedPath != null) {
      _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
    }
  }

  void _onModelSelect() async {
    final String? providerKey = await ModelSelectorDialog.show(context);
    if (providerKey != null) {
      _aiService.setProvider(providerKey);
      setState(() {});

      if (mounted) {
        String friendlyName = switch (providerKey) {
          'openai' => 'OpenAI (GPT-4)',
          'ollama' => 'Ollama (Local)',
          'gemini' => 'Google Gemini',
          _ => providerKey,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Switched to $friendlyName")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Set<Naics> availableIndustries = _allTopics.map((t) => t.industry).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(
                'NexThread',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text(
                      "$_userPoints",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            tooltip: "Generate Intelligence",
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected();
              } else if (value == 'model') {
                _onModelSelect();
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
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'model',
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest, size: 20, color: Colors.black54),
                    const SizedBox(width: 12),
                    Text(
                        'Model: ${_aiService.currentProviderName.split(' ')[0]}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87)
                    ),
                  ],
                ),
              ),
            ],
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
          TopicFilterBar(
            industries: availableIndustries,
            selectedIndustry: _selectedIndustry,
            onSelected: _onIndustrySelected,
          ),
          if (_filteredTopics.isNotEmpty)
            MarketPulseCard(
              topics: _filteredTopics,
              currentTopic: _currentTopic,
              marketFact: _marketFact,
              isLoading: _loading,
              onTopicChanged: _onTopicChanged,
              onSimulation: (scenario) => _generateNewBriefing(_marketFact, customScenario: scenario),
              userPoints: _userPoints,
            ),
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
                // NEW: PASSING THE REFRESH CALLBACK
                onPointsUpdated: _refreshPoints,
              ),
            ),
          ),
        ],
      ),
    );
  }
}