// lib/topics/mining/oil_gas/oil_gas_risk_rules.dart

const String oilGasRiskRules = """
# OIL & GAS SECTOR RISK ANALYSIS PROTOCOL

## 1. PRICE VOLATILITY & CRITICAL THRESHOLDS
- **Crude Oil (WTI/Brent)**:
  - Daily moves > 3% are SIGNIFICANT.
  - Weekly moves > 5% indicate TREND SHIFT.
  - Sustained prices > \$90/bbl triggers INFLATIONARY RISK.
  - Sustained prices < \$60/bbl triggers PRODUCER STRESS (Capex cuts).

## 2. SUPPLY CHAIN & GEOPOLITICAL FACTORS
- **OPEC+ Activity**: Any unplanned production cuts or disagreements are HIGH IMPACT.
- **Strategic Reserves (SPR)**: Significant releases or refills alter short-term supply dynamics.
- **Infrastructure**: Pipeline leaks, refinery outages, or tanker blockages are IMMEDIATE RISKS.

## 3. INVENTORY LEVELS
- Compare EIA (Energy Information Administration) weekly inventory reports against 5-year averages.
- **Low Inventory**: Supports BULLISH price action (Risk of squeeze).
- **High Inventory**: Supports BEARISH price action (Oversupply).

## 4. MACRO CORRELATIONS
- **USD Strength**: Strong Dollar usually suppresses Oil prices (Inverse correlation).
- **Industrial Demand**: Weak manufacturing PMI data suggests lower demand.

## 5. RISK SCORING
- **HIGH SEVERITY**: War in oil-producing regions, major refinery disaster, OPEC+ collapse.
- **MEDIUM SEVERITY**: Inventory surprises (+/- 2M barrels), extreme weather impacting drilling.
- **LOW SEVERITY**: Routine maintenance updates, minor rig count changes.
""";