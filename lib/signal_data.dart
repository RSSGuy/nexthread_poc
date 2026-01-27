/*
class SignalData {
  static const Map<String, List<Map<String, String>>> matrix = {
    "311 Food Mfg": [
      { "signal": "Black Sea Grain Initiative", "type": "Geo-Political", "polarity": "+/-", "weight": "0" },
      { "signal": "Protectionist Export Bans", "type": "Trade", "polarity": "-", "weight": "-5" },
      { "signal": "Packaging Cost Spike", "type": "Inputs", "polarity": "-", "weight": "-2" },
      { "signal": "Sugar/Cocoa Deficit", "type": "Supply", "polarity": "-", "weight": "-4" }
    ],
    "Logistics & Infra": [
      { "signal": "Panama Canal Draft Restrictions", "type": "Climate/Infra", "polarity": "-", "weight": "-3" },
      { "signal": "Red Sea / Suez Disruptions", "type": "Geo-Political", "polarity": "-", "weight": "-5" },
      { "signal": "ILA Port Strikes (East Coast)", "type": "Labor", "polarity": "-", "weight": "-8" },
      { "signal": "Rail Stoppages (Canada/US)", "type": "Labor", "polarity": "-", "weight": "-6" }
    ],
    "Inputs & Energy": [
      { "signal": "Natural Gas (Fertilizer Feedstock)", "type": "Energy", "polarity": "-", "weight": "-4" },
      { "signal": "Diesel Price Volatility", "type": "Energy", "polarity": "-", "weight": "-3" },
      { "signal": "Potash/Phosphate Shortage", "type": "Inputs", "polarity": "-", "weight": "-5" }
    ],
    "Climate & Bio": [
      { "signal": "El Nino / La Nina Transition", "type": "Climate", "polarity": "+/-", "weight": "0" },
      { "signal": "Aquifer Depletion (Ogallala)", "type": "Climate", "polarity": "-", "weight": "-2" },
      { "signal": "Avian Flu (H5N1) Spread", "type": "Bio-Threat", "polarity": "-", "weight": "-9" },
      { "signal": "African Swine Fever (ASF)", "type": "Bio-Threat", "polarity": "-", "weight": "-10" }
    ]
  };

  static const List<Map<String, dynamic>> divergenceGlossary = [
    {
      "category": "Buying Opportunities (Green)",
      "items": [
        { "tag": "Unjustified Panic", "desc": "Market is scared, but data proves supply is fine. Sentiment is low, Facts are high." },
        { "tag": "Margin Padding", "desc": "Suppliers' costs dropped, but they haven't lowered prices." },
        { "tag": "Sector Split", "desc": "One niche is booming/crashing, but the market generalizes it to the whole sector." }
      ]
    },
    {
      "category": "Risk Warnings (Red)",
      "items": [
        { "tag": "Over-Ordering", "desc": "Panic-hoarding creating a demand bubble. Buying is high, actual usage is low." },
        { "tag": "Over-Confidence", "desc": "Market is too bullish despite rotting fundamentals." }
      ]
    }
  ];
}*/
class SignalData {
  // ==============================================================================
  // 1. MASTER DATA LISTS (The Raw Ingredients)
  // ==============================================================================

  static const List<String> _foodCommodities = [
    // Grains
    "Hard Red Winter Wheat", "Soft Red Winter Wheat", "Durum Wheat", "Spring Wheat",
    "Yellow Corn", "White Corn", "Soybeans", "Soybean Meal", "Soybean Oil",
    "Rough Rice", "Milled Rice", "Basmati Rice", "Oats", "Barley", "Sorghum",
    "Canola", "Rapeseed", "Palm Oil", "Sunflower Oil", "Distillers Grains (DDGS)",
    // Softs
    "Raw Sugar #11", "White Sugar", "Cocoa Butter", "Cocoa Powder", "Arabica Coffee",
    "Robusta Coffee", "Orange Juice Concentrate", "Cotton", "Wool", "Lumber",
    // Livestock & Dairy
    "Live Cattle", "Feeder Cattle", "Lean Hogs", "Pork Bellies", "Class III Milk",
    "Class IV Milk", "Nonfat Dry Milk", "Butter", "Cheddar Cheese", "Whey Protein",
    "Broiler Chickens", "Turkeys", "Eggs (Shell)", "Eggs (Liquid)",
    // Seafood
    "Farm Raised Salmon", "Wild Caught Salmon", "Shrimp", "Tilapia", "Tuna", "Pollock",
    // Produce / Nuts / Specialty
    "Almonds", "Walnuts", "Pistachios", "Cashews", "Peanuts", "Hazelnuts",
    "Tomatoes (Processing)", "Potatoes (Russet)", "Onions", "Garlic", "Apples",
    "Bananas", "Avocados", "Olive Oil (Extra Virgin)", "Honey", "Vanilla Beans",
    "Black Pepper", "Mustard Seed", "Lecithin", "Guar Gum", "Corn Syrup (HFCS)"
  ];

