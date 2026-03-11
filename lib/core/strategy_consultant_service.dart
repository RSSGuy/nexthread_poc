
/*

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

        if (response.containsKey('sector_name') || response.containsKey('synthesized_development')) {
          response['sector_name'] ??= sector;

*/
/*          // --- DALL-E 3 IMAGE GENERATION ---
          if (response['visual_suggestion'] != null && response['visual_suggestion'].toString().isNotEmpty) {
            ConsoleLogger.log("Requesting DALL-E 3 Image for $sector...", type: 'system');
            onProgress?.call("Generating visual illustration for $sector...", null);



            final imageUrl = await activeProvider.generateImage(prompt: response['visual_suggestion']);

            if (imageUrl != null) {
              // Wrap the DALL-E URL in the CORS proxy so CanvasKit is allowed to draw it
              final proxiedUrl = "https://corsproxy.io/?${Uri.encodeComponent(imageUrl)}";
              response['image_url'] = proxiedUrl;

              ConsoleLogger.success("Image generated for $sector.");
            }
          }
          // ---------------------------------

          generatedSectors.add(response);
          briefSummariesForConclusion.add("$sector: ${response['synthesized_development']}");

          onProgress?.call("Completed: $sector", response);
        }
      }*/
/*

          // --- DALL-E 3 IMAGE GENERATION ---
          if (response['visual_suggestion'] != null && response['visual_suggestion'].toString().isNotEmpty) {
            ConsoleLogger.log("Requesting DALL-E 3 Image for $sector...", type: 'system');
            onProgress?.call("Generating visual illustration for $sector...", null);

            final imageB64 = await activeProvider.generateImage(prompt: response['visual_suggestion']);

            if (imageB64 != null) {
              response['image_base64'] = imageB64; // <-- Changed key
              ConsoleLogger.success("Image generated for $sector.");
            } else {
              ConsoleLogger.warning("Failed to generate image for $sector.");
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
}*/

// lib/core/strategy_consultant_service.dart
/*

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

        if (response.containsKey('sector_name') || response.containsKey('synthesized_development')) {
          response['sector_name'] ??= sector;

          // --- DALL-E 3 BASE64 IMAGE GENERATION ---
          if (response['visual_suggestion'] != null && response['visual_suggestion'].toString().isNotEmpty) {
            ConsoleLogger.log("Requesting DALL-E 3 Image for $sector...", type: 'system');
            onProgress?.call("Generating visual illustration for $sector...", null);

            final imageB64 = await activeProvider.generateImage(prompt: response['visual_suggestion']);

            if (imageB64 != null) {
              response['image_base64'] = imageB64;
              ConsoleLogger.success("Image generated for $sector.");
            } else {
              ConsoleLogger.warning("Failed to generate image for $sector.");
            }
          }
          // ---------------------------------

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

    //6. SAFETY FALLBACK: Guarantees Dart compiler never worries about returning null.
    return {
      "report_title": "Unknown Error",
      "synthesis_conclusion": "Execution failed unexpectedly.",
      "sectors": []
    };
  }
}*/
/*

// lib/core/strategy_consultant_service.dart

import 'dart:async';
import 'local_feed_service.dart';
import 'ai_service.dart';
import 'prompts/ai_prompts.dart';
import '../ui/widgets/console_log_widget.dart';

class StrategyConsultantService {
  final LocalFeedService _localFeedService = LocalFeedService();

  Future<Map<String, dynamic>> generateIndustrialStrategyReport({
    required String promptAssetPath,
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

        // --- DYNAMIC PROMPT BUILDER ---
        final prompt = await AiPrompts.generateDynamicSectorAnalysis(
          assetPath: promptAssetPath,
          sectorName: sector,
          sectorNews: sectorNews,
        );
        // ------------------------------

        final response = await activeProvider.generateBriefingJson(
          systemPrompt: prompt,
          userContext: "Generate the verbose report specifically for $sector.",
        );

        if (response.containsKey('sector_name') || response.containsKey('synthesized_development')) {
          response['sector_name'] ??= sector;

          // --- DALL-E 3 BASE64 IMAGE GENERATION ---
          if (response['visual_suggestion'] != null && response['visual_suggestion'].toString().isNotEmpty) {
            ConsoleLogger.log("Requesting DALL-E 3 Image for $sector...", type: 'system');
            onProgress?.call("Generating visual illustration for $sector...", null);

            final imageB64 = await activeProvider.generateImage(prompt: response['visual_suggestion']);

            if (imageB64 != null) {
              response['image_base64'] = imageB64;
              ConsoleLogger.success("Image generated for $sector.");
            } else {
              ConsoleLogger.warning("Failed to generate image for $sector.");
            }
          }
          // ---------------------------------

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

    //6. SAFETY FALLBACK: Guarantees Dart compiler never worries about returning null.
    return {
      "report_title": "Unknown Error",
      "synthesis_conclusion": "Execution failed unexpectedly.",
      "sectors": []
    };
  }
}*/

