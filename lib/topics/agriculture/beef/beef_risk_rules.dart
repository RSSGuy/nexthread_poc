class BeefRiskRules {
  static const String rules = '''
    --- SECTION A: BIOLOGICAL & DISEASE RISKS (Critical Weight -10) ---
    1. Foot and Mouth Disease (FMD): Any report of outbreaks, even rumors, in export zones.
    2. BSE (Mad Cow Disease): Atypical or classic cases detected in commercial herds.
    3. H5N1 (Avian Flu): Transmission to dairy or beef cattle herds.
    4. Lumpy Skin Disease: Spread in trading partner regions (Asia/Europe).
    5. Brucellosis/TB: Flare-ups causing quarantine of specific regions.
    6. Anthrax: Localized outbreaks affecting herd mortality.
    7. Screw-worm: Re-emergence in Central/North America.
    8. Mass Mortality Events: Unexplained die-offs reported in feedlots.

    --- SECTION B: INPUTS & FEED COSTS (High Weight -8) ---
    9. Corn Price Surge: Corn futures exceeding \$6.00/bu (Feed ratio pressure).
    10. Hay Scarcity: Alfalfa/Hay price spikes or low inventory reports.
    11. Soy Meal Costs: Rising protein supplement costs squeezing margins.
    12. Fertilizer Spikes: High NPK prices reducing pasture quality/yield.
    13. Diesel/Energy Costs: Rising transport and machinery operation costs.
    14. Water Rights: Regulatory cuts to irrigation for feed crops.
    15. Labor Shortages: Lack of ranch hands or feedlot operators.

    --- SECTION C: CLIMATE & WEATHER (High Weight -8) ---
    16. Severe Drought: D3/D4 drought classification in Plains/Western regions.
    17. Heat Domes: Extreme heat stress causing feedlot mortality or weight loss.
    18. Winter Blizzards: Deep freeze events killing calves or preventing transport.
    19. Flooding: Inundation of grazing lands or feedlot infrastructure.
    20. Wildfires: Destruction of pasture fencing and forage.
    21. Pasture Condition: USDA ratings showing "Poor" or "Very Poor" > 30%.
    22. Water Table Depletion: Wells running dry in key cattle states (TX, KS, NE).

    --- SECTION D: GEOPOLITICAL & TRADE (Medium Weight -6) ---
    23. China Import Bans: Suspensions due to political tension or sanitary issues.
    24. Brazil Export Surge: Cheap supply flooding global markets (dumping).
    25. Border Closures: Mexico/Canada border friction (e.g., transport blockades).
    26. Tariffs: New duties imposed by major importers (Japan, Korea).
    27. Currency Strength: Strong USD making US beef uncompetitive abroad.
    28. Trade Deal Collapses: Failure to renew or ratify trade agreements.

    --- SECTION E: DEMAND & ECONOMY (Medium Weight -5) ---
    29. Recession Fears: Consumers "trading down" to ground beef, pork, or chicken.
    30. Steak Inflation: High retail prices reducing restaurant traffic.
    31. Inventory Liquidation: Herd contraction due to financial stress (short-term supply glut).
    32. High Interest Rates: Operating loans becoming too expensive for ranchers.
    33. Plant-Based Competitors: Major fast-food chains adopting fake meat options.
    34. Lab-Grown Approval: Regulatory clearance for cultured meat sales.

    --- SECTION F: REGULATORY & SUPPLY CHAIN (Medium Weight -5) ---
    35. Methane Taxes: Government proposals to tax cattle emissions.
    36. COOL (Labeling): Disputes over "Country of Origin Labeling" creating trade friction.
    37. Packer Consolidation: Antitrust lawsuits or investigations into "Big 4" packers.
    38. Logistics Failures: Trucking shortages or rail strikes stranding cattle.
    39. Antibiotic Bans: Restrictions on growth-promoting drugs affecting efficiency.
    40. Animal Welfare Laws: strict confinement regulations (e.g., Prop 12 style).

    --- SECTION G: EMERGING TRENDS & OPPORTUNITIES (Positive/Neutral) ---
    41. Low Carbon Beef: Premiums for "Climate Smart" or low-emission certified beef.
    42. Regenerative Grazing: Carbon credit revenue streams for ranchers.
    43. Export Growth (SE Asia): Rising demand in Vietnam, Indonesia, Philippines.
    44. Wagyu/Premiumization: High-margin cross-breeding gaining market share.
    45. Traceability Tech: Blockchain/RFID adoption for premium export verification.
    46. Precision Livestock Farming: AI/Sensors monitoring herd health/estrus.
    47. Methane Additives: Feed supplements (seaweed/3-NOP) reducing emissions.
    48. Direct-to-Consumer: Growth in "Box Beef" subscriptions and local sales.
    49. Sustainable Leather: Resurgence in demand for natural, traceable hides.
    50. Robotic Processing: Automation in packing plants reducing labor reliance.
    51. Halal Certification: Expanding access to Middle Eastern markets.
    52. Vertical Integration: Retailers (e.g., Walmart) owning supply chain steps.
  ''';
}