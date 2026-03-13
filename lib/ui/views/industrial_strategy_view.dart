

/*

// lib/ui/views/industrial_strategy_view.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/strategy_consultant_service.dart';

class IndustrialStrategyView extends StatefulWidget {
  const IndustrialStrategyView({super.key});

  @override
  State<IndustrialStrategyView> createState() => _IndustrialStrategyViewState();
}

class _IndustrialStrategyViewState extends State<IndustrialStrategyView> with AutomaticKeepAliveClientMixin {
  final StrategyConsultantService _strategyService = StrategyConsultantService();

  bool _isLoading = false;
  String _loadingStatus = "";

  Map<String, dynamic>? _reportData;
  List<Map<String, dynamic>> _liveSectors = [];

  // --- PROMPT SELECTION STATE ---
  final Map<String, String> _availablePrompts = {
    "Standard Strategy Consultant": "assets/prompts/senior_industrial_strategy_consultant.json",
    "Aggressive P.E. Analyst": "assets/prompts/aggressive_pe_analyst.json",
    "Canadian Phosphate Focus": "assets/prompts/canadian_phosphate_analyst.json",
    "Canadian Canola Focus": "assets/prompts/canadian_canola_analyst.json",
  };
  late String _selectedPromptPath;

  @override
  void initState() {
    super.initState();
    _selectedPromptPath = _availablePrompts.values.first; // Default
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _reportData = null;
      _liveSectors.clear();
      _loadingStatus = "Initializing AI Consultant...";
    });

    final result = await _strategyService.generateIndustrialStrategyReport(
        promptAssetPath: _selectedPromptPath,
        onProgress: (status, newSector) {
          if (mounted) {
            setState(() {
              _loadingStatus = status;
              if (newSector != null) {
                _liveSectors.add(newSector);
              }
            });
          }
        }
    );

    if (mounted) {
      setState(() {
        _reportData = result;
        _isLoading = false;
      });
    }
  }

  // --- DROPDOWN WIDGET HELPER ---
  Widget _buildPromptSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPromptPath,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6366F1)),
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          items: _availablePrompts.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.value,
              child: Text(entry.key),
            );
          }).toList(),
          onChanged: _isLoading ? null : (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedPromptPath = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  // --- LOGIC MODAL TRIGGER ---
  void _showAiLogicModal(BuildContext context, String logicText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Ensures top corners match container
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Text("AI Logic & Data Provenance", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // --- CHANGED TO SELECTABLE TEXT FOR URLs ---
              SelectableText(
                logicText,
                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.6),
              ),
              // ------------------------------------------
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 1. EMPTY STATE
    if (_reportData == null && !_isLoading && _liveSectors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree_outlined, size: 64, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              "Industrial Intelligence Hub",
              style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select an AI Persona to analyze the cross-sector intelligence.",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),

            _buildPromptSelector(),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateReport,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generate Intelligence Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      );
    }

    final title = _reportData?['report_title'] ?? "Live Intelligence Generation";
    final conclusion = _reportData?['synthesis_conclusion'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              Row(
                children: [
                  if (!_isLoading) _buildPromptSelector(),
                  const SizedBox(width: 16),
                  if (!_isLoading)
                    OutlinedButton.icon(
                      onPressed: _generateReport,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text("Regenerate"),
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
                    )
                ],
              )
            ],
          ),
          const SizedBox(height: 24),

          // LIVE SECTOR GRID
          ..._liveSectors.map((sector) => _buildSectorCard(sector)).toList(),

          // LOADING INDICATOR
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF6366F1)),
                    const SizedBox(height: 16),
                    Text(_loadingStatus, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),

          // SYNTHESIS CONCLUSION
          if (!_isLoading && conclusion != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Text("Synthesis Conclusion & Meta-Trend", style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    conclusion,
                    style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  // --- REUSED WIDGET BUILDERS ---

  Widget _buildSectorCard(Map<String, dynamic> sector) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.domain, color: Color(0xFF6366F1)),
                ),
                const SizedBox(width: 12),
                Text(
                  sector['sector_name'] ?? "Unknown Sector",
                  style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDataRow("Development:", sector['synthesized_development']),
            const SizedBox(height: 16),
            _buildDataRow("Strategic Insight:", sector['strategic_insight'], isHighlight: true),
            const SizedBox(height: 16),
            _buildDataRow("Opportunity:", sector['opportunity'], icon: Icons.trending_up, iconColor: Colors.green),
            const SizedBox(height: 16),
            _buildDataRow("Visual Suggestion:", sector['visual_suggestion'], icon: Icons.image_outlined, iconColor: Colors.grey),

            // --- BASE64 IMAGE RENDERER ---
            if (sector['image_base64'] != null && sector['image_base64'].toString().isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.memory(
                          base64Decode(sector['image_base64']),
                          height: 350,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 350,
                              color: const Color(0xFFF8FAFC),
                              child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: Colors.grey, size: 48),
                                      SizedBox(height: 8),
                                      Text("Failed to decode image", style: TextStyle(color: Colors.grey)),
                                    ],
                                  )
                              ),
                            );
                          }
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF6366F1)),
                          const SizedBox(width: 8),
                          Text(
                            "AI-Generated Strategic Visualization",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // --- AI LOGIC BUTTON (Always Visible & Type-Safe) ---
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                // Safely parse the references whether the AI returned a String or a List
                String logicText = "No references were returned by the AI for this sector.";
                final rawLogic = sector['ai_logic_references'];

                if (rawLogic != null && rawLogic.toString().trim().isNotEmpty) {
                  if (rawLogic is List) {
                    logicText = rawLogic.map((e) => "• $e").join("\n\n");
                  } else {
                    logicText = rawLogic.toString();
                  }
                }

                _showAiLogicModal(context, logicText);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                    SizedBox(width: 4),
                    Text("LOGIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  ],
                ),
              ),
            )
            // ----------------------------------------------------

          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String? text, {bool isHighlight = false, IconData? icon, Color? iconColor}) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[Icon(icon, size: 18, color: iconColor), const SizedBox(width: 8)],
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Color(0xFF334155), height: 1.6),
              children: [
                TextSpan(text: "$label ", style: TextStyle(fontWeight: FontWeight.bold, color: isHighlight ? const Color(0xFF6366F1) : const Color(0xFF0F172A))),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}*/

