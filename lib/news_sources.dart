class NewsSources {
  // Configuration for Agent A (Scraper)
  // Define specific feeds for NAICS 11 (Agriculture) and 311 (Food Mfg)

  static const List<Map<String, String>> targetSources = [
    {
      "name": "AgWeb (Farm Journal)",
      "url": "https://www.agweb.com/rss/all",
      "type": "Trade Journal"
    },
    {
      "name": "Reuters Commodities",
      "url": "https://www.reutersagency.com/feed/?best-topics=commodities&post_type=best",
      "type": "Global Macro"
    },
    {
      "name": "USDA Newsroom",
      "url": "https://www.usda.gov/rss/latest-releases.xml",
      "type": "Government"
    },
    {
      "name": "The Western Producer (Canada)",
      "url": "https://www.producer.com/feed/",
      "type": "Regional Niche"
    },
    {
      "name": "Food Business News",
      "url": "https://www.foodbusinessnews.net/rss/articles",
      "type": "Manufacturing (311)"
    },
    {
      "name": "biofuels-news",
      "url": "https://biofuels-news.com/feed/",
      "type": "Manufacturing (311)"
    }
  ];
}