import 'models.dart';

class NewsRegistry {
  // --- GLOBAL / MACRO ---
  static const reutersCommodities = NewsSourceConfig(
      name: "Reuters",
      url: "https://www.reutersagency.com/feed/?best-topics=commodities&post_type=best",
      type: "Global",
      tags: [Naics.information, Naics.finance]
  );

  // --- GOVERNMENT ---
  static const usdaGeneral = NewsSourceConfig(
      name: "USDA",
      url: "https://www.usda.gov/rss/latest-releases.xml",
      type: "Government",
      tags: [Naics.publicAdmin, Naics.agriculture]
  );

  static const usdaForestService = NewsSourceConfig(
      name: "USDA Forest Svc",
      url: "https://www.fs.usda.gov/rss/news/releases",
      type: "Government",
      tags: [Naics.publicAdmin, Naics.agriculture] // Forestry falls under Agriculture/Forestry NAICS
  );

  // --- AGRICULTURE / WHEAT ---
  static const agWeb = NewsSourceConfig(
      name: "AgWeb",
      url: "https://www.agweb.com/rss/all",
      type: "Trade",
      tags: [Naics.agriculture, Naics.information]
  );

  static const westernProducer = NewsSourceConfig(
      name: "Western Producer",
      url: "https://www.producer.com/feed/",
      type: "Regional",
      tags: [Naics.agriculture, Naics.information]
  );

  static const foodBusinessNews = NewsSourceConfig(
      name: "Food Business",
      url: "https://www.foodbusinessnews.net/rss/articles",
      type: "Manufacturing",
      tags: [Naics.manufacturing, Naics.accommodation]
  );

  static const biofuelsNews = NewsSourceConfig(
      name: "Biofuels News",
      url: "https://biofuels-news.com/feed/",
      type: "Energy",
      tags: [Naics.manufacturing, Naics.utilities]
  );

  // --- LUMBER / CONSTRUCTION ---
  static const lbmJournal = NewsSourceConfig(
      name: "LBM Journal",
      url: "https://lbmjournal.com/feed/",
      type: "Trade",
      tags: [Naics.wholesaleTrade, Naics.construction]
  );

  static const constructionDive = NewsSourceConfig(
      name: "Construction Dive",
      url: "https://www.constructiondive.com/feeds/news/",
      type: "Demand",
      tags: [Naics.construction, Naics.information]
  );

  static const madisonsReport = NewsSourceConfig(
      name: "Madison's Report",
      url: "https://madisonsreport.com/feed/",
      type: "Industry",
      tags: [Naics.agriculture, Naics.manufacturing] // Forestry & Wood Product Mfg
  );
}