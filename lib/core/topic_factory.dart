import 'models.dart';
import 'topic_config.dart';
import 'news_registry.dart';
import 'market_data_provider.dart';

// 1. Define the General Topic Types
enum TopicType {
  sectorNews,
  innovation,
  funding,
  economicPressures,
  laborMarket,
  policyImpact
}

// 2. Define the Template Configuration
class TopicTemplate {
  final String idSuffix;
  final String nameSuffix;
  final List<String> keywords;
  final List<String> preferredSourceTypes;
  final String riskPrompt;

  const TopicTemplate({
    required this.idSuffix,
    required this.nameSuffix,
    required this.keywords,
    required this.preferredSourceTypes,
    required this.riskPrompt,
  });
}

// 3. The Factory Service
class TopicFactory {
  // Singleton Pattern
  static final TopicFactory _instance = TopicFactory._internal();
  factory TopicFactory() => _instance;
  TopicFactory._internal();

  // --- TEMPLATE REGISTRY ---
  static final Map<TopicType, TopicTemplate> _templates = {
    TopicType.sectorNews: const TopicTemplate(
      idSuffix: 'news',
      nameSuffix: 'Sector News',
      keywords: [], // Broadest possible scope
      preferredSourceTypes: ['Trade', 'Industry', 'General', 'Regional', 'News'],
      riskPrompt: "Identify general market trends, major announcements, and supply chain disruptions affecting the sector.",
    ),
    TopicType.innovation: const TopicTemplate(
      idSuffix: 'tech',
      nameSuffix: 'Innovation & Tech',
      keywords: ['AI', 'automation', 'robotics', 'software', 'technology', 'R&D', 'patent', 'startup', 'digital', 'sensor'],
      preferredSourceTypes: ['Tech', 'Science', 'Machinery'],
      riskPrompt: "Focus on technological disruptions, new product launches, adoption of automation, and R&D breakthroughs.",
    ),
    TopicType.funding: const TopicTemplate(
      idSuffix: 'fund',
      nameSuffix: 'Funding & Investment',
      keywords: ['investment', 'funding', 'capital', 'venture', 'acquisition', 'merger', 'IPO', 'quarterly results', 'profit', 'revenue'],
      preferredSourceTypes: ['Finance', 'Business', 'Global'],
      riskPrompt: "Analyze financial health, investment flows, M&A activity, and capital allocation within the sector.",
    ),
    TopicType.economicPressures: const TopicTemplate(
      idSuffix: 'econ',
      nameSuffix: 'Economic Pressures',
      keywords: ['inflation', 'interest rates', 'cost', 'price', 'tariff', 'trade war', 'recession', 'currency', 'supply chain', 'freight'],
      preferredSourceTypes: ['Finance', 'Global', 'Market Data'],
      riskPrompt: "Assess the impact of macroeconomic factors, inflation, input costs, and global trade dynamics.",
    ),
    TopicType.laborMarket: const TopicTemplate(
      idSuffix: 'labor',
      nameSuffix: 'Labor Market',
      keywords: ['labor', 'union', 'strike', 'shortage', 'wages', 'hiring', 'workforce', 'layoffs', 'talent'],
      preferredSourceTypes: ['General', 'Trade', 'Gov'],
      riskPrompt: "Evaluate workforce availability, labor disputes, wage pressure risks, and talent retention challenges.",
    ),
    TopicType.policyImpact: const TopicTemplate(
      idSuffix: 'policy',
      nameSuffix: 'Policy & Regs',
      keywords: ['regulation', 'law', 'compliance', 'ban', 'subsidy', 'tax', 'EPA', 'government', 'bill', 'legislation'],
      preferredSourceTypes: ['Government', 'Policy', 'Legal', 'Gov'],
      riskPrompt: "Monitor changes in government policy, compliance requirements, environmental regulations, and trade laws.",
    ),
  };

  // --- SOURCE AGGREGATION ---
  // Returns all sources from the registry to allow filtering.
  List<NewsSourceConfig> _getAllSources() {
    return [
      // Global / Macro
      NewsRegistry.reutersCommodities, NewsRegistry.nytAgriculture, NewsRegistry.forbesAg,
      // Gov / Policy
      NewsRegistry.usdaGeneral, NewsRegistry.usdaForestService, NewsRegistry.nationalAgLaw,
      NewsRegistry.sustainableAgCoalition, NewsRegistry.calClimateAg, NewsRegistry.epaNews,
      // Tech
      NewsRegistry.globalAgTech, NewsRegistry.agritecture, NewsRegistry.urbanAgNews,
      NewsRegistry.cropAIA, NewsRegistry.pureGreens, NewsRegistry.agWired,
      // Machinery
      NewsRegistry.machineFinder, NewsRegistry.ktwoMachinery, NewsRegistry.padgilwar, NewsRegistry.estesConcaves,
      // Sustainability
      NewsRegistry.civilEats, NewsRegistry.modernFarmer, NewsRegistry.farmingFirst, NewsRegistry.understandingAg,
      // Livestock
      NewsRegistry.animalAgAlliance, NewsRegistry.westTexasLivestock, NewsRegistry.beefRunner, NewsRegistry.dairyCarrie, NewsRegistry.farmerAngus,
      // General Ag
      NewsRegistry.agWeb, NewsRegistry.agUpdate, NewsRegistry.agDaily, NewsRegistry.cropLife, NewsRegistry.proAg, NewsRegistry.westernProducer, NewsRegistry.lathamSeeds,
      // Regional
      NewsRegistry.agNetWest, NewsRegistry.californiaAgToday, NewsRegistry.farmtario, NewsRegistry.brownfieldAg, NewsRegistry.texasAgriLife, NewsRegistry.iowaAgLiteracy,
      NewsRegistry.mnFarmLiving, NewsRegistry.ffaIndiana, NewsRegistry.uvmAg,
      NewsRegistry.farmersAustralia, NewsRegistry.raynerAg, NewsRegistry.agriFarmingIn, NewsRegistry.krishiJagran, NewsRegistry.justAgriculture, NewsRegistry.accessAfrica,
      NewsRegistry.thriveAgric, NewsRegistry.agricIncome, NewsRegistry.grandmasterGlobal,
      // Science
      NewsRegistry.scienceDailyAg, NewsRegistry.saiFood, NewsRegistry.biodiversity,
      // Niche
      NewsRegistry.smallFarmersJournal, NewsRegistry.lifeAndAgri, NewsRegistry.farmersDaughter, NewsRegistry.harvie, NewsRegistry.episode3, NewsRegistry.agric4Profits,
      // Legacy / Misc
      NewsRegistry.foodBusinessNews, NewsRegistry.biofuelsNews,
      NewsRegistry.farmsMachinery, NewsRegistry.farmsAll, NewsRegistry.farmsSwine, NewsRegistry.farmsCrop, NewsRegistry.farmsBeef,
      // Construction / Lumber
      NewsRegistry.lbmJournal, NewsRegistry.constructionDive, NewsRegistry.madisonsReport,
      // Manufacturing / Apparel
      NewsRegistry.sourcingJournal, NewsRegistry.justStyle, NewsRegistry.wwd,
      NewsRegistry.canadianMfg, NewsRegistry.plantMagazine, NewsRegistry.industryWest,
      // Chemicals
      NewsRegistry.cenNews, NewsRegistry.chemicalWeek, NewsRegistry.icis,
    ];
  }

  /// **Main Factory Method**
  /// Generates a TopicConfig for the given [industry] and [type].
  TopicConfig createTopic({
    required Naics industry,
    required TopicType type,
    List<NewsSourceConfig>? customSources, // Optional override
  }) {
    final template = _templates[type]!;
    final sourcePool = customSources ?? _getAllSources();

    // FILTER LOGIC:
    // 1. Must match the Industry Tag.
    // 2. Prioritize matching 'preferredSourceTypes'.
    // 3. Always include if it matches the industry and the topic is 'Sector News'.
    final relevantSources = sourcePool.where((s) {
      if (!s.tags.contains(industry)) return false;

      // If it's general news, take everything in the industry
      if (type == TopicType.sectorNews) return true;

      // Otherwise, filter by type (e.g., only "Tech" sources for Innovation)
      return template.preferredSourceTypes.contains(s.type);
    }).toList();

    // Fallback: If strict filtering returns empty (e.g. no "Tech" sources for this industry),
    // we loosen the filter to include "General" or "News" sources from that industry
    // so the topic isn't empty.
    if (relevantSources.isEmpty) {
      final fallbackSources = sourcePool.where((s) =>
      s.tags.contains(industry) &&
          ['General', 'News', 'Trade'].contains(s.type)
      ).toList();
      relevantSources.addAll(fallbackSources);
    }

    // Construct the ID and Name
    final shortLabel = industry.label.split(',')[0]; // "Agriculture"
    final topicId = "${industry.name}_${template.idSuffix}";
    final topicName = "$shortLabel ${template.nameSuffix}";

    return _GeneratedTopicConfig(
      id: topicId,
      name: topicName,
      industry: industry,
      sources: relevantSources,
      keywords: template.keywords,
      riskRules: template.riskPrompt,
    );
  }
}

// 4. Concrete Implementation (Private)
class _GeneratedTopicConfig implements TopicConfig {
  @override
  final String id;
  @override
  final String name;
  @override
  final Naics industry;
  @override
  final List<NewsSourceConfig> sources;
  @override
  final List<String> keywords;
  @override
  final String riskRules;

  _GeneratedTopicConfig({
    required this.id,
    required this.name,
    required this.industry,
    required this.sources,
    required this.keywords,
    required this.riskRules,
  });

  @override
  Future<MarketFact> fetchMarketPulse() async {
    // Generated topics rely on the standard sector benchmarks
    return await MarketDataProvider().getSectorBenchmarks(industry);
  }
}