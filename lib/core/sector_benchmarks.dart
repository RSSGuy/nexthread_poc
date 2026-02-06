
/*

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
}*/
/*
import 'models.dart';

class SectorBenchmarks {

  // UPDATED: Expanded to ~4 tickers per NAICS industry
  // Maps Industry -> { Label : Ticker }
  static const Map<Naics, Map<String, String>> _benchmarks = {
    Naics.agriculture: {
      "Agribusiness ETF": "MOO",
      "Invesco DB Agriculture": "DBA",
      "Teucrium Wheat": "WEAT",
      "Teucrium Corn": "CORN"
    },
    Naics.mining: {
      "Metals & Mining": "XME",
      "Energy Select Sector": "XLE",
      "iShares Global Mining": "PICK",
      "Global X Copper Miners": "COPX"
    },
    Naics.utilities: {
      "Utilities Select Sector": "XLU",
      "Vanguard Utilities": "VPU",
      "iShares U.S. Utilities": "IDU",
      "Fidelity MSCI Utilities": "FUTY"
    },
    Naics.construction: {
      "Home Construction": "ITB",
      "SPDR Homebuilders": "XHB",
      "Invesco Building & Const": "PKB",
      "Global X US Infrastructure": "PAVE"
    },
    Naics.manufacturing: {
      "Industrial Select Sector": "XLI",
      "Vanguard Industrials": "VIS",
      "Fidelity MSCI Industrials": "FIDU",
      "iShares U.S. Industrials": "IYJ"
    },
    Naics.wholesaleTrade: {
      "Industrial Select": "XLI", // Wholesale often tracks with broad industrials
      "VanEck Retail (Distributors)": "RTH",
      "Sysco Corp (Food Dist)": "SYY",
      "McKesson (Med Dist)": "MCK"
    },
    Naics.retailTrade: {
      "SPDR S&P Retail": "XRT",
      "VanEck Retail": "RTH",
      "Vanguard Consumer Disc": "VCR",
      "Fidelity Consumer Disc": "FDIS"
    },
    Naics.transportation: {
      "iShares Transportation": "IYT",
      "SPDR S&P Transportation": "XTN",
      "US Global Jets": "JETS",
      "SonicShares Global Shipping": "BOAT"
    },
    Naics.information: {
      "Communication Services": "VOX",
      "Technology Select Sector": "XLK",
      "Fidelity Telecom": "FCOM",
      "iShares Global Tech": "IXN"
    },
    Naics.finance: {
      "Financial Select Sector": "XLF",
      "Vanguard Financials": "VFH",
      "SPDR S&P Bank": "KBE",
      "SPDR Regional Banking": "KRE"
    },
    Naics.realEstate: {
      "Real Estate Select Sector": "XLRE",
      "Vanguard Real Estate": "VNQ",
      "iShares U.S. Real Estate": "IYR",
      "Global REIT": "REET"
    },
    Naics.professionalServices: {
      "Software (Proxy)": "IGV",
      "SPDR Software & Services": "XSW",
      "Accenture (Consulting)": "ACN",
      "Marsh & McLennan": "MMC"
    },
    Naics.management: {
      "Quality Factor": "QUAL",
      "Vanguard Mega Cap": "MGC",
      "S&P 100 Giant": "OEF",
      "Dow Jones Industrial": "DIA"
    },
    Naics.adminSupport: {
      "Industrial Select Sector": "XLI",
      "Vanguard Industrials": "VIS",
      "iShares U.S. Industrials": "IYJ",
      "First Trust AlphaDEX Ind": "FHG"
    },
    Naics.education: {
      "Stride Inc": "LRN",
      "Adtalem Global Ed": "ATGE",
      "Chegg Inc": "CHGG",
      "New Oriental Ed": "EDU"
    },
    Naics.healthCare: {
      "Health Care Select Sector": "XLV",
      "Vanguard Health Care": "VHT",
      "iShares Biotechnology": "IBB",
      "iShares Medical Devices": "IHI"
    },
    Naics.arts: {
      "Leisure & Entertainment": "PEJ",
      "Live Nation Ent": "LYV",
      "Walt Disney Co": "DIS",
      "VanEck Gaming": "BJK"
    },
    Naics.accommodation: {
      "Restaurants & Hotels": "EATZ",
      "Marriott International": "MAR",
      "Hilton Worldwide": "HLT",
      "Airbnb Inc": "ABNB"
    },
    Naics.otherServices: {
      "Consumer Discretionary": "IYC",
      "Select Sector Cons Disc": "XLY",
      "Vanguard Cons Disc": "VCR",
      "Invesco Leisure": "PEJ"
    },
    Naics.publicAdmin: {
      "US Treasury Bond": "GOVT",
      "Short Treasury": "SHV",
      "20+ Year Treasury": "TLT",
      "1-3 Month T-Bill": "BIL"
    },
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
    return _benchmarks[industry] ?? {"General Innovation": "ARKK"};
  }
}*/

import 'models.dart';

class SectorBenchmarks {

