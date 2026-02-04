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

  // --- MANUFACTURING SOURCES ---

  static final NewsSourceConfig canadianMfg = NewsSourceConfig(
    name: "Cdn Manufacturing",
    url: "https://www.canadianmanufacturing.com/feed/",
      type: "News",
      tags: [Naics.manufacturing]
  );

  static final NewsSourceConfig plantMagazine = NewsSourceConfig(
    name: "Plant Magazine",
    url: "https://www.plant.ca/feed/",
      type: "News",
      tags: [Naics.manufacturing]
  );

  static final NewsSourceConfig industryWest = NewsSourceConfig(
    name: "Industry West",
    url: "https://industrywestmagazine.com/feed/",
      type: "News",
      tags: [Naics.manufacturing]
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


  // --- MINING & OIL/GAS ---
  static const miningDotCom = NewsSourceConfig(
      name: "Mining.com",
      url: "https://www.mining.com/feed/",
      type: "Trade",
      tags: [Naics.mining]
  );

  static const oilPrice = NewsSourceConfig(
      name: "OilPrice.com",
      url: "https://oilprice.com/rss/main",
      type: "Trade",
      tags: [Naics.mining, Naics.utilities]
  );

  static const eiaEnergy = NewsSourceConfig(
      name: "EIA Today",
      url: "https://www.eia.gov/rss/todayinenergy.xml",
      type: "Government",
      tags: [Naics.mining, Naics.utilities]
  );

  static const miningTechnology = NewsSourceConfig(
      name: "Mining Tech",
      url: "https://www.mining-technology.com/feed/",
      type: "Tech",
      tags: [Naics.mining, Naics.professionalServices]
  );

  static const worldOil = NewsSourceConfig(
      name: "World Oil",
      url: "https://www.worldoil.com/rss",
      type: "Trade",
      tags: [Naics.mining]
  );

  // --- UTILITIES & ENERGY ---
  static const utilityDive = NewsSourceConfig(
      name: "Utility Dive",
      url: "https://www.utilitydive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.utilities]
  );

  static const powerMag = NewsSourceConfig(
      name: "POWER Mag",
      url: "https://www.powermag.com/feed/",
      type: "Trade",
      tags: [Naics.utilities, Naics.construction]
  );

  static const renewableEnergyWorld = NewsSourceConfig(
      name: "Renewable Energy",
      url: "https://www.renewableenergyworld.com/feed/",
      type: "Tech",
      tags: [Naics.utilities, Naics.professionalServices]
  );

  static const energyStorageNews = NewsSourceConfig(
      name: "Energy Storage",
      url: "https://www.energy-storage.news/feed/",
      type: "Tech",
      tags: [Naics.utilities, Naics.manufacturing]
  );

  static const smartCitiesDive = NewsSourceConfig(
      name: "Smart Cities Dive",
      url: "https://www.smartcitiesdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.utilities, Naics.publicAdmin]
  );

  // --- CONSTRUCTION ---


  static const constrEquipGuide = NewsSourceConfig(
      name: "Const Equip Guide",
      url: "https://www.constructionequipmentguide.com/rss/news-feed",
      type: "Trade",
      tags: [Naics.construction, Naics.wholesaleTrade]
  );

  static const builderOnline = NewsSourceConfig(
      name: "Builder Online",
      url: "https://www.builderonline.com/rss/news",
      type: "Trade",
      tags: [Naics.construction, Naics.realEstate]
  );

  static const enrNews = NewsSourceConfig(
      name: "ENR",
      url: "https://www.enr.com/rss/news",
      type: "Trade",
      tags: [Naics.construction, Naics.professionalServices]
  );

  static const buildingDesign = NewsSourceConfig(
      name: "BD+C",
      url: "https://www.bdcnetwork.com/rss",
      type: "Trade",
      tags: [Naics.construction, Naics.professionalServices]
  );

  // --- MANUFACTURING ---
  static const mfgDive = NewsSourceConfig(
      name: "Manufacturing Dive",
      url: "https://www.manufacturingdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.manufacturing]
  );

  static const industryWeek = NewsSourceConfig(
      name: "IndustryWeek",
      url: "https://www.industryweek.com/rss",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.management]
  );

  static const foodDive = NewsSourceConfig(
      name: "Food Dive",
      url: "https://www.fooddive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.agriculture]
  );

  static const plasticsNews = NewsSourceConfig(
      name: "Plastics News",
      url: "https://www.plasticsnews.com/rss",
      type: "Trade",
      tags: [Naics.manufacturing]
  );

  static const thomasInsights = NewsSourceConfig(
      name: "Thomas Insights",
      url: "https://www.thomasnet.com/insights/rss",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );

  // --- WHOLESALE & RETAIL ---
  static const retailDive = NewsSourceConfig(
      name: "Retail Dive",
      url: "https://www.retaildive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.retailTrade]
  );

  static const wholesaleCentral = NewsSourceConfig(
      name: "Wholesale Central",
      url: "https://blog.wholesalecentral.com/feed/",
      type: "Trade",
      tags: [Naics.wholesaleTrade]
  );

  static const nrfRetail = NewsSourceConfig(
      name: "NRF",
      url: "https://nrf.com/rss.xml",
      type: "Trade",
      tags: [Naics.retailTrade, Naics.wholesaleTrade]
  );

  static const groceryDive = NewsSourceConfig(
      name: "Grocery Dive",
      url: "https://www.grocerydive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.retailTrade, Naics.agriculture]
  );

  static const retailWire = NewsSourceConfig(
      name: "RetailWire",
      url: "https://retailwire.com/feed/",
      type: "Trade",
      tags: [Naics.retailTrade]
  );

  // --- TRANSPORTATION & LOGISTICS ---
  static const supplyChainDive = NewsSourceConfig(
      name: "Supply Chain Dive",
      url: "https://www.supplychaindive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.transportation, Naics.wholesaleTrade]
  );

  static const transportDive = NewsSourceConfig(
      name: "Transport Dive",
      url: "https://www.transportdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.transportation]
  );

  static const freightWaves = NewsSourceConfig(
      name: "FreightWaves",
      url: "https://www.freightwaves.com/feed",
      type: "Trade",
      tags: [Naics.transportation]
  );

  static const truckingInfo = NewsSourceConfig(
      name: "Trucking Info",
      url: "https://www.truckinginfo.com/rss",
      type: "Trade",
      tags: [Naics.transportation]
  );

  static const logisticsMgmt = NewsSourceConfig(
      name: "Logistics Mgmt",
      url: "https://www.logisticsmgmt.com/rss",
      type: "Trade",
      tags: [Naics.transportation, Naics.management]
  );

  // --- INFORMATION & TECH ---
  static const techCrunch = NewsSourceConfig(
      name: "TechCrunch",
      url: "https://techcrunch.com/feed/",
      type: "Tech",
      tags: [Naics.information]
  );

  static const cioDive = NewsSourceConfig(
      name: "CIO Dive",
      url: "https://www.ciodive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.information, Naics.management]
  );

  static const vergeTech = NewsSourceConfig(
      name: "The Verge",
      url: "https://www.theverge.com/rss/index.xml",
      type: "Tech",
      tags: [Naics.information]
  );

  static const wiredBiz = NewsSourceConfig(
      name: "Wired Business",
      url: "https://www.wired.com/feed/category/business/latest/rss",
      type: "Tech",
      tags: [Naics.information, Naics.professionalServices]
  );

  static const infoWeek = NewsSourceConfig(
      name: "InformationWeek",
      url: "https://www.informationweek.com/rss.xml",
      type: "Tech",
      tags: [Naics.information]
  );

  // --- FINANCE & REAL ESTATE ---
  static const bankingDive = NewsSourceConfig(
      name: "Banking Dive",
      url: "https://www.bankingdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.finance]
  );

  static const cfoDive = NewsSourceConfig(
      name: "CFO Dive",
      url: "https://www.cfodive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.finance, Naics.management]
  );

  static const insuranceJournal = NewsSourceConfig(
      name: "Insurance Journal",
      url: "https://www.insurancejournal.com/rss/news",
      type: "Trade",
      tags: [Naics.finance]
  );

  static const housingWire = NewsSourceConfig(
      name: "HousingWire",
      url: "https://www.housingwire.com/feed/",
      type: "Trade",
      tags: [Naics.realEstate, Naics.finance]
  );

  static const multifamilyDive = NewsSourceConfig(
      name: "Multifamily Dive",
      url: "https://www.multifamilydive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.realEstate, Naics.construction]
  );

  static const inmanNews = NewsSourceConfig(
      name: "Inman",
      url: "https://www.inman.com/feed/",
      type: "Trade",
      tags: [Naics.realEstate]
  );

  // --- PROFESSIONAL SERVICES & MANAGEMENT ---
  static const legalDive = NewsSourceConfig(
      name: "Legal Dive",
      url: "https://www.legaldive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.professionalServices]
  );

  static const marketingDive = NewsSourceConfig(
      name: "Marketing Dive",
      url: "https://www.marketingdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.professionalServices]
  );

  static const consultingUs = NewsSourceConfig(
      name: "Consulting.us",
      url: "https://www.consulting.us/rss",
      type: "Trade",
      tags: [Naics.professionalServices, Naics.management]
  );

  static const hrDive = NewsSourceConfig(
      name: "HR Dive",
      url: "https://www.hrdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.adminSupport, Naics.management]
  );

  static const wasteDive = NewsSourceConfig(
      name: "Waste Dive",
      url: "https://www.wastedive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.adminSupport, Naics.utilities]
  );

  // --- HEALTHCARE & EDUCATION ---
  static const healthcareDive = NewsSourceConfig(
      name: "Healthcare Dive",
      url: "https://www.healthcaredive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.healthCare]
  );

  static const medtechDive = NewsSourceConfig(
      name: "MedTech Dive",
      url: "https://www.medtechdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.healthCare, Naics.manufacturing]
  );

  static const biopharmaDive = NewsSourceConfig(
      name: "BioPharma Dive",
      url: "https://www.biopharmadive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.healthCare, Naics.manufacturing]
  );

  static const k12Dive = NewsSourceConfig(
      name: "K-12 Dive",
      url: "https://www.k12dive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.education]
  );

  static const higherEdDive = NewsSourceConfig(
      name: "Higher Ed Dive",
      url: "https://www.highereddive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.education]
  );

  static const chronicleHigherEd = NewsSourceConfig(
      name: "Chronicle HE",
      url: "https://www.chronicle.com/rss",
      type: "Trade",
      tags: [Naics.education]
  );

  // --- ARTS, HOSPITALITY & OTHER ---
  static const hotelDive = NewsSourceConfig(
      name: "Hotel Dive",
      url: "https://www.hoteldive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.accommodation]
  );

  static const restaurantDive = NewsSourceConfig(
      name: "Restaurant Dive",
      url: "https://www.restaurantdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.accommodation]
  );

  static const variety = NewsSourceConfig(
      name: "Variety",
      url: "https://variety.com/feed/",
      type: "Trade",
      tags: [Naics.arts]
  );

  static const hollywoodReporter = NewsSourceConfig(
      name: "Hollywood Rptr",
      url: "https://www.hollywoodreporter.com/feed/",
      type: "Trade",
      tags: [Naics.arts]
  );

  static const artNews = NewsSourceConfig(
      name: "ARTnews",
      url: "https://www.artnews.com/feed/",
      type: "Trade",
      tags: [Naics.arts]
  );

  static const govTech = NewsSourceConfig(
      name: "GovTech",
      url: "https://www.govtech.com/rss",
      type: "Trade",
      tags: [Naics.publicAdmin, Naics.information]
  );

  static const googleNewsTest = NewsSourceConfig(
      name: "Google News Test",
      url: "https://news.google.com/rss/topics/CAAqKggKIiRDQkFTRlFvSUwyMHZNRGx6TVdZU0JXVnVMVWRDR2dKRFFTZ0FQAQ?hl=en-CA&gl=CA&ceid=CA%3Aen&oc=11?gl=CA&ceid=CA%253Aen&hl=en-CA",
      type: "News",
      tags: [Naics.publicAdmin, Naics.information,Naics.manufacturing, Naics.construction,]
  );

}





