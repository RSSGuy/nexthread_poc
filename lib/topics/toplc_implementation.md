Here is a comprehensive guide on **How to Implement a New Industry Topic** in NexThread. 

---

```markdown
# Developer Guide: Implementing a New Industry Topic

This guide outlines the steps required to add a new tracked sector (e.g., "Corn", "Semiconductors", "Automotive") to the NexThread engine.

The architecture follows a strict **Config -> Service -> Rules** pattern.

---

## Prerequisites
Before writing code, gather the following:
1.  **Market Proxy Symbol:** A stock ticker or ETF representing the sector (e.g., `CORN` or `SOXX`).
2.  **RSS Feeds:** 3-5 reliable news URLs relevant to the specific industry.
3.  **Domain Knowledge:** A list of 10-20 specific risks or trends (e.g., "drought", "chip shortage").

---

## Step 1: Create the Risk Rules
Define the "brain" of the topic. This is a static text block used by the AI to analyze news.

**File:** `lib/topics/[industry]/[topic]/[topic]_risk_rules.dart`

```dart
class CornRiskRules {
  static const String rules = '''
    --- SECTION A: SUPPLY RISKS (High Weight) ---
    1. Drought in Midwest: Low rainfall in Iowa/Illinois during pollination.
    2. Fertilizer Costs: High Nitrogen/Urea prices affecting planting decisions.
    3. Ethanol Demand: Changes in biofuel mandates (RFS) reducing industrial demand.
    
    --- SECTION B: TRADE & GEOPOLITICS ---
    4. China Purchases: Large cancellations or massive buy orders of US Corn.
    5. Ukraine Exports: Black Sea grain corridor disruptions.
  ''';
}

```

---

## Step 2: Create the Market Service

Create a service to fetch the real-time "Pulse" (Price/Trend) for this topic.

**File:** `lib/topics/[industry]/[topic]/[topic]_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models.dart';
import '../../../secrets.dart';

class CornService {
  // Use a relevant ETF or Futures Ticker
  static const String _symbol = "CORN.US"; 

  Future<MarketFact> getPulse() async {
    // 1. Fetch Data (EODHD API or Mock)
    // See BeefService.dart for the full boilerplate code regarding 
    // HTTP calls, caching, and parsing logic.
    
    // 2. Return the Fact
    return MarketFact(
      category: "Agriculture",
      name: "Corn Futures (Teucrium)",
      value: "\$22.50",
      trend: "+1.2%",
      status: "Rising",
      lineData: [21.0, 21.5, 22.0, 22.5], // 90-day trend
    );
  }
}

```

---

## Step 3: Create the Topic Configuration

This file binds the Service, the Rules, and the News Sources together.

**File:** `lib/topics/[industry]/[topic]/[topic]_config.dart`

```dart
import '../../../core/topic_config.dart';
import '../../../core/models.dart';
import '../../../core/news_registry.dart';
import 'corn_service.dart';
import 'corn_risk_rules.dart';

class CornConfig implements TopicConfig {
  final _service = CornService();

  @override
  String get id => "corn"; // Must be unique

  @override
  String get name => "Corn & Ethanol";

  @override
  Naics get industry => Naics.agriculture; // UI Filter Group

  @override
  List<NewsSourceConfig> get sources => [
    NewsRegistry.reutersCommodities,
    NewsRegistry.agWeb,
    NewsRegistry.biofuelsNews, // Add specific sources
  ];

  @override
  List<String> get keywords => [
    "Corn", "Maize", "Ethanol", "Silage", "Bushel", 
    "USDA", "Harvest", "Acreage"
  ];

  @override
  String get riskRules => CornRiskRules.rules;

  @override
  Future<MarketFact> fetchMarketPulse() async {
    return await _service.getPulse();
  }
}

```

---

## Step 4: Register in Dashboard

Finally, add the new configuration to the main list in the UI.

**File:** `lib/ui/screens/dashboard_screen.dart`

```dart
// ... imports
import '../../topics/agriculture/corn/corn_config.dart'; // Import it

class _DashboardScreenState extends State<DashboardScreen> {
  
  // Add to the list
  final List<TopicConfig> _allTopics = [
    WheatConfig(),
    BeefConfig(),
    CornConfig(), // <--- NEW TOPIC ADDED HERE
    AgTechConfig(),
    LumberConfig(),
    // ...
  ];

  // ... rest of code
}

```

---

## Step 5: (Optional) Update Assets

If you want to support **Offline/Crisis Simulation** for this new topic:

1. Create `assets/feeds/corn_crisis.xml`.
2. Add the path to `pubspec.yaml`.
3. The `FallbackSelectorDialog` will automatically pick it up via `AssetManifest.json`.

## Checklist

* [ ] Risk Rules defined (approx 20-50 rules).
* [ ] Service Class created with valid Ticker Symbol.
* [ ] Configuration Class implements `TopicConfig` correctly.
* [ ] Added to `_allTopics` list in Dashboard.
* [ ] Run `flutter restart` to verify.

```

```