  // UPDATED: Added Sea Freight and Couriers to Transportation.
  // Maps Industry -> { Label : Ticker }
  static const Map<Naics, Map<String, String>> _benchmarks = {
    Naics.agriculture: {
      // Equities
      "US Agribusiness (MOO)": "MOO",
      "Canada Global Ag (COW.TO)": "COW.TO",
      "Nutrien Ltd (Canada)": "NTR.TO",
      "Invesco DB Agriculture (Global)": "DBA",
      // Commodities
      "Corn Futures": "ZC=F",
      "Wheat Futures": "ZW=F",
      "Soybean Futures": "ZS=F",
      "Live Cattle": "LE=F",
      "Coffee": "KC=F"
    },
    Naics.mining: {
      // Equities
      "US Energy (XLE)": "XLE",
      "Canada Energy (XEG.TO)": "XEG.TO",
      "Global Mining (PICK)": "PICK",
      "Rio Tinto (Intl)": "RIO",
      // Commodities
      "Crude Oil WTI": "CL=F",
      "Natural Gas": "NG=F",
      "Gold Futures": "GC=F",
      "Silver Futures": "SI=F",
      "Copper Futures": "HG=F"
    },
    Naics.utilities: {
      "US Utilities (XLU)": "XLU",
      "Canada Utilities (XUT.TO)": "XUT.TO",
      "National Grid (UK/Intl)": "NGG",
      "Fortis Inc (Canada)": "FTS.TO"
    },
    Naics.construction: {
      "US Home Construction (ITB)": "ITB",
      "Stantec Inc (Canada)": "STN.TO",
      "Global Infrastructure (PAVE)": "PAVE",
      "CRH Plc (Ireland)": "CRH"
    },
    Naics.manufacturing: {
      // General Industrial
      "US Industrial (XLI)": "XLI",
      "Magna International (Canada)": "MG.TO",
      "Toyota Motor (Japan)": "TM",
      "Eaton Corp (Global)": "ETN",
      // Semiconductors
      "Semiconductor ETF (SMH)": "SMH",
      "TSMC (Taiwan)": "TSM",
      "ASML Holding (Netherlands)": "ASML",
      "Intel Corp (US)": "INTC"
    },
    Naics.wholesaleTrade: {
      "Costco Wholesale (US)": "COST",
      "Fastenal (US)": "FAST",
      "Loblaw Companies (Canada)": "L.TO",
      "Ferguson Plc (UK)": "FERG",
      "W.W. Grainger (US)": "GWW"
    },
    Naics.retailTrade: {
      "US Retail (XRT)": "XRT",
      "Alimentation Couche-Tard (Canada)": "ATD.TO",
      "Alibaba Group (China)": "BABA",
      "Home Depot (US)": "HD",
      "Dollarama Inc (Canada)": "DOL.TO",
    },
    Naics.transportation: {
      // General & Rail
      "US Transportation (IYT)": "IYT",
      "CN Railway (Canada)": "CNR.TO",
      "CPKC Railway (Canada/US)": "CP.TO",
      // Couriers & Logistics
      "FedEx Corp (US)": "FDX",
      "United Parcel Service (US)": "UPS",
      "Deutsche Post DHL (Intl)": "DHL.DE",
      // Sea Freight
      "Maersk (Sea Freight)": "AMKBY",
      "Global Shipping ETF (BOAT)": "BOAT"
    },
    Naics.information: {
      "US Technology (XLK)": "XLK",
      "Constellation Software (Canada)": "CSU.TO",
      "TSMC (Taiwan)": "TSM",
      "Shopify (Canada/US)": "SHOP"
    },
    Naics.finance: {
      "US Financials (XLF)": "XLF",
      "Royal Bank (Canada)": "RY.TO",
      "HDFC Bank (India)": "HDB",
      "iShares Global Financials": "IXG"
    },
    Naics.realEstate: {
      "US Real Estate (XLRE)": "XLRE",
      "Canada REITs (XRE.TO)": "XRE.TO",
      "Global REIT ETF": "REET",
      "CAPREIT (Canada)": "CAR-UN.TO"
    },
    Naics.professionalServices: {
      "Accenture (Global)": "ACN",
      "Thomson Reuters (Canada)": "TRI.TO",
      "US Software (IGV)": "IGV",
      "RELX Plc (UK)": "RELX"
    },
    Naics.management: {
      "Berkshire Hathaway (US)": "BRK-B",
      "Brookfield Corp (Canada)": "BN.TO",
      "BlackRock (US)": "BLK",
      "Global 100 ETF": "IOO"
    },
    Naics.adminSupport: {
      "Cintas Corp (US)": "CTAS",
      "GFL Environmental (Canada)": "GFL.TO",
      "Waste Connections (CA/US)": "WCN",
      "Rollins Inc (US)": "ROL"
    },
    Naics.education: {
      "Stride Inc (US)": "LRN",
      "Pearson Plc (UK)": "PSON",
      "New Oriental (China)": "EDU",
      "PowerSchool (US)": "PWSC"
    },
    Naics.healthCare: {
      "US Health Care (XLV)": "XLV",
      "Novartis AG (Swiss)": "NVS",
      "AstraZeneca (UK)": "AZN",
      "Bausch + Lomb (Canada)": "BLCO"
    },
    Naics.arts: {
      "Disney (Global)": "DIS",
      "Sony Group (Japan)": "SONY",
      "Cineplex Inc (Canada)": "CGX.TO",
      "Live Nation (US)": "LYV"
    },
    Naics.accommodation: {
      "Marriott Intl (Global)": "MAR",
      "Rest. Brands Intl (Canada)": "QSR.TO",
      "InterContinental (UK)": "IHG",
      "Booking Holdings (US)": "BKNG"
    },
    Naics.otherServices: {
      "US Consumer Disc (IYC)": "IYC",
      "Starbucks (Global)": "SBUX",
      "Premium Brands (Canada)": "PBH.TO",
      "Unilever (UK)": "UL"
    },
    Naics.publicAdmin: {
      "US Treasury (GOVT)": "GOVT",
      "Canada Bonds (XGB.TO)": "XGB.TO",
      "Intl Treasury (IGOV)": "IGOV",
      "US 20+ Year Bond (TLT)": "TLT"
    },
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
    return _benchmarks[industry] ?? {"General Innovation": "ARKK"};
  }
}