*/

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

  // --- MANUFACTURING SOURCES ---

  static final NewsSourceConfig canadianMfg = NewsSourceConfig(
      name: "Cdn Manufacturing",
      url: "https://www.canadianmanufacturing.com/feed/",
      type: "News",
      tags: [Naics.manufacturing]
  );

  static final NewsSourceConfig plantMagazine = NewsSourceConfig(
      name: "Plant Magazine",
      url: "https://www.plant.ca/feed/",
      type: "News",
      tags: [Naics.manufacturing]
  );

  static final NewsSourceConfig industryWest = NewsSourceConfig(
      name: "Industry West",
      url: "https://industrywestmagazine.com/feed/",
      type: "News",
      tags: [Naics.manufacturing]
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


  // --- MINING & OIL/GAS ---
  static const miningDotCom = NewsSourceConfig(
      name: "Mining.com",
      url: "https://www.mining.com/feed/",
      type: "Trade",
      tags: [Naics.mining]
  );

  static const oilPrice = NewsSourceConfig(
      name: "OilPrice.com",
      url: "https://oilprice.com/rss/main",
      type: "Trade",
      tags: [Naics.mining, Naics.utilities]
  );

  static const eiaEnergy = NewsSourceConfig(
      name: "EIA Today",
      url: "https://www.eia.gov/rss/todayinenergy.xml",
      type: "Government",
      tags: [Naics.mining, Naics.utilities]
  );

  static const miningTechnology = NewsSourceConfig(
      name: "Mining Tech",
      url: "https://www.mining-technology.com/feed/",
      type: "Tech",
      tags: [Naics.mining, Naics.professionalServices]
  );

  static const worldOil = NewsSourceConfig(
      name: "World Oil",
      url: "https://www.worldoil.com/rss",
      type: "Trade",
      tags: [Naics.mining]
  );

  // --- UTILITIES & ENERGY ---
  static const utilityDive = NewsSourceConfig(
      name: "Utility Dive",
      url: "https://www.utilitydive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.utilities]
  );

  static const powerMag = NewsSourceConfig(
      name: "POWER Mag",
      url: "https://www.powermag.com/feed/",
      type: "Trade",
      tags: [Naics.utilities, Naics.construction]
  );

  static const renewableEnergyWorld = NewsSourceConfig(
      name: "Renewable Energy",
      url: "https://www.renewableenergyworld.com/feed/",
      type: "Tech",
      tags: [Naics.utilities, Naics.professionalServices]
  );

  static const energyStorageNews = NewsSourceConfig(
      name: "Energy Storage",
      url: "https://www.energy-storage.news/feed/",
      type: "Tech",
      tags: [Naics.utilities, Naics.manufacturing]
  );

  static const smartCitiesDive = NewsSourceConfig(
      name: "Smart Cities Dive",
      url: "https://www.smartcitiesdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.utilities, Naics.publicAdmin]
  );

  // --- CONSTRUCTION ---


  static const constrEquipGuide = NewsSourceConfig(
      name: "Const Equip Guide",
      url: "https://www.constructionequipmentguide.com/rss/news-feed",
      type: "Trade",
      tags: [Naics.construction, Naics.wholesaleTrade]
  );

  static const builderOnline = NewsSourceConfig(
      name: "Builder Online",
      url: "https://www.builderonline.com/rss/news",
      type: "Trade",
      tags: [Naics.construction, Naics.realEstate]
  );

  static const enrNews = NewsSourceConfig(
      name: "ENR",
      url: "https://www.enr.com/rss/news",
      type: "Trade",
      tags: [Naics.construction, Naics.professionalServices]
  );

  static const buildingDesign = NewsSourceConfig(
      name: "BD+C",
      url: "https://www.bdcnetwork.com/rss",
      type: "Trade",
      tags: [Naics.construction, Naics.professionalServices]
  );

  // --- MANUFACTURING ---
  static const mfgDive = NewsSourceConfig(
      name: "Manufacturing Dive",
      url: "https://www.manufacturingdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.manufacturing]
  );

  static const industryWeek = NewsSourceConfig(
      name: "IndustryWeek",
      url: "https://www.industryweek.com/rss",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.management]
  );

  static const foodDive = NewsSourceConfig(
      name: "Food Dive",
      url: "https://www.fooddive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.agriculture]
  );

  static const plasticsNews = NewsSourceConfig(
      name: "Plastics News",
      url: "https://www.plasticsnews.com/rss",
      type: "Trade",
      tags: [Naics.manufacturing]
  );

  static const thomasInsights = NewsSourceConfig(
      name: "Thomas Insights",
      url: "https://www.thomasnet.com/insights/rss",
      type: "Trade",
      tags: [Naics.manufacturing, Naics.wholesaleTrade]
  );

  // --- WHOLESALE & RETAIL ---
  static const retailDive = NewsSourceConfig(
      name: "Retail Dive",
      url: "https://www.retaildive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.retailTrade]
  );

  static const wholesaleCentral = NewsSourceConfig(
      name: "Wholesale Central",
      url: "https://blog.wholesalecentral.com/feed/",
      type: "Trade",
      tags: [Naics.wholesaleTrade]
  );

  static const nrfRetail = NewsSourceConfig(
      name: "NRF",
      url: "https://nrf.com/rss.xml",
      type: "Trade",
      tags: [Naics.retailTrade, Naics.wholesaleTrade]
  );

  static const groceryDive = NewsSourceConfig(
      name: "Grocery Dive",
      url: "https://www.grocerydive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.retailTrade, Naics.agriculture]
  );

  static const retailWire = NewsSourceConfig(
      name: "RetailWire",
      url: "https://retailwire.com/feed/",
      type: "Trade",
      tags: [Naics.retailTrade]
  );

  // --- TRANSPORTATION & LOGISTICS ---
  static const supplyChainDive = NewsSourceConfig(
      name: "Supply Chain Dive",
      url: "https://www.supplychaindive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.transportation, Naics.wholesaleTrade]
  );

  static const transportDive = NewsSourceConfig(
      name: "Transport Dive",
      url: "https://www.transportdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.transportation]
  );

  static const freightWaves = NewsSourceConfig(
      name: "FreightWaves",
      url: "https://www.freightwaves.com/feed",
      type: "Trade",
      tags: [Naics.transportation]
  );

  static const truckingInfo = NewsSourceConfig(
      name: "Trucking Info",
      url: "https://www.truckinginfo.com/rss",
      type: "Trade",
      tags: [Naics.transportation]
  );

  static const logisticsMgmt = NewsSourceConfig(
      name: "Logistics Mgmt",
      url: "https://www.logisticsmgmt.com/rss",
      type: "Trade",
      tags: [Naics.transportation, Naics.management]
  );

  // --- INFORMATION & TECH ---
  static const techCrunch = NewsSourceConfig(
      name: "TechCrunch",
      url: "https://techcrunch.com/feed/",
      type: "Tech",
      tags: [Naics.information]
  );

  static const cioDive = NewsSourceConfig(
      name: "CIO Dive",
      url: "https://www.ciodive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.information, Naics.management]
  );

  static const vergeTech = NewsSourceConfig(
      name: "The Verge",
      url: "https://www.theverge.com/rss/index.xml",
      type: "Tech",
      tags: [Naics.information]
  );

  static const wiredBiz = NewsSourceConfig(
      name: "Wired Business",
      url: "https://www.wired.com/feed/category/business/latest/rss",
      type: "Tech",
      tags: [Naics.information, Naics.professionalServices]
  );

  static const infoWeek = NewsSourceConfig(
      name: "InformationWeek",
      url: "https://www.informationweek.com/rss.xml",
      type: "Tech",
      tags: [Naics.information]
  );

  // --- FINANCE & REAL ESTATE ---
  static const bankingDive = NewsSourceConfig(
      name: "Banking Dive",
      url: "https://www.bankingdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.finance]
  );

  static const cfoDive = NewsSourceConfig(
      name: "CFO Dive",
      url: "https://www.cfodive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.finance, Naics.management]
  );

  static const insuranceJournal = NewsSourceConfig(
      name: "Insurance Journal",
      url: "https://www.insurancejournal.com/rss/news",
      type: "Trade",
      tags: [Naics.finance]
  );

  static const housingWire = NewsSourceConfig(
      name: "HousingWire",
      url: "https://www.housingwire.com/feed/",
      type: "Trade",
      tags: [Naics.realEstate, Naics.finance]
  );

  static const multifamilyDive = NewsSourceConfig(
      name: "Multifamily Dive",
      url: "https://www.multifamilydive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.realEstate, Naics.construction]
  );

  static const inmanNews = NewsSourceConfig(
      name: "Inman",
      url: "https://www.inman.com/feed/",
      type: "Trade",
      tags: [Naics.realEstate]
  );

  // --- PROFESSIONAL SERVICES & MANAGEMENT ---
  static const legalDive = NewsSourceConfig(
      name: "Legal Dive",
      url: "https://www.legaldive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.professionalServices]
  );

  static const marketingDive = NewsSourceConfig(
      name: "Marketing Dive",
      url: "https://www.marketingdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.professionalServices]
  );

  static const consultingUs = NewsSourceConfig(
      name: "Consulting.us",
      url: "https://www.consulting.us/rss",
      type: "Trade",
      tags: [Naics.professionalServices, Naics.management]
  );

  static const hrDive = NewsSourceConfig(
      name: "HR Dive",
      url: "https://www.hrdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.adminSupport, Naics.management]
  );

  static const wasteDive = NewsSourceConfig(
      name: "Waste Dive",
      url: "https://www.wastedive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.adminSupport, Naics.utilities]
  );

  // --- HEALTHCARE & EDUCATION ---
  static const healthcareDive = NewsSourceConfig(
      name: "Healthcare Dive",
      url: "https://www.healthcaredive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.healthCare]
  );

  static const medtechDive = NewsSourceConfig(
      name: "MedTech Dive",
      url: "https://www.medtechdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.healthCare, Naics.manufacturing]
  );

  static const biopharmaDive = NewsSourceConfig(
      name: "BioPharma Dive",
      url: "https://www.biopharmadive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.healthCare, Naics.manufacturing]
  );

  static const k12Dive = NewsSourceConfig(
      name: "K-12 Dive",
      url: "https://www.k12dive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.education]
  );

  static const higherEdDive = NewsSourceConfig(
      name: "Higher Ed Dive",
      url: "https://www.highereddive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.education]
  );

  static const chronicleHigherEd = NewsSourceConfig(
      name: "Chronicle HE",
      url: "https://www.chronicle.com/rss",
      type: "Trade",
      tags: [Naics.education]
  );

  // --- ARTS, HOSPITALITY & OTHER ---
  static const hotelDive = NewsSourceConfig(
      name: "Hotel Dive",
      url: "https://www.hoteldive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.accommodation]
  );

  static const restaurantDive = NewsSourceConfig(
      name: "Restaurant Dive",
      url: "https://www.restaurantdive.com/feeds/news/",
      type: "Trade",
      tags: [Naics.accommodation]
  );

  static const variety = NewsSourceConfig(
      name: "Variety",
      url: "https://variety.com/feed/",
      type: "Trade",
      tags: [Naics.arts]
  );

  static const hollywoodReporter = NewsSourceConfig(
      name: "Hollywood Rptr",
      url: "https://www.hollywoodreporter.com/feed/",
      type: "Trade",
      tags: [Naics.arts]
  );

  static const artNews = NewsSourceConfig(
      name: "ARTnews",
      url: "https://www.artnews.com/feed/",
      type: "Trade",
      tags: [Naics.arts]
  );

  static const govTech = NewsSourceConfig(
      name: "GovTech",
      url: "https://www.govtech.com/rss",
      type: "Trade",
      tags: [Naics.publicAdmin, Naics.information]
  );

  static const googleNewsTest = NewsSourceConfig(
      name: "Google News Test",
      url: "https://news.google.com/rss/topics/CAAqKggKIiRDQkFTRlFvSUwyMHZNRGx6TVdZU0JXVnVMVWRDR2dKRFFTZ0FQAQ?hl=en-CA&gl=CA&ceid=CA%3Aen&oc=11?gl=CA&ceid=CA%253Aen&hl=en-CA",
      type: "News",
      tags: [Naics.publicAdmin, Naics.information,Naics.manufacturing, Naics.construction,]
  );

  // --- EXPOSED LIST FOR DIAGNOSTICS ---
  static List<NewsSourceConfig> get allSources => [
    // Global
    reutersCommodities, nytAgriculture, forbesAg,
    // Gov & Policy
    usdaGeneral, usdaForestService, nationalAgLaw, sustainableAgCoalition, calClimateAg,
    // AgTech
    globalAgTech, agritecture, urbanAgNews, cropAIA, pureGreens, agWired,
    // Machinery
    machineFinder, ktwoMachinery, padgilwar, estesConcaves,
    // Sustainability
    civilEats, modernFarmer, farmingFirst, understandingAg,
    // Livestock
    animalAgAlliance, westTexasLivestock, beefRunner, dairyCarrie, farmerAngus,
    // General Ag
    agWeb, agUpdate, agDaily, cropLife, proAg, westernProducer, lathamSeeds,
    // Regional
    agNetWest, californiaAgToday, farmtario, brownfieldAg, texasAgriLife,
    iowaAgLiteracy, mnFarmLiving, ffaIndiana, uvmAg,
    // International
    farmersAustralia, raynerAg, agriFarmingIn, krishiJagran, justAgriculture,
    accessAfrica, thriveAgric, agricIncome, grandmasterGlobal,
    // Research
    scienceDailyAg, saiFood, biodiversity,
    // Niche
    smallFarmersJournal, lifeAndAgri, farmersDaughter, harvie, episode3, agric4Profits,
    // Legacy
    foodBusinessNews, biofuelsNews,
    // Farms.com Suite
    farmsMachinery, farmsAll, farmsSwine, farmsCrop, farmsBeef,
    farmsFeaturedAll, farmsFeaturedCrop, farmsFeaturedBeeph,
    farmsCanadaWest, farmsCanadaEast, farmsFeaturedCanadaWest,
    farmsFeaturedCanadaEast, farmsFeaturedNews, farmsFeaturedHeadlines, farmsIndustryNews,
    // Lumber
    lbmJournal, constructionDive, madisonsReport,
    // Mfg / Apparel
    sourcingJournal, justStyle, wwd, canadianMfg, plantMagazine, industryWest,
    // Chemical
    cenNews, chemicalWeek, epaNews, icis,
    // Mining
    miningDotCom, oilPrice, eiaEnergy, miningTechnology, worldOil,
    // Utilities
    utilityDive, powerMag, renewableEnergyWorld, energyStorageNews, smartCitiesDive,
    // Construction
    constrEquipGuide, builderOnline, enrNews, buildingDesign,
    // Manufacturing General
    mfgDive, industryWeek, foodDive, plasticsNews, thomasInsights,
    // Wholesale/Retail
    retailDive, wholesaleCentral, nrfRetail, groceryDive, retailWire,
    // Transport
    supplyChainDive, transportDive, freightWaves, truckingInfo, logisticsMgmt,
    // Info / Tech
    techCrunch, cioDive, vergeTech, wiredBiz, infoWeek,
    // Finance
    bankingDive, cfoDive, insuranceJournal, housingWire, multifamilyDive, inmanNews,
    // Professional
    legalDive, marketingDive, consultingUs, hrDive, wasteDive,
    // Healthcare/Ed
    healthcareDive, medtechDive, biopharmaDive, k12Dive, higherEdDive, chronicleHigherEd,
    // Arts/Hosp
    hotelDive, restaurantDive, variety, hollywoodReporter, artNews, govTech,
    // Test
    googleNewsTest
  ];
}