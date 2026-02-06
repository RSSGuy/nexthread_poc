

import 'models.dart';

class SectorBenchmarks {

  // UPDATED: Now maps Industry -> { Label : Ticker }
  static const Map<Naics, Map<String, String>> _benchmarks = {
    Naics.agriculture: {"Agriculture ETF": "MOO"},
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
    Naics.adminSupport: {
      "Industrial Select Sector SPDR Fund XLI": "XLI",
      "Vanguard Industrials": "VIS",
      "iShares U.S. Industrials IYJ":"IYJ",
      "First Trust AlphaDEX™ U.S. Industrials Sector Index ETF (FHG)":"FHG"
    },
    Naics.education: {"Education": "LRN"},
    Naics.healthCare: {"Health Care": "XLV"},
    Naics.arts: {"Leisure & Ent": "PEJ"},
    Naics.accommodation: {"Restaurants": "EATZ"},
    Naics.otherServices: {"Consumer Disc": "IYC"},
    Naics.publicAdmin: {"Treasuries": "GOVT"},
  };

  // --- GLOBAL INDICES ---
  static const Map<String, String> globalIndices = {
    "S&P 500": "^GSPC",
    "Dow Jones Industrial Average": "^DJI",
    "NASDAQ Composite": "^IXIC",
    "NYSE Composite Index": "^NYA",
    "NYSE American Composite Index": "^XAX",
    "Cboe UK 100": "^BUK100P",
    "Russell 2000 Index": "^RUT",
    "CBOE Volatility Index": "^VIX",
    "FTSE 100": "^FTSE",
    "DAX P": "^GDAXI",
    "CAC 40": "^FCHI",
    "EURO STOXX 50 I": "^STOXX50E",
    "Euronext 100 Index": "^N100",
    "BEL 20": "^BFX",
    "MOEX Russia": "MOEX.ME",
    "HANG SENG INDEX": "^HSI",
    "STI Index": "^STI",
    "S&P/ASX 200": "^AXJO",
    "ALL ORDINARIES": "^AORD",
    "S&P BSE SENSEX": "^BSESN",
    "IDX COMPOSITE": "^JKSE",
    "FTSE Bursa Malaysia KLCI": "^KLSE",
    "S&P/NZX 50 INDEX GROSS": "^NZ50",
    "KOSPI Composite Index": "^KS11",
    "TWSE Capitalization Weighted Stock Index": "^TWII",
    "S&P/TSX Composite index": "^GSPTSE",
    "IBOVESPA": "^BVSP",
    "IPC MEXICO": "^MXX",
    "S&P IPSA": "^IPSA",
    "MERVAL": "^MERV",
    "TA-125": "^TA125.TA",
    "EGX 30 Price Return Index": "^CASE30",
    "Top 40 USD Net TRI Index": "^JN0U.JO",
    "US Dollar Index": "DX-Y.NYB",
    "MSCI EUROPE": "^125904-USD-STRD",
    "British Pound Currency Index": "^XDB",
    "Euro Currency Index": "^XDE",
    "SSE Composite Index": "000001.SS",
    "Nikkei 225": "^N225",
    "Japanese Yen Currency Index": "^XDN"
  };

  // --- METHODS ---
  static Map<String, String> getBenchmarks(Naics industry) {
    return _benchmarks[industry] ?? {"General": "ARKK"};
  }
}