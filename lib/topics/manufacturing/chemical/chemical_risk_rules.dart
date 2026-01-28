class ChemicalRiskRules {
  static const String rules = '''
    1. FEEDSTOCK COSTS (Weight -8 to -10): Natural Gas/Oil price spikes, Naptha shortages (margin compression).
    2. REGULATION/COMPLIANCE (Weight -7 to -9): PFAS bans ("Forever Chemicals"), REACH (EU) restrictions, EPA emissions crackdowns.
    3. SAFETY/ACCIDENTS (Weight -9 to -10): Plant explosions, Train derailments (hazmat), Chemical spills.
    4. SUPPLY CHAIN (Weight -5 to -7): Force Majeure declarations, Port congestion (specialty tankers).
    5. DEMAND (Weight -5 to -7): Construction slowdown (PVC), Automotive slowdown (Plastics/Coatings).
  ''';
}