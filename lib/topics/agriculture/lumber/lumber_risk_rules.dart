class LumberRiskRules {
  static const String rules = '''
    1. HOUSING/DEMAND (Weight -8 to -10): Housing Starts Crash, High Interest Rates, Mortgage Rates.
    2. SUPPLY/CLIMATE (Weight -7 to -9): Wildfires (Canada/US), Pine Beetle infestation, Flooding in logging zones.
    3. TRADE (Weight -6 to -8): Softwood Lumber Agreement, Tariffs, Export restrictions.
    4. LABOR/LOGISTICS (Weight -4 to -6): Mill closures, Rail car shortages, Trucking costs.
  ''';
}