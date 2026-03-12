

/*

// lib/core/strategy_consultant_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// --- Adjusted Imports ---
// Make sure this path points to wherever you saved the Config Loader
import '../config/feed_config_manager.dart';

import 'local_feed_service.dart';
import 'feed_service.dart';
import 'news_registry.dart';
import 'models.dart';
import 'ai_service.dart';
import 'prompts/ai_prompts.dart';
import 'market_data_provider.dart';
import '../ui/widgets/console_log_widget.dart';

class StrategyConsultantService {
  final LocalFeedService _localFeedService = LocalFeedService();
  final FeedService _feedService = FeedService();

  /// Helper to safely parse the NAICS enum from a string
  Naics? _parseNaics(String? naicsString) {
    if (naicsString == null) return null;
    for (var value in Naics.values) {
      if (value.name.toLowerCase() == naicsString.toLowerCase()) {
        return value;
      }
    }
    return null;
  }

  /// Helper to map sector strings to NAICS for the ETF market data.
  /// Replaces the massive if/else chain in the generation loop.
  Naics? _determineNaicsForSector(String sectorName) {
    final s = sectorName.toLowerCase();
    final Map<String, Naics> keywordToNaics = {
      'agri': Naics.agriculture, 'farm': Naics.agriculture, 'beef': Naics.agriculture, 'wheat': Naics.agriculture, 'lumber': Naics.agriculture,
      'min': Naics.mining, 'oil': Naics.mining, 'gas': Naics.mining,
      'util': Naics.utilities,
      'construct': Naics.construction,
      'manufact': Naics.manufacturing, 'chem': Naics.manufacturing, 'apparel': Naics.manufacturing,
      'whole': Naics.wholesaleTrade,
      'retail': Naics.retailTrade,
      'trans': Naics.transportation, 'logis': Naics.transportation,
      'info': Naics.information, 'tech': Naics.information,
      'finan': Naics.finance, 'bank': Naics.finance,
      'real est': Naics.realEstate, 'prop': Naics.realEstate,
      'prof': Naics.professionalServices,
      'health': Naics.healthCare, 'med': Naics.healthCare,
      'art': Naics.arts, 'entert': Naics.arts,
      'accom': Naics.accommodation, 'food': Naics.accommodation,
    };

    for (var entry in keywordToNaics.entries) {
      if (s.contains(entry.key)) return entry.value;
    }
    return null;
  }

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

      final String targetSector = roleConfig['target_sector'] ?? 'All';

      onProgress?.call("Loading local cross-sector intelligence...", null);

      // 2. Fetch the multi-sector news feed (Local Archive First)
      List<String> newsItems = await _localFeedService.getCrossSectorIntelligence('assets/feeds/cubeler_industrial_news.xml');

      if (newsItems.isNotEmpty && newsItems.first.contains("[System]")) {
        newsItems.clear();
      }

      // --- 3. CONFIG-DRIVEN LIVE WEB FETCH ---
      ConsoleLogger.log("Initiating Live Feed Polling for $targetSector...", type: 'system');
      onProgress?.call("Polling live web feeds for additional insights...", null);

      final localConfig = FeedConfigManager.config;
      final int maxSources = localConfig['feed_settings']?['max_target_sources'] ?? 10;
      final int fallbackCount = localConfig['feed_settings']?['fallback_source_count'] ?? 15;

      List<NewsSourceConfig> targetSources = [];

      final sectorMap = localConfig['sector_mappings'] as Map<String, dynamic>? ?? {};
      final mappedString = sectorMap[targetSector.toLowerCase()];
      final targetFeedNaics = _parseNaics(mappedString);

      if (targetFeedNaics != null) {
        targetSources = NewsRegistry.allSources.where((s) => s.tags.contains(targetFeedNaics)).toList();
      } else {
        // Diverse fallback mix
        final diverseList = List.of(NewsRegistry.allSources)..shuffle();
        targetSources = diverseList.take(fallbackCount).toList();
      }

      targetSources = targetSources.take(maxSources).toList();

      // Extract keywords dynamically via config
      List<String> liveKeywords = [];
      if (roleConfig['live_keywords'] != null) {
        liveKeywords = List<String>.from(roleConfig['live_keywords'].map((e) => e.toString()));
      } else if (roleConfig['etf_focus'] != null) {
        liveKeywords = List<String>.from(roleConfig['etf_focus'].map((e) => e.toString()));
      } else {
        final roleName = roleConfig['role']?.toString().toLowerCase() ?? '';
        final fallbacks = localConfig['role_keyword_fallbacks'] as Map<String, dynamic>? ?? {};

        for (var entry in fallbacks.entries) {
          if (roleName.contains(entry.key.toLowerCase())) {
            liveKeywords = List<String>.from(entry.value.map((e) => e.toString()));
            break;
          }
        }
      }

      // Execute the robust live fetch (Assuming FeedService handles Future.wait internally)
      final liveHeadlines = await _feedService.fetchHeadlines(targetSources, liveKeywords);

      if (liveHeadlines.isNotEmpty) {
        final fallbackSectorName = targetSector == 'All' ? 'Live Global Market' : targetSector;
        final formattedLiveNews = liveHeadlines.map((headline) => "[SECTOR: $fallbackSectorName] [LIVE] $headline").toList();

        newsItems.addAll(formattedLiveNews);
        ConsoleLogger.success("Successfully added ${liveHeadlines.length} live headlines to the intelligence pool.");
      }
      // -----------------------------------------------------------------

      // 4. Extract unique sectors dynamically from the COMBINED feed
      Set<String> uniqueSectors = {};
      for (var item in newsItems) {
        final match = RegExp(r'\[SECTOR:\s*(.*?)\]').firstMatch(item);
        if (match != null) {
          final sectorName = match.group(1)!.trim();
          if (targetSector == 'All' || sectorName.toLowerCase().contains(targetSector.toLowerCase())) {
            uniqueSectors.add(sectorName);
          }
        }
      }

      if (uniqueSectors.isEmpty) {
        return {
          "report_title": "No Relevant Data Found",
          "synthesis_conclusion": "No news could be found locally or via live web fetch for the target sector: $targetSector.",
          "sectors": []
        };
      }

      final activeProvider = AIService().activeProvider;
      List<Map<String, dynamic>> generatedSectors = [];
      List<String> briefSummariesForConclusion = [];

      // 5. Generate analysis INDIVIDUALLY for each filtered sector
      for (String sector in uniqueSectors) {
        ConsoleLogger.log("Analyzing Sector: $sector...", type: 'system');
        onProgress?.call("Analyzing Sector: $sector...", null);

        final sectorNews = newsItems.where((n) => n.contains('[SECTOR: $sector]')).toList();

        // --- FETCH MARKET ACTIVITY (ETFs) USING NEW HELPER ---
        Naics? targetNaics = _determineNaicsForSector(sector);

        MarketFact? sectorFact;
        if (targetNaics != null) {
          sectorFact = await MarketDataProvider().getSectorBenchmarks(targetNaics);

          final List<dynamic>? etfKeywords = roleConfig['etf_focus'];

          if (etfKeywords != null && etfKeywords.isNotEmpty) {
            final List<String> keywords = etfKeywords.map((e) => e.toString().toLowerCase()).toList();

            final filteredSubFacts = sectorFact.subFacts.where((fact) {
              final nameLower = fact.name.toLowerCase();
              return keywords.any((kw) => nameLower.contains(kw));
            }).toList();

            if (filteredSubFacts.isNotEmpty) {
              sectorFact = MarketFact(
                  category: sectorFact.category,
                  name: "${roleConfig['target_sector'] ?? 'Targeted'} Pulse",
                  value: sectorFact.value,
                  trend: sectorFact.trend,
                  status: sectorFact.status,
                  history: sectorFact.history,
                  lineData: sectorFact.lineData,
                  subFacts: filteredSubFacts
              );
            } else {
              sectorFact = null;
            }
          }
        } else {
          sectorFact = await MarketDataProvider().getSectorBenchmarks(Naics.manufacturing);
        }

        List<String> combinedContext = List.from(sectorNews);
        if (sectorFact != null) {
          combinedContext.add("[MARKET ACTIVITY (ETFs): ${sectorFact.toString()}]");
        }
        // -------------------------------------

        final prompt = AiPrompts.generateDynamicSectorAnalysis(
          roleConfig: roleConfig,
          sectorName: sector,
          sectorNews: combinedContext,
        );

        final response = await activeProvider.generateBriefingJson(
          systemPrompt: prompt,
          userContext: "Generate the verbose report specifically for $sector.",
        );

        if (response.containsKey('sector_name') || response.containsKey('synthesized_development')) {
          response['sector_name'] ??= sector;
          response['market_fact'] = sectorFact;

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
  }
}*/