/*
// lib/core/strategy_consultant_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'local_feed_service.dart';
import 'ai_service.dart';
import 'prompts/ai_prompts.dart';
import '../ui/widgets/console_log_widget.dart';

class StrategyConsultantService {
  final LocalFeedService _localFeedService = LocalFeedService();

  Future<Map<String, dynamic>> generateIndustrialStrategyReport({
    required String promptAssetPath,
    Function(String statusMessage, Map<String, dynamic>? newSector)? onProgress,
  }) async {
    ConsoleLogger.log("StrategyService: Initiating Verbose Sector-by-Sector Analysis...", type: 'system');

    try {
      onProgress?.call("Loading AI Persona Configuration...", null);

      // 1. Load and parse the AI Persona JSON immediately
      final jsonString = await rootBundle.loadString(promptAssetPath);
      final Map<String, dynamic> roleConfig = jsonDecode(jsonString);

      // Determine what sector this persona targets (defaults to 'All')
      final String targetSector = roleConfig['target_sector'] ?? 'All';

      onProgress?.call("Loading cross-sector intelligence feed...", null);

      // 2. Fetch the multi-sector news feed
      final newsItems = await _localFeedService.getCrossSectorIntelligence('assets/feeds/cubeler_industrial_news.xml');

      if (newsItems.isEmpty || newsItems.first.contains("[System]")) {
        return {"report_title": "Data Error", "synthesis_conclusion": "Could not load feed.", "sectors": []};
      }

      // 3. Extract unique sectors dynamically, APPLYING THE TARGET FILTER
      Set<String> uniqueSectors = {};
      for (var item in newsItems) {
        final match = RegExp(r'\[SECTOR:\s*(.*?)\]').firstMatch(item);
        if (match != null) {
          final sectorName = match.group(1)!.trim();

          // If the persona wants "All", or if the sector string contains "Agriculture", add it.
          if (targetSector == 'All' || sectorName.toLowerCase().contains(targetSector.toLowerCase())) {
            uniqueSectors.add(sectorName);
          }
        }
      }

      if (uniqueSectors.isEmpty) {
        return {
          "report_title": "No Relevant Data",
          "synthesis_conclusion": "No news found in the feed for the target sector: $targetSector.",
          "sectors": []
        };
      }

      final activeProvider = AIService().activeProvider;
      List<Map<String, dynamic>> generatedSectors = [];
      List<String> briefSummariesForConclusion = [];

      // 4. Generate analysis INDIVIDUALLY for each filtered sector
      for (String sector in uniqueSectors) {
        ConsoleLogger.log("Analyzing Sector: $sector...", type: 'system');
        onProgress?.call("Analyzing Sector: $sector...", null);

        // Filter news for just this sector
        final sectorNews = newsItems.where((n) => n.contains('[SECTOR: $sector]')).toList();

        // Pass the pre-loaded roleConfig directly
        final prompt = AiPrompts.generateDynamicSectorAnalysis(
          roleConfig: roleConfig,
          sectorName: sector,
          sectorNews: sectorNews,
        );

        final response = await activeProvider.generateBriefingJson(
          systemPrompt: prompt,
          userContext: "Generate the verbose report specifically for $sector.",
        );

        if (response.containsKey('sector_name') || response.containsKey('synthesized_development')) {
          response['sector_name'] ??= sector;

          // --- DALL-E 3 BASE64 IMAGE GENERATION ---
          if (response['visual_suggestion'] != null && response['visual_suggestion'].toString().isNotEmpty) {
            ConsoleLogger.log("Requesting DALL-E 3 Image for $sector...", type: 'system');
            onProgress?.call("Generating visual illustration for $sector...", null);

            final imageB64 = await activeProvider.generateImage(prompt: response['visual_suggestion']);

            if (imageB64 != null) {
              response['image_base64'] = imageB64;
              ConsoleLogger.success("Image generated for $sector.");
            } else {
              ConsoleLogger.warning("Failed to generate image for $sector.");
            }
          }
          // ---------------------------------

          generatedSectors.add(response);
          briefSummariesForConclusion.add("$sector: ${response['synthesized_development']}");

          onProgress?.call("Completed: $sector", response);
        }
      }

      // 5. Generate the final overarching conclusion
      ConsoleLogger.log("Generating Final Meta-Trend Conclusion...", type: 'system');
      onProgress?.call("Synthesizing final meta-trend conclusion...", null);

      final conclusionPrompt = AiPrompts.industrialConclusionSystem(briefSummariesForConclusion);
      final conclusionResponse = await activeProvider.generateBriefingJson(
        systemPrompt: conclusionPrompt,
        userContext: "Generate the final overarching synthesis conclusion.",
      );

      ConsoleLogger.success("Industrial Strategy Report Complete.");
      onProgress?.call("Report Complete", null);

      // 6. Return full payload
      return {
        "report_title": roleConfig['role'] ?? "Industrial Intelligence Report", // Dynamically name the report based on persona
        "synthesis_conclusion": conclusionResponse['synthesis_conclusion'] ?? "Analysis complete.",
        "sectors": generatedSectors
      };

    } catch (e) {
      ConsoleLogger.error("Strategy Generation Failed: $e");
      onProgress?.call("Error: $e", null);
      return {"report_title": "Generation Failed", "synthesis_conclusion": "Error: $e", "sectors": []};
    }

    return {
      "report_title": "Unknown Error",
      "synthesis_conclusion": "Execution failed unexpectedly.",
      "sectors": []
    };
  }
}*/

