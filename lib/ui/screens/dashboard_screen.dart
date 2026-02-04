

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
  final IndustryProvider _industryProvider = IndustryProvider();

  late Naics _selectedIndustry;
  late TopicConfig _currentTopic;

  List<Briefing> _briefings = [];
  MarketFact? _marketFact;
  bool _loading = false;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    // Default to first active topic
    final activeTopics = _industryProvider.getActiveTopics();
    if (activeTopics.isNotEmpty) {
      _selectedIndustry = activeTopics.first.industry;
      _currentTopic = activeTopics.first;
    } else {
      _selectedIndustry = Naics.values.first; // Safety fallback
    }
    _initLoad();
  }

  List<TopicConfig> get _filteredTopics {
    return _industryProvider.getActiveTopics()
        .where((t) => t.industry == _selectedIndustry)
        .toList();
  }

  void _initLoad() async {
    setState(() => _loading = true);
    try {
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
    } catch (e) {
      if(mounted) setState(() => _loading = false);
    }
  }

  void _refreshPoints() {
    setState(() {
      _userPoints = StorageService.getPoints();
    });
  }

  // --- GENERATION LOGIC ---

  void _generateNewBriefing(MarketFact? fact, {String? manualFeedPath, String? customScenario}) async {
    if (customScenario != null) {
      bool success = await StorageService.deductPoints(1000);
      if (!success) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Insufficient Points."), backgroundColor: Colors.redAccent));
        return;
      }
      setState(() => _userPoints = StorageService.getPoints());
    }

    GenerationLoader.show(context);
    setState(() => _loading = true);

    final mFact = fact ?? await _currentTopic.fetchMarketPulse();

    try {
      await _aiService.generateBriefing(
          _currentTopic,
          manualFeedPath: manualFeedPath,
          customScenario: customScenario
      );

      final updatedHistory = StorageService.getHistory(_currentTopic.id);

      if (mounted) {
        setState(() {
          _marketFact = mFact;
          _briefings = updatedHistory;
          _loading = false;
        });
        if (customScenario != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Simulation Complete. Balance: $_userPoints pts"), backgroundColor: const Color(0xFF10B981)));
        }
      }
    } on IrrelevantScenarioException catch (e) {
      await StorageService.addPoints(500);
      if (mounted) {
        setState(() { _userPoints = StorageService.getPoints(); _loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Simulation Rejected (500 pts returned): ${e.message}"), backgroundColor: Colors.red.shade800));
      }
    } catch (e) {
      if (customScenario != null) {
        await StorageService.addPoints(1000);
        if(mounted) setState(() => _userPoints = StorageService.getPoints());
      }
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("System Error: $e"), duration: const Duration(seconds: 5)));
      }
    } finally {
      if (mounted) GenerationLoader.hide(context);
    }
  }

  // --- ACTIONS ---

  void _performSystemReset() async {
    await StorageService.clearAll();
    setState(() {
      _briefings = [];
      _marketFact = null;
    });
    _initLoad();
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("System Reset Complete")));
  }

  void _onIndustrySelected(Naics industry) {
    if (_selectedIndustry == industry) return;
    final topic = _industryProvider.getTopicForIndustry(industry);
    if (topic != null) {
      setState(() {
        _selectedIndustry = industry;
        _currentTopic = topic;
        _marketFact = null;
        _briefings = [];
      });
      _initLoad();
    }
  }

  void _onIndustrySelectorClicked() async {
    final Naics? selected = await IndustrySelectorDialog.show(context, _selectedIndustry);
    if (selected != null) _onIndustrySelected(selected);
  }

  void _onFallbackSelected() async {
    final String? selectedPath = await FallbackSelectorDialog.show(context);
    if (selectedPath != null) _generateNewBriefing(_marketFact, manualFeedPath: selectedPath);
  }

  // --- MODEL SELECTION (UPDATED) ---
  void _onModelSelect() async {
    // 1. Get the complex result from the dialog
    final result = await ModelSelectorDialog.show(context);

    if (result != null) {
      final String key = result['key'];

      // 2. Cast the config map safely
      Map<String, String>? config;
      if (result['config'] != null) {
        config = Map<String, String>.from(result['config']);
      }

      // 3. Pass to Service
      _aiService.setProvider(key, config: config);

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
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  const Icon(Icons.stars, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  Text("$_userPoints", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                ],
              ),
            ),
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
              PopupMenuItem(value: 'model', child: Text('Model: ${_aiService.currentProviderName.split('(')[0].trim()}')), // Clean name
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Color(0xFF94A3B8)),
            onPressed: _loading ? null : _performSystemReset,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
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
                          const Text("INDUSTRY SECTOR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Text(_selectedIndustry.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
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
            MarketPulseCard(
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
          Expanded(
            child: _loading && _briefings.isEmpty
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                : _briefings.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history_edu, size: 48, color: Colors.grey.shade300), const SizedBox(height: 16), const Text("No Reports Found", style: TextStyle(color: Colors.grey))]))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) => BriefingCard(
                brief: _briefings[index],
                industryTag: _currentTopic.industry.label.split(',')[0],
                topicId: _currentTopic.id,
                onPointsUpdated: _refreshPoints,
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
import '../../core/market_data_provider.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/market_pulse_card.dart';

// DIALOGS
import '../dialogs/fallback_selector_dialog.dart';
import '../dialogs/model_selector_dialog.dart';
import '../dialogs/industry_selector_dialog.dart';

// TOPICS
import '../../topics/agriculture/wheat/wheat_config.dart';
import '../../topics/agriculture/lumber/lumber_config.dart';
import '../../topics/agriculture/beef/beef_config.dart';
import '../../topics/agriculture/agtech/agtech_config.dart';
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
    WheatConfig(), BeefConfig(), AgTechConfig(), LumberConfig(),
    ApparelConfig(), ChemicalConfig(), CanadianManufacturingConfig(),
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

  // --- UPDATED MODEL SELECTION LOGIC ---
  void _onModelSelect() async {
    // Expecting a Map return type now, containing key and config
    final Map<String, dynamic>? result = await ModelSelectorDialog.show(context);

    if (result != null) {
      final String providerKey = result['key'] as String;
      final Map<String, String>? config = result['config'] as Map<String, String>?;

      // Pass the config (if any) to the service
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
              } else if (value == 'model') {
                _onModelSelect();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'poll', child: Text('Poll RSS Feeds')),
              const PopupMenuItem<String>(value: 'fallback', child: Text('Use Fallback Data')),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                ? const Center(child: Text("No Reports Found", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) => BriefingCard(
                brief: _briefings[index],
                industryTag: _currentTopic.industry.label.split(',')[0],
                topicId: _currentTopic.id,
                onPointsUpdated: _refreshPoints,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
  String get riskRules => "";

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await MarketDataProvider().getSectorBenchmarks(industry);
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
import '../../core/industry_provider.dart'; // IMPORT PROVIDER

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/market_pulse_card.dart';

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

  // UPDATED: Now fetches the Single Source of Truth from IndustryProvider
  // This ensures "Oil & Gasoline" appears instead of "General Mining"
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

    // 2. Set Defaults (Fail-safe if list is empty, though unlikely)
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
              } else if (value == 'model') {
                _onModelSelect();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'poll', child: Text('Poll RSS Feeds')),
              const PopupMenuItem<String>(value: 'fallback', child: Text('Use Fallback Data')),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                ? const Center(child: Text("No Reports Found", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) => BriefingCard(
                brief: _briefings[index],
                industryTag: _currentTopic.industry.label.split(',')[0],
                topicId: _currentTopic.id,
                onPointsUpdated: _refreshPoints,
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
import '../../core/industry_provider.dart';

// UI COMPONENTS
import '../widgets/briefing_card.dart';
import '../widgets/generation_loader.dart';
import '../widgets/market_pulse_card.dart';

// SCREENS
import 'feed_tester_screen.dart'; // <--- NEW IMPORT

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
                // <--- NEW HANDLER
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
              // <--- NEW MENU ITEM
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                ? const Center(child: Text("No Reports Found", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) => BriefingCard(
                brief: _briefings[index],
                industryTag: _currentTopic.industry.label.split(',')[0],
                topicId: _currentTopic.id,
                onPointsUpdated: _refreshPoints,
              ),
            ),
          ),
        ],
      ),
    );
  }
}