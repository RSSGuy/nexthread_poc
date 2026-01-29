/*
import 'models.dart';

class NewsRegistry {
  // --- GLOBAL / MACRO ---
  static const reutersCommodities = NewsSourceConfig(
      name: "Reuters",
      url: "https://www.reutersagency.com/feed/?best-topics=commodities&post_type=best",
      type: "Global",
      tags: [Naics.information, Naics.finance]
  );

  static const farms = NewsSourceConfig(
      name: "Farms.com",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Canada_West.xml",
      type: "Canada West",
      tags: [Naics.agriculture]
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

  // --- MANUFACTURING / APPAREL ---
  static const sourcingJournal = NewsSourceConfig(
      name: "Sourcing Journal",
      url: "https://sourcingjournal.com/feed/",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.transportation]
  );

  static const justStyle = NewsSourceConfig(
      name: "Just-Style",
      url: "https://www.just-style.com/feed/",
      type: "Industry",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );

  static const wwd = NewsSourceConfig(
      name: "WWD",
      url: "https://wwd.com/feed/",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.retailTrade] // Bridges Mfg and Retail
  );

  // --- CHEMICALS ---
  static const cenNews = NewsSourceConfig(
      name: "C&EN", // Chemical & Engineering News
      url: "https://cen.acs.org/content/cen/global/en.feed.html",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.professionalServices]
  );

  static const chemicalWeek = NewsSourceConfig(
      name: "ChemWeek",
      url: "https://www.chemweek.com/rss",
      type: "Industry",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );

  static const epaNews = NewsSourceConfig(
      name: "EPA Releases",
      url: "https://www.epa.gov/newsreleases/search/rss",
      type: "Gov",
      tags: [Naics.publicAdmin, Naics.manufacturing] // Regulatory impact
  );

  static const icis = NewsSourceConfig(
      name: "ICIS News",
      url: "https://www.icis.com/explore/resources/news-feeds/",
      type: "Market Data",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );
}*/
/*
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

  // --- FARMS.COM ---
  static const farmsMachinery = NewsSourceConfig(
      name: "Farms.com Machinery",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Machinery.xml",
      type: "Trade",
      tags: [Naics.agriculture, Naics.wholesaleTrade]
  );

  static const farmsAll = NewsSourceConfig(
      name: "Farms.com News",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_All.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsSwine = NewsSourceConfig(
      name: "Farms.com Swine",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Swine.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsCrop = NewsSourceConfig(
      name: "Farms.com Crops",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Crop.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsBeef = NewsSourceConfig(
      name: "Farms.com Beef",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Beef.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedAll = NewsSourceConfig(
      name: "Farms.com Featured",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_All.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedCrop = NewsSourceConfig(
      name: "Farms.com Feat Crops",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Crop.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedBeeph = NewsSourceConfig(
      name: "Farms.com Feat Beef",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Beef.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsCanadaWest = NewsSourceConfig(
      name: "Farms.com West",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Canada_West.xml",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const farmsCanadaEast = NewsSourceConfig(
      name: "Farms.com East",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Canada_East.xml",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedCanadaWest = NewsSourceConfig(
      name: "Farms.com Feat West",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Canada_West.xml",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedCanadaEast = NewsSourceConfig(
      name: "Farms.com Feat East",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Canada_East.xml",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedNews = NewsSourceConfig(
      name: "Farms.com Feat News",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_News.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedHeadlines = NewsSourceConfig(
      name: "Farms.com Headlines",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Headlines.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsIndustryNews = NewsSourceConfig(
      name: "Farms.com Industry",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/ag-industry-news.xml",
      type: "Industry",
      tags: [Naics.agriculture]
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

  // --- MANUFACTURING / APPAREL ---
  static const sourcingJournal = NewsSourceConfig(
      name: "Sourcing Journal",
      url: "https://sourcingjournal.com/feed/",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.transportation]
  );

  static const justStyle = NewsSourceConfig(
      name: "Just-Style",
      url: "https://www.just-style.com/feed/",
      type: "Industry",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );

  static const wwd = NewsSourceConfig(
      name: "WWD",
      url: "https://wwd.com/feed/",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.retailTrade] // Bridges Mfg and Retail
  );

  // --- CHEMICALS ---
  static const cenNews = NewsSourceConfig(
      name: "C&EN", // Chemical & Engineering News
      url: "https://cen.acs.org/content/cen/global/en.feed.html",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.professionalServices]
  );

  static const chemicalWeek = NewsSourceConfig(
      name: "ChemWeek",
      url: "https://www.chemweek.com/rss",
      type: "Industry",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );

  static const epaNews = NewsSourceConfig(
      name: "EPA Releases",
      url: "https://www.epa.gov/newsreleases/search/rss",
      type: "Gov",
      tags: [Naics.publicAdmin, Naics.manufacturing] // Regulatory impact
  );

  static const icis = NewsSourceConfig(
      name: "ICIS News",
      url: "https://www.icis.com/explore/resources/news-feeds/",
      type: "Market Data",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );
}*/

