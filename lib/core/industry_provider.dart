import '../core/topic_config.dart';
import '../core/models.dart';

// TOPIC IMPORTS
import '../topics/agriculture/wheat/wheat_config.dart';
import '../topics/agriculture/lumber/lumber_config.dart';
import '../topics/agriculture/beef/beef_config.dart';
import '../topics/agriculture/agtech/agtech_config.dart';
import '../topics/manufacturing/apparel/apparel_config.dart';
import '../topics/manufacturing/chemical/chemical_config.dart';
import '../topics/manufacturing/canadian_manufacturing/canadian_manufacturing_config.dart';

class IndustryProvider {
  // Singleton pattern for easy access
  static final IndustryProvider _instance = IndustryProvider._internal();
  factory IndustryProvider() => _instance;
  IndustryProvider._internal();

  // THE REGISTRY - Single Source of Truth
  final List<TopicConfig> _registeredTopics = [
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),
    ApparelConfig(),
    ChemicalConfig(),
    CanadianManufacturingConfig(),
  ];

  /// Returns a list of all TopicConfigs that are currently active/implemented
  List<TopicConfig> getActiveTopics() {
    return _registeredTopics;
  }

  /// Returns the specific TopicConfig for a given active industry
  /// Returns null if the industry is not yet supported
  TopicConfig? getTopicForIndustry(Naics industry) {
    try {
      return _registeredTopics.firstWhere((t) => t.industry == industry);
    } catch (e) {
      return null;
    }
  }

  /// Returns a set of all Naics enum values that have active implementations
  Set<Naics> getActiveIndustries() {
    return _registeredTopics.map((t) => t.industry).toSet();
  }

  /// Check if a specific industry is supported
  bool isSupported(Naics industry) {
    return _registeredTopics.any((t) => t.industry == industry);
  }

  /// Get ALL possible industries (active + inactive) sorted by label
  List<Naics> getAllIndustriesSorted() {
    final list = Naics.values.toList();
    list.sort((a, b) => a.label.compareTo(b.label));
    return list;
  }
}