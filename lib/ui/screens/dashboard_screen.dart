


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// CORE SERVICES
import '../../core/ai_service.dart';
import '../../core/topic_config.dart';
import '../../core/models.dart';
import '../../core/storage_service.dart';
import '../../core/industry_provider.dart';

// UI COMPONENTS
import '../widgets/dashboard_toolbar.dart';
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
import '../views/industrial_strategy_view.dart';

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
    _tabController = TabController(length: 3, vsync: this);

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

  // FIXED: Changed manualFeedPath (String) to manualFeedPaths (List<String>)
  void _generateNewBriefing(MarketFact? fact, {List<String>? manualFeedPaths, String? customScenario}) async {
    GenerationLoader.show(context);
    setState(() => _loading = true);
    final mFact = fact ?? await _currentTopic.fetchMarketPulse();
    try {
      await _aiService.generateBriefing(
          _currentTopic,
          manualFeedPaths: manualFeedPaths, // FIXED: Passing list to service
          customScenario: customScenario,
          allTopics: _allTopics
      );
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

  // FIXED: Handling List<String>? return type
  void _onFallbackSelected() async {
    final List<String>? selectedPaths = await FallbackSelectorDialog.show(context);
    if (selectedPaths != null && selectedPaths.isNotEmpty) {
      _generateNewBriefing(_marketFact, manualFeedPaths: selectedPaths);
    }
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

          // TAB 3: NEW INDUSTRIAL STRATEGY VIEW <-- ADD THIS
          const IndustrialStrategyView(),
        ],
      ),
    );
  }
}