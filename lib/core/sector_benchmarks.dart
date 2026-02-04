/*
import 'models.dart';

class SectorBenchmarks {

  // Internal map stores LISTS now
  static const Map<Naics, List<String>> _tickers = {
    Naics.agriculture: ["MOO"],

    // MINING NOW HAS TWO: Metals (XME) + Energy (XLE)
    Naics.mining: ["XME", "XLE"],

    Naics.utilities: ["XLU"],
    Naics.construction: ["ITB"],
    Naics.manufacturing: ["XLI"],
    Naics.wholesaleTrade: ["IYW"],
    Naics.retailTrade: ["XRT"],
    Naics.transportation: ["IYT"],
    Naics.information: ["VOX"],
    Naics.finance: ["XLF"],
    Naics.realEstate: ["XLRE"],
    Naics.professionalServices: ["IGV"],
    Naics.management: ["QUAL"],
    Naics.adminSupport: ["RBO"],
    Naics.education: ["LRN"],
    Naics.healthCare: ["XLV"],
    Naics.arts: ["PEJ"],
    Naics.accommodation: ["EATZ"],
    Naics.otherServices: ["IYC"],
    Naics.publicAdmin: ["GOVT"],
  };

  // --- LEGACY METHOD (The "If" Statement) ---
  // Existing topics call this. It safely returns just the FIRST ticker.
  static String getTicker(Naics industry) {
    return _tickers[industry]?.first ?? "ARKK";
  }

  // --- NEW METHOD (For General/Innovation Topics) ---
  // Returns ALL tickers so we can show Mining AND Energy
  static List<String> getAllTickers(Naics industry) {
    return _tickers[industry] ?? ["ARKK"];
  }
}*/

import 'models.dart';

class SectorBenchmarks {

  // UPDATED: Now maps Industry -> { Label : Ticker }
  // This supports the "Key Value Pair" approach you requested.
  static const Map<Naics, Map<String, String>> _benchmarks = {
    Naics.agriculture: {"Agriculture ETF": "MOO"},

    // MINING SPLIT: Explicitly labeled for clarity in analysis
    Naics.mining: {
      "Metals & Mining": "XME",
      "Energy Sector": "XLE"
    },

    Naics.utilities: {"Utilities": "XLU"},
    Naics.construction: {"Home Construction": "ITB",
      "State Street SPDR S&P Homebuilders ETF (XHB)": "XHB",
      "Invesco Building & Construction ET (PKB)": "PKB"
    },
    Naics.manufacturing: {"Industrial": "XLI"},
    Naics.wholesaleTrade: {"Technology": "IYW"}, // Proxy
    Naics.retailTrade: {"Retail": "XRT"},
    Naics.transportation: {"Transportation": "IYT"},
    Naics.information: {"Comms Services": "VOX"},
    Naics.finance: {"Financial": "XLF"},
    Naics.realEstate: {"Real Estate": "XLRE"},
    Naics.professionalServices: {"Software": "IGV"},
    Naics.management: {"Quality Factor": "QUAL"},
    Naics.adminSupport: {"Robotics": "RBO"},
    Naics.education: {"Education": "LRN"},
    Naics.healthCare: {"Health Care": "XLV"},
    Naics.arts: {"Leisure & Ent": "PEJ"},
    Naics.accommodation: {"Restaurants": "EATZ"},
    Naics.otherServices: {"Consumer Disc": "IYC"},
    Naics.publicAdmin: {"Treasuries": "GOVT"},
  };

  // --- NEW METHOD ---
  // Returns the map of {Label: Ticker}
  static Map<String, String> getBenchmarks(Naics industry) {
    return _benchmarks[industry] ?? {"General": "ARKK"};
  }
}