// lib/core/strategy_consultant_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../config/feed_config_manager.dart';
import 'local_feed_service.dart';
import 'feed_service.dart';
import 'news_registry.dart';
import 'models.dart';
import 'ai_service.dart';
import 'prompts/ai_prompts.dart';
import 'market_data_provider.dart';
import '../ui/widgets/console_log_widget.dart';

class StrategyConsultantService {
  final LocalFeedService _localFeedService = LocalFeedService();
  final FeedService _feedService = FeedService();

  /// Helper to safely parse the NAICS enum from a string
  Naics? _parseNaics(String? naicsString) {
    if (naicsString == null) return null;
    for (var value in Naics.values) {
      if (value.name.toLowerCase() == naicsString.toLowerCase()) {
        return value;
      }
    }
    return null;
  }

  /// Helper to map sector strings to NAICS for the ETF market data.
  Naics? _determineNaicsForSector(String sectorName) {
    final s = sectorName.toLowerCase();
    final Map<String, Naics> keywordToNaics = {
      'agri': Naics.agriculture, 'farm': Naics.agriculture, 'beef': Naics.agriculture, 'wheat': Naics.agriculture, 'lumber': Naics.agriculture,
      'min': Naics.mining, 'oil': Naics.mining, 'gas': Naics.mining,
      'util': Naics.utilities,
      'construct': Naics.construction,
      'manufact': Naics.manufacturing, 'chem': Naics.manufacturing, 'apparel': Naics.manufacturing,
      'whole': Naics.wholesaleTrade,
      'retail': Naics.retailTrade,
      'trans': Naics.transportation, 'logis': Naics.transportation,
      'info': Naics.information, 'tech': Naics.information,
      'finan': Naics.finance, 'bank': Naics.finance,
      'real est': Naics.realEstate, 'prop': Naics.realEstate,
      'prof': Naics.professionalServices,
      'health': Naics.healthCare, 'med': Naics.healthCare,
      'art': Naics.arts, 'entert': Naics.arts,
      'accom': Naics.accommodation, 'food': Naics.accommodation,
    };

    for (var entry in keywordToNaics.entries) {
      if (s.contains(entry.key)) return entry.value;
    }
    return null;
  }

/*  Future<Map<String, dynamic>> generateIndustrialStrategyReport({
    required String promptAssetPath,
    Function(String statusMessage, Map<String, dynamic>? newSector)? onProgress,
  }) async {
    ConsoleLogger.log("StrategyService: Initiating Verbose Sector-by-Sector Analysis...", type: 'system');

    try {
      onProgress?.call("Loading AI Persona Configuration...", null);

      // 1. Load and parse the AI Persona JSON immediately
      final jsonString = await rootBundle.loadString(promptAssetPath);
      final Map<String, dynamic> roleConfig = jsonDecode(jsonString);

      final String targetSector = roleConfig['target_sector'] ?? 'All';

      onProgress?.call("Loading local cross-sector intelligence...", null);

      // 2. Fetch the multi-sector news feed (Local Archive First)
      List<String> newsItems = await _localFeedService.getCrossSectorIntelligence('assets/feeds/cubeler_industrial_news.xml');

      if (newsItems.isNotEmpty && newsItems.first.contains("[System]")) {
        newsItems.clear();
      }*/

  Future<Map<String, dynamic>> generateIndustrialStrategyReport({
    required String promptAssetPath,
    List<String>? customLocalFeedPaths, // <-- Add this parameter
    Function(String statusMessage, Map<String, dynamic>? newSector)? onProgress,
  }) async {
    ConsoleLogger.log("StrategyService: Initiating Verbose Sector-by-Sector Analysis...", type: 'system');

    try {
      onProgress?.call("Loading AI Persona Configuration...", null);

      // 1. Load and parse the AI Persona JSON immediately
      final jsonString = await rootBundle.loadString(promptAssetPath);
      final Map<String, dynamic> roleConfig = jsonDecode(jsonString);

      final String targetSector = roleConfig['target_sector'] ?? 'All';

      // --- 2. LOCAL ARCHIVE FETCH (UPDATED FOR CUSTOM DIALOG) ---
      List<String> newsItems = [];

      if (customLocalFeedPaths != null && customLocalFeedPaths.isNotEmpty) {
        onProgress?.call("Loading ${customLocalFeedPaths.length} selected local feeds...", null);
        ConsoleLogger.log("Loading user-selected local feeds: $customLocalFeedPaths", type: 'system');

        // Loop through all selected XML files and combine their data
        for (String path in customLocalFeedPaths) {
          final items = await _localFeedService.getCrossSectorIntelligence(path);
          newsItems.addAll(items);
        }
      } else {
        // Default behavior if the user didn't select anything
        onProgress?.call("Loading default local cross-sector intelligence...", null);
        final items = await _localFeedService.getCrossSectorIntelligence('assets/feeds/cubeler_industrial_news.xml');
        newsItems.addAll(items);
      }

      // Clear out the system placeholder if it's the only thing in the file
      if (newsItems.isNotEmpty && newsItems.first.contains("[System]")) {
        // Safer clear: just remove the placeholder itself rather than clearing everything
        newsItems.removeWhere((item) => item.contains("[System]"));
      }
      // ----------------------------------------------------------




      // --- 3. CONFIG-DRIVEN LIVE WEB FETCH ---
      ConsoleLogger.log("Initiating Live Feed Polling for $targetSector...", type: 'system');
      onProgress?.call("Polling live web feeds for additional insights...", null);

      final localConfig = FeedConfigManager.config;
      final int maxSources = localConfig['feed_settings']?['max_target_sources'] ?? 10;
      final int fallbackCount = localConfig['feed_settings']?['fallback_source_count'] ?? 15;

      List<NewsSourceConfig> targetSources = [];

      final sectorMap = localConfig['sector_mappings'] as Map<String, dynamic>? ?? {};
      final mappedString = sectorMap[targetSector.toLowerCase()];
      final targetFeedNaics = _parseNaics(mappedString);

      if (targetFeedNaics != null) {
        targetSources = NewsRegistry.allSources.where((s) => s.tags.contains(targetFeedNaics)).toList();
      } else {
        // Diverse fallback mix
        final diverseList = List.of(NewsRegistry.allSources)..shuffle();
        targetSources = diverseList.take(fallbackCount).toList();
      }

      targetSources = targetSources.take(maxSources).toList();

      // Extract keywords dynamically via config
      List<String> liveKeywords = [];
      if (roleConfig['live_keywords'] != null) {
        liveKeywords = List<String>.from(roleConfig['live_keywords'].map((e) => e.toString()));
      } else if (roleConfig['etf_focus'] != null) {
        liveKeywords = List<String>.from(roleConfig['etf_focus'].map((e) => e.toString()));
      } else {
        final roleName = roleConfig['role']?.toString().toLowerCase() ?? '';
        final fallbacks = localConfig['role_keyword_fallbacks'] as Map<String, dynamic>? ?? {};

        for (var entry in fallbacks.entries) {
          if (roleName.contains(entry.key.toLowerCase())) {
            liveKeywords = List<String>.from(entry.value.map((e) => e.toString()));
            break;
          }
        }
      }

      // Execute the robust live fetch
      final liveHeadlines = await _feedService.fetchHeadlines(targetSources, liveKeywords);

      if (liveHeadlines.isNotEmpty) {
        final fallbackSectorName = targetSector == 'All' ? 'Live Global Market' : targetSector;
        final formattedLiveNews = liveHeadlines.map((headline) => "[SECTOR: $fallbackSectorName] [LIVE] $headline").toList();

        newsItems.addAll(formattedLiveNews);
        ConsoleLogger.success("Successfully added ${liveHeadlines.length} live headlines to the intelligence pool.");
      }
      // -----------------------------------------------------------------

      // 4. Extract unique sectors dynamically from the COMBINED feed
      Set<String> uniqueSectors = {};
      for (var item in newsItems) {
        final match = RegExp(r'\[SECTOR:\s*(.*?)\]').firstMatch(item);
        if (match != null) {
          final sectorName = match.group(1)!.trim();
          if (targetSector == 'All' || sectorName.toLowerCase().contains(targetSector.toLowerCase())) {
            uniqueSectors.add(sectorName);
          }
        }
      }

      if (uniqueSectors.isEmpty) {
        return {
          "report_title": "No Relevant Data Found",
          "synthesis_conclusion": "No news could be found locally or via live web fetch for the target sector: $targetSector.",
          "sectors": []
        };
      }

      final activeProvider = AIService().activeProvider;
      List<Map<String, dynamic>> generatedSectors = [];
      List<String> briefSummariesForConclusion = [];

      // 5. Generate analysis INDIVIDUALLY for each filtered sector
      for (String sector in uniqueSectors) {
        ConsoleLogger.log("Analyzing Sector: $sector...", type: 'system');
        onProgress?.call("Analyzing Sector: $sector...", null);

        final sectorNews = newsItems.where((n) => n.contains('[SECTOR: $sector]')).toList();

        // --- FETCH MARKET ACTIVITY (ETFs) USING NEW HELPER ---
        Naics? targetNaics = _determineNaicsForSector(sector);

        MarketFact? sectorFact;
        if (targetNaics != null) {
          sectorFact = await MarketDataProvider().getSectorBenchmarks(targetNaics);

          final List<dynamic>? etfKeywords = roleConfig['etf_focus'];

          if (etfKeywords != null && etfKeywords.isNotEmpty) {
            final List<String> keywords = etfKeywords.map((e) => e.toString().toLowerCase()).toList();

            final filteredSubFacts = sectorFact.subFacts.where((fact) {
              final nameLower = fact.name.toLowerCase();
              return keywords.any((kw) => nameLower.contains(kw));
            }).toList();

            if (filteredSubFacts.isNotEmpty) {
              sectorFact = MarketFact(
                  category: sectorFact.category,
                  name: "${roleConfig['target_sector'] ?? 'Targeted'} Pulse",
                  value: sectorFact.value,
                  trend: sectorFact.trend,
                  status: sectorFact.status,
                  history: sectorFact.history,
                  lineData: sectorFact.lineData,
                  subFacts: filteredSubFacts
              );
            } else {
              sectorFact = null;
            }
          }
        } else {
          sectorFact = await MarketDataProvider().getSectorBenchmarks(Naics.manufacturing);
        }

        List<String> combinedContext = List.from(sectorNews);
        if (sectorFact != null) {
          combinedContext.add("[MARKET ACTIVITY (ETFs): ${sectorFact.toString()}]");
        }
        // -------------------------------------

        final prompt = AiPrompts.generateDynamicSectorAnalysis(
          roleConfig: roleConfig,
          sectorName: sector,
          sectorNews: combinedContext,
        );

        final response = await activeProvider.generateBriefingJson(
          systemPrompt: prompt,
          userContext: "Generate the verbose report specifically for $sector.",
        );

        if (response.containsKey('sector_name') || response.containsKey('synthesized_development')) {
          response['sector_name'] ??= sector;
          response['market_fact'] = sectorFact;

          // Note: DALL-E 3 image generation logic has been removed to ensure compatibility
          // with text-only local LLMs (e.g., via Ollama).

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
  }
}