/*
// lib/ui/views/industrial_strategy_view.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/strategy_consultant_service.dart';
import '../../core/models.dart';
import '../widgets/market_pulse_row.dart';

class IndustrialStrategyView extends StatefulWidget {
  const IndustrialStrategyView({super.key});

  @override
  State<IndustrialStrategyView> createState() => _IndustrialStrategyViewState();
}

class _IndustrialStrategyViewState extends State<IndustrialStrategyView> with AutomaticKeepAliveClientMixin {
  final StrategyConsultantService _strategyService = StrategyConsultantService();

  bool _isLoading = false;
  String _loadingStatus = "";

  Map<String, dynamic>? _reportData;
  List<Map<String, dynamic>> _liveSectors = [];

  // --- PROMPT SELECTION STATE ---
  final Map<String, String> _availablePrompts = {
    "Standard Strategy Consultant": "assets/prompts/senior_industrial_strategy_consultant.json",
    "Aggressive P.E. Analyst": "assets/prompts/aggressive_pe_analyst.json",
    "Canadian Phosphate Focus": "assets/prompts/canadian_phosphate_analyst.json",
    "Canadian Canola Focus": "assets/prompts/canadian_canola_analyst.json",
  };
  late String _selectedPromptPath;

  @override
  void initState() {
    super.initState();
    _selectedPromptPath = _availablePrompts.values.first; // Default
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _reportData = null;
      _liveSectors.clear();
      _loadingStatus = "Initializing AI Consultant...";
    });

    final result = await _strategyService.generateIndustrialStrategyReport(
        promptAssetPath: _selectedPromptPath,
        onProgress: (status, newSector) {
          if (mounted) {
            setState(() {
              _loadingStatus = status;
              if (newSector != null) {
                _liveSectors.add(newSector);
              }
            });
          }
        }
    );

    if (mounted) {
      setState(() {
        _reportData = result;
        _isLoading = false;
      });
    }
  }

  // --- DROPDOWN WIDGET HELPER ---
  Widget _buildPromptSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPromptPath,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6366F1)),
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          items: _availablePrompts.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.value,
              child: Text(entry.key),
            );
          }).toList(),
          onChanged: _isLoading ? null : (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedPromptPath = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  // --- LOGIC MODAL TRIGGER ---
  void _showAiLogicModal(BuildContext context, String logicText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Ensures top corners match container
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Text("AI Logic & Data Provenance", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SelectableText(
                logicText,
                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 1. EMPTY STATE
    if (_reportData == null && !_isLoading && _liveSectors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree_outlined, size: 64, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              "Industrial Intelligence Hub",
              style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select an AI Persona to analyze the cross-sector intelligence.",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),

            _buildPromptSelector(),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateReport,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generate Intelligence Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
        ),
      );
    }

    final title = _reportData?['report_title'] ?? "Live Intelligence Generation";
    final conclusion = _reportData?['synthesis_conclusion'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              Row(
                children: [
                  if (!_isLoading) _buildPromptSelector(),
                  const SizedBox(width: 16),
                  if (!_isLoading)
                    OutlinedButton.icon(
                      onPressed: _generateReport,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text("Regenerate"),
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
                    )
                ],
              )
            ],
          ),
          const SizedBox(height: 24),

          // LIVE SECTOR GRID
          ..._liveSectors.map((sector) => _buildSectorCard(sector)).toList(),

          // LOADING INDICATOR
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF6366F1)),
                    const SizedBox(height: 16),
                    Text(_loadingStatus, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),

          // SYNTHESIS CONCLUSION
          if (!_isLoading && conclusion != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Text("Synthesis Conclusion & Meta-Trend", style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    conclusion,
                    style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  // --- REUSED WIDGET BUILDERS ---

  Widget _buildSectorCard(Map<String, dynamic> sector) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.domain, color: Color(0xFF6366F1)),
                ),
                const SizedBox(width: 12),
                Text(
                  sector['sector_name'] ?? "Unknown Sector",
                  style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDataRow("Development:", sector['synthesized_development']),
            const SizedBox(height: 16),
            _buildDataRow("Strategic Insight:", sector['strategic_insight'], isHighlight: true),
            const SizedBox(height: 16),
            _buildDataRow("Opportunity:", sector['opportunity'], icon: Icons.trending_up, iconColor: Colors.green),
            const SizedBox(height: 16),
            _buildDataRow("Visual Suggestion:", sector['visual_suggestion'], icon: Icons.image_outlined, iconColor: Colors.grey),

            // --- MARKET ACTIVITY (ETFs) ---
            if (sector['market_fact'] != null && sector['market_fact'] is MarketFact) ...[
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(Icons.show_chart, color: Color(0xFF6366F1), size: 20),
                  SizedBox(width: 8),
                  Text("Market Activity (ETFs)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 12),
              Builder(builder: (context) {
                final fact = sector['market_fact'] as MarketFact;
                if (fact.subFacts.isNotEmpty) {
                  return Column(
                    children: fact.subFacts.map((sub) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: MarketPulseRow(fact: sub),
                    )).toList(),
                  );
                } else {
                  return MarketPulseRow(fact: fact);
                }
              }),
            ],

            // --- BASE64 IMAGE RENDERER ---
            if (sector['image_base64'] != null && sector['image_base64'].toString().isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.memory(
                          base64Decode(sector['image_base64']),
                          height: 350,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 350,
                              color: const Color(0xFFF8FAFC),
                              child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: Colors.grey, size: 48),
                                      SizedBox(height: 8),
                                      Text("Failed to decode image", style: TextStyle(color: Colors.grey)),
                                    ],
                                  )
                              ),
                            );
                          }
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF6366F1)),
                          const SizedBox(width: 8),
                          Text(
                            "AI-Generated Strategic Visualization",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // --- AI LOGIC BUTTON (Always Visible & Type-Safe) ---
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                // Safely parse the references whether the AI returned a String or a List
                String logicText = "No references were returned by the AI for this sector.";
                final rawLogic = sector['ai_logic_references'];

                if (rawLogic != null && rawLogic.toString().trim().isNotEmpty) {
                  if (rawLogic is List) {
                    logicText = rawLogic.map((e) => "• $e").join("\n\n");
                  } else {
                    logicText = rawLogic.toString();
                  }
                }

                _showAiLogicModal(context, logicText);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                    SizedBox(width: 4),
                    Text("LOGIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  ],
                ),
              ),
            )
            // ----------------------------------------------------

          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String? text, {bool isHighlight = false, IconData? icon, Color? iconColor}) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[Icon(icon, size: 18, color: iconColor), const SizedBox(width: 8)],
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Color(0xFF334155), height: 1.6),
              children: [
                TextSpan(text: "$label ", style: TextStyle(fontWeight: FontWeight.bold, color: isHighlight ? const Color(0xFF6366F1) : const Color(0xFF0F172A))),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}*/

