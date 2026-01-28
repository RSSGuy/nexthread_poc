class ApparelRiskRules {
  static const String rules = '''
    1. LABOR/ETHICS (Weight -9 to -10): Forced Labor allegations (Uyghur region), Sweatshop scandals, Strikes in Bangladesh/Vietnam.
    2. RAW MATERIALS (Weight -6 to -8): Cotton price spikes, Polyester/Oil costs, Dye shortages.
    3. LOGISTICS (Weight -5 to -7): Red Sea shipping delays (crucial for Asia->EU fashion), Port congestion.
    4. DEMAND/INVENTORY (Weight -7 to -9): Inventory glut (markups/discounting), Fast Fashion bans, Consumer spending slowdown.
    5. REGULATION (Weight -4 to -6): PFAS restrictions in textiles, Sustainability disclosure mandates (EU).
  ''';
}