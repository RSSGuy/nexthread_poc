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
}