// lib/ui/views/industrial_strategy_view.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

import '../../core/strategy_consultant_service.dart';
// Adjust this import to point to wherever your dialog is saved:
import '../dialogs/fallback_selector_dialog.dart';

class IndustrialStrategyView extends StatefulWidget {
  const IndustrialStrategyView({super.key});

  @override
  State<IndustrialStrategyView> createState() => _IndustrialStrategyViewState();
}

class _IndustrialStrategyViewState extends State<IndustrialStrategyView> with AutomaticKeepAliveClientMixin {
  final StrategyConsultantService _strategyService = StrategyConsultantService();

  bool _isLoading = false;
  String _loadingStatus = "";

  Map<String, dynamic>? _reportData;
  List<Map<String, dynamic>> _liveSectors = [];

  // --- DYNAMIC PROMPT & FEED STATE ---
  Map<String, String> _availablePrompts = {};
  String? _selectedPromptPath;
  bool _isLoadingPrompts = true;

  List<String>? _selectedLocalFeeds;

  @override
  void initState() {
    super.initState();
    _loadAvailablePrompts();
  }

  @override
  bool get wantKeepAlive => true;

  // --- 1. LOAD PROMPTS DYNAMICALLY FROM ASSETS ---
  Future<void> _loadAvailablePrompts() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final promptFiles = manifestMap.keys
          .where((key) => key.startsWith('assets/prompts/') && key.endsWith('.json'))
          .toList();

