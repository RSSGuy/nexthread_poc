

import '../core/topic_config.dart';
import '../core/models.dart';
import '../core/topic_factory.dart'; // Factory Import

// TOPIC IMPORTS (Manual)
import '../topics/agriculture/wheat/wheat_config.dart';
import '../topics/agriculture/lumber/lumber_config.dart';
import '../topics/agriculture/beef/beef_config.dart';
import '../topics/agriculture/agtech/agtech_config.dart';
import '../topics/manufacturing/apparel/apparel_config.dart';
import '../topics/manufacturing/chemical/chemical_config.dart';
import '../topics/manufacturing/canadian_manufacturing/canadian_manufacturing_config.dart';
import '../topics/mining/oil_gas/oil_gas_config.dart';

class IndustryProvider {
  // Singleton pattern
  static final IndustryProvider _instance = IndustryProvider._internal();
  factory IndustryProvider() => _instance;
  IndustryProvider._internal();

  // 1. REGISTERED MANUAL TOPICS
  final List<TopicConfig> _manualTopics = [
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),
    ApparelConfig(),
    ChemicalConfig(),
    CanadianManufacturingConfig(),
    OilGasConfig(),
  ];

  List<TopicConfig>? _cachedTopics;

  /// Returns ALL active topics (Manual + Generated)
  List<TopicConfig> getActiveTopics() {
    // Return cached list if available to prevent re-generating on every call
    if (_cachedTopics != null) return _cachedTopics!;

    // Start with the manually configured topics
    List<TopicConfig> allTopics = List.from(_manualTopics);

    // 2. GENERATE FACTORY TOPICS FOR ALL INDUSTRIES
    // This ensures every industry has a full suite of feeds (News, Tech, Funding, etc.)
    for (var industry in Naics.values) {
      allTopics.add(TopicFactory().createTopic(industry: industry, type: TopicType.sectorNews));
      allTopics.add(TopicFactory().createTopic(industry: industry, type: TopicType.innovation));
      allTopics.add(TopicFactory().createTopic(industry: industry, type: TopicType.funding));
      allTopics.add(TopicFactory().createTopic(industry: industry, type: TopicType.economicPressures));
      allTopics.add(TopicFactory().createTopic(industry: industry, type: TopicType.laborMarket));
      allTopics.add(TopicFactory().createTopic(industry: industry, type: TopicType.policyImpact));
    }

    _cachedTopics = allTopics;
    return allTopics;
  }

  /// Returns the default topic for an industry (Prioritizes 'Sector News')
  TopicConfig? getTopicForIndustry(Naics industry) {
    // Filter all active topics to find ones for this industry
    final topics = getActiveTopics().where((t) => t.industry == industry).toList();

    if (topics.isEmpty) return null;

    // Try to return "Sector News" as the default landing topic for consistency
    try {
      return topics.firstWhere((t) => t.name.contains("Sector News"));
    } catch (e) {
      // Fallback to the first available topic (e.g. a manual one)
      return topics.first;
    }
  }

  /// All industries are now active/supported via the Factory
  Set<Naics> getActiveIndustries() {
    return Naics.values.toSet();
  }

  /// Get ALL possible industries sorted by label
  List<Naics> getAllIndustriesSorted() {
    final list = Naics.values.toList();
    list.sort((a, b) => a.label.compareTo(b.label));
    return list;
  }
}