  static const List<String> _logisticsAssets = [
    // Maritime Chokepoints
    "Panama Canal", "Suez Canal", "Strait of Hormuz", "Strait of Malacca",
    "Bab el-Mandeb", "Bosporus Strait", "Dardanelles", "Cape of Good Hope",
    // Major Global Ports
    "Port of Shanghai", "Port of Singapore", "Port of Ningbo-Zhoushan", "Port of Shenzhen",
    "Port of Busan", "Port of Rotterdam", "Port of Antwerp-Bruges", "Port of Hamburg",
    "Port of Los Angeles", "Port of Long Beach", "Port of NY/NJ", "Port of Savannah",
    "Port of Houston", "Port of Vancouver", "Port of Prince Rupert", "Port of Santos (Brazil)",
    "Port of Rosario (Argentina)", "Port of Odessa", "Port of Novorossiysk",
    // Inland Waterways
    "Mississippi River", "Rhine River", "Danube River", "Yangtze River", "Mekong River",
    "Parana River", "St. Lawrence Seaway",
    // Rail & Road
    "CN Rail", "CPKC Rail", "Union Pacific", "BNSF", "CSX", "Norfolk Southern",
    "Eurotunnel", "Trans-Siberian Railway", "US Trucking", "Teamsters Union"
  ];

  static const List<String> _inputsAndEnergy = [
    // Energy
    "Brent Crude", "WTI Crude", "Natural Gas (Henry Hub)", "Natural Gas (Dutch TTF)",
    "Diesel Fuel", "Jet Fuel", "Bunker Fuel", "Electricity (Industrial)",
    // Fertilizers & Chemicals
    "Anhydrous Ammonia", "Urea", "UAN-28", "UAN-32", "DAP (Diammonium Phosphate)",
    "MAP (Monoammonium Phosphate)", "Potash (MOP)", "Phosphate Rock", "Sulfur",
    "Sulfuric Acid", "Glyphosate", "Glufosinate", "Atrazine", "Dicamba", "Fungicides",
    // AgTech & Hard Goods
    "Farm Tires", "Tractors", "Combine Harvesters", "Semiconductors (AgTech)",
    "Corrugated Cardboard", "Plastic Resin (PET)", "Glass Jars", "Aluminum Cans",
    "Steel Drums", "Wooden Pallets"
  ];

  static const List<String> _regionsAndClimate = [
    // North America
    "US Midwest Corn Belt", "US Southern Plains", "California Central Valley",
    "US Delta Region", "Canadian Prairies", "Ogallala Aquifer",
    // South America
    "Brazil Mato Grosso", "Brazil Parana", "Argentina Pampas", "Amazon Basin",
    // Europe/Black Sea
    "Ukraine Black Sea Steppe", "Russia Southern District", "France Wheat Belt",
    "Germany Rhine Valley", "Spain Andalusia", "Italy Po Valley",
    // Asia/Oceania
    "China North China Plain", "India Punjab", "India Monsoon Belt",
    "Australia Murray-Darling Basin", "Indonesia Palm Belt", "Malaysia Palm Belt",
    "Vietnam Mekong Delta", "Thailand Rice Belt"
  ];

  // ==============================================================================
  // 2. RISK VECTORS (The Multipliers)
  // ==============================================================================

  static const List<String> _supplyRisks = [
    "Shortage", "Stockpile Depletion", "Harvest Failure", "Yield Drag",
    "Quality Degradation", "Contamination", "Recall", "Spoilage"
  ];

  static const List<String> _tradeRisks = [
    "Export Ban", "Import Tariff", "Quota Reduction", "Sanctions",
    "Trade War", "Border Closure", "Currency Crisis"
  ];

  static const List<String> _logisticsRisks = [
    "Port Strike", "Rail Strike", "Low Water Levels", "Draft Restrictions",
    "Congestion", "Cyberattack", "Vessel Grounding", "Bridge Collapse",
    "Container Shortage", "Freight Rate Spike"
  ];