      Map<String, String> loadedPrompts = {};

      for (String path in promptFiles) {
        final fileName = path.split('/').last.replaceAll('.json', '');
        final displayName = fileName
            .replaceAll(RegExp(r'[-_]'), ' ')
            .split(' ')
            .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
            .join(' ');

        loadedPrompts[displayName] = path;
      }

      setState(() {
        _availablePrompts = loadedPrompts;
        if (loadedPrompts.isNotEmpty) {
          // Default to the first prompt automatically
          _selectedPromptPath = loadedPrompts.values.first;
        }
        _isLoadingPrompts = false;
      });
    } catch (e) {
      print("Error loading prompt assets: $e");
      setState(() {
        _isLoadingPrompts = false;
      });
    }
  }

  // --- 2. FALLBACK FEED SELECTOR TRIGGER ---
  Future<void> _selectFallbackFeeds() async {
    final selectedPaths = await FallbackSelectorDialog.show(context);

    if (selectedPaths != null) {
      setState(() {
        _selectedLocalFeeds = selectedPaths;
      });
    }
  }

  // --- 3. GENERATE REPORT LOGIC ---
  Future<void> _generateReport() async {
    if (_selectedPromptPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for prompts to load or select one.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _reportData = null;
      _liveSectors.clear();
      _loadingStatus = "Initializing AI Consultant...";
    });

    try {
      final result = await _strategyService.generateIndustrialStrategyReport(
          promptAssetPath: _selectedPromptPath!,
          customLocalFeedPaths: _selectedLocalFeeds, // Injecting the user's data sources here!
          onProgress: (status, newSector) {
            if (mounted) {
              setState(() {
                _loadingStatus = status;
                if (newSector != null) {
                  _liveSectors.add(newSector);
                }
              });
            }
          }
      );

      if (mounted) {
        setState(() {
          _reportData = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingStatus = "Error: $e";
        });
      }
    }
  }

  // --- DROPDOWN WIDGET HELPER ---
  Widget _buildPromptSelector() {
    if (_isLoadingPrompts) {
      return const CircularProgressIndicator();
    }

    if (_availablePrompts.isEmpty) {
      return const Text("No prompts found.", style: TextStyle(color: Colors.red));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPromptPath,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6366F1)),
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          isExpanded: true, // Prevents overflow issues if names are long
          items: _availablePrompts.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.value,
              child: Text(entry.key, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: _isLoading ? null : (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedPromptPath = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  // --- LOGIC MODAL TRIGGER ---
  void _showAiLogicModal(BuildContext context, String logicText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Text("AI Logic & Data Provenance", style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SelectableText(
                logicText,
                style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 1. EMPTY STATE
    if (_reportData == null && !_isLoading && _liveSectors.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_tree_outlined, size: 64, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              Text(
                "Industrial Intelligence Hub",
                style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Select an AI Persona to analyze the cross-sector intelligence.",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),

              _buildPromptSelector(),

              const SizedBox(height: 16),

              // --- UI BUTTON TO SELECT FEEDS ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _selectFallbackFeeds,
                  icon: const Icon(Icons.source),
                  label: Text(
                    _selectedLocalFeeds != null && _selectedLocalFeeds!.isNotEmpty
                        ? "Change Data Sources (${_selectedLocalFeeds!.length} Selected)"
                        : "Select Local Data Sources (Optional)",
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateReport,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Generate Intelligence Report"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    // 2. LIVE GENERATION & RESULTS STATE
    final title = _reportData?['report_title'] ?? "Live Intelligence Generation";
    final conclusion = _reportData?['synthesis_conclusion'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
              ),
              if (!_isLoading)
                OutlinedButton.icon(
                  onPressed: () {
                    // Reset state to allow configuring a new report
                    setState(() {
                      _reportData = null;
                      _liveSectors.clear();
                    });
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text("New Report"),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
                )
            ],
          ),
          const SizedBox(height: 24),

          // LIVE SECTOR GRID
          ..._liveSectors.map((sector) => _buildSectorCard(sector)),

          // LOADING INDICATOR
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF6366F1)),
                    const SizedBox(height: 16),
                    Text(_loadingStatus, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),

          // SYNTHESIS CONCLUSION
          if (!_isLoading && conclusion != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Text("Synthesis Conclusion & Meta-Trend", style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    conclusion,
                    style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  // --- REUSED WIDGET BUILDERS ---

  Widget _buildSectorCard(Map<String, dynamic> sector) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.domain, color: Color(0xFF6366F1)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sector['sector_name'] ?? "Unknown Sector",
                    style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDataRow("Development:", sector['synthesized_development']),
            const SizedBox(height: 16),
            _buildDataRow("Strategic Insight:", sector['strategic_insight'], isHighlight: true),
            const SizedBox(height: 16),
            _buildDataRow("Opportunity:", sector['opportunity'], icon: Icons.trending_up, iconColor: Colors.green),
            const SizedBox(height: 16),
            _buildDataRow("Visual Suggestion:", sector['visual_suggestion'], icon: Icons.image_outlined, iconColor: Colors.grey),

            // --- BASE64 IMAGE RENDERER (Will silently hide if you use Ollama) ---
            if (sector['image_base64'] != null && sector['image_base64'].toString().isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.memory(
                          base64Decode(sector['image_base64']),
                          height: 350,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 350,
                              color: const Color(0xFFF8FAFC),
                              child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: Colors.grey, size: 48),
                                      SizedBox(height: 8),
                                      Text("Failed to decode image", style: TextStyle(color: Colors.grey)),
                                    ],
                                  )
                              ),
                            );
                          }
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF6366F1)),
                          const SizedBox(width: 8),
                          Text(
                            "AI-Generated Strategic Visualization",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // --- AI LOGIC BUTTON (Always Visible & Type-Safe) ---
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                String logicText = "No references were returned by the AI for this sector.";
                final rawLogic = sector['ai_logic_references'];

                if (rawLogic != null && rawLogic.toString().trim().isNotEmpty) {
                  if (rawLogic is List) {
                    logicText = rawLogic.map((e) => "• $e").join("\n\n");
                  } else {
                    logicText = rawLogic.toString();
                  }
                }

                _showAiLogicModal(context, logicText);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.code, size: 14, color: Color(0xFF6366F1)),
                    SizedBox(width: 4),
                    Text("LOGIC", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

/*  Widget _buildDataRow(String label, String? text, {bool isHighlight = false, IconData? icon, Color? iconColor}) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[Icon(icon, size: 18, color: iconColor), const SizedBox(width: 8)],
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Color(0xFF334155), height: 1.6),
              children: [
                TextSpan(text: "$label ", style: TextStyle(fontWeight: FontWeight.bold, color: isHighlight ? const Color(0xFF6366F1) : const Color(0xFF0F172A))),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }*/

  Widget _buildDataRow(String label, String? text, {bool isHighlight = false, IconData? icon, Color? iconColor}) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    // --- NEW: Sanitize the AI text before rendering ---
    // This catches double-escaped backslashes, forward slashes, and spaces between them.
    final String cleanText = text
        .replaceAll(r'\n', '\n')   // Catch literal \n
        .replaceAll(r'/n', '\n')   // Catch literal /n
        .replaceAll(r'\\n', '\n'); // Catch double-escaped \\n

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0), // Give it some breathing room
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[Icon(icon, size: 18, color: iconColor), const SizedBox(width: 8)],
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Color(0xFF334155), height: 1.6),
                children: [
                  TextSpan(
                    text: "$label\n", // Moved the label to its own line for better readability
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isHighlight ? const Color(0xFF6366F1) : const Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(text: cleanText), // Use the sanitized text here!
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}