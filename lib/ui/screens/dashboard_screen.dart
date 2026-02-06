
/*

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CORE SERVICES
import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';
import '../../core/industry_provider.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/console_log_widget.dart';

// SCREENS
import 'feed_tester_screen.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';
import '../dialogs/industry_selector_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();

  late List<TopicConfig> _allTopics;

  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;
  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();

    // 1. Load Topics from Provider
    _allTopics = IndustryProvider().getActiveTopics();

    // 2. Set Defaults
    if (_allTopics.isNotEmpty) {
      _selectedIndustry = _allTopics.first.industry;
      _currentTopic = _filteredTopics.first;
      _initLoad();
    }
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

  void _refreshPoints() {
    setState(() {
      _userPoints = StorageService.getPoints();
    });
  }

  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath, String? customScenario}) async {
    GenerationLoader.show(context);
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      await _aiService.generateBriefing(
        _currentTopic,
        manualFeedPath: manualFeedPath,
        customScenario: customScenario,
        allTopics: _allTopics, // NEW: Pass all topics for potential cross-sector polling
      );
      final updatedHistory = StorageService.getHistory(_currentTopic.id);
      final points = StorageService.getPoints();

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _userPoints = points;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error generating: $e");
      if (mounted) {
        setState(() => _loading = false);
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
      _userPoints = StorageService.getPoints();
    });
    // Re-fetch default
    _initLoad();
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

  void _onIndustrySelectorClicked() async {
    final Naics? selected = await IndustrySelectorDialog.show(
        context,
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
    final Map<String, dynamic>? result = await ModelSelectorDialog.show(context);

    if (result != null) {
      final String providerKey = result['key'] as String;
      final Map<String, String>? config = result['config'] as Map<String, String>?;

      _aiService.setProvider(providerKey, config: config);

      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Switched to ${_aiService.currentProviderName}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text("$_userPoints", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected();
              } else if (value == 'test_feeds') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FeedTesterScreen()),
                );
              } else if (value == 'model') {
                _onModelSelect();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'poll', child: Text('Poll RSS Feeds')),
              const PopupMenuItem<String>(value: 'fallback', child: Text('Use Fallback Data')),
              const PopupMenuItem<String>(value: 'test_feeds', child: Text('Test Feed Health')),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'model',
                child: Text('Model: ${_aiService.currentProviderName.split(' ')[0]}', style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF94A3B8)),
            onPressed: _loading ? null : _performSystemReset,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LEFT COLUMN: CONTROL & FACTS ---
          SizedBox(
            width: 500,
            child: Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Industry Selector
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: _onIndustrySelectorClicked,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.domain, size: 20, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("INDUSTRY SECTOR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                  const SizedBox(height: 2),
                                  Text(_selectedIndustry.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Market Pulse (Contains Topic Filter & Facts)
                  if (_filteredTopics.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MarketPulseCard(
                          topics: _filteredTopics,
                          currentTopic: _currentTopic,
                          marketFact: _marketFact,
                          isLoading: _loading,
                          onTopicChanged: _onTopicChanged,
                          onSimulation: (scenario) => _generateNewBriefing(_marketFact, customScenario: scenario),
                          userPoints: _userPoints,
                        ),
                      ),
                    ),

                  // --- CONSOLE LOGGER AT BOTTOM ---
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ConsoleLogWidget(height: 200),
                  ),
                ],
              ),
            ),
          ),

          // --- RIGHT COLUMN: FEED ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text(
                    "Intelligence Feed",
                    style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                ),
                Expanded(
                  child: _loading && _briefings.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                      : _briefings.isEmpty
                      ? const Center(child: Text("No Reports Found", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: _briefings.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BriefingCard(
                        brief: _briefings[index],
                        industryTag: _currentTopic.industry.label.split(',')[0],
                        topicId: _currentTopic.id,
                        onPointsUpdated: _refreshPoints,
                      ),
                    ),
                  ),
                ),
              ],
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
import '../../core/industry_provider.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/console_log_widget.dart';

// SCREENS
import 'feed_tester_screen.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';
import '../dialogs/industry_selector_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();

  late List<TopicConfig> _allTopics;

  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;
  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();

    // 1. Load Topics from Provider
    _allTopics = IndustryProvider().getActiveTopics();

    // 2. Set Defaults
    if (_allTopics.isNotEmpty) {
      _selectedIndustry = _allTopics.first.industry;
      _currentTopic = _filteredTopics.first;
      _initLoad();
    }
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

  void _refreshPoints() {
    setState(() {
      _userPoints = StorageService.getPoints();
    });
  }

  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath, String? customScenario}) async {
    GenerationLoader.show(context);
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      await _aiService.generateBriefing(
        _currentTopic,
        manualFeedPath: manualFeedPath,
        customScenario: customScenario,
        allTopics: _allTopics,
      );
      final updatedHistory = StorageService.getHistory(_currentTopic.id);
      final points = StorageService.getPoints();

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _userPoints = points;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error generating: $e");
      if (mounted) {
        setState(() => _loading = false);
      }
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  // --- NEW HANDLER FOR EXPANSION ---
  Future<void> _handleExpandBriefing(Briefing brief) async {
    // We don't show the full GenerationLoader here, just let the card show its local spinner
    // but we can log to console
    try {
      await _aiService.expandBriefing(brief, _allTopics);

      // Refresh the list to show the updated brief
      final updatedHistory = StorageService.getHistory(brief.id); // brief.id is tricky if it's generic '1'
      // Better: refresh current topic history
      final history = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _briefings = history;
        });
      }
    } catch (e) {
      print("Expansion failed: $e");
    }
  }

  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() {
      _briefings = [];
      _marketFact = null;
      _userPoints = StorageService.getPoints();
    });
    // Re-fetch default
    _initLoad();
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

  void _onIndustrySelectorClicked() async {
    final Naics? selected = await IndustrySelectorDialog.show(
        context,
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
    final Map<String, dynamic>? result = await ModelSelectorDialog.show(context);

    if (result != null) {
      final String providerKey = result['key'] as String;
      final Map<String, String>? config = result['config'] as Map<String, String>?;

      _aiService.setProvider(providerKey, config: config);

      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Switched to ${_aiService.currentProviderName}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text("$_userPoints", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') {
                _generateNewBriefing(_marketFact);
              } else if (value == 'fallback') {
                _onFallbackSelected();
              } else if (value == 'test_feeds') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FeedTesterScreen()),
                );
              } else if (value == 'model') {
                _onModelSelect();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'poll', child: Text('Poll RSS Feeds')),
              const PopupMenuItem<String>(value: 'fallback', child: Text('Use Fallback Data')),
              const PopupMenuItem<String>(value: 'test_feeds', child: Text('Test Feed Health')),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'model',
                child: Text('Model: ${_aiService.currentProviderName.split(' ')[0]}', style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF94A3B8)),
            onPressed: _loading ? null : _performSystemReset,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LEFT COLUMN ---
          SizedBox(
            width: 500,
            child: Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // Industry Selector
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: _onIndustrySelectorClicked,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.domain, size: 20, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("INDUSTRY SECTOR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                  const SizedBox(height: 2),
                                  Text(_selectedIndustry.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Market Pulse
                  if (_filteredTopics.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MarketPulseCard(
                          topics: _filteredTopics,
                          currentTopic: _currentTopic,
                          marketFact: _marketFact,
                          isLoading: _loading,
                          onTopicChanged: _onTopicChanged,
                          onSimulation: (scenario) => _generateNewBriefing(_marketFact, customScenario: scenario),
                          userPoints: _userPoints,
                        ),
                      ),
                    ),

                  // Console
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ConsoleLogWidget(height: 200),
                  ),
                ],
              ),
            ),
          ),

          // --- RIGHT COLUMN ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text(
                    "Intelligence Feed",
                    style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                ),
                Expanded(
                  child: _loading && _briefings.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                      : _briefings.isEmpty
                      ? const Center(child: Text("No Reports Found", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: _briefings.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: BriefingCard(
                        brief: _briefings[index],
                        industryTag: _currentTopic.industry.label.split(',')[0],
                        topicId: _currentTopic.id,
                        onPointsUpdated: _refreshPoints,
                        onExpand: _handleExpandBriefing, // PASSED CALLBACK
                      ),
                    ),
                  ),
                ),
              ],
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
import '../../core/industry_provider.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/console_log_widget.dart';

// VIEWS
import '../views/global_trends_view.dart'; // Import the new view

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';
import '../dialogs/industry_selector_dialog.dart';
import 'feed_tester_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  late TabController _tabController; // Add TabController

  late List<TopicConfig> _allTopics;
  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;
  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Init TabController

    _allTopics = IndustryProvider().getActiveTopics();
    if (_allTopics.isNotEmpty) {
      _selectedIndustry = _allTopics.first.industry;
      _currentTopic = _filteredTopics.first;
      _initLoad();
    }
  }

  // ... [Keep existing _initLoad, _generateNewBriefing, etc. methods unchanged] ...

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

  void _refreshPoints() {
    setState(() => _userPoints = StorageService.getPoints());
  }

  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath, String? customScenario}) async {
    GenerationLoader.show(context);
    setState(() => _loading = true);
    final mFact = fact ?? await _currentTopic.fetchMarketPulse();
    try {
      await _aiService.generateBriefing(_currentTopic, manualFeedPath: manualFeedPath, customScenario: customScenario, allTopics: _allTopics);
      final updatedHistory = StorageService.getHistory(_currentTopic.id);
      final points = StorageService.getPoints();
      if (mounted) setState(() { _marketFact = mFact; _briefings = updatedHistory; _userPoints = points; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() { _briefings = []; _marketFact = null; _userPoints = StorageService.getPoints(); });
    _initLoad();
  }

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;
    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;
      if (newTopics.isNotEmpty) { _currentTopic = newTopics.first; _initLoad(); }
      else { _marketFact = null; _briefings = []; }
    });
  }

  void _onIndustrySelectorClicked() async {
    final Naics? selected = await IndustrySelectorDialog.show(context, _selectedIndustry);
    if (selected != null) _onIndustrySelected(selected);
  }

  void _onFallbackSelected() async {
    final String? selectedPath = await FallbackSelectorDialog.show(context);
    if (selectedPath != null) _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
  }

  void _onModelSelect() async {
    final Map<String, dynamic>? result = await ModelSelectorDialog.show(context);
    if (result != null) {
      _aiService.setProvider(result['key'], config: result['config']);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Switched to ${_aiService.currentProviderName}")));
    }
  }

  @override
  Widget build(BuildContext context) {
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
        // ADDED: TabBar
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF6366F1),
          tabs: const [
            Tab(text: "Standard Industry Analytics"),
            Tab(text: "Global Trends"),
          ],
        ),
        actions: [
          // [Keep existing actions: Points, PopupMenu, Delete]
          // Copy the actions code from your existing file here...
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text("$_userPoints", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') _generateNewBriefing(_marketFact);
              else if (value == 'fallback') _onFallbackSelected();
              else if (value == 'test_feeds') Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FeedTesterScreen()));
              else if (value == 'model') _onModelSelect();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'poll', child: Text('Poll RSS Feeds')),
              const PopupMenuItem(value: 'fallback', child: Text('Use Fallback Data')),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'model', child: Text('Model: ${_aiService.currentProviderName.split(' ')[0]}')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF94A3B8)),
            onPressed: _loading ? null : _performSystemReset,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: EXISTING DASHBOARD CONTENT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN (Industry & Pulse)
              SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.domain, size: 20, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("INDUSTRY SECTOR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                      const SizedBox(height: 2),
                                      Text(_selectedIndustry.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_filteredTopics.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MarketPulseCard(
                            topics: _filteredTopics,
                            currentTopic: _currentTopic,
                            marketFact: _marketFact,
                            isLoading: _loading,
                            onTopicChanged: (t) {
                              if (t != _currentTopic) {
                                setState(() { _currentTopic = t; _marketFact = null; });
                                _initLoad();
                              }
                            },
                            onSimulation: (s) => _generateNewBriefing(_marketFact, customScenario: s),
                            userPoints: _userPoints,
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: ConsoleLogWidget(height: 200),
                      ),
                    ],
                  ),
                ),
              ),
              // RIGHT COLUMN (Feed)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Text("Intelligence Feed", style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ),
                    Expanded(
                      child: _loading && _briefings.isEmpty
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                          : _briefings.isEmpty
                          ? const Center(child: Text("No Reports Found", style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: _briefings.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: BriefingCard(
                            brief: _briefings[index],
                            industryTag: _currentTopic.industry.label.split(',')[0],
                            topicId: _currentTopic.id,
                            onPointsUpdated: _refreshPoints,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // TAB 2: NEW GLOBAL TRENDS VIEW
          const GlobalTrendsView(),
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
import '../../core/industry_provider.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/console_log_widget.dart';

// VIEWS
import '../views/global_trends_view.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';
import '../dialogs/industry_selector_dialog.dart';
import 'feed_tester_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  late TabController _tabController;

  late List<TopicConfig> _allTopics;
  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;
  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _allTopics = IndustryProvider().getActiveTopics();
    if (_allTopics.isNotEmpty) {
      _selectedIndustry = _allTopics.first.industry;
      _currentTopic = _filteredTopics.first;
      _initLoad();
    }
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

  void _refreshPoints() {
    setState(() => _userPoints = StorageService.getPoints());
  }

  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath, String? customScenario}) async {
    GenerationLoader.show(context);
    setState(() => _loading = true);
    final mFact = fact ?? await _currentTopic.fetchMarketPulse();
    try {
      await _aiService.generateBriefing(_currentTopic, manualFeedPath: manualFeedPath, customScenario: customScenario, allTopics: _allTopics);
      final updatedHistory = StorageService.getHistory(_currentTopic.id);
      final points = StorageService.getPoints();
      if (mounted) setState(() { _marketFact = mFact; _briefings = updatedHistory; _userPoints = points; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() { _briefings = []; _marketFact = null; _userPoints = StorageService.getPoints(); });
    _initLoad();
  }

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;
    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;
      if (newTopics.isNotEmpty) { _currentTopic = newTopics.first; _initLoad(); }
      else { _marketFact = null; _briefings = []; }
    });
  }

  void _onIndustrySelectorClicked() async {
    final Naics? selected = await IndustrySelectorDialog.show(context, _selectedIndustry);
    if (selected != null) _onIndustrySelected(selected);
  }

  void _onFallbackSelected() async {
    final String? selectedPath = await FallbackSelectorDialog.show(context);
    if (selectedPath != null) _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
  }

  void _onModelSelect() async {
    final Map<String, dynamic>? result = await ModelSelectorDialog.show(context);
    if (result != null) {
      _aiService.setProvider(result['key'], config: result['config']);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Switched to ${_aiService.currentProviderName}")));
    }
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF6366F1),
          tabs: const [
            Tab(text: "Standard Industry Analytics"),
            Tab(text: "Global Trends"),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text("$_userPoints", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
              ],
            ),
          ),
          // --- NEW DEDICATED FEED TESTER BUTTON ---
          IconButton(
            icon: const Icon(Icons.network_check, color: Color(0xFF64748B)),
            tooltip: "Test Feed Health",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FeedTesterScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.add_circle_outline, color: _loading ? Colors.grey : const Color(0xFF6366F1)),
            enabled: !_loading,
            onSelected: (value) {
              if (value == 'poll') _generateNewBriefing(_marketFact);
              else if (value == 'fallback') _onFallbackSelected();
              else if (value == 'model') _onModelSelect();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'poll', child: Text('Poll RSS Feeds')),
              const PopupMenuItem(value: 'fallback', child: Text('Use Fallback Data')),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'model', child: Text('Model: ${_aiService.currentProviderName.split(' ')[0]}')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF94A3B8)),
            onPressed: _loading ? null : _performSystemReset,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: EXISTING DASHBOARD CONTENT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN (Industry & Pulse)
              SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.domain, size: 20, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("INDUSTRY SECTOR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                      const SizedBox(height: 2),
                                      Text(_selectedIndustry.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_filteredTopics.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MarketPulseCard(
                            topics: _filteredTopics,
                            currentTopic: _currentTopic,
                            marketFact: _marketFact,
                            isLoading: _loading,
                            onTopicChanged: (t) {
                              if (t != _currentTopic) {
                                setState(() { _currentTopic = t; _marketFact = null; });
                                _initLoad();
                              }
                            },
                            onSimulation: (s) => _generateNewBriefing(_marketFact, customScenario: s),
                            userPoints: _userPoints,
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: ConsoleLogWidget(height: 200),
                      ),
                    ],
                  ),
                ),
              ),
              // RIGHT COLUMN (Feed)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Text("Intelligence Feed", style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ),
                    Expanded(
                      child: _loading && _briefings.isEmpty
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                          : _briefings.isEmpty
                          ? const Center(child: Text("No Reports Found", style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: _briefings.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: BriefingCard(
                            brief: _briefings[index],
                            industryTag: _currentTopic.industry.label.split(',')[0],
                            topicId: _currentTopic.id,
                            onPointsUpdated: _refreshPoints,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // TAB 2: GLOBAL TRENDS VIEW
          const GlobalTrendsView(),
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
import '../../core/industry_provider.dart';

// UI COMPONENTS
import '../widgets/dashboard_toolbar.dart'; // NEW IMPORT
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/market_pulse_card.dart';
import '../widgets/console_log_widget.dart';

// VIEWS
import '../views/global_trends_view.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';
import '../dialogs/industry_selector_dialog.dart';
import 'feed_tester_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  late TabController _tabController;

  late List<TopicConfig> _allTopics;
  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;
  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _allTopics = IndustryProvider().getActiveTopics();
    if (_allTopics.isNotEmpty) {
      _selectedIndustry = _allTopics.first.industry;
      _currentTopic = _filteredTopics.first;
      _initLoad();
    }
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

  void _refreshPoints() {
    setState(() => _userPoints = StorageService.getPoints());
  }

  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath, String? customScenario}) async {
    GenerationLoader.show(context);
    setState(() => _loading = true);
    final mFact = fact ?? await _currentTopic.fetchMarketPulse();
    try {
      await _aiService.generateBriefing(_currentTopic, manualFeedPath: manualFeedPath, customScenario: customScenario, allTopics: _allTopics);
      final updatedHistory = StorageService.getHistory(_currentTopic.id);
      final points = StorageService.getPoints();
      if (mounted) setState(() { _marketFact = mFact; _briefings = updatedHistory; _userPoints = points; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() { _briefings = []; _marketFact = null; _userPoints = StorageService.getPoints(); });
    _initLoad();
  }

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;
    setState(() {
      _selectedIndustry = industry;
      final newTopics = _filteredTopics;
      if (newTopics.isNotEmpty) { _currentTopic = newTopics.first; _initLoad(); }
      else { _marketFact = null; _briefings = []; }
    });
  }

  void _onIndustrySelectorClicked() async {
    final Naics? selected = await IndustrySelectorDialog.show(context, _selectedIndustry);
    if (selected != null) _onIndustrySelected(selected);
  }

  void _onFallbackSelected() async {
    final String? selectedPath = await FallbackSelectorDialog.show(context);
    if (selectedPath != null) _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
  }

  void _onModelSelect() async {
    final Map<String, dynamic>? result = await ModelSelectorDialog.show(context);
    if (result != null) {
      _aiService.setProvider(result['key'], config: result['config']);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Switched to ${_aiService.currentProviderName}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // REFACTORED: Using the extracted DashboardToolbar widget
      appBar: DashboardToolbar(
        tabController: _tabController,
        userPoints: _userPoints,
        loading: _loading,
        currentProviderName: _aiService.currentProviderName,
        onPollFeeds: () => _generateNewBriefing(_marketFact),
        onFallback: _onFallbackSelected,
        onModelSelect: _onModelSelect,
        onSystemReset: _performSystemReset,
        onFeedTester: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FeedTesterScreen()),
          );
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: EXISTING DASHBOARD CONTENT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN (Industry & Pulse)
              SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
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
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.domain, size: 20, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("INDUSTRY SECTOR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                                      const SizedBox(height: 2),
                                      Text(_selectedIndustry.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_filteredTopics.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: MarketPulseCard(
                            topics: _filteredTopics,
                            currentTopic: _currentTopic,
                            marketFact: _marketFact,
                            isLoading: _loading,
                            onTopicChanged: (t) {
                              if (t != _currentTopic) {
                                setState(() { _currentTopic = t; _marketFact = null; });
                                _initLoad();
                              }
                            },
                            onSimulation: (s) => _generateNewBriefing(_marketFact, customScenario: s),
                            userPoints: _userPoints,
                          ),
                        ),
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: ConsoleLogWidget(height: 200),
                      ),
                    ],
                  ),
                ),
              ),
              // RIGHT COLUMN (Feed)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Text("Intelligence Feed", style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    ),
                    Expanded(
                      child: _loading && _briefings.isEmpty
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                          : _briefings.isEmpty
                          ? const Center(child: Text("No Reports Found", style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: _briefings.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: BriefingCard(
                            brief: _briefings[index],
                            industryTag: _currentTopic.industry.label.split(',')[0],
                            topicId: _currentTopic.id,
                            onPointsUpdated: _refreshPoints,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // TAB 2: GLOBAL TRENDS VIEW
          const GlobalTrendsView(),
        ],
      ),
    );
  }
}