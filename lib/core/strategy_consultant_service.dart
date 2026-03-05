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
      final newsItems = await _localFeedService.getHeadlinesFromPath(
          'assets/feeds/cubeler_industrial_news.xml',
          []
      );

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
}