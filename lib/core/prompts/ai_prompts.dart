

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models.dart';

class AiPrompts {

  // --- HELPERS ---

  static const String _jsonFormattingRule =
      "IMPORTANT: Output valid JSON only. Escape all quotes and special characters within strings. Do not use Markdown code blocks (```json).";

  static String get _dateContext =>
      "CURRENT DATE: ${DateTime.now().toIso8601String().split('T')[0]}";

  // --- 1. GLOBAL MARKET ANALYSIS ---

  static String get globalMarketSystem => '''
You are a Chief Global Market Strategist.
$_jsonFormattingRule

TASK: Provide a comprehensive executive summary of the "Entire State of the World Market".

INPUT:
1. Live Global Market Indices (Equities, Forex, Volatility).
2. Real-time Headlines from diverse industrial sectors.

INSTRUCTIONS:
1. Synthesize the Indices Data with the Sector News.
2. Identify MACRO TRENDS (e.g. "Rising energy costs are suppressing manufacturing output").
3. Detect SYSTEMIC RISKS (e.g. "Supply chain fractures in Region X").
4. Verdict: Provide a "Global Sentiment" (Bullish/Bearish/Neutral/Volatile).

OUTPUT JSON FORMAT:
{
  "analysis": "## Global Market Outlook\\n\\n[Markdown content...]" 
}
''';

  // --- 2. GLOBAL TRENDS DEEP DIVE ---
  static String globalTrendsSystem(String globalDataStr, List<String> newsItems) {
    return '''
You are a Macro-Economic Strategist.
$_jsonFormattingRule
$_dateContext

TASK: Produce a deep-dive Executive Summary of Global Trends.

[GLOBAL MARKET DATA]
$globalDataStr

[NEWS ARCHIVE]
${newsItems.take(60).join('\n')} 

INSTRUCTION:
1. Analyze the data for **Correlations** (e.g., Oil price up -> Transport stocks down).
2. "Emerging Trends": Identify patterns appearing across multiple headlines.
3. "News-to-Macro Insights": specific headlines that explain a broader market move.

OUTPUT JSON FORMAT:
{
  "summary": "## Executive Summary\\n\\n...",
  "expansions": [
    {
      "title": "Data Sources & Confidence",
      "content": "Critique the data mix. Are we missing key sectors?"
    },
    {
      "title": "Emerging Cross-Sector Trends",
      "content": "- Trend 1\\n- Trend 2"
    },
    {
      "title": "Key News Insights",
      "content": "Analysis of specific items..."
    }
  ]
}
''';
  }

  // --- 3. RELEVANCE GUARDRAIL ---
  static String relevanceCheckSystem(String topicName, String input) {
    return '''
SYSTEM: You are a Relevance Filter.
$_jsonFormattingRule

TASK: Determine if the following input is RELEVANT to the $topicName industry.
CRITERIA:
- RELEVANT: Economic shocks, supply chain, regulations, prices, labor, logistics.
- IRRELEVANT: Celebrity gossip, sports, coding tutorials, personal advice.

INPUT: "$input"

OUTPUT JSON: {"is_relevant": boolean, "reason": "short string"}
''';
  }

  // --- 4. Q&A ON BRIEFING ---
  static String askAboutBriefingSystem(Briefing brief, String userQuestion) {
    return '''
CONTEXT: You are an Intelligence Analyst for the ${brief.subsector} sector.
$_jsonFormattingRule

REPORT DATA:
- Summary: ${brief.summary}
- Severity: ${brief.severity}
- Metrics: ${brief.metrics.commodity} @ ${brief.metrics.price} (${brief.metrics.trend})
- Headlines: ${brief.headlines.join(' | ')}

USER QUESTION: "$userQuestion"

INSTRUCTION: 
1. Answer the question using STRICTLY the Report Data provided above.
2. If the answer is not in the data, state "The report does not contain information about [X]".
3. You may use general economic knowledge only to explain terms, not to fabricate events.

OUTPUT JSON: { "answer": "markdown text" }
''';
  }

  // --- 5. EXPAND EXISTING BRIEFING ---
  static String expandBriefingSystem(String topicName, Briefing brief, List<String> extraNews) {
    return '''
You are an Intelligence Analyst for $topicName.
$_jsonFormattingRule

TASK: UPDATE an existing intelligence report with new Cross-Sector data.

[ORIGINAL REPORT]
Title: ${brief.title}
Severity: ${brief.severity}

[NEW CROSS-SECTOR INTEL]
${extraNews.join('\n')}

INSTRUCTION:
1. Assess if the NEW intel materially impacts the Original Sector.
2. Rewrite the "Summary" to include a "Cross-Sector Impact" section.
3. UPGRADE Severity ONLY if the new intel represents an immediate, high-impact threat.

OUTPUT JSON: 
{ 
  "briefs": [{ 
    "summary": "Updated summary...", 
    "severity": "High/Medium/Low", 
    "divergence_desc": "Explanation of change..." 
  }] 
}
''';
  }

  // --- 6. GENERATE PRIMARY BRIEFING ---
  static String generateBriefingSystem({
    required String topicName,
    required String globalContext,
    required String marketFactStr,
    required List<String> news,
    String? riskRules, // <-- NULL SAFE
    String? customScenario,
    bool forceCrossSectorAnalysis = false,
  }) {
    String scenarioBlock = "";
    if (customScenario != null && customScenario.isNotEmpty) {
      scenarioBlock = '''
        [SCENARIO MODE ACTIVE]
        HYPOTHESIS: "$customScenario"
        INSTRUCTION: Treat this hypothesis as FACT. Analyze consequences.
        ''';
    }

    String crossSectorInstruction = "";
    if (forceCrossSectorAnalysis) {
      crossSectorInstruction = '''
        [CROSS-SECTOR INTEL]
        Additional headlines from other sectors are labeled [SECTOR].
        TASK: Connect these external events to $topicName impacts.
        ''';
    }

    // Safely handle null risk rules
    String riskBlock = "";
    if (riskRules != null && riskRules.isNotEmpty) {
      riskBlock = "[RISK PROTOCOLS]\n$riskRules";
    }

    return '''
      You are a Senior Intelligence Analyst for the $topicName sector.
      $_jsonFormattingRule
      $_dateContext

      [GLOBAL CONTEXT]
      $globalContext

      [SECTOR METRICS]
      $marketFactStr
      
      [NEWS STREAM]
      ${news.join('\n')}

      $riskBlock
      
      $scenarioBlock
      $crossSectorInstruction
      
      ANALYSIS STEPS:
      1. Filter news for relevance and recency.
      2. Compare specific Metrics (Price/Trend) against News Sentiment.
      3. Determine Severity:
         - HIGH: Immediate disruption, supply halt, or price shock > 5%.
         - MEDIUM: Emerging risk, regulatory change, or price volatility.
         - LOW: Routine updates, minor fluctuations.

      OUTPUT JSON STRUCTURE:
      {
        "briefs": [
          {
            "id": "generate_unique_id",
            "subsector": "$topicName",
            "title": "Professional Title (max 10 words)",
            "thinking_process": "Briefly explain why you chose this severity and summary...",
            "summary": "Executive summary (Markdown). Use bolding for key terms.",
            "severity": "High/Medium/Low",
            "fact_score": 0-100,
            "sent_score": 0-100,
            "divergence_tag": "Convergence/Divergence/Neutral",
            "divergence_desc": "One sentence explaining data vs news alignment.",
            "metrics": {
               "commodity": "extracted from data",
               "price": "extracted",
               "trend": "extracted"
            },
            "headlines": ["List the 3 most relevant headlines used"]
          }
        ]
      }
      ''';
  }
// prompt injection***********************************************************************

  // --- 7. SENIOR INDUSTRIAL STRATEGY CONSULTANT (Dynamic JSON) ---
/*  static Future<String> industrialStrategyConsultantSystem(List<String> crossSectorNews) async {
    // 1. Load the prompt configuration from the assets folder
    final jsonString = await rootBundle.loadString('assets/prompts/senior_industrial_strategy_consultant.json');
    final Map<String, dynamic> roleConfig = jsonDecode(jsonString);

    // 2. Pass it to the private builder
    return _buildDynamicRoleSystem(
      roleConfig: roleConfig,
      newsData: crossSectorNews,
    );
  }*/
// --- 7. DYNAMIC SECTOR ANALYSIS (JSON DRIVEN) ---
/*  static Future<String> generateDynamicSectorAnalysis({
    required String assetPath,
    required String sectorName,
    required List<String> sectorNews,
  }) async {
    // 1. Load the selected prompt configuration
    final jsonString = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> roleConfig = jsonDecode(jsonString);

    // 2. Pass it to the private builder, focusing on the specific sector
    return _buildDynamicRoleSystem(
      roleConfig: roleConfig,
      newsData: sectorNews,
      specificSector: sectorName,
    );
  }*/

  // --- 7. DYNAMIC SECTOR ANALYSIS (JSON DRIVEN) ---
  static String generateDynamicSectorAnalysis({
    required Map<String, dynamic> roleConfig,
    required String sectorName,
    required List<String> sectorNews,
  }) {
    // Pass the pre-parsed JSON map directly to the private builder
    return _buildDynamicRoleSystem(
      roleConfig: roleConfig,
      newsData: sectorNews,
      specificSector: sectorName,
    );
  }


  // --- 7A. SECTOR-SPECIFIC ANALYSIS ---
  static String industrialSectorAnalysisSystem(String sectorName, List<String> sectorNews) {
    return '''
You are a Senior Industrial Strategy Consultant focusing exclusively on the "$sectorName" sector.
$_jsonFormattingRule
$_dateContext

[SECTOR NEWS]
${sectorNews.join('\n')}

INSTRUCTIONS & ANALYSIS PARAMETERS:
1. Write a highly detailed, verbose analysis specifically for the "$sectorName" sector.
2. VERBOSITY REQUIREMENT: You MUST write a full, robust paragraph (at least 4 to 6 sentences) for EVERY field. Do not use bullet points; use cohesive paragraph structures.

OUTPUT JSON FORMAT:
{
  "sector_name": "$sectorName",
  "synthesized_development": "Write a highly detailed paragraph (4-6 sentences) providing an original analysis of the primary trend.",
  "strategic_insight": "Write a highly detailed paragraph (4-6 sentences) explaining the 'so what' factor and cascading consequences.",
  "opportunity": "Write a highly detailed paragraph (4-6 sentences) outlining a specific, actionable upside or strategic pivot.",
  "visual_suggestion": "Write a detailed paragraph (2-4 sentences) describing a specific chart, graph, or illustration."
}
''';
  }

  // --- 7B. META-TREND CONCLUSION ---
  static String industrialConclusionSystem(List<String> sectorSummaries) {
    return '''
You are a Senior Industrial Strategy Consultant summarizing an overarching global report.
$_jsonFormattingRule

[SECTOR SUMMARIES]
${sectorSummaries.join('\n')}

TASK:
Review the developments across all the analyzed sectors above. Write a highly detailed, multi-paragraph Synthesis Conclusion identifying the primary "Meta-Trend" connecting all these industries (e.g., Agentic AI, Capital Concentration, etc.).

OUTPUT JSON FORMAT:
{
  "synthesis_conclusion": "Write a comprehensive, multi-paragraph conclusion here..."
}
''';
  }

  // --- 8. DYNAMIC JSON ROLE BUILDER (Private) ---
  static String _buildDynamicRoleSystem({
    required Map<String, dynamic> roleConfig,
    required List<String> newsData,
    String? specificSector,
  }) {
    final role = roleConfig['role'] ?? 'AI Assistant';
    final objective = roleConfig['objective'] ?? '';
    final instructions = roleConfig['instructions'] as Map<String, dynamic>? ?? {};
    final analysisParams = (instructions['analysis_parameters'] as List<dynamic>?)?.cast<String>() ?? [];
    final metaThemes = (instructions['meta_themes'] as List<dynamic>?)?.cast<String>() ?? [];
    final sectorReqs = instructions['sector_requirements'] as Map<String, dynamic>? ?? {};
    final constraints = (roleConfig['constraints'] as List<dynamic>?)?.cast<String>() ?? [];

    final buffer = StringBuffer();

    // 1. Core Identity & Rules
    buffer.writeln("You are a $role.");
    if (specificSector != null && specificSector.isNotEmpty) {
      buffer.writeln('Focusing exclusively on the "$specificSector" sector.');
    }
    buffer.writeln(_jsonFormattingRule);
    buffer.writeln(_dateContext);
    buffer.writeln();

    // 2. Objective
    if (objective.isNotEmpty) {
      buffer.writeln("OBJECTIVE: $objective\n");
    }

    // 3. Dynamic Data Injection
    buffer.writeln("[DATA/NEWS STREAM]");
    buffer.writeln(newsData.join('\n'));
    buffer.writeln();

    // 4. Instructions & Parameters
    if (analysisParams.isNotEmpty) {
      buffer.writeln("INSTRUCTIONS & ANALYSIS PARAMETERS:");
      for (int i = 0; i < analysisParams.length; i++) {
        buffer.writeln("${i + 1}. ${analysisParams[i]}");
      }
    }

    if (metaThemes.isNotEmpty) {
      buffer.writeln("\nKeep an eye out for the following Meta-Themes:");
      for (var theme in metaThemes) {
        buffer.writeln("- $theme");
      }
    }
    buffer.writeln();

    // 5. Constraints
    if (constraints.isNotEmpty) {
      buffer.writeln("CONSTRAINTS:");
      for (var constraint in constraints) {
        buffer.writeln("- $constraint");
      }
      buffer.writeln();
    }

    // 6. Output JSON Format Structure
    buffer.writeln("OUTPUT JSON FORMAT:");
    buffer.writeln("{");

    if (specificSector == null) {
      buffer.writeln('  "report_title": "Industrial Intelligence Report",');
      buffer.writeln('  "sectors": [');
      buffer.writeln('    {');
      buffer.writeln('      "sector_name": "Name of the Sector",');
    } else {
      buffer.writeln('  "sector_name": "$specificSector",');
    }

    // Dynamically build the required JSON fields from "sector_requirements"
    final indent = specificSector == null ? '      ' : '  ';
    sectorReqs.forEach((key, description) {
      buffer.writeln('$indent"$key": "$description",');
    });

    if (specificSector == null) {
      buffer.writeln('    }');
      buffer.writeln('  ],');
      buffer.writeln('  "synthesis_conclusion": "${instructions['output_format']?['conclusions'] ?? 'Write a detailed conclusion.'}"');
    } else {
      buffer.writeln('  "visual_suggestion": "Chart or graph description."');
    }

    buffer.writeln("}");

    return buffer.toString();
  }
}