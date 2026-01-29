# Feed Service Documentation (`feed_service.dart`)

## Overview
The `FeedService` is responsible for fetching live news from the open web. Since RSS feeds are often hosted on servers that do not support CORS (Cross-Origin Resource Sharing) for browser-based requests, this service implements a robust **"Proxy Race"** strategy to ensure data availability.

## Key Features

### 1. Robust Network Fetching (`_fetchContentRobustly`)
To mitigate timeouts and CORS errors, the service employs a tiered strategy:
* **Tier 1 (Mobile/Desktop):** Attempts a direct HTTP GET request. This is the fastest method.
* **Tier 2 (Web/Fallback):** If the direct fetch fails or the app is running on the web, it initiates a **"Proxy Race"**.
    * It fires simultaneous requests to multiple CORS proxies (e.g., `allorigins.win`, `corsproxy.io`).
    * **Winner-Takes-All:** The first proxy to return a `200 OK` status is used; the slower requests are discarded.

### 2. Multi-Layer Parsing Strategy
RSS and Atom standards are often implemented loosely. To prevent parsing failures, the service tries three methods in sequence:
1.  **Strict RSS:** Uses `webfeed_plus` to parse as RSS 2.0.
2.  **Strict Atom:** Uses `webfeed_plus` to parse as Atom 1.0.
3.  **Regex Fallback ("Dirty Read"):** If strictly structured parsing fails (due to bad namespaces or unescaped characters), a Regular Expression extracts content between `<title>` tags. This ensures we almost always get *some* data.

### 3. Keyword Filtering
Before returning the headlines, the service filters them against the `keywords` list defined in the `TopicConfig`. This removes irrelevant noise (e.g., generic ads or unrelated articles in a general feed).

## Usage
```dart
final FeedService service = FeedService();
// Returns a list of strings formatted as "[Source Name] Headline Title"
List<String> news = await service.fetchHeadlines(topic.sources, topic.keywords);