// lib/core/strategy_consultant_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'local_feed_service.dart';
import 'feed_service.dart';
import 'news_registry.dart';
import 'models.dart';
import 'ai_service.dart';
import 'prompts/ai_prompts.dart';
import '../ui/widgets/console_log_widget.dart';

class StrategyConsultantService {
  final LocalFeedService _localFeedService = LocalFeedService();
  final FeedService _feedService = FeedService(); // Injecting live feed handler

  Future<Map<String, dynamic>> generateIndustrialStrategyReport({
    required String promptAssetPath,
    Function(String statusMessage, Map<String, dynamic>? newSector)? onProgress,
  }) async {
    ConsoleLogger.log("StrategyService: Initiating Verbose Sector-by-Sector Analysis...", type: 'system');

    try {
      onProgress?.call("Loading AI Persona Configuration...", null);

      // 1. Load and parse the AI Persona JSON immediately
      final jsonString = await rootBundle.loadString(promptAssetPath);
      final Map<String, dynamic> roleConfig = jsonDecode(jsonString);

      // Determine what sector this persona targets (defaults to 'All')
      final String targetSector = roleConfig['target_sector'] ?? 'All';

      onProgress?.call("Loading local cross-sector intelligence...", null);

      // 2. Fetch the multi-sector news feed (Local Archive First)
      List<String> newsItems = await _localFeedService.getCrossSectorIntelligence('assets/feeds/cubeler_industrial_news.xml');

      // 3. Extract unique sectors dynamically, APPLYING THE TARGET FILTER
      Set<String> uniqueSectors = {};

      if (newsItems.isNotEmpty && !newsItems.first.contains("[System]")) {
        for (var item in newsItems) {
          final match = RegExp(r'\[SECTOR:\s*(.*?)\]').firstMatch(item);
          if (match != null) {
            final sectorName = match.group(1)!.trim();
            // If the persona wants "All", or if the sector string matches the target, keep it
            if (targetSector == 'All' || sectorName.toLowerCase().contains(targetSector.toLowerCase())) {
              uniqueSectors.add(sectorName);
            }
          }
        }
      }

      // --- 4. LIVE WEB FALLBACK (Utilizing FeedService Race Strategy) ---
      if (uniqueSectors.isEmpty) {
        ConsoleLogger.warning("Local XML empty or irrelevant for $targetSector. Initiating Live Feed Race Strategy...");
        onProgress?.call("Local data unavailable. Polling live web feeds for $targetSector...", null);

        List<NewsSourceConfig> targetSources = [];

        // Map the JSON target_sector to our NewsRegistry Naics tags
        if (targetSector.toLowerCase() == 'agriculture') {
          targetSources = NewsRegistry.allSources.where((s) => s.tags.contains(Naics.agriculture)).toList();
        } else if (targetSector.toLowerCase() == 'manufacturing') {
          targetSources = NewsRegistry.allSources.where((s) => s.tags.contains(Naics.manufacturing)).toList();
        } else if (targetSector.toLowerCase() == 'construction') {
          targetSources = NewsRegistry.allSources.where((s) => s.tags.contains(Naics.construction)).toList();
        } else {
          // If "All", grab a diverse mix but limit to prevent mass network timeouts
          targetSources = NewsRegistry.allSources.take(15).toList();
        }

        // Cap the sources to 10 to ensure the FeedService resolves quickly
        if (targetSources.length > 10) {
          targetSources = targetSources.sublist(0, 10);
        }

        // Extract keywords from the prompt's role to hyper-focus the live feed
        List<String> liveKeywords = [];
        final roleName = roleConfig['role']?.toString().toLowerCase() ?? '';
        if (roleName.contains('phosphate') || roleName.contains('fertilizer')) {
          liveKeywords.addAll(['phosphate', 'fertilizer', 'potash', 'nutrien']);
        }
        if (roleName.contains('canola')) {
          liveKeywords.addAll(['canola', 'crop yield', 'crush']);
        }

        // Execute the robust live fetch
        final liveHeadlines = await _feedService.fetchHeadlines(targetSources, liveKeywords);

        if (liveHeadlines.isNotEmpty) {
          // Reformat live headlines to match what the AI Prompt builder expects ([SECTOR: X] Headline)
          final fallbackSectorName = targetSector == 'All' ? 'Live Global Market' : targetSector;
          newsItems = liveHeadlines.map((headline) => "[SECTOR: $fallbackSectorName] $headline").toList();
          uniqueSectors.add(fallbackSectorName);
          ConsoleLogger.success("Successfully fetched ${liveHeadlines.length} live headlines via FeedService.");
        } else {
          return {
            "report_title": "No Relevant Data Found",
            "synthesis_conclusion": "No news could be found locally or via live web fetch for the target sector: $targetSector.",
            "sectors": []
          };
        }
      }
      // -----------------------------------------------------------------

      final activeProvider = AIService().activeProvider;
      List<Map<String, dynamic>> generatedSectors = [];
      List<String> briefSummariesForConclusion = [];

      // 5. Generate analysis INDIVIDUALLY for each filtered sector
      for (String sector in uniqueSectors) {
        ConsoleLogger.log("Analyzing Sector: $sector...", type: 'system');
        onProgress?.call("Analyzing Sector: $sector...", null);

        // Filter news for just this sector
        final sectorNews = newsItems.where((n) => n.contains('[SECTOR: $sector]')).toList();

        // Pass the pre-loaded roleConfig directly
        final prompt = AiPrompts.generateDynamicSectorAnalysis(
          roleConfig: roleConfig,
          sectorName: sector,
          sectorNews: sectorNews,
        );

        final response = await activeProvider.generateBriefingJson(
          systemPrompt: prompt,
          userContext: "Generate the verbose report specifically for $sector.",
        );

        if (response.containsKey('sector_name') || response.containsKey('synthesized_development')) {
          response['sector_name'] ??= sector;

          // --- DALL-E 3 BASE64 IMAGE GENERATION ---
          if (response['visual_suggestion'] != null && response['visual_suggestion'].toString().isNotEmpty) {
            ConsoleLogger.log("Requesting DALL-E 3 Image for $sector...", type: 'system');
            onProgress?.call("Generating visual illustration for $sector...", null);

            final imageB64 = await activeProvider.generateImage(prompt: response['visual_suggestion']);

            if (imageB64 != null) {
              response['image_base64'] = imageB64;
              ConsoleLogger.success("Image generated for $sector.");
            } else {
              ConsoleLogger.warning("Failed to generate image for $sector.");
            }
          }
          // ---------------------------------

          generatedSectors.add(response);
          briefSummariesForConclusion.add("$sector: ${response['synthesized_development']}");

          onProgress?.call("Completed: $sector", response);
        }
      }

      // 6. Generate the final overarching conclusion
      ConsoleLogger.log("Generating Final Meta-Trend Conclusion...", type: 'system');
      onProgress?.call("Synthesizing final meta-trend conclusion...", null);

      final conclusionPrompt = AiPrompts.industrialConclusionSystem(briefSummariesForConclusion);
      final conclusionResponse = await activeProvider.generateBriefingJson(
        systemPrompt: conclusionPrompt,
        userContext: "Generate the final overarching synthesis conclusion.",
      );

      ConsoleLogger.success("Industrial Strategy Report Complete.");
      onProgress?.call("Report Complete", null);

      // 7. Return full payload
      return {
        "report_title": roleConfig['role'] ?? "Industrial Intelligence Report",
        "synthesis_conclusion": conclusionResponse['synthesis_conclusion'] ?? "Analysis complete.",
        "sectors": generatedSectors
      };

    } catch (e) {
      ConsoleLogger.error("Strategy Generation Failed: $e");
      onProgress?.call("Error: $e", null);
      return {"report_title": "Generation Failed", "synthesis_conclusion": "Error: $e", "sectors": []};
    }

    return {
      "report_title": "Unknown Error",
      "synthesis_conclusion": "Execution failed unexpectedly.",
      "sectors": []
    };
  }
}