  static const List<String> _climateRisks = [
    "Flash Drought", "Extreme Heat / Heat Dome", "Frost / Freeze Event",
    "Flooding", "Hurricane / Typhoon", "Wildfire Smoke", "Hail Damage",
    "El Nino Impact", "La Nina Impact", "Groundwater Depletion"
  ];

  static const List<String> _bioRisks = [
    "Avian Flu (H5N1)", "African Swine Fever (ASF)", "Foot and Mouth Disease",
    "Rust Fungus", "Locust Plague", "Armyworm Infestation", "Citrus Greening"
  ];

  // ==============================================================================
  // 3. GENERATOR LOGIC
  // ==============================================================================

  static Map<String, List<Map<String, String>>> get matrix {
    return {
      "311 Food Mfg": [
        // Priority Hardcoded
        { "signal": "Black Sea Grain Initiative Suspension", "type": "Geo-Political", "polarity": "-", "weight": "-8" },
        { "signal": "India Rice Export Ban", "type": "Trade", "polarity": "-", "weight": "-9" },
        // Generated Combinations (Approx 1000+)
        ..._combine(_foodCommodities, _supplyRisks, "Supply", "-", -5),
        ..._combine(_foodCommodities, _tradeRisks, "Trade", "-", -7),
        ..._combine(_foodCommodities, ["Price Spike", "Margin Squeeze"], "Price", "-", -4),
      ],

      "Logistics & Infra": [
        // Priority Hardcoded
        { "signal": "Red Sea Missile Attacks", "type": "Geo-Political", "polarity": "-", "weight": "-10" },
        { "signal": "ILA East Coast Port Negotiations", "type": "Labor", "polarity": "-", "weight": "-8" },
        // Generated Combinations (Approx 1000+)
        ..._combine(_logisticsAssets, _logisticsRisks, "Logistics", "-", -6),
        ..._combine(_logisticsAssets, ["Closure", "Blockage"], "Infra", "-", -10),
      ],

      "Inputs & Energy": [
        // Priority Hardcoded
        { "signal": "China Phosphate Export Quota", "type": "Trade", "polarity": "-", "weight": "-6" },
        { "signal": "European Natural Gas Storage Critical", "type": "Energy", "polarity": "-", "weight": "-5" },
        // Generated Combinations (Approx 1000+)
        ..._combine(_inputsAndEnergy, _supplyRisks, "Supply", "-", -6),
        ..._combine(_inputsAndEnergy, ["Price Surge", "Volatility"], "Price", "-", -4),
        ..._combine(_inputsAndEnergy, _tradeRisks, "Trade", "-", -5),
      ],

      "Climate & Bio": [
        // Generated Combinations (Approx 1000+)
        ..._combine(_regionsAndClimate, _climateRisks, "Climate", "-", -7),
        // Bio risks apply generally to regions or specific livestock
        ..._combine(["Global Poultry", "Global Swine", "Global Cattle", ..._regionsAndClimate], _bioRisks, "Bio-Threat", "-", -9),
      ]
    };
  }

  // --- Helper to Generate Combinations ---
  static List<Map<String, String>> _combine(List<String> items, List<String> risks, String type, String polarity, int weight) {
    List<Map<String, String>> results = [];
    for (var item in items) {
      for (var risk in risks) {
        results.add({
          "signal": "$item $risk",
          "type": type,
          "polarity": polarity,
          "weight": weight.toString()
        });
      }
    }
    return results;
  }

  // --- 4. GLOSSARY ---
  static const List<Map<String, dynamic>> divergenceGlossary = [
    {
      "category": "Buying Opportunities (Green)",
      "items": [
        { "tag": "Unjustified Panic", "desc": "Market is scared, but data proves supply is fine. Sentiment is low, Facts are high." },
        { "tag": "Margin Padding", "desc": "Suppliers' costs dropped, but they haven't lowered prices." },
        { "tag": "Sector Split", "desc": "One niche is booming/crashing, but the market generalizes it to the whole sector." }
      ]
    },
    {
      "category": "Risk Warnings (Red)",
      "items": [
        { "tag": "Over-Ordering", "desc": "Panic-hoarding creating a demand bubble. Buying is high, actual usage is low." },
        { "tag": "Over-Confidence", "desc": "Market is too bullish despite rotting fundamentals." },
        { "tag": "Supply Shock", "desc": "Physical availability has dropped significantly despite neutral sentiment." },
        { "tag": "Cascading Failure", "desc": "A disruption in one node (e.g. Panama Canal) causes failure in dependent nodes (e.g. East Coast Ports)." }
      ]
    }
  ];
}