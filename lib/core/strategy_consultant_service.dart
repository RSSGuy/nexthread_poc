/*
// lib/core/strategy_consultant_service.dart

import 'dart:async';
import 'local_feed_service.dart';
import 'ai_service.dart';
import 'prompts/ai_prompts.dart';
import '../ui/widgets/console_log_widget.dart';

class StrategyConsultantService {
  final LocalFeedService _localFeedService = LocalFeedService();

  Future<Map<String, dynamic>> generateIndustrialStrategyReport() async {
    ConsoleLogger.log("StrategyService: Generating Industrial Strategy Report...", type: 'system');

    try {
      // 1. Fetch the multi-sector news feed from local assets.
  */
/*    final newsItems = await _localFeedService.getHeadlinesFromPath(
          'assets/feeds/cubeler_industrial_news.xml',
          []
      );*/
/*


      final newsItems = await _localFeedService.getCrossSectorIntelligence('assets/feeds/cubeler_industrial_news.xml');

      if (newsItems.isEmpty || newsItems.first.contains("[System]")) {
        return {
          "report_title": "Data Error",
          "synthesis_conclusion": "Could not load the Cubeler Industrial News feed.",
          "sectors": []
        };
      }

      // 2. Generate using the specialized prompt
      final systemPrompt = AiPrompts.industrialStrategyConsultantSystem(newsItems);

      // 3. Ask the AIService for the currently active provider to make the call
      final activeProvider = AIService().activeProvider;
      final response = await activeProvider.generateBriefingJson(
        systemPrompt: systemPrompt,
        userContext: "Generate the Industrial Intelligence Report based on the provided cross-sector data.",
      );

      // Validation fallback
      if (response['sectors'] == null) {
        response['sectors'] = [];
      }

      return response;
    } catch (e) {
      ConsoleLogger.error("Strategy Generation Failed: $e");
      return {
        "report_title": "Generation Failed",
        "synthesis_conclusion": "An error occurred: $e",
        "sectors": []
      };
    }
  }
}*/


// lib/core/strategy_consultant_service.dart

import 'dart:async';
import 'local_feed_service.dart';
import 'ai_service.dart';
import 'prompts/ai_prompts.dart';
import '../ui/widgets/console_log_widget.dart';

class StrategyConsultantService {
  final LocalFeedService _localFeedService = LocalFeedService();

  Future<Map<String, dynamic>> generateIndustrialStrategyReport({
    Function(String statusMessage, Map<String, dynamic>? newSector)? onProgress,
  }) async {
    ConsoleLogger.log("StrategyService: Initiating Verbose Sector-by-Sector Analysis...", type: 'system');

    try {
      onProgress?.call("Loading cross-sector intelligence feed...", null);

      // 1. Fetch the multi-sector news feed
      final newsItems = await _localFeedService.getCrossSectorIntelligence('assets/feeds/cubeler_industrial_news.xml');

      if (newsItems.isEmpty || newsItems.first.contains("[System]")) {
        return {"report_title": "Data Error", "synthesis_conclusion": "Could not load feed.", "sectors": []};
      }

      // 2. Extract unique sectors dynamically from the feed
      Set<String> uniqueSectors = {};
      for (var item in newsItems) {
        final match = RegExp(r'\[SECTOR:\s*(.*?)\]').firstMatch(item);
        if (match != null) {
          uniqueSectors.add(match.group(1)!.trim());
        }
      }

      final activeProvider = AIService().activeProvider;
      List<Map<String, dynamic>> generatedSectors = [];
      List<String> briefSummariesForConclusion = [];

      // 3. Generate analysis INDIVIDUALLY for each sector
      for (String sector in uniqueSectors) {
        ConsoleLogger.log("Analyzing Sector: $sector...", type: 'system');
        onProgress?.call("Analyzing Sector: $sector...", null);

        // Filter news for just this sector
        final sectorNews = newsItems.where((n) => n.contains('[SECTOR: $sector]')).toList();

        final prompt = AiPrompts.industrialSectorAnalysisSystem(sector, sectorNews);
        final response = await activeProvider.generateBriefingJson(
          systemPrompt: prompt,
          userContext: "Generate the verbose report specifically for $sector.",
        );

        // Map and yield the new sector back to the UI immediately
        if (response.containsKey('sector_name') || response.containsKey('synthesized_development')) {
          response['sector_name'] ??= sector;
          generatedSectors.add(response);
          briefSummariesForConclusion.add("$sector: ${response['synthesized_development']}");

          onProgress?.call("Completed: $sector", response);
        }
      }

      // 4. Generate the final overarching conclusion
      ConsoleLogger.log("Generating Final Meta-Trend Conclusion...", type: 'system');
      onProgress?.call("Synthesizing final meta-trend conclusion...", null);

      final conclusionPrompt = AiPrompts.industrialConclusionSystem(briefSummariesForConclusion);
      final conclusionResponse = await activeProvider.generateBriefingJson(
        systemPrompt: conclusionPrompt,
        userContext: "Generate the final overarching synthesis conclusion.",
      );

      ConsoleLogger.success("Industrial Strategy Report Complete.");
      onProgress?.call("Report Complete", null);

      // 5. Return full payload
      return {
        "report_title": "Industrial Intelligence Report",
        "synthesis_conclusion": conclusionResponse['synthesis_conclusion'] ?? "Analysis complete.",
        "sectors": generatedSectors
      };

    } catch (e) {
      ConsoleLogger.error("Strategy Generation Failed: $e");
      onProgress?.call("Error: $e", null);
      return {"report_title": "Generation Failed", "synthesis_conclusion": "Error: $e", "sectors": []};
    }
  }
}