import 'models.dart';

class NewsRegistry {
  // --- GLOBAL / MACRO ---
  static const reutersCommodities = NewsSourceConfig(
      name: "Reuters",
      url: "https://www.reutersagency.com/feed/?best-topics=commodities&post_type=best",
      type: "Global",
      tags: [Naics.information, Naics.finance]
  );

  static const nytAgriculture = NewsSourceConfig(
      name: "NYT Agriculture",
      url: "https://www.nytimes.com/svc/collections/v1/publish/http://www.nytimes.com/topic/subject/agriculture-and-farming/rss.xml",
      type: "Global",
      tags: [Naics.information, Naics.agriculture]
  );

  static const forbesAg = NewsSourceConfig(
      name: "Forbes Ag",
      url: "https://www.feedspot.com/infiniterss.php?_src=feed_title&followfeedid=5000056&q=site:https%3A%2F%2Fwww.forbes.com%2Fsites%2Fdaphneewingchow%2Ffeed%2F",
      type: "Finance",
      tags: [Naics.finance, Naics.agriculture]
  );

  // --- GOVERNMENT & POLICY ---
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
      tags: [Naics.publicAdmin, Naics.agriculture]
  );

  static const nationalAgLaw = NewsSourceConfig(
      name: "Nat. Ag Law Center",
      url: "https://nationalaglawcenter.org/ag-and-food-law-blog/feed/",
      type: "Legal",
      tags: [Naics.professionalServices, Naics.agriculture]
  );

  static const sustainableAgCoalition = NewsSourceConfig(
      name: "NSAC",
      url: "http://sustainableagriculture.net/blog/feed/",
      type: "Policy",
      tags: [Naics.publicAdmin, Naics.agriculture]
  );

  static const calClimateAg = NewsSourceConfig(
      name: "Cal Climate Ag",
      url: "https://calclimateag.org/feed/",
      type: "Policy",
      tags: [Naics.publicAdmin, Naics.agriculture]
  );

  // --- AGTECH & INNOVATION ---
  static const globalAgTech = NewsSourceConfig(
      name: "Global AgTech",
      url: "https://www.globalagtechinitiative.com/feed/",
      type: "Tech",
      tags: [Naics.agriculture, Naics.professionalServices]
  );

  static const agritecture = NewsSourceConfig(
      name: "Agritecture",
      url: "https://www.agritecture.com/blog/rss.xml",
      type: "Tech",
      tags: [Naics.agriculture, Naics.construction]
  );

  static const urbanAgNews = NewsSourceConfig(
      name: "Urban Ag News",
      url: "https://urbanagnews.com/feed/",
      type: "Tech",
      tags: [Naics.agriculture, Naics.construction]
  );

  static const cropAIA = NewsSourceConfig(
      name: "CropAIA",
      url: "https://cropaia.com/feed/",
      type: "Tech",
      tags: [Naics.agriculture, Naics.information]
  );

  static const pureGreens = NewsSourceConfig(
      name: "Pure Greens",
      url: "https://puregreensaz.com/feed/",
      type: "Tech",
      tags: [Naics.agriculture, Naics.manufacturing]
  );

  static const agWired = NewsSourceConfig(
      name: "AgWired",
      url: "https://agwired.com/feed/",
      type: "Tech",
      tags: [Naics.agriculture, Naics.information]
  );

  // --- MACHINERY & EQUIPMENT ---
  static const machineFinder = NewsSourceConfig(
      name: "MachineFinder",
      url: "https://blog.machinefinder.com/category/agriculture/feed",
      type: "Machinery",
      tags: [Naics.agriculture, Naics.wholesaleTrade]
  );

  static const ktwoMachinery = NewsSourceConfig(
      name: "Ktwo",
      url: "https://www.ktwo.co.uk/feed/",
      type: "Machinery",
      tags: [Naics.agriculture, Naics.manufacturing]
  );

  static const padgilwar = NewsSourceConfig(
      name: "Padgilwar",
      url: "https://padgilwar.com/blogs/feed/",
      type: "Machinery",
      tags: [Naics.agriculture, Naics.manufacturing]
  );

  static const estesConcaves = NewsSourceConfig(
      name: "Estes Performance",
      url: "https://www.estesperformanceconcaves.com/feed/",
      type: "Machinery",
      tags: [Naics.agriculture, Naics.manufacturing]
  );

  // --- SUSTAINABILITY & ORGANIC ---
  static const civilEats = NewsSourceConfig(
      name: "Civil Eats",
      url: "https://feeds.feedburner.com/CivilEats",
      type: "Sustainability",
      tags: [Naics.agriculture, Naics.accommodation]
  );

  static const modernFarmer = NewsSourceConfig(
      name: "Modern Farmer",
      url: "https://modernfarmer.com/feed/",
      type: "General",
      tags: [Naics.agriculture]
  );

  static const farmingFirst = NewsSourceConfig(
      name: "Farming First",
      url: "https://farmingfirst.org/feed/",
      type: "NGO",
      tags: [Naics.agriculture, Naics.publicAdmin]
  );

  static const understandingAg = NewsSourceConfig(
      name: "Understanding Ag",
      url: "https://understandingag.com/feed/",
      type: "Education",
      tags: [Naics.agriculture, Naics.education]
  );

  // --- LIVESTOCK & DAIRY ---
  static const animalAgAlliance = NewsSourceConfig(
      name: "Animal Ag Alliance",
      url: "https://animalagalliance.org/feed/",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const westTexasLivestock = NewsSourceConfig(
      name: "West Texas Livestock",
      url: "https://www.westtexaslivestockgrowers.com/feed/",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const beefRunner = NewsSourceConfig(
      name: "Beef Runner",
      url: "https://beefrunner.com/feed/",
      type: "Blog",
      tags: [Naics.agriculture]
  );

  static const dairyCarrie = NewsSourceConfig(
      name: "Dairy Carrie",
      url: "https://dairycarrie.com/feed/",
      type: "Blog",
      tags: [Naics.agriculture]
  );

  static const farmerAngus = NewsSourceConfig(
      name: "Farmer Angus",
      url: "https://www.farmerangus.co.za/feed/",
      type: "Blog",
      tags: [Naics.agriculture]
  );

  // --- GENERAL AGRICULTURE & TRADE ---
  static const agWeb = NewsSourceConfig(
      name: "AgWeb",
      url: "https://www.agweb.com/rss/all",
      type: "Trade",
      tags: [Naics.agriculture, Naics.information]
  );

  static const agUpdate = NewsSourceConfig(
      name: "AgUpdate",
      url: "https://agupdate.com/search/?f=rss",
      type: "General",
      tags: [Naics.agriculture]
  );

  static const agDaily = NewsSourceConfig(
      name: "AgDaily",
      url: "https://www.agdaily.com/feed/",
      type: "General",
      tags: [Naics.agriculture]
  );

  static const cropLife = NewsSourceConfig(
      name: "CropLife",
      url: "https://www.croplife.com/feed/",
      type: "Trade",
      tags: [Naics.agriculture, Naics.manufacturing]
  );

  static const proAg = NewsSourceConfig(
      name: "ProAg",
      url: "https://www.proag.com/feed/",
      type: "Insurance",
      tags: [Naics.finance, Naics.agriculture]
  );

  static const westernProducer = NewsSourceConfig(
      name: "Western Producer",
      url: "https://www.producer.com/feed/",
      type: "Regional",
      tags: [Naics.agriculture, Naics.information]
  );

  static const lathamSeeds = NewsSourceConfig(
      name: "Latham Seeds",
      url: "https://www.lathamseeds.com/feed/",
      type: "Trade",
      tags: [Naics.agriculture, Naics.wholesaleTrade]
  );

  // --- REGIONAL (US & CANADA) ---
  static const agNetWest = NewsSourceConfig(
      name: "AgNet West",
      url: "https://agnetwest.com/feed/",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const californiaAgToday = NewsSourceConfig(
      name: "CA Ag Today",
      url: "https://californiaagtoday.com/feed/",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const farmtario = NewsSourceConfig(
      name: "Farmtario",
      url: "https://farmtario.com/feed/",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const brownfieldAg = NewsSourceConfig(
      name: "Brownfield Ag",
      url: "https://www.brownfieldagnews.com/feed/",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const texasAgriLife = NewsSourceConfig(
      name: "Texas A&M AgriLife",
      url: "https://agrilifetoday.tamu.edu/feed/",
      type: "Research",
      tags: [Naics.agriculture, Naics.education]
  );

  static const iowaAgLiteracy = NewsSourceConfig(
      name: "Iowa Ag Literacy",
      url: "https://iowaagliteracy.wordpress.com/feed/",
      type: "Education",
      tags: [Naics.agriculture, Naics.education]
  );

  static const mnFarmLiving = NewsSourceConfig(
      name: "MN Farm Living",
      url: "https://www.mnfarmliving.com/feed",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const ffaIndiana = NewsSourceConfig(
      name: "FFA Indiana",
      url: "http://ffaindiana.blogspot.com/feeds/posts/default?alt=rss",
      type: "Education",
      tags: [Naics.agriculture, Naics.education]
  );

  static const uvmAg = NewsSourceConfig(
      name: "UVM Ag",
      url: "https://blog.uvm.edu/wagn/feed/",
      type: "Research",
      tags: [Naics.agriculture, Naics.education]
  );

  // --- INTERNATIONAL ---
  static const farmersAustralia = NewsSourceConfig(
      name: "NFF Australia",
      url: "https://farmers.org.au/feed/",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const raynerAg = NewsSourceConfig(
      name: "RaynerAg (AU)",
      url: "https://www.raynerag.com.au/blog?format=rss",
      type: "Consulting",
      tags: [Naics.agriculture]
  );

  static const agriFarmingIn = NewsSourceConfig(
      name: "AgriFarming",
      url: "https://www.agrifarming.in/feed",
      type: "Intl",
      tags: [Naics.agriculture]
  );

  static const krishiJagran = NewsSourceConfig(
      name: "Krishi Jagran",
      url: "https://krishijagran.com/feeds/rss",
      type: "Intl",
      tags: [Naics.agriculture]
  );

  static const justAgriculture = NewsSourceConfig(
      name: "Just Agriculture",
      url: "https://justagriculture.in/feed/",
      type: "Intl",
      tags: [Naics.agriculture]
  );

  static const accessAfrica = NewsSourceConfig(
      name: "Access Africa",
      url: "https://access-africa.com/feed/",
      type: "Intl",
      tags: [Naics.agriculture]
  );

  static const thriveAgric = NewsSourceConfig(
      name: "Thrive Agric",
      url: "https://medium.com/feed/thrive-agric",
      type: "Intl",
      tags: [Naics.agriculture, Naics.finance]
  );

  static const agricIncome = NewsSourceConfig(
      name: "AgricIncome",
      url: "https://agricincome.com/feed/",
      type: "Intl",
      tags: [Naics.agriculture]
  );

  static const grandmasterGlobal = NewsSourceConfig(
      name: "Grandmaster",
      url: "https://www.grandmasterglobal.com/blog/feed/",
      type: "Trade",
      tags: [Naics.agriculture, Naics.wholesaleTrade]
  );

  // --- RESEARCH & SCIENCE ---
  static const scienceDailyAg = NewsSourceConfig(
      name: "ScienceDaily Ag",
      url: "https://rss.sciencedaily.com/plants_animals/agriculture_and_food.xml",
      type: "Science",
      tags: [Naics.agriculture, Naics.professionalServices]
  );

  static const saiFood = NewsSourceConfig(
      name: "SAIFood",
      url: "https://saifood.ca/feed/",
      type: "Research",
      tags: [Naics.agriculture, Naics.education]
  );

  static const biodiversity = NewsSourceConfig(
      name: "Biodiverse",
      url: "https://agro.biodiver.se/feed/",
      type: "Research",
      tags: [Naics.agriculture]
  );

  // --- NICHE / BLOGS ---
  static const smallFarmersJournal = NewsSourceConfig(
      name: "Small Farmers",
      url: "https://smallfarmersjournal.com/feed/",
      type: "Niche",
      tags: [Naics.agriculture]
  );

  static const lifeAndAgri = NewsSourceConfig(
      name: "Life & Agri",
      url: "https://lifeandagri.com/feed/",
      type: "Blog",
      tags: [Naics.agriculture]
  );

  static const farmersDaughter = NewsSourceConfig(
      name: "Farmer's Daughter",
      url: "http://thefarmersdaughterusa.com/feed/",
      type: "Blog",
      tags: [Naics.agriculture]
  );

  static const harvie = NewsSourceConfig(
      name: "Harvie",
      url: "https://www.harvie.farm/blog/feed/",
      type: "DTC",
      tags: [Naics.agriculture, Naics.retailTrade]
  );

  static const episode3 = NewsSourceConfig(
      name: "Episode 3",
      url: "https://episode3.net/feed/",
      type: "Blog",
      tags: [Naics.agriculture]
  );

  static const agric4Profits = NewsSourceConfig(
      name: "Agric4Profits",
      url: "https://agric4profits.com/feed/",
      type: "Blog",
      tags: [Naics.agriculture]
  );

  // --- EXISTING LEGACY SOURCES (Preserved) ---
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

  // --- FARMS.COM SUITE ---
  static const farmsMachinery = NewsSourceConfig(
      name: "Farms.com Machinery",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Machinery.xml",
      type: "Trade",
      tags: [Naics.agriculture, Naics.wholesaleTrade]
  );

  static const farmsAll = NewsSourceConfig(
      name: "Farms.com News",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_All.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsSwine = NewsSourceConfig(
      name: "Farms.com Swine",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Swine.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsCrop = NewsSourceConfig(
      name: "Farms.com Crops",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Crop.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsBeef = NewsSourceConfig(
      name: "Farms.com Beef",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Beef.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedAll = NewsSourceConfig(
      name: "Farms.com Featured",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_All.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedCrop = NewsSourceConfig(
      name: "Farms.com Feat Crops",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Crop.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedBeeph = NewsSourceConfig(
      name: "Farms.com Feat Beef",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Beef.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsCanadaWest = NewsSourceConfig(
      name: "Farms.com West",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Canada_West.xml",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const farmsCanadaEast = NewsSourceConfig(
      name: "Farms.com East",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/News_Canada_East.xml",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedCanadaWest = NewsSourceConfig(
      name: "Farms.com Feat West",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Canada_West.xml",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedCanadaEast = NewsSourceConfig(
      name: "Farms.com Feat East",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Canada_East.xml",
      type: "Regional",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedNews = NewsSourceConfig(
      name: "Farms.com Feat News",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_News.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsFeaturedHeadlines = NewsSourceConfig(
      name: "Farms.com Headlines",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/Featured_Headlines.xml",
      type: "Trade",
      tags: [Naics.agriculture]
  );

  static const farmsIndustryNews = NewsSourceConfig(
      name: "Farms.com Industry",
      url: "https://m.farms.com/Portals/_default/RSS_Portal/ag-industry-news.xml",
      type: "Industry",
      tags: [Naics.agriculture]
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
      tags: [Naics.agriculture, Naics.manufacturing]
  );

  // --- MANUFACTURING / APPAREL ---
  static const sourcingJournal = NewsSourceConfig(
      name: "Sourcing Journal",
      url: "https://sourcingjournal.com/feed/",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.transportation]
  );

  static const justStyle = NewsSourceConfig(
      name: "Just-Style",
      url: "https://www.just-style.com/feed/",
      type: "Industry",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );

  static const wwd = NewsSourceConfig(
      name: "WWD",
      url: "https://wwd.com/feed/",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.retailTrade]
  );

  // --- CHEMICALS ---
  static const cenNews = NewsSourceConfig(
      name: "C&EN",
      url: "https://cen.acs.org/content/cen/global/en.feed.html",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.professionalServices]
  );

  static const chemicalWeek = NewsSourceConfig(
      name: "ChemWeek",
      url: "https://www.chemweek.com/rss",
      type: "Industry",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );

  static const epaNews = NewsSourceConfig(
      name: "EPA Releases",
      url: "https://www.epa.gov/newsreleases/search/rss",
      type: "Gov",
      tags: [Naics.publicAdmin, Naics.manufacturing]
  );

  static const icis = NewsSourceConfig(
      name: "ICIS News",
      url: "https://www.icis.com/explore/resources/news-feeds/",
      type: "Market Data",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );
}