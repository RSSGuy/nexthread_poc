/*
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
import '../topics/mining/oil_gas/oil_gas_config.dart';

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
    OilGasConfig(),
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
}*/

/*
import '../topics/agriculture/wheat/wheat_config.dart';
import '../topics/agriculture/lumber/lumber_config.dart';
import '../topics/agriculture/beef/beef_config.dart';
import '../topics/agriculture/agtech/agtech_config.dart';

import '../topics/manufacturing/apparel/apparel_config.dart';
import '../topics/manufacturing/chemical/chemical_config.dart';
import '../topics/manufacturing/canadian_manufacturing/canadian_manufacturing_config.dart';

import '../topics/mining/oil_gas/oil_gas_config.dart';

import 'topic_config.dart';
import 'models.dart';
import 'market_data_provider.dart';
import 'sector_benchmarks.dart'; // Import for Stub

class IndustryProvider {
  static final IndustryProvider _instance = IndustryProvider._internal();
  factory IndustryProvider() => _instance;
  IndustryProvider._internal();

  // --- THE REGISTRY ---
  final List<TopicConfig> _topics = [
    // Agriculture
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),

    // Manufacturing
    ApparelConfig(),
    ChemicalConfig(),
    CanadianManufacturingConfig(),

    // Mining (Updated to Oil & Gas)
    OilGasConfig(),

    // --- STUBS (For unimplemented sectors) ---
    StubTopicConfig("util_grid", "Utilities & Grid", Naics.utilities),
    StubTopicConfig("const_cre", "Construction & RE", Naics.construction),
    StubTopicConfig("whole_log", "Wholesale Logistics", Naics.wholesaleTrade),
    StubTopicConfig("retail_cons", "Retail Sentiment", Naics.retailTrade),
    StubTopicConfig("trans_freight", "Freight & Transport", Naics.transportation),
    StubTopicConfig("info_tech", "Tech & Information", Naics.information),
    StubTopicConfig("fin_bank", "Finance & Banking", Naics.finance),
    StubTopicConfig("real_housing", "Housing Market", Naics.realEstate),
    StubTopicConfig("prof_svcs", "Professional Svcs", Naics.professionalServices),
    StubTopicConfig("mgmt_corp", "Corporate Mgmt", Naics.management),
    StubTopicConfig("admin_labor", "Admin & Support", Naics.adminSupport),
    StubTopicConfig("edu_high", "Higher Education", Naics.education),
    StubTopicConfig("health_pharma", "Health & Pharma", Naics.healthCare),
    StubTopicConfig("arts_ent", "Arts & Entertainment", Naics.arts),
    StubTopicConfig("accom_hosp", "Hospitality", Naics.accommodation),
    StubTopicConfig("other_svcs", "Other Services", Naics.otherServices),
    StubTopicConfig("pub_policy", "Public Policy", Naics.publicAdmin),
  ];

  List<TopicConfig> getActiveTopics() {
    return _topics;
  }

  TopicConfig? getTopicForIndustry(Naics industry) {
    return _topics.where((t) => t.industry == industry).firstOrNull;
  }
}

// --- HELPER CONFIG FOR STUBS ---
class StubTopicConfig implements TopicConfig {
  @override
  final String id;
  @override
  final String name;
  @override
  final Naics industry;

  StubTopicConfig(this.id, this.name, this.industry);

  @override
  List<NewsSourceConfig> get sources => [];
  @override
  List<String> get keywords => [];
  @override
  String get riskRules => "Standard risk assessment rules apply for the $name sector.";

  @override
  Future<MarketFact> fetchMarketPulse() async {
    // Uses the new Key-Value SectorBenchmarks
    return await MarketDataProvider().getSectorBenchmarks(industry);
  }
}*/

import '../core/topic_config.dart';
import '../core/models.dart';
import '../core/market_data_provider.dart';

// TOPIC IMPORTS
import '../topics/agriculture/wheat/wheat_config.dart';
import '../topics/agriculture/lumber/lumber_config.dart';
import '../topics/agriculture/beef/beef_config.dart';
import '../topics/agriculture/agtech/agtech_config.dart';
import '../topics/manufacturing/apparel/apparel_config.dart';
import '../topics/manufacturing/chemical/chemical_config.dart';
import '../topics/manufacturing/canadian_manufacturing/canadian_manufacturing_config.dart';

// NEW TOPIC IMPORT
import '../topics/mining/oil_gas/oil_gas_config.dart';

class IndustryProvider {
  // Singleton pattern
  static final IndustryProvider _instance = IndustryProvider._internal();
  factory IndustryProvider() => _instance;
  IndustryProvider._internal();

  // THE REGISTRY - Single Source of Truth
  final List<TopicConfig> _registeredTopics = [
    // Agriculture
    WheatConfig(),
    BeefConfig(),
    AgTechConfig(),
    LumberConfig(),

    // Manufacturing
    ApparelConfig(),
    ChemicalConfig(),
    CanadianManufacturingConfig(),

    // Mining (NEW)
    OilGasConfig(),

    // --- STUBS (For unimplemented sectors) ---
    // These ensure the UI allows selection of these industries,
    // even if we only have basic benchmark data for them.
    StubTopicConfig("util_grid", "Utilities & Grid", Naics.utilities),
    StubTopicConfig("const_cre", "Construction & RE", Naics.construction),
    StubTopicConfig("whole_log", "Wholesale Logistics", Naics.wholesaleTrade),
    StubTopicConfig("retail_cons", "Retail Sentiment", Naics.retailTrade),
    StubTopicConfig("trans_freight", "Freight & Transport", Naics.transportation),
    StubTopicConfig("info_tech", "Tech & Information", Naics.information),
    StubTopicConfig("fin_bank", "Finance & Banking", Naics.finance),
    StubTopicConfig("real_housing", "Housing Market", Naics.realEstate),
    StubTopicConfig("prof_svcs", "Professional Svcs", Naics.professionalServices),
    StubTopicConfig("mgmt_corp", "Corporate Mgmt", Naics.management),
    StubTopicConfig("admin_labor", "Admin & Support", Naics.adminSupport),
    StubTopicConfig("edu_high", "Higher Education", Naics.education),
    StubTopicConfig("health_pharma", "Health & Pharma", Naics.healthCare),
    StubTopicConfig("arts_ent", "Arts & Entertainment", Naics.arts),
    StubTopicConfig("accom_hosp", "Hospitality", Naics.accommodation),
    StubTopicConfig("other_svcs", "Other Services", Naics.otherServices),
    StubTopicConfig("pub_policy", "Public Policy", Naics.publicAdmin),
  ];

  /// Returns a list of all TopicConfigs that are currently active/implemented
  List<TopicConfig> getActiveTopics() {
    return _registeredTopics;
  }

  /// Returns the specific TopicConfig for a given active industry
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

  /// Get ALL possible industries (active + inactive) sorted by label
  List<Naics> getAllIndustriesSorted() {
    final list = Naics.values.toList();
    list.sort((a, b) => a.label.compareTo(b.label));
    return list;
  }
}

// --- HELPER CONFIG FOR STUBS ---
// This allows sectors to exist in the menu without full implementation files
class StubTopicConfig implements TopicConfig {
  @override
  final String id;
  @override
  final String name;
  @override
  final Naics industry;

  StubTopicConfig(this.id, this.name, this.industry);

  @override
  List<NewsSourceConfig> get sources => [];
  @override
  List<String> get keywords => [];
  @override
  String get riskRules => "Standard risk assessment rules apply for the $name sector.";

  @override
  Future<MarketFact> fetchMarketPulse() async {
    // Uses the MarketDataProvider to get basic sector benchmarks
    return await MarketDataProvider().getSectorBenchmarks(industry);
  }
}