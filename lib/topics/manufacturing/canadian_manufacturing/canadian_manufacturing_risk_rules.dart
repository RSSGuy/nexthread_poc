class CanadianManufacturingRiskRules {
  static const String rules = '''
    --- SECTION A: LABOR & WORKFORCE (High Weight) ---
    1. Skilled Trades Shortage: "Skills gap," "labor shortage," or "retiring workforce" indicates production capacity risks.
    2. Immigration Policy: Changes to "temporary foreign workers" or "immigration caps" affecting labor supply.
    3. Union Activity: Mentions of "Unifor," "strike," "collective bargaining," or "ratification" (e.g., Crown Royal dispute).

    --- SECTION B: SUPPLY CHAIN & TRADE ---
    4. EV Transition: "Electric Vehicle" mandates, "battery plant" investments (Stellantis, VW), or retooling costs.
    5. Critical Minerals: "Ring of Fire," "lithium," or "processing fund" news affecting raw material availability.
    6. Trade Barriers: "Tariffs" (especially China/USA), "CUSMA" renegotiations, or "Buy American" policies.

    --- SECTION C: TECHNOLOGY & INNOVATION ---
    7. AI Adoption: "Agentic AI," "automation," or "digital transformation" (e.g., Vention, Scale AI funding).
    8. Energy Costs: "Hydro rates," "carbon tax," or "net-zero" transition costs affecting margins.
  ''';
}