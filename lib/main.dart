/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ai_service.dart';
import 'market_data_service.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const NexThreadApp());
}

class NexThreadApp extends StatelessWidget {
  const NexThreadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexThread Industrials',
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

// --- CONSTANTS ---
const SIGNAL_MATRIX = {
  "311 Food": [
    { "signal": "Black Sea Grain Initiative", "type": "Geo-Political", "polarity": "+/-", "weight": "0" },
    { "signal": "Protectionist export bans", "type": "Geo-Political", "polarity": "-", "weight": "-1" },
    { "signal": "Sovereign food security mandates", "type": "Geo-Political", "polarity": "+", "weight": "+1.0" },
    { "signal": "Sugar export caps (TRQ)", "type": "Trade/Reg", "polarity": "-", "weight": "-1" },
    { "signal": "Skimpflation", "type": "Crisis", "polarity": "-", "weight": "-4" }
  ],
  "334 Computer/Electronics": [
    { "signal": "Entity List additions (BIS)", "type": "Geo-Political", "polarity": "-", "weight": "-1" },
    { "signal": "CHIPS Act subsidy milestones", "type": "Geo-Political", "polarity": "+", "weight": "+1.0" },
    { "signal": "Neon Gas Shock", "type": "Crisis", "polarity": "-", "weight": "-9" },
    { "signal": "Panic Buying", "type": "Crisis", "polarity": "-", "weight": "-5" }
  ],
  "112 Animal": [
    { "signal": "Livestock contagion", "type": "Crisis", "polarity": "-", "weight": "-10" },
    { "signal": "Feed cost spike", "type": "Crisis", "polarity": "-", "weight": "-6" }
  ]
};

const DIVERGENCE_GLOSSARY = [
  {
    "category": "Buying Opportunities (Green)",
    "items": [
      { "tag": "Unjustified Panic", "desc": "Market is scared, but data proves supply is fine. Sentiment is low, Facts are high." },
      { "tag": "Margin Padding", "desc": "Suppliers' costs dropped, but they haven't lowered prices." },
      { "tag": "Sector Split", "desc": "One niche is booming/crashing, but the market generalizes it to the whole sector." }
    ]
  },
  {
    "category": "Risk Warnings (Red)",
    "items": [
      { "tag": "Over-Ordering", "desc": "Panic-hoarding creating a demand bubble. Buying is high, actual usage is low." },
      { "tag": "Over-Confidence", "desc": "Market is too bullish despite rotting fundamentals." }
    ]
  }
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();
  final MarketDataService _marketService = MarketDataService();

  List<Briefing> _briefings = [];
  bool _loading = false;

  // Market Facts
  MarketFact? _wheatFact;
  MarketFact? _rateFact;
  MarketFact? _fxFact;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      await Future.wait([
        _fetchPulseData(),
        _generateLiveIntelligence(),
      ]);
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _fetchPulseData() async {
    final results = await Future.wait([
      _marketService.fetchWheatPrice(),
      _marketService.fetchInterestRate(),
      _marketService.fetchCadExchangeRate(),
    ]);

    if (mounted) {
      setState(() {
        _wheatFact = results[0];
        _rateFact = results[1];
        _fxFact = results[2];
      });
    }
  }

  Future<void> _generateLiveIntelligence() async {
    try {
      final headlines = await _aiService.fetchAgHeadlines();
      final jsonMap = await _aiService.generateIntelligence(headlines);

      if (jsonMap.containsKey('briefs')) {
        final List<dynamic> briefsJson = jsonMap['briefs'];
        if (mounted) {
          setState(() {
            _briefings = briefsJson.map((json) => Briefing.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      print("Error generating intelligence: $e");
    }
  }

  void _showAgentSim() {
    showDialog(
      context: context,
      builder: (context) => const AgentSimulationDialog(),
    );
  }

  void _showSignalMatrix() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const SignalMatrixModal(),
    );
  }

  void _showGlossary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const GlossaryModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text('NexThread Agri-POC', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.play_circle_fill, color: Color(0xFF6366F1)), onPressed: _showAgentSim, tooltip: "Live Agents"),
          IconButton(icon: const Icon(Icons.menu_book, color: Color(0xFF64748B)), onPressed: _showSignalMatrix, tooltip: "Signals"),
          IconButton(icon: const Icon(Icons.help_outline, color: Color(0xFF64748B)), onPressed: _showGlossary, tooltip: "Glossary"),
          IconButton(
            icon: Icon(Icons.refresh, color: _loading ? Colors.grey : const Color(0xFF64748B)),
            onPressed: _loading ? null : _loadAllData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          PulseBar(wheat: _wheatFact, rate: _rateFact, fx: _fxFact),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAllData,
              color: const Color(0xFF6366F1),
              child: _loading && _briefings.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _briefings.length,
                itemBuilder: (context, index) => BriefingCard(brief: _briefings[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PulseBar extends StatelessWidget {
  final MarketFact? wheat;
  final MarketFact? rate;
  final MarketFact? fx;

  const PulseBar({super.key, this.wheat, this.rate, this.fx});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
          color: Color(0xFFEEF2FF),
          border: Border(bottom: BorderSide(color: Color(0xFFE0E7FF)))
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildPulseItem(wheat, "Wheat"),
          const SizedBox(width: 24),
          _buildPulseItem(rate, "Bond Yield"),
          const SizedBox(width: 24),
          _buildPulseItem(fx, "USD/CAD"),
        ],
      ),
    );
  }

  Widget _buildPulseItem(MarketFact? fact, String label) {
    if (fact == null) {
      return Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)));
    }
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
      ],
    );
  }
}

class BriefingCard extends StatelessWidget {
  final Briefing brief;

  const BriefingCard({super.key, required this.brief});

  // Helper to format the time difference
  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  void _showLogicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _LogicModalContent(brief: brief, controller: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(brief.subsector.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                        const SizedBox(width: 8),
                        // --- STALENESS INDICATOR ---
                        Icon(Icons.access_time, size: 10, color: const Color(0xFF94A3B8)),
                        const SizedBox(width: 2),
                        Text(
                            "Analysis: ${_getTimeAgo(brief.timestamp)}",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B))
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
                _buildSeverityBadge(brief.severity),
              ],
            ),

            // Signal Tags
            if (brief.signals.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: brief.signals.map((sig) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Text(sig, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                )).toList(),
              ),
            ],

            const SizedBox(height: 12),
            Text(brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('FACT SOURCE (MARKET PATH)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                              const SizedBox(height: 4),
                              Text(brief.metrics.commodity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Row(
                                children: [
                                  Text(brief.metrics.price, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Text(brief.metrics.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                ],
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: brief.chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: true,
                                    color: const Color(0xFF6366F1),
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                      factScore: brief.factScore,
                      sentScore: brief.sentScore,
                      tag: brief.divergenceTag,
                      desc: brief.divergenceDesc,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showLogicModal(context),
              child: const Row(
                children: [
                  Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text("AI LOGIC & VERIFICATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color bg = severity == 'High' ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    Color text = severity == 'High' ? const Color(0xFFBE123C) : const Color(0xFF047857);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(severity.toUpperCase(), style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class DivergenceMeter extends StatelessWidget {
  final int factScore;
  final int sentScore;
  final String tag;
  final String desc;

  const DivergenceMeter({super.key, required this.factScore, required this.sentScore, required this.tag, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFF43F5E)),
              SizedBox(width: 4),
              Text("Scarcity / Crisis", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E))),
            ]),
            Row(children: [
              Text("Abundance / Glut", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              SizedBox(width: 4),
              Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final factPos = (factScore / 100) * w;
            final sentPos = (sentScore / 100) * w;
            final left = math.min(factPos, sentPos);
            final width = (factPos - sentPos).abs();

            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(width: w, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFFFFE4E6), Color(0xFFF1F5F9), Color(0xFFD1FAE5)]))),
                  Positioned(left: left, width: width, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.3), borderRadius: BorderRadius.circular(4)))),
                  Positioned(left: factPos, top: -24, child: _buildMarker("FACT", const Color(0xFF6366F1), true)),
                  Positioned(left: sentPos, bottom: -24, child: _buildMarker("SENTIMENT", const Color(0xFFF43F5E), false)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.analytics, size: 14, color: Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
          ],
        ),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildMarker(String label, Color color, bool top) {
    return FractionalTranslation(
      translation: const Offset(-0.5, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (top) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
            const SizedBox(height: 2),
            Container(width: 2, height: 8, color: color),
          ] else ...[
            Container(width: 2, height: 8, color: color),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
          ],
        ],
      ),
    );
  }
}

class AgentSimulationDialog extends StatefulWidget {
  const AgentSimulationDialog({super.key});
  @override
  State<AgentSimulationDialog> createState() => _AgentSimulationDialogState();
}

class _AgentSimulationDialogState extends State<AgentSimulationDialog> {
  int _step = 0;
  final List<String> _logs = [];
  Timer? _timer;

  final List<Map<String, String>> _steps = [
    {"agent": "A", "msg": "Booting Scraper Cluster (US-East-1)..."},
    {"agent": "A", "msg": "Scanning 12 Whitelisted Agriculture Feeds..."},
    {"agent": "A", "msg": "Extracted 'Avian Flu' entity from USDA.gov"},
    {"agent": "B", "msg": "Verifying 'Layer Flock' count against Census Data..."},
    {"agent": "B", "msg": "Fact Confirmed: -12% YoY. Trust Score: 99%"},
    {"agent": "C", "msg": "Mining Sentiment from 400+ Forum comments..."},
    {"agent": "C", "msg": "Detected 'Panic' polarity (Score: 18/100)"},
    {"agent": "D", "msg": "Calculating Divergence: |80 - 18| = 62%"},
    {"agent": "D", "msg": "Generating 'Sector Split' Briefing JSON..."},
    {"agent": "D", "msg": "Published via WebSocket."}
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_step < _steps.length) {
        setState(() {
          _logs.add("[${DateTime.now().second}s] AGENT ${_steps[_step]['agent']}: ${_steps[_step]['msg']}");
          _step++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Live Agent Orchestration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(_logs[i], style: const TextStyle(color: Color(0xFF10B981), fontFamily: 'monospace', fontSize: 10)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SignalMatrixModal extends StatelessWidget {
  const SignalMatrixModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Master Signal Matrix", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: SIGNAL_MATRIX.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ...entry.value.map((sig) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(sig['signal']!, style: const TextStyle(fontSize: 12))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                            child: Text("${sig['type']} (${sig['weight']})", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    )),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class GlossaryModal extends StatelessWidget {
  const GlossaryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Divergence Glossary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: DIVERGENCE_GLOSSARY.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section['category'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    ...(section['items'] as List).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['tag'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          Text(item['desc'], style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _LogicModalContent extends StatelessWidget {
  final Briefing brief;
  final ScrollController controller;

  const _LogicModalContent({required this.brief, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Color(0xFF6366F1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Analytical Chain of Thought", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          Text("Subsector: ${brief.subsector}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 1. Process Steps
                const Text("1. SYNTHESIS WORKFLOW", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 16),
                ...brief.processSteps.asMap().entries.map((entry) => _buildStepItem(entry.key + 1, entry.value)),

                const Divider(height: 24),

                // 2. Sentiment Drivers
                if (brief.sentimentHeadlines.isNotEmpty) ...[
                  const Text("2. SENTIMENT DRIVERS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                  const SizedBox(height: 12),
                  ...brief.sentimentHeadlines.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                            h.polarity == 'Negative' ? Icons.trending_down : Icons.trending_up,
                            size: 14,
                            color: h.polarity == 'Negative' ? Colors.red : Colors.green
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(h.source, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
                  const Divider(height: 24),
                ],

                // 3. Verification Sources
                const Text("3. VERIFICATION MATRIX", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 16),
                ...brief.sources.map((s) => _buildSourceItem(s)),

                const Divider(height: 24),

                // 4. Harness Prompt
                const Text("4. SYSTEM HARNESS (LOGIC)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    brief.harness.isNotEmpty ? brief.harness : "System prompt unavailable.",
                    style: const TextStyle(color: Color(0xFFE2E8F0), fontFamily: 'monospace', fontSize: 11, height: 1.5),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index, ProcessStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC7D2FE))),
            child: Text(index.toString(), style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.step, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(step.desc, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(Source source) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(source.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
            if (source.uri.isNotEmpty) Text(source.uri, style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1), decoration: TextDecoration.underline))
            else Text(source.type, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFD1FAE5))),
            child: Text("${source.reliability} Trust", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
          ),
        ],
      ),
    );
  }
}

// --- DATA MODELS ---

class Briefing {
  final String id;
  final String subsector;
  final String title;
  final DateTime timestamp; // Freshness timestamp
  final String summary;
  final String severity;
  final List<String> signals;
  final int factScore;
  final int sentScore;
  final String divergenceTag;
  final String divergenceDesc;
  final Metrics metrics;
  final List<double> chartData;
  final List<ProcessStep> processSteps;
  final List<Source> sources;
  final String harness;
  final List<Headline> sentimentHeadlines;

  Briefing({
    required this.id,
    required this.subsector,
    required this.title,
    required this.timestamp,
    required this.summary,
    required this.severity,
    required this.signals,
    required this.factScore,
    required this.sentScore,
    required this.divergenceTag,
    required this.divergenceDesc,
    required this.metrics,
    required this.chartData,
    required this.processSteps,
    required this.sources,
    required this.harness,
    required this.sentimentHeadlines,
  });

  factory Briefing.fromJson(Map<String, dynamic> json) {
    return Briefing(
      id: json['id']?.toString() ?? '0',
      subsector: json['subsector']?.toString() ?? 'Unknown',
      title: json['title']?.toString() ?? 'Untitled',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      summary: json['summary']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'Low',
      signals: (json['signals'] as List?)?.map((e) => e.toString()).toList() ?? [],

      // FIXED: Safely handle numeric types for scores
      factScore: (json['fact_score'] as num?)?.toInt() ?? 50,
      sentScore: (json['sent_score'] as num?)?.toInt() ?? 50,

      divergenceTag: json['divergence_tag']?.toString() ?? 'None',
      divergenceDesc: json['divergence_desc']?.toString() ?? '',

      metrics: Metrics.fromJson(json['metrics'] ?? {}),

      // FIXED: Safely handle numeric types for chart data
      chartData: (json['chart_data'] as List?)?.map((e) {
        if (e is num) return e.toDouble();
        if (e is String) return double.tryParse(e) ?? 0.0;
        return 0.0;
      }).toList() ?? [],

      processSteps: (json['process_steps'] as List?)?.map((e) => ProcessStep.fromJson(e)).toList() ?? [],
      sources: (json['sources'] as List?)?.map((e) => Source.fromJson(e)).toList() ?? [],
      harness: json['harness']?.toString() ?? '',
      sentimentHeadlines: (json['sentiment_headlines'] as List?)?.map((e) => Headline.fromJson(e)).toList() ?? [],
    );
  }
}

class Metrics {
  final String commodity;
  final String price;
  final String trend;

  Metrics({required this.commodity, required this.price, required this.trend});

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      // FIXED: Added .toString() to prevent double vs string errors
      commodity: json['commodity']?.toString() ?? 'N/A',
      price: json['price']?.toString() ?? '0.00',
      trend: json['trend']?.toString() ?? '0%',
    );
  }
}

class ProcessStep {
  final String step;
  final String desc;

  ProcessStep({required this.step, required this.desc});

  factory ProcessStep.fromJson(Map<String, dynamic> json) {
    return ProcessStep(
      step: json['step']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
    );
  }
}

class Source {
  final String name;
  final String type;
  final String reliability;
  final String uri;

  Source({required this.name, required this.type, required this.reliability, required this.uri});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      reliability: json['reliability']?.toString() ?? '',
      uri: json['uri']?.toString() ?? '',
    );
  }
}

class Headline {
  final String text;
  final String source;
  final String polarity;

  Headline({required this.text, required this.source, required this.polarity});

  factory Headline.fromJson(Map<String, dynamic> json) {
    return Headline(
      text: json['text']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      polarity: json['polarity']?.toString() ?? 'Neutral',
    );
  }
}*//*
*/
/*

*//*

*/
/*

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ai_service.dart';
import 'market_data_service.dart';
import 'signal_data.dart'; // IMPORTED NEW FILE
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const NexThreadApp());
}

class NexThreadApp extends StatelessWidget {
  const NexThreadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexThread Industrials',
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
  final MarketDataService _marketService = MarketDataService();

  List<Briefing> _briefings = [];
  bool _loading = false;

  // Market Facts List (Dynamic)
  List<MarketFact> _marketFacts = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      await Future.wait([
        _fetchPulseData(),
        _generateLiveIntelligence(),
      ]);
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _fetchPulseData() async {
    final facts = await _marketService.getAllFacts();
    if (mounted) {
      setState(() {
        _marketFacts = facts;
      });
    }
  }

  Future<void> _generateLiveIntelligence() async {
    try {
      final headlines = await _aiService.fetchAgHeadlines();
      final jsonMap = await _aiService.generateIntelligence(headlines);

      if (jsonMap.containsKey('briefs')) {
        final List<dynamic> briefsJson = jsonMap['briefs'];
        if (mounted) {
          setState(() {
            _briefings = briefsJson.map((json) => Briefing.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      print("Error generating intelligence: $e");
    }
  }

  void _showAgentSim() {
    showDialog(
      context: context,
      builder: (context) => const AgentSimulationDialog(),
    );
  }

  void _showSignalMatrix() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const SignalMatrixModal(),
    );
  }

  void _showGlossary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const GlossaryModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text('NexThread Agri-POC', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.play_circle_fill, color: Color(0xFF6366F1)), onPressed: _showAgentSim, tooltip: "Live Agents"),
          IconButton(icon: const Icon(Icons.menu_book, color: Color(0xFF64748B)), onPressed: _showSignalMatrix, tooltip: "Signals"),
          IconButton(icon: const Icon(Icons.help_outline, color: Color(0xFF64748B)), onPressed: _showGlossary, tooltip: "Glossary"),
          IconButton(
            icon: Icon(Icons.refresh, color: _loading ? Colors.grey : const Color(0xFF64748B)),
            onPressed: _loading ? null : _loadAllData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          PulseBar(facts: _marketFacts),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadAllData,
              color: const Color(0xFF6366F1),
              child: _loading && _briefings.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _briefings.length,
                itemBuilder: (context, index) => BriefingCard(brief: _briefings[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PulseBar extends StatelessWidget {
  final List<MarketFact> facts;

  const PulseBar({super.key, required this.facts});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
          color: Color(0xFFEEF2FF),
          border: Border(bottom: BorderSide(color: Color(0xFFE0E7FF)))
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: facts.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 24),
        itemBuilder: (ctx, i) => _buildPulseItem(facts[i]),
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
      ],
    );
  }
}

class BriefingCard extends StatelessWidget {
  final Briefing brief;

  const BriefingCard({super.key, required this.brief});

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inHours < 1) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  void _showLogicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _LogicModalContent(brief: brief, controller: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(brief.subsector.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 10, color: const Color(0xFF94A3B8)),
                        const SizedBox(width: 2),
                        Text(
                            "Analysis: ${_getTimeAgo(brief.timestamp)}",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B))
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
                _buildSeverityBadge(brief.severity),
              ],
            ),

            if (brief.signals.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: brief.signals.map((sig) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Text(sig, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                )).toList(),
              ),
            ],

            const SizedBox(height: 12),
            Text(brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('FACT SOURCE (MARKET PATH)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                              const SizedBox(height: 4),
                              Text(brief.metrics.commodity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Row(
                                children: [
                                  Text(brief.metrics.price, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Text(brief.metrics.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                ],
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: brief.chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: true,
                                    color: const Color(0xFF6366F1),
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                      factScore: brief.factScore,
                      sentScore: brief.sentScore,
                      tag: brief.divergenceTag,
                      desc: brief.divergenceDesc,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showLogicModal(context),
              child: const Row(
                children: [
                  Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text("AI LOGIC & VERIFICATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color bg = severity == 'High' ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    Color text = severity == 'High' ? const Color(0xFFBE123C) : const Color(0xFF047857);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(severity.toUpperCase(), style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class DivergenceMeter extends StatelessWidget {
  final int factScore;
  final int sentScore;
  final String tag;
  final String desc;

  const DivergenceMeter({super.key, required this.factScore, required this.sentScore, required this.tag, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFF43F5E)),
              SizedBox(width: 4),
              Text("Scarcity / Crisis", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E))),
            ]),
            Row(children: [
              Text("Abundance / Glut", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              SizedBox(width: 4),
              Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final factPos = (factScore / 100) * w;
            final sentPos = (sentScore / 100) * w;
            final left = math.min(factPos, sentPos);
            final width = (factPos - sentPos).abs();

            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(width: w, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFFFFE4E6), Color(0xFFF1F5F9), Color(0xFFD1FAE5)]))),
                  Positioned(left: left, width: width, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.3), borderRadius: BorderRadius.circular(4)))),
                  Positioned(left: factPos, top: -24, child: _buildMarker("FACT", const Color(0xFF6366F1), true)),
                  Positioned(left: sentPos, bottom: -24, child: _buildMarker("SENTIMENT", const Color(0xFFF43F5E), false)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.analytics, size: 14, color: Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
          ],
        ),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildMarker(String label, Color color, bool top) {
    return FractionalTranslation(
      translation: const Offset(-0.5, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (top) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
            const SizedBox(height: 2),
            Container(width: 2, height: 8, color: color),
          ] else ...[
            Container(width: 2, height: 8, color: color),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
          ],
        ],
      ),
    );
  }
}

class AgentSimulationDialog extends StatefulWidget {
  const AgentSimulationDialog({super.key});
  @override
  State<AgentSimulationDialog> createState() => _AgentSimulationDialogState();
}

class _AgentSimulationDialogState extends State<AgentSimulationDialog> {
  int _step = 0;
  final List<String> _logs = [];
  Timer? _timer;

  final List<Map<String, String>> _steps = [
    {"agent": "A", "msg": "Booting Scraper Cluster (US-East-1)..."},
    {"agent": "A", "msg": "Scanning 12 Whitelisted Agriculture Feeds..."},
    {"agent": "A", "msg": "Extracted 'Avian Flu' entity from USDA.gov"},
    {"agent": "B", "msg": "Verifying 'Layer Flock' count against Census Data..."},
    {"agent": "B", "msg": "Fact Confirmed: -12% YoY. Trust Score: 99%"},
    {"agent": "C", "msg": "Mining Sentiment from 400+ Forum comments..."},
    {"agent": "C", "msg": "Detected 'Panic' polarity (Score: 18/100)"},
    {"agent": "D", "msg": "Calculating Divergence: |80 - 18| = 62%"},
    {"agent": "D", "msg": "Generating 'Sector Split' Briefing JSON..."},
    {"agent": "D", "msg": "Published via WebSocket."}
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_step < _steps.length) {
        setState(() {
          _logs.add("[${DateTime.now().second}s] AGENT ${_steps[_step]['agent']}: ${_steps[_step]['msg']}");
          _step++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Live Agent Orchestration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(_logs[i], style: const TextStyle(color: Color(0xFF10B981), fontFamily: 'monospace', fontSize: 10)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SignalMatrixModal extends StatelessWidget {
  const SignalMatrixModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Master Signal Matrix", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: SignalData.matrix.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ...entry.value.map((sig) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(sig['signal']!, style: const TextStyle(fontSize: 12))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                            child: Text("${sig['type']} (${sig['weight']})", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    )),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class GlossaryModal extends StatelessWidget {
  const GlossaryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Divergence Glossary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: SignalData.divergenceGlossary.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section['category'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    ...(section['items'] as List).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['tag'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          Text(item['desc'], style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _LogicModalContent extends StatelessWidget {
  final Briefing brief;
  final ScrollController controller;

  const _LogicModalContent({required this.brief, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Color(0xFF6366F1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Analytical Chain of Thought", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          Text("Subsector: ${brief.subsector}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 1. Process Steps
                const Text("1. SYNTHESIS WORKFLOW", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 16),
                ...brief.processSteps.asMap().entries.map((entry) => _buildStepItem(entry.key + 1, entry.value)),

                const Divider(height: 24),

                // 2. Sentiment Drivers
                if (brief.sentimentHeadlines.isNotEmpty) ...[
                  const Text("2. SENTIMENT DRIVERS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                  const SizedBox(height: 12),
                  ...brief.sentimentHeadlines.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                            h.polarity == 'Negative' ? Icons.trending_down : Icons.trending_up,
                            size: 14,
                            color: h.polarity == 'Negative' ? Colors.red : Colors.green
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(h.source, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
                  const Divider(height: 24),
                ],

                // 3. Verification Sources
                const Text("3. VERIFICATION MATRIX", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 16),
                ...brief.sources.map((s) => _buildSourceItem(s)),

                const Divider(height: 24),

                // 4. Harness Prompt
                const Text("4. SYSTEM HARNESS (LOGIC)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    brief.harness.isNotEmpty ? brief.harness : "System prompt unavailable.",
                    style: const TextStyle(color: Color(0xFFE2E8F0), fontFamily: 'monospace', fontSize: 11, height: 1.5),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index, ProcessStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC7D2FE))),
            child: Text(index.toString(), style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.step, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(step.desc, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(Source source) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(source.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
            if (source.uri.isNotEmpty) Text(source.uri, style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1), decoration: TextDecoration.underline))
            else Text(source.type, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFD1FAE5))),
            child: Text("${source.reliability} Trust", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
          ),
        ],
      ),
    );
  }
}

// --- DATA MODELS ---

class Briefing {
  final String id;
  final String subsector;
  final String title;
  final DateTime timestamp; // Freshness timestamp
  final String summary;
  final String severity;
  final List<String> signals;
  final int factScore;
  final int sentScore;
  final String divergenceTag;
  final String divergenceDesc;
  final Metrics metrics;
  final List<double> chartData;
  final List<ProcessStep> processSteps;
  final List<Source> sources;
  final String harness;
  final List<Headline> sentimentHeadlines;

  Briefing({
    required this.id,
    required this.subsector,
    required this.title,
    required this.timestamp,
    required this.summary,
    required this.severity,
    required this.signals,
    required this.factScore,
    required this.sentScore,
    required this.divergenceTag,
    required this.divergenceDesc,
    required this.metrics,
    required this.chartData,
    required this.processSteps,
    required this.sources,
    required this.harness,
    required this.sentimentHeadlines,
  });

  factory Briefing.fromJson(Map<String, dynamic> json) {
    return Briefing(
      id: json['id']?.toString() ?? '0',
      subsector: json['subsector']?.toString() ?? 'Unknown',
      title: json['title']?.toString() ?? 'Untitled',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      summary: json['summary']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'Low',
      signals: (json['signals'] as List?)?.map((e) => e.toString()).toList() ?? [],

      // FIXED: Safely handle numeric types for scores
      factScore: (json['fact_score'] as num?)?.toInt() ?? 50,
      sentScore: (json['sent_score'] as num?)?.toInt() ?? 50,

      divergenceTag: json['divergence_tag']?.toString() ?? 'None',
      divergenceDesc: json['divergence_desc']?.toString() ?? '',

      metrics: Metrics.fromJson(json['metrics'] ?? {}),

      // FIXED: Safely handle numeric types for chart data
      chartData: (json['chart_data'] as List?)?.map((e) {
        if (e is num) return e.toDouble();
        if (e is String) return double.tryParse(e) ?? 0.0;
        return 0.0;
      }).toList() ?? [],

      processSteps: (json['process_steps'] as List?)?.map((e) => ProcessStep.fromJson(e)).toList() ?? [],
      sources: (json['sources'] as List?)?.map((e) => Source.fromJson(e)).toList() ?? [],
      harness: json['harness']?.toString() ?? '',
      sentimentHeadlines: (json['sentiment_headlines'] as List?)?.map((e) => Headline.fromJson(e)).toList() ?? [],
    );
  }
}

class Metrics {
  final String commodity;
  final String price;
  final String trend;

  Metrics({required this.commodity, required this.price, required this.trend});

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      // FIXED: Added .toString() to prevent double vs string errors
      commodity: json['commodity']?.toString() ?? 'N/A',
      price: json['price']?.toString() ?? '0.00',
      trend: json['trend']?.toString() ?? '0%',
    );
  }
}

class ProcessStep {
  final String step;
  final String desc;

  ProcessStep({required this.step, required this.desc});

  factory ProcessStep.fromJson(Map<String, dynamic> json) {
    return ProcessStep(
      step: json['step']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
    );
  }
}

class Source {
  final String name;
  final String type;
  final String reliability;
  final String uri;

  Source({required this.name, required this.type, required this.reliability, required this.uri});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      reliability: json['reliability']?.toString() ?? '',
      uri: json['uri']?.toString() ?? '',
    );
  }
}

class Headline {
  final String text;
  final String source;
  final String polarity;

  Headline({required this.text, required this.source, required this.polarity});

  factory Headline.fromJson(Map<String, dynamic> json) {
    return Headline(
      text: json['text']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      polarity: json['polarity']?.toString() ?? 'Neutral',
    );
  }
}*//*

*/
/*

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ai_service.dart';

import 'market_data_service.dart'; // Required for Pulse Bar

import 'dart:async';
import 'dart:math' as math;


void main() {
  runApp(const NexThreadApp());
}

class NexThreadApp extends StatelessWidget {
  const NexThreadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexThread Industrials',
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

// --- CONSTANTS ---
const SIGNAL_MATRIX = {
  "311 Food": [
    { "signal": "Black Sea Grain Initiative", "type": "Geo-Political", "polarity": "+/-", "weight": "0" },
    { "signal": "Protectionist export bans", "type": "Geo-Political", "polarity": "-", "weight": "-1" },
    { "signal": "Sovereign food security mandates", "type": "Geo-Political", "polarity": "+", "weight": "+1.0" },
    { "signal": "Sugar export caps (TRQ)", "type": "Trade/Reg", "polarity": "-", "weight": "-1" },
    { "signal": "Skimpflation", "type": "Crisis", "polarity": "-", "weight": "-4" }
  ],
  "334 Computer/Electronics": [
    { "signal": "Entity List additions (BIS)", "type": "Geo-Political", "polarity": "-", "weight": "-1" },
    { "signal": "CHIPS Act subsidy milestones", "type": "Geo-Political", "polarity": "+", "weight": "+1.0" },
    { "signal": "Neon Gas Shock", "type": "Crisis", "polarity": "-", "weight": "-9" },
    { "signal": "Panic Buying", "type": "Crisis", "polarity": "-", "weight": "-5" }
  ],
  "112 Animal": [
    { "signal": "Livestock contagion", "type": "Crisis", "polarity": "-", "weight": "-10" },
    { "signal": "Feed cost spike", "type": "Crisis", "polarity": "-", "weight": "-6" }
  ]
};

const DIVERGENCE_GLOSSARY = [
  {
    "category": "Buying Opportunities (Green)",
    "items": [
      { "tag": "Unjustified Panic", "desc": "Market is scared, but data proves supply is fine. Sentiment is low, Facts are high." },
      { "tag": "Margin Padding", "desc": "Suppliers' costs dropped, but they haven't lowered prices." },
      { "tag": "Sector Split", "desc": "One niche is booming/crashing, but the market generalizes it to the whole sector." }
    ]
  },
  {
    "category": "Risk Warnings (Red)",
    "items": [
      { "tag": "Over-Ordering", "desc": "Panic-hoarding creating a demand bubble. Buying is high, actual usage is low." },
      { "tag": "Over-Confidence", "desc": "Market is too bullish despite rotting fundamentals." }
    ]
  }
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

*//*

*/
/*class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();
  final MarketDataService _marketService = MarketDataService();

  List<Briefing> _briefings = [];
  bool _loading = false;

  // Store facts in a list for easier updating
  List<MarketFact> _marketFacts = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    _fetchPulseData();
    _generateLiveIntelligence();
  }

  Future<void> _fetchPulseData() async {
    // 1. Fetch all facts at once using the new method
    final results = await _marketService.getAllFacts();

    if (mounted) {
      setState(() {
        _marketFacts = results;
      });

      // 2. Check for pending data and schedule retries
      _schedulePendingRetries(results);
    }
  }

  // --- NEW: Async Retry Logic ---
  void _schedulePendingRetries(List<MarketFact> facts) {
    for (int i = 0; i < facts.length; i++) {
      final fact = facts[i];
      if (fact.isPending) {
        // Wait 3 seconds, then try to update just this specific fact
        Timer(const Duration(seconds: 3), () async {
          if (!mounted) return;

          print("Attempting to update pending fact: ${fact.name}");
          final updatedFact = await _marketService.updatePendingFact(fact);

          if (mounted && updatedFact.status != "Pending Update") {
            setState(() {
              _marketFacts[i] = updatedFact;
            });
          } else {
            // If still pending, you could recursively call this to retry again
            // For now, we'll just leave it as Pending to avoid infinite loops in this demo
          }
        });
      }
    }
  }

  Future<void> _generateLiveIntelligence() async {
    setState(() => _loading = true);
    final headlines = await _aiService.fetchAgHeadlines();
    final jsonMap = await _aiService.generateIntelligence(headlines);
    final List<dynamic> briefsJson = jsonMap['briefs'];

    if (mounted) {
      setState(() {
        _briefings = briefsJson.map((json) => Briefing.fromJson(json)).toList();
        _loading = false;
      });
    }
  }

  void _showAgentSim() {
    showDialog(
      context: context,
      builder: (context) => const AgentSimulationDialog(),
    );
  }

  void _showSignalMatrix() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const SignalMatrixModal(),
    );
  }

  void _showGlossary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const GlossaryModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text('NexThread Agri-POC', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.play_circle_fill, color: Color(0xFF6366F1)), onPressed: _showAgentSim, tooltip: "Live Agents"),
          IconButton(icon: const Icon(Icons.menu_book, color: Color(0xFF64748B)), onPressed: _showSignalMatrix, tooltip: "Signals"),
          IconButton(icon: const Icon(Icons.help_outline, color: Color(0xFF64748B)), onPressed: _showGlossary, tooltip: "Glossary"),
          IconButton(
            icon: Icon(Icons.refresh, color: _loading ? Colors.grey : const Color(0xFF64748B)),
            onPressed: _loading ? null : _loadAllData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            decoration: const BoxDecoration(color: Color(0xFFEEF2FF), border: Border(bottom: BorderSide(color: Color(0xFFE0E7FF)))),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: _marketFacts.isEmpty
              // Show placeholders if empty
                  ? [ _buildPulseItem(null, "Loading...") ]
              // Show actual facts
                  : _marketFacts.map((f) => Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: _buildPulseItem(f, ""),
              )).toList(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
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

  Widget _buildPulseItem(MarketFact? fact, String placeholderLabel) {
    if (fact == null) {
      return Row(children: [Text(placeholderLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))]);
    }

    // UI for Pending Status
    if (fact.isPending) {
      return Row(
        children: [
          Text(fact.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(width: 8),
          const SizedBox(
              width: 10, height: 10,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF59E0B))
          ),
          const SizedBox(width: 4),
          const Text("Updating...", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
        ],
      );
    }

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
      ],
    );
  }
}*//*

*/
/*


// ... imports equal to your file ...

// ... NexThreadApp class ...

// ... DashboardScreen StatefulWidget ...

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();
  final MarketDataService _marketService = MarketDataService();

  List<Briefing> _briefings = [];
  bool _loading = false;

  // Changed to a list for easier iteration
  List<MarketFact?> _marketFacts = [null, null, null];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    _fetchPulseData();
    _generateLiveIntelligence();
  }

  Future<void> _fetchPulseData() async {
    final results = await Future.wait([
      _marketService.fetchWheatPrice(),
      _marketService.fetchInterestRate(),
      _marketService.fetchCadExchangeRate(),
    ]);

    if (mounted) {
      setState(() {
        _marketFacts = results;
      });
      // TRIGGER RETRY LOGIC HERE
      _schedulePendingRetries(results);
    }
  }

  // --- NEW: Async Retry Logic ---
  void _schedulePendingRetries(List<MarketFact> facts) {
    for (int i = 0; i < facts.length; i++) {
      final fact = facts[i];

      // If the fact is "Pending Update", we wait 3s and try again
      if (fact.isPending) {
        Timer(const Duration(seconds: 3), () async {
          if (!mounted) return;

          print("Attempting to retry update for: ${fact.name}");
          final updatedFact = await _marketService.updatePendingFact(fact);

          if (mounted) {
            setState(() {
              _marketFacts[i] = updatedFact;
            });

            // Recursively retry if it failed again
            if (updatedFact.isPending) {
              _schedulePendingRetries(_marketFacts.whereType<MarketFact>().toList());
            }
          }
        });
      }
    }
  }

  // ... _generateLiveIntelligence, _showAgentSim, etc ...

  // ... build method ...

  child: ListView(
  scrollDirection: Axis.horizontal,
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  children: [
  _buildPulseItem(_marketFacts[0], "Wheat"),
  const SizedBox(width: 24),
  _buildPulseItem(_marketFacts[1], "Bond Yield"),
  const SizedBox(width: 24),
  _buildPulseItem(_marketFacts[2], "USD/CAD"),
  ],
  ),

  // ... rest of build ...

  Widget _buildPulseItem(MarketFact? fact, String placeholderLabel) {
  if (fact == null) {
  return Row(children: [Text(placeholderLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))]);
  }

  // UI for Pending Status (The spinner logic)
  if (fact.isPending) {
  return Row(
  children: [
  Text(fact.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
  const SizedBox(width: 8),
  const SizedBox(
  width: 10, height: 10,
  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF59E0B))
  ),
  const SizedBox(width: 4),
  const Text("Updating...", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
  ],
  );
  }

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
  ],
  );
  }
}
class BriefingCard extends StatelessWidget {
  final Briefing brief;

  const BriefingCard({super.key, required this.brief});

  void _showLogicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _LogicModalContent(brief: brief, controller: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(brief.subsector.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
                _buildSeverityBadge(brief.severity),
              ],
            ),

            // Signal Tags
            if (brief.signals.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: brief.signals.map((sig) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Text(sig, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                )).toList(),
              ),
            ],

            const SizedBox(height: 12),
            Text(brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('FACT SOURCE (MARKET PATH)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                              const SizedBox(height: 4),
                              Text(brief.metrics.commodity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Row(
                                children: [
                                  Text(brief.metrics.price, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Text(brief.metrics.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                ],
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: brief.chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: true,
                                    color: const Color(0xFF6366F1),
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                      factScore: brief.factScore,
                      sentScore: brief.sentScore,
                      tag: brief.divergenceTag,
                      desc: brief.divergenceDesc,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showLogicModal(context),
              child: const Row(
                children: [
                  Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text("AI LOGIC & VERIFICATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color bg = severity == 'High' ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    Color text = severity == 'High' ? const Color(0xFFBE123C) : const Color(0xFF047857);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(severity.toUpperCase(), style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class DivergenceMeter extends StatelessWidget {
  final int factScore;
  final int sentScore;
  final String tag;
  final String desc;

  const DivergenceMeter({super.key, required this.factScore, required this.sentScore, required this.tag, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFF43F5E)),
              SizedBox(width: 4),
              Text("Scarcity / Crisis", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E))),
            ]),
            Row(children: [
              Text("Abundance / Glut", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              SizedBox(width: 4),
              Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final factPos = (factScore / 100) * w;
            final sentPos = (sentScore / 100) * w;
            final left = math.min(factPos, sentPos);
            final width = (factPos - sentPos).abs();

            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(width: w, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFFFFE4E6), Color(0xFFF1F5F9), Color(0xFFD1FAE5)]))),
                  Positioned(left: left, width: width, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.3), borderRadius: BorderRadius.circular(4)))),
                  Positioned(left: factPos, top: -24, child: _buildMarker("FACT", const Color(0xFF6366F1), true)),
                  Positioned(left: sentPos, bottom: -24, child: _buildMarker("SENTIMENT", const Color(0xFFF43F5E), false)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.analytics, size: 14, color: Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
          ],
        ),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildMarker(String label, Color color, bool top) {
    return FractionalTranslation(
      translation: const Offset(-0.5, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (top) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
            const SizedBox(height: 2),
            Container(width: 2, height: 8, color: color),
          ] else ...[
            Container(width: 2, height: 8, color: color),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
          ],
        ],
      ),
    );
  }
}

class AgentSimulationDialog extends StatefulWidget {
  const AgentSimulationDialog({super.key});
  @override
  State<AgentSimulationDialog> createState() => _AgentSimulationDialogState();
}

class _AgentSimulationDialogState extends State<AgentSimulationDialog> {
  int _step = 0;
  final List<String> _logs = [];
  Timer? _timer;

  final List<Map<String, String>> _steps = [
    {"agent": "A", "msg": "Booting Scraper Cluster (US-East-1)..."},
    {"agent": "A", "msg": "Scanning 12 Whitelisted Agriculture Feeds..."},
    {"agent": "A", "msg": "Extracted 'Avian Flu' entity from USDA.gov"},
    {"agent": "B", "msg": "Verifying 'Layer Flock' count against Census Data..."},
    {"agent": "B", "msg": "Fact Confirmed: -12% YoY. Trust Score: 99%"},
    {"agent": "C", "msg": "Mining Sentiment from 400+ Forum comments..."},
    {"agent": "C", "msg": "Detected 'Panic' polarity (Score: 18/100)"},
    {"agent": "D", "msg": "Calculating Divergence: |80 - 18| = 62%"},
    {"agent": "D", "msg": "Generating 'Sector Split' Briefing JSON..."},
    {"agent": "D", "msg": "Published via WebSocket."}
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_step < _steps.length) {
        setState(() {
          _logs.add("[${DateTime.now().second}s] AGENT ${_steps[_step]['agent']}: ${_steps[_step]['msg']}");
          _step++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Live Agent Orchestration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(_logs[i], style: const TextStyle(color: Color(0xFF10B981), fontFamily: 'monospace', fontSize: 10)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SignalMatrixModal extends StatelessWidget {
  const SignalMatrixModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Master Signal Matrix", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: SIGNAL_MATRIX.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ...entry.value.map((sig) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(sig['signal']!, style: const TextStyle(fontSize: 12))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                            child: Text("${sig['type']} (${sig['weight']})", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    )),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class GlossaryModal extends StatelessWidget {
  const GlossaryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Divergence Glossary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: DIVERGENCE_GLOSSARY.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section['category'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    ...(section['items'] as List).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['tag'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          Text(item['desc'], style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _LogicModalContent extends StatelessWidget {
  final Briefing brief;
  final ScrollController controller;

  const _LogicModalContent({required this.brief, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Color(0xFF6366F1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Analytical Chain of Thought", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          Text("Subsector: ${brief.subsector}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 1. Process Steps
                const Text("1. SYNTHESIS WORKFLOW", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 16),
                ...brief.processSteps.asMap().entries.map((entry) => _buildStepItem(entry.key + 1, entry.value)),

                const Divider(height: 24),

                // NEW: Sentiment Drivers
                if (brief.sentimentHeadlines.isNotEmpty) ...[
                  const Text("2. SENTIMENT DRIVERS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                  const SizedBox(height: 12),
                  ...brief.sentimentHeadlines.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                            h.polarity == 'Negative' ? Icons.trending_down : Icons.trending_up,
                            size: 14,
                            color: h.polarity == 'Negative' ? Colors.red : Colors.green
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(h.source, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
                  const Divider(height: 24),
                ],

                // 3. Verification Sources
                const Text("3. VERIFICATION MATRIX", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 16),
                ...brief.sources.map((s) => _buildSourceItem(s)),

                const Divider(height: 24),

                // 4. Harness Prompt
                const Text("4. SYSTEM HARNESS (LOGIC)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    brief.harness.isNotEmpty ? brief.harness : "System prompt unavailable.",
                    style: const TextStyle(color: Color(0xFFE2E8F0), fontFamily: 'monospace', fontSize: 11, height: 1.5),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index, ProcessStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC7D2FE))),
            child: Text(index.toString(), style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.step, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(step.desc, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(Source source) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(source.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
            if (source.uri.isNotEmpty) Text(source.uri, style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1), decoration: TextDecoration.underline))
            else Text(source.type, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFD1FAE5))),
            child: Text("${source.reliability} Trust", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
          ),
        ],
      ),
    );
  }
}*/
/*

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ai_service.dart';
// REMOVED: import 'data_service.dart'; (Causes duplicate class error)
import 'market_data_service.dart';

import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const NexThreadApp());
}

class NexThreadApp extends StatelessWidget {
  const NexThreadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexThread Industrials',
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

// --- CONSTANTS ---
const SIGNAL_MATRIX = {
  "311 Food": [
    { "signal": "Black Sea Grain Initiative", "type": "Geo-Political", "polarity": "+/-", "weight": "0" },
    { "signal": "Protectionist export bans", "type": "Geo-Political", "polarity": "-", "weight": "-1" },
    { "signal": "Sovereign food security mandates", "type": "Geo-Political", "polarity": "+", "weight": "+1.0" },
    { "signal": "Sugar export caps (TRQ)", "type": "Trade/Reg", "polarity": "-", "weight": "-1" },
    { "signal": "Skimpflation", "type": "Crisis", "polarity": "-", "weight": "-4" }
  ],
  "334 Computer/Electronics": [
    { "signal": "Entity List additions (BIS)", "type": "Geo-Political", "polarity": "-", "weight": "-1" },
    { "signal": "CHIPS Act subsidy milestones", "type": "Geo-Political", "polarity": "+", "weight": "+1.0" },
    { "signal": "Neon Gas Shock", "type": "Crisis", "polarity": "-", "weight": "-9" },
    { "signal": "Panic Buying", "type": "Crisis", "polarity": "-", "weight": "-5" }
  ],
  "112 Animal": [
    { "signal": "Livestock contagion", "type": "Crisis", "polarity": "-", "weight": "-10" },
    { "signal": "Feed cost spike", "type": "Crisis", "polarity": "-", "weight": "-6" }
  ]
};

const DIVERGENCE_GLOSSARY = [
  {
    "category": "Buying Opportunities (Green)",
    "items": [
      { "tag": "Unjustified Panic", "desc": "Market is scared, but data proves supply is fine. Sentiment is low, Facts are high." },
      { "tag": "Margin Padding", "desc": "Suppliers' costs dropped, but they haven't lowered prices." },
      { "tag": "Sector Split", "desc": "One niche is booming/crashing, but the market generalizes it to the whole sector." }
    ]
  },
  {
    "category": "Risk Warnings (Red)",
    "items": [
      { "tag": "Over-Ordering", "desc": "Panic-hoarding creating a demand bubble. Buying is high, actual usage is low." },
      { "tag": "Over-Confidence", "desc": "Market is too bullish despite rotting fundamentals." }
    ]
  }
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();
  final MarketDataService _marketService = MarketDataService();

  List<Briefing> _briefings = [];
  bool _loading = false;

  // Use MarketFact? to allow for initial null states if needed
  List<MarketFact?> _marketFacts = [null, null, null];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    _fetchPulseData();
    _generateLiveIntelligence();
  }

  Future<void> _fetchPulseData() async {
    // 1. Initial Fetch with explicit typing to fix type error
    final List<MarketFact> results = await Future.wait<MarketFact>([
      _marketService.fetchWheatPrice(),
      _marketService.fetchInterestRate(),
      _marketService.fetchCadExchangeRate(),
    ]);

    if (mounted) {
      setState(() {
        _marketFacts = results;
      });

      // 2. Trigger the Retry Logic for any items that failed (are Pending)
      _schedulePendingRetries(results);
    }
  }

  // --- ASYNC RETRY LOGIC ---
  void _schedulePendingRetries(List<MarketFact?> facts) {
    for (int i = 0; i < facts.length; i++) {
      final fact = facts[i];
      if (fact == null) continue;

      // Check if this specific fact is in the "Pending Update" state
      if (fact.status == 'Pending Update') {

        // Wait 3 seconds, then try to update just this item
        Timer(const Duration(seconds: 3), () async {
          if (!mounted) return;

          print("Attempting to retry update for: ${fact.name}");
          // Call the new method in MarketDataService
          final updatedFact = await _marketService.updatePendingFact(fact);

          if (mounted) {
            setState(() {
              _marketFacts[i] = updatedFact;
            });

            // Recursively retry if it failed again
            if (updatedFact.status == 'Pending Update') {
              // Re-evaluate the list to keep retrying
              _schedulePendingRetries(_marketFacts);
            }
          }
        });
      }
    }
  }

  Future<void> _generateLiveIntelligence() async {
    setState(() => _loading = true);
    final headlines = await _aiService.fetchAgHeadlines();
    final jsonMap = await _aiService.generateIntelligence(headlines);
    final List<dynamic> briefsJson = jsonMap['briefs'];

    if (mounted) {
      setState(() {
        _briefings = briefsJson.map((json) => Briefing.fromJson(json)).toList();
        _loading = false;
      });
    }
  }

  void _showAgentSim() {
    showDialog(
      context: context,
      builder: (context) => const AgentSimulationDialog(),
    );
  }

  void _showSignalMatrix() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const SignalMatrixModal(),
    );
  }

  void _showGlossary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const GlossaryModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text('NexThread Agri-POC', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.play_circle_fill, color: Color(0xFF6366F1)), onPressed: _showAgentSim, tooltip: "Live Agents"),
          IconButton(icon: const Icon(Icons.menu_book, color: Color(0xFF64748B)), onPressed: _showSignalMatrix, tooltip: "Signals"),
          IconButton(icon: const Icon(Icons.help_outline, color: Color(0xFF64748B)), onPressed: _showGlossary, tooltip: "Glossary"),
          IconButton(
            icon: Icon(Icons.refresh, color: _loading ? Colors.grey : const Color(0xFF64748B)),
            onPressed: _loading ? null : _loadAllData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            decoration: const BoxDecoration(color: Color(0xFFEEF2FF), border: Border(bottom: BorderSide(color: Color(0xFFE0E7FF)))),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildPulseItem(_marketFacts[0], "Wheat"),
                const SizedBox(width: 24),
                _buildPulseItem(_marketFacts[1], "Bond Yield"),
                const SizedBox(width: 24),
                _buildPulseItem(_marketFacts[2], "USD/CAD"),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
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

  Widget _buildPulseItem(MarketFact? fact, String placeholderLabel) {
    if (fact == null) {
      return Row(children: [Text(placeholderLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))]);
    }

    // UI for Pending Status (The Spinner)
    if (fact.status == 'Pending Update') {
      return Row(
        children: [
          Text(fact.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(width: 8),
          const SizedBox(
              width: 10, height: 10,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF59E0B))
          ),
          const SizedBox(width: 4),
          const Text("Updating...", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
        ],
      );
    }

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
      ],
    );
  }
}

class BriefingCard extends StatelessWidget {
  final Briefing brief;

  const BriefingCard({super.key, required this.brief});

  void _showLogicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _LogicModalContent(brief: brief, controller: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(brief.subsector.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
                _buildSeverityBadge(brief.severity),
              ],
            ),

            // Signal Tags
            if (brief.signals.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: brief.signals.map((sig) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Text(sig, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                )).toList(),
              ),
            ],

            const SizedBox(height: 12),
            Text(brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('FACT SOURCE (MARKET PATH)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                              const SizedBox(height: 4),
                              Text(brief.metrics.commodity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Row(
                                children: [
                                  Text(brief.metrics.price, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Text(brief.metrics.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                ],
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: brief.chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: true,
                                    color: const Color(0xFF6366F1),
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                      factScore: brief.factScore,
                      sentScore: brief.sentScore,
                      tag: brief.divergenceTag,
                      desc: brief.divergenceDesc,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showLogicModal(context),
              child: const Row(
                children: [
                  Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text("AI LOGIC & VERIFICATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color bg = severity == 'High' ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    Color text = severity == 'High' ? const Color(0xFFBE123C) : const Color(0xFF047857);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(severity.toUpperCase(), style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class DivergenceMeter extends StatelessWidget {
  final int factScore;
  final int sentScore;
  final String tag;
  final String desc;

  const DivergenceMeter({super.key, required this.factScore, required this.sentScore, required this.tag, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFF43F5E)),
              SizedBox(width: 4),
              Text("Scarcity / Crisis", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E))),
            ]),
            Row(children: [
              Text("Abundance / Glut", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              SizedBox(width: 4),
              Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final factPos = (factScore / 100) * w;
            final sentPos = (sentScore / 100) * w;
            final left = math.min(factPos, sentPos);
            final width = (factPos - sentPos).abs();

            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(width: w, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFFFFE4E6), Color(0xFFF1F5F9), Color(0xFFD1FAE5)]))),
                  Positioned(left: left, width: width, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.3), borderRadius: BorderRadius.circular(4)))),
                  Positioned(left: factPos, top: -24, child: _buildMarker("FACT", const Color(0xFF6366F1), true)),
                  Positioned(left: sentPos, bottom: -24, child: _buildMarker("SENTIMENT", const Color(0xFFF43F5E), false)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.analytics, size: 14, color: Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
          ],
        ),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildMarker(String label, Color color, bool top) {
    return FractionalTranslation(
      translation: const Offset(-0.5, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (top) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
            const SizedBox(height: 2),
            Container(width: 2, height: 8, color: color),
          ] else ...[
            Container(width: 2, height: 8, color: color),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
          ],
        ],
      ),
    );
  }
}

class AgentSimulationDialog extends StatefulWidget {
  const AgentSimulationDialog({super.key});
  @override
  State<AgentSimulationDialog> createState() => _AgentSimulationDialogState();
}

class _AgentSimulationDialogState extends State<AgentSimulationDialog> {
  int _step = 0;
  final List<String> _logs = [];
  Timer? _timer;

  final List<Map<String, String>> _steps = [
    {"agent": "A", "msg": "Booting Scraper Cluster (US-East-1)..."},
    {"agent": "A", "msg": "Scanning 12 Whitelisted Agriculture Feeds..."},
    {"agent": "A", "msg": "Extracted 'Avian Flu' entity from USDA.gov"},
    {"agent": "B", "msg": "Verifying 'Layer Flock' count against Census Data..."},
    {"agent": "B", "msg": "Fact Confirmed: -12% YoY. Trust Score: 99%"},
    {"agent": "C", "msg": "Mining Sentiment from 400+ Forum comments..."},
    {"agent": "C", "msg": "Detected 'Panic' polarity (Score: 18/100)"},
    {"agent": "D", "msg": "Calculating Divergence: |80 - 18| = 62%"},
    {"agent": "D", "msg": "Generating 'Sector Split' Briefing JSON..."},
    {"agent": "D", "msg": "Published via WebSocket."}
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_step < _steps.length) {
        setState(() {
          _logs.add("[${DateTime.now().second}s] AGENT ${_steps[_step]['agent']}: ${_steps[_step]['msg']}");
          _step++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Live Agent Orchestration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(_logs[i], style: const TextStyle(color: Color(0xFF10B981), fontFamily: 'monospace', fontSize: 10)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SignalMatrixModal extends StatelessWidget {
  const SignalMatrixModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Master Signal Matrix", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: SIGNAL_MATRIX.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ...entry.value.map((sig) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(sig['signal']!, style: const TextStyle(fontSize: 12))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                            child: Text("${sig['type']} (${sig['weight']})", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    )),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class GlossaryModal extends StatelessWidget {
  const GlossaryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Divergence Glossary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: DIVERGENCE_GLOSSARY.map((section) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section['category'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    ...(section['items'] as List).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['tag'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          Text(item['desc'], style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _LogicModalContent extends StatelessWidget {
  final Briefing brief;
  final ScrollController controller;

  const _LogicModalContent({required this.brief, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Color(0xFF6366F1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Analytical Chain of Thought", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          Text("Subsector: ${brief.subsector}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 1. Process Steps
                const Text("1. SYNTHESIS WORKFLOW", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 16),
                ...brief.processSteps.asMap().entries.map((entry) => _buildStepItem(entry.key + 1, entry.value)),

                const Divider(height: 24),

                // NEW: Sentiment Drivers
                if (brief.sentimentHeadlines.isNotEmpty) ...[
                  const Text("2. SENTIMENT DRIVERS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                  const SizedBox(height: 12),
                  ...brief.sentimentHeadlines.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                            h.polarity == 'Negative' ? Icons.trending_down : Icons.trending_up,
                            size: 14,
                            color: h.polarity == 'Negative' ? Colors.red : Colors.green
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              Text(h.source, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
                  const Divider(height: 24),
                ],

                // 3. Verification Sources
                const Text("3. VERIFICATION MATRIX", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 16),
                ...brief.sources.map((s) => _buildSourceItem(s)),

                const Divider(height: 24),

                // 4. Harness Prompt
                const Text("4. SYSTEM HARNESS (LOGIC)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    brief.harness.isNotEmpty ? brief.harness : "System prompt unavailable.",
                    style: const TextStyle(color: Color(0xFFE2E8F0), fontFamily: 'monospace', fontSize: 11, height: 1.5),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int index, ProcessStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFC7D2FE))),
            child: Text(index.toString(), style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.step, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(step.desc, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(Source source) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(source.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
            if (source.uri.isNotEmpty) Text(source.uri, style: const TextStyle(fontSize: 10, color: Color(0xFF6366F1), decoration: TextDecoration.underline))
            else Text(source.type, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFD1FAE5))),
            child: Text("${source.reliability} Trust", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
          ),
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ai_service.dart';
import 'market_data_service.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(const NexThreadApp());
}

class NexThreadApp extends StatelessWidget {
  const NexThreadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexThread Wheat POC',
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

// --- CONSTANTS ---
// Kept strictly for the UI widgets to reference
const DIVERGENCE_GLOSSARY = [
  {
    "category": "Buying Opportunities",
    "items": [
      { "tag": "Unjustified Panic", "desc": "Market is scared, but data proves supply is fine. Sentiment is low, Facts are high." },
      { "tag": "Margin Padding", "desc": "Suppliers' costs dropped, but they haven't lowered prices." }
    ]
  },
  {
    "category": "Risk Warnings",
    "items": [
      { "tag": "Over-Ordering", "desc": "Panic-hoarding creating a demand bubble." },
      { "tag": "Confirmed Crisis", "desc": "Both data and sentiment agree: Supply is crashing." }
    ]
  }
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AIService _aiService = AIService();
  final MarketDataService _marketService = MarketDataService();

  List<Briefing> _briefings = [];
  bool _loading = false;

  // Single-item list for Wheat Futures
  List<MarketFact?> _marketFacts = [null];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    _fetchPulseData();
    _generateLiveIntelligence();
  }

  Future<void> _fetchPulseData() async {
    // 1. Fetch ONLY Wheat Futures
    final List<MarketFact> results = await Future.wait<MarketFact>([
      _marketService.fetchWheatPrice(),
    ]);

    if (mounted) {
      setState(() {
        _marketFacts = results;
      });
      _schedulePendingRetries(results);
    }
  }

  // Retry logic for the single Wheat item
  void _schedulePendingRetries(List<MarketFact?> facts) {
    for (int i = 0; i < facts.length; i++) {
      final fact = facts[i];
      if (fact == null) continue;

      if (fact.status == 'Pending Update') {
        Timer(const Duration(seconds: 3), () async {
          if (!mounted) return;

          final updatedFact = await _marketService.updatePendingFact(fact);

          if (mounted) {
            setState(() {
              _marketFacts[i] = updatedFact;
            });
            // Keep retrying if still pending
            if (updatedFact.status == 'Pending Update') {
              _schedulePendingRetries(_marketFacts);
            }
          }
        });
      }
    }
  }

  Future<void> _generateLiveIntelligence() async {
    setState(() => _loading = true);
    final headlines = await _aiService.fetchAgHeadlines();
    final jsonMap = await _aiService.generateIntelligence(headlines);
    final List<dynamic> briefsJson = jsonMap['briefs'];

    if (mounted) {
      setState(() {
        _briefings = briefsJson.map((json) => Briefing.fromJson(json)).toList();
        _loading = false;
      });
    }
  }

  void _showAgentSim() {
    showDialog(context: context, builder: (context) => const AgentSimulationDialog());
  }

  void _showGlossary() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const GlossaryModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.grain, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text('NexThread Wheat POC', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.play_circle_fill, color: Color(0xFF6366F1)), onPressed: _showAgentSim, tooltip: "Live Agents"),
          IconButton(icon: const Icon(Icons.help_outline, color: Color(0xFF64748B)), onPressed: _showGlossary, tooltip: "Glossary"),
          IconButton(
            icon: Icon(Icons.refresh, color: _loading ? Colors.grey : const Color(0xFF64748B)),
            onPressed: _loading ? null : _loadAllData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // MARKET PULSE BAR (Wheat Only)
          Container(
            height: 50,
            decoration: const BoxDecoration(color: Color(0xFFEEF2FF), border: Border(bottom: BorderSide(color: Color(0xFFE0E7FF)))),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildPulseItem(_marketFacts[0], "Wheat Futures"),
              ],
            ),
          ),
          // BRIEFING CARDS
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
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

  Widget _buildPulseItem(MarketFact? fact, String placeholderLabel) {
    if (fact == null) {
      return Row(children: [Text(placeholderLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))]);
    }

    // UI for Pending Status
    if (fact.status == 'Pending Update') {
      return Row(
        children: [
          Text(fact.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(width: 8),
          const SizedBox(
              width: 10, height: 10,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF59E0B))
          ),
          const SizedBox(width: 4),
          const Text("Updating...", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
        ],
      );
    }

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
      ],
    );
  }
}

// --- RESTORED: FULL UI COMPONENTS ---

class BriefingCard extends StatelessWidget {
  final Briefing brief;

  const BriefingCard({super.key, required this.brief});

  void _showLogicModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _LogicModalContent(brief: brief, controller: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(brief.subsector.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(brief.title, style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                  ],
                ),
                _buildSeverityBadge(brief.severity),
              ],
            ),
            const SizedBox(height: 12),
            Text(brief.summary, style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4)),
            const SizedBox(height: 20),

            // VISUALIZATION BLOCK
            Container(
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('MARKET PATH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                              const SizedBox(height: 4),
                              Text(brief.metrics.commodity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              Row(
                                children: [
                                  Text(brief.metrics.price, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Text(brief.metrics.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                                ],
                              )
                            ],
                          ),
                        ),
                        // Tiny Sparkline Chart
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: brief.chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                                    isCurved: true,
                                    color: const Color(0xFF6366F1),
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // DIVERGENCE METER (The requested feature)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: DivergenceMeter(
                      factScore: brief.factScore,
                      sentScore: brief.sentScore,
                      tag: brief.divergenceTag,
                      desc: brief.divergenceDesc,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showLogicModal(context),
              child: const Row(
                children: [
                  Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text("AI LOGIC & VERIFICATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  Spacer(),
                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color bg = severity == 'High' ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5);
    Color text = severity == 'High' ? const Color(0xFFBE123C) : const Color(0xFF047857);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(severity.toUpperCase(), style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class DivergenceMeter extends StatelessWidget {
  final int factScore;
  final int sentScore;
  final String tag;
  final String desc;

  const DivergenceMeter({super.key, required this.factScore, required this.sentScore, required this.tag, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFF43F5E)),
              SizedBox(width: 4),
              Text("Scarcity / Crisis", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF43F5E))),
            ]),
            Row(children: [
              Text("Abundance / Glut", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              SizedBox(width: 4),
              Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
            ]),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final factPos = (factScore / 100) * w;
            final sentPos = (sentScore / 100) * w;
            final left = math.min(factPos, sentPos);
            final width = (factPos - sentPos).abs();

            return SizedBox(
              height: 12,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Container(width: w, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFFFFE4E6), Color(0xFFF1F5F9), Color(0xFFD1FAE5)]))),
                  Positioned(left: left, width: width, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.3), borderRadius: BorderRadius.circular(4)))),
                  Positioned(left: factPos, top: -24, child: _buildMarker("FACT", const Color(0xFF6366F1), true)),
                  Positioned(left: sentPos, bottom: -24, child: _buildMarker("SENTIMENT", const Color(0xFFF43F5E), false)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.analytics, size: 14, color: Color(0xFF6366F1)),
            const SizedBox(width: 6),
            Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
          ],
        ),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildMarker(String label, Color color, bool top) {
    return FractionalTranslation(
      translation: const Offset(-0.5, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (top) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
            const SizedBox(height: 2),
            Container(width: 2, height: 8, color: color),
          ] else ...[
            Container(width: 2, height: 8, color: color),
            const SizedBox(height: 2),
            Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: color), boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)]), child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color))),
          ],
        ],
      ),
    );
  }
}

// --- LOGIC MODAL & OTHERS ---

class _LogicModalContent extends StatelessWidget {
  final Briefing brief;
  final ScrollController controller;
  const _LogicModalContent({required this.brief, required this.controller});
  @override Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: ListView(
        controller: controller,
        children: [
          Text("AI Logic Analysis", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(brief.harness, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          const SizedBox(height: 16),
          const Text("Verified Sources:", style: TextStyle(fontWeight: FontWeight.bold)),
          ...brief.headlines.map((h) => Padding(padding: const EdgeInsets.all(4), child: Text("• $h", style: const TextStyle(fontSize: 12))))
        ],
      ),
    );
  }
}

class GlossaryModal extends StatelessWidget {
  const GlossaryModal({super.key});
  @override Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Divergence Glossary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...DIVERGENCE_GLOSSARY.expand((s) => (s['items'] as List).map((i) => Text("• ${i['tag']}: ${i['desc']}\n"))),
        ],
      ),
    );
  }
}

class AgentSimulationDialog extends StatefulWidget {
  const AgentSimulationDialog({super.key});
  @override State<AgentSimulationDialog> createState() => _AgentSimulationDialogState();
}

class _AgentSimulationDialogState extends State<AgentSimulationDialog> {
  @override Widget build(BuildContext context) {
    return const Dialog(backgroundColor: Color(0xFF0F172A), child: SizedBox(height: 200, child: Center(child: Text("Agents Running...", style: TextStyle(color: Colors.green)))));
  }
}