import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ai_service.dart';
import 'data_service.dart';
import 'market_data_service.dart'; // Required for Pulse Bar

/*
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

  // Pulse Bar State
  MarketFact? _wheatFact;
  MarketFact? _rateFact;
  MarketFact? _fxFact;

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
    // Parallel fetch for speed
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
    setState(() => _loading = true);

    // 1. Fetch News
    final headlines = await _aiService.fetchAgHeadlines();

    // 2. Synthesize with GPT-4
    final jsonMap = await _aiService.generateIntelligence(headlines);

    if (mounted) {
      setState(() {
        final List<dynamic> briefsJson = jsonMap['briefs'];
        _briefings = briefsJson.map((json) => Briefing.fromJson(json)).toList();
        _loading = false;
      });
    }
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
            Text(
              'NexThread Agri-POC',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _loading ? Colors.grey : const Color(0xFF64748B)),
            onPressed: _loading ? null : _loadAllData,
            tooltip: "Generate New Intelligence",
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // 1. Sector Pulse Bar (Sticky Top)
          Container(
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF), // Indigo-50
              border: Border(bottom: BorderSide(color: Color(0xFFE0E7FF))),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildPulseItem(_wheatFact, "Wheat"),
                const SizedBox(width: 24),
                _buildPulseItem(_rateFact, "Bond Yield"),
                const SizedBox(width: 24),
                _buildPulseItem(_fxFact, "USD/CAD"),
              ],
            ),
          ),

          // 2. Main Content
          Expanded(
            child: _loading
                ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6366F1)),
                    SizedBox(height: 16),
                    Text("Agents A & B are scanning...", style: TextStyle(color: Colors.grey))
                  ],
                )
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) {
                return BriefingCard(brief: _briefings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseItem(MarketFact? fact, String placeholderLabel) {
    if (fact == null) {
      return Row(
        children: [
          Text(placeholderLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(width: 8),
          const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      );
    }

    final isUp = !fact.trend.startsWith('-');
    return Row(
      children: [
        Text(fact.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        const SizedBox(width: 8),
        Text(fact.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Icon(
          isUp ? Icons.arrow_upward : Icons.arrow_downward,
          size: 12,
          color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
        Text(
          fact.trend,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }
}

class BriefingCard extends StatelessWidget {
  final Briefing brief;

  const BriefingCard({super.key, required this.brief});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brief.subsector.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      brief.title,
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                _buildSeverityBadge(brief.severity),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              brief.summary,
              style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 20),

            // Quad-Grid Layout
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Row 1: Fact Source (Market Path)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Explicit Label for Traceability
                              const Text(
                                  'FACT SOURCE (MARKET PATH)',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))
                              ),
                              const SizedBox(height: 4),
                              Text(brief.metrics.commodity, style: _valueStyle()),
                              Row(
                                children: [
                                  Text(brief.metrics.price, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  const SizedBox(width: 8),
                                  Text(
                                      brief.metrics.trend,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444)
                                      )
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        // Sparkline Chart
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
                                    spots: brief.chartData.asMap().entries.map((e) {
                                      return FlSpot(e.key.toDouble(), e.value);
                                    }).toList(),
                                    isCurved: true,
                                    color: const Color(0xFF6366F1), // Matches Fact Color
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

                  // Visual Connector Line Logic
                  // Note: In standard Flutter column/row layout, we imply connection via alignment and proximity.
                  // For a literal line, we use a CustomPaint or simple container bridge.
                  // Here we use color coding (Indigo chart -> Indigo Fact Marker) to imply the link.

                  const Divider(height: 1),

                  // Row 2: Divergence Meter
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
            // Footer
            Row(
              children: [
                const Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                const SizedBox(width: 4),
                const Text(
                  "AI LOGIC",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                ),
                const Spacer(),
                const Icon(Icons.newspaper, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  "${brief.headlines.length} Sources",
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle() => const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8));
  TextStyle _valueStyle() => const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A));

  Widget _buildSeverityBadge(String severity) {
    Color bg;
    Color text;
    switch (severity) {
      case 'High':
        bg = const Color(0xFFFEE2E2); text = const Color(0xFFBE123C); break;
      case 'Medium':
        bg = const Color(0xFFFEF3C7); text = const Color(0xFFB45309); break;
      default:
        bg = const Color(0xFFD1FAE5); text = const Color(0xFF047857);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class DivergenceMeter extends StatelessWidget {
  final int factScore;
  final int sentScore;
  final String tag;
  final String desc;

  const DivergenceMeter({
    super.key,
    required this.factScore,
    required this.sentScore,
    required this.tag,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMarkerLabel(Icons.warning_amber_rounded, "Scarcity / Crisis", const Color(0xFFF43F5E)),
            _buildMarkerLabel(Icons.check_circle_outline, "Abundance / Glut", const Color(0xFF10B981)),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return SizedBox(
                height: 12,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Track
                    Container(
                      height: 8,
                      width: width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFE4E6), Color(0xFFF1F5F9), Color(0xFFD1FAE5)],
                        ),
                      ),
                    ),
                    // Fact Marker (Indigo)
                    Positioned(
                      left: (factScore / 100) * width,
                      child: _buildMarker("FACT", const Color(0xFF6366F1), true),
                    ),
                    // Sentiment Marker (Rose)
                    Positioned(
                      left: (sentScore / 100) * width,
                      child: _buildMarker("SENTIMENT", const Color(0xFFF43F5E), false),
                    ),
                  ],
                ),
              );
            }
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

  Widget _buildMarkerLabel(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color),
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)],
              ),
              child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
            ),
            const SizedBox(height: 2),
            Container(width: 2, height: 8, color: color),
          ] else ...[
            Container(width: 2, height: 8, color: color),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color),
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)],
              ),
              child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ],
      ),
    );
  }
}*/

/*

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
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF10B981),
          error: const Color(0xFFEF4444),
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

  MarketFact? _wheatFact;
  MarketFact? _rateFact;
  MarketFact? _fxFact;

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
        _wheatFact = results[0];
        _rateFact = results[1];
        _fxFact = results[2];
      });
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
            Text(
              'NexThread Agri-POC',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _loading ? Colors.grey : const Color(0xFF64748B)),
            onPressed: _loading ? null : _loadAllData,
            tooltip: "Generate New Intelligence",
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              border: Border(bottom: BorderSide(color: Color(0xFFE0E7FF))),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildPulseItem(_wheatFact, "Wheat"),
                const SizedBox(width: 24),
                _buildPulseItem(_rateFact, "Can Bond Yield"),
                const SizedBox(width: 24),
                _buildPulseItem(_fxFact, "USD/CAD"),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6366F1)),
                    SizedBox(height: 16),
                    Text("Agent A is scanning news feeds...", style: TextStyle(color: Colors.grey)),
                  ],
                )
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _briefings.length,
              itemBuilder: (context, index) {
                return BriefingCard(brief: _briefings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseItem(MarketFact? fact, String placeholderLabel) {
    if (fact == null) {
      return Row(
        children: [
          Text(placeholderLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(width: 8),
          const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
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
        Text(fact.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
        initialChildSize: 0.7,
        minChildSize: 0.4,
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
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
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

            // Quad-Grid (Simplified for brevity in main file, assumes charts logic is same as before)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('FACT SOURCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                        Text(brief.metrics.commodity, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(brief.metrics.trend, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: brief.metrics.trend.contains('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                      ]),
                    ],
                  ),
                  const Divider(),
                  _buildDivergenceMeter(brief),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Logic Button
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

  Widget _buildDivergenceMeter(Briefing brief) {
    // Reusing the DivergenceMeter logic from previous steps but inline for brevity
    return Column(
      children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("FACT", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
          Text("SENTIMENT", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
        ]),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(3))),
            Container(width: 300 * (brief.factScore / 100), height: 6, decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(3))),
            Container(width: 300 * (brief.sentScore / 100), height: 6, decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
          ],
        ),
        const SizedBox(height: 4),
        Text("Signal: ${brief.divergenceTag}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      ],
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

class _LogicModalContent extends StatelessWidget {
  final Briefing brief;
  final ScrollController controller;

  const _LogicModalContent({required this.brief, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: [
        const Center(child: SizedBox(width: 40, height: 4, child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFE2E8F0), borderRadius: BorderRadius.all(Radius.circular(2)))))),
        const SizedBox(height: 24),
        const Text("Analytical Chain of Thought", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        Text("Subsector: ${brief.subsector}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 24),

        // 1. Process Steps
        ...brief.processSteps.asMap().entries.map((entry) => _buildStepItem(entry.key + 1, entry.value)),

        const Divider(height: 40),

        // 2. Verification Sources
        const Text("Verification Matrix", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        ...brief.sources.map((s) => _buildSourceItem(s)),

        const Divider(height: 40),

        // 3. Harness Prompt
        const Text("System Harness (Logic)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
          child: Text(brief.harness, style: const TextStyle(color: Color(0xFFE2E8F0), fontFamily: 'monospace', fontSize: 10, height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildStepItem(int index, ProcessStep step) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24, height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
            child: Text(index.toString(), style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.step, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(step.desc, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(Source source) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(source.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(source.type, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
            child: Text("${source.reliability} Trust", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
          ),
        ],
      ),
    );
  }
}*/

/*
import 'dart:math' as math; // Import math for min/abs

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
  bool _verifyingSources = false;

  MarketFact? _wheatFact;
  MarketFact? _rateFact;
  MarketFact? _fxFact;
  List<Map<String, dynamic>> _sourceHealth = [];

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
        _wheatFact = results[0];
        _rateFact = results[1];
        _fxFact = results[2];
      });
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

  Future<void> _verifyDataSources() async {
    setState(() => _verifyingSources = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {
        _verifyingSources = false;
        _sourceHealth = [
          {"source": "Bank of Canada (Valet)", "url": "bankofcanada.ca/valet", "status": "200 OK", "latency": "45ms"},
          {"source": "Alpha Vantage API", "url": "alphavantage.co/query", "status": "200 OK", "latency": "120ms"},
          {"source": "AgWeb RSS Feed", "url": "agweb.com/rss/all", "status": "Active", "items": "12 new"},
          {"source": "Reuters Commodities", "url": "reuters.com/feed", "status": "Active", "items": "8 new"},
          {"source": "OpenAI Engine", "url": "api.openai.com/v1", "status": "Ready", "model": "gpt-4-turbo"},
        ];
      });
      _showSourceStatusModal();
    }
  }

  void _showSourceStatusModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.network_check, color: Color(0xFF6366F1)),
                SizedBox(width: 12),
                Text("Active Data Pipelines", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 24),
            ..._sourceHealth.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s['source'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(s['url'], style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace')),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                    child: Text(s['status'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 10)),
                  )
                ],
              ),
            )),
          ],
        ),
      ),
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
          IconButton(
            icon: Icon(Icons.network_check, color: _verifyingSources ? const Color(0xFF6366F1) : const Color(0xFF64748B)),
            onPressed: _verifyingSources ? null : _verifyDataSources,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: _loading ? Colors.grey : const Color(0xFF64748B)),
            onPressed: _loading ? null : _loadAllData,
          ),
          const SizedBox(width: 16),
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
                _buildPulseItem(_wheatFact, "Wheat"),
                const SizedBox(width: 24),
                _buildPulseItem(_rateFact, "Bond Yield"),
                const SizedBox(width: 24),
                _buildPulseItem(_fxFact, "USD/CAD"),
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
      return Row(
        children: [
          Text(placeholderLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(width: 8),
          const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
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
        Text(fact.value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
        initialChildSize: 0.7,
        minChildSize: 0.4,
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

  const DivergenceMeter({
    super.key,
    required this.factScore,
    required this.sentScore,
    required this.tag,
    required this.desc,
  });

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
        const SizedBox(height: 24), // Space for top markers
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
                  // Base Track
                  Container(
                    width: w,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE4E6), Color(0xFFF1F5F9), Color(0xFFD1FAE5)],
                      ),
                    ),
                  ),
                  // Connection Bar (The Gap)
                  Positioned(
                    left: left,
                    width: width,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Fact Marker (Top)
                  Positioned(
                    left: factPos,
                    top: -24,
                    child: _buildMarker("FACT", const Color(0xFF6366F1), true),
                  ),
                  // Sentiment Marker (Bottom)
                  Positioned(
                    left: sentPos,
                    bottom: -24,
                    child: _buildMarker("SENTIMENT", const Color(0xFFF43F5E), false),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24), // Space for bottom markers
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color),
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)],
              ),
              child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
            ),
            const SizedBox(height: 2),
            Container(width: 2, height: 8, color: color),
          ] else ...[
            Container(width: 2, height: 8, color: color),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color),
                boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4)],
              ),
              child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                const Text("1. SYNTHESIS WORKFLOW", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 16),
                ...brief.processSteps.asMap().entries.map((entry) => _buildStepItem(entry.key + 1, entry.value)),
                const Divider(height: 40),
                const Text("2. VERIFICATION MATRIX", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 16),
                ...brief.sources.map((s) => _buildSourceItem(s)),
                const Divider(height: 40),
                const Text("3. SYSTEM HARNESS (LOGIC)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                  child: Text(brief.harness.isNotEmpty ? brief.harness : "Unavailable", style: const TextStyle(color: Color(0xFFE2E8F0), fontFamily: 'monospace', fontSize: 12, height: 1.5)),
                ),
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
            Text(source.type, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
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
  MarketFact? _wheatFact;
  MarketFact? _rateFact;
  MarketFact? _fxFact;

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
        _wheatFact = results[0];
        _rateFact = results[1];
        _fxFact = results[2];
      });
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
                _buildPulseItem(_wheatFact, "Wheat"),
                const SizedBox(width: 24),
                _buildPulseItem(_rateFact, "Bond Yield"),
                const SizedBox(width: 24),
                _buildPulseItem(_fxFact, "USD/CAD"),
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
}