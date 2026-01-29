# NexThread: Agriculture & Manufacturing Intelligence Engine

## 1. Project Overview
**NexThread** is a Proof-of-Concept (POC) mobile application built with **Flutter**. It functions as an automated intelligence analyst for the Agriculture and Manufacturing sectors.

The system aggregates real-time market data and industry-specific news feeds, then utilizes Generative AI (GPT-4) to synthesize this information against strict "Risk Rules." The result is a concise, actionable **Briefing** that identifies market divergences, supply chain risks, and emerging trends.

---

## 2. System Architecture

The application follows a **Service-Oriented Architecture (SOA)** with a clean separation between UI, Data Ingestion, AI Processing, and State Management.

### High-Level Data Flow
1.  **User Selection:** User selects an Industry (e.g., Agriculture) and Topic (e.g., Beef).
2.  **Data Ingestion (Parallel):**
    * **Market Data:** Fetches price, trend, and status from API (EODHD) or mock services via specific Topic Services.
    * **News Data:** Fetches RSS feeds via `FeedService` (Live) or `LocalFeedService` (Fallback/Simulation).
3.  **Context Assembly:** The `AIService` combines Market Data + News Headlines + Pre-defined Risk Rules.
4.  **AI Synthesis:** Data is sent to OpenAI (GPT-4) with a System Prompt acting as a "Senior Analyst."
5.  **Persistence:** The resulting JSON intelligence is parsed and stored locally via `Hive`.
6.  **Presentation:** UI updates to show the "Market Pulse" and the generated "Briefing Card."

---

## 3. Core Business Logic

### A. The Topic Configuration Pattern
The app is designed to be scalable. Each sector is defined by a `TopicConfig` implementation (e.g., `BeefConfig`, `AgTechConfig`).
* **Identity:** Name, ID, Industry (NAICS code).
* **Data Source:** Dedicated service for market data (e.g., `BeefService` fetching `COW.TO` or `AgTechService` fetching `MOO.US`).
* **News Registry:** A curated list of RSS URLs specific to that topic.
* **Keywords:** A list of filtering terms to remove noise from RSS feeds.
* **Risk Rules:** A large, static text block defining roughly 50 specific risks (e.g., "Drought in Midwest," "Rail Strike," "Avian Flu"). **This is the "Brain" of the domain expertise.**

### B. The "Proxy Race" Strategy (News Ingestion)
To ensure reliability when fetching RSS feeds from the web (which often face CORS issues or timeouts), the `FeedService` implements a **Race Strategy**:
1.  **Direct Fetch:** Tried first on mobile/desktop.
2.  **Proxy Race:** If on Web or Direct fails, the system fires requests to multiple CORS proxies simultaneously (e.g., `allorigins`, `corsproxy`).
3.  **Winner Takes All:** The first proxy to return a `200 OK` status is used; others are discarded.
4.  **Fallback:** If all live strategies fail, the system degrades gracefully to local XML archives.

### C. Fallback & Simulation Logic
The app includes a robust simulation engine for demos or offline use:
* **Standard Mode:** Uses live APIs for both Markets and News.
* **Fallback Mode:** If APIs fail or keys are missing, it loads `assets/feeds/fallback_news.xml`.
* **Crisis Simulation:** A specific user-triggerable mode via the UI (Action Menu) that allows selecting specific XML files (e.g., `crisis_news.xml`) to demonstrate how the AI reacts to high-volatility news (e.g., "Port Strikes," "Export Bans"). The list of available simulation files is built dynamically by reading the `AssetManifest.json`.

---

## 4. Directory Structure

```text
lib/
├── core/
│   ├── ai_service.dart          # Orchestrates Data + Prompt + OpenAI
│   ├── feed_service.dart        # Live RSS parsing with Proxy Race strategy
│   ├── local_feed_service.dart  # Asset-based XML parsing (Fallback/Crisis)
│   ├── models.dart              # Data models (Briefing, MarketFact, NewsSource)
│   ├── news_registry.dart       # Central catalog of all RSS URLs
│   ├── storage_service.dart     # Hive local database wrapper
│   └── topic_config.dart        # Interface for all Industry Topics
│
├── topics/                      # Domain Specific Implementations
│   ├── agriculture/
│   │   ├── beef/                # Beef Config, Service, and Risk Rules
│   │   ├── agtech/              # AgTech Config, Service, and Risk Rules
│   │   └── ... (Wheat, Lumber)
│   └── manufacturing/
│       └── ... (Chemicals, Apparel)
│
├── ui/
│   ├── dialogs/                 # Modal Logic (FallbackSelectorDialog)
│   ├── screens/                 # Dashboard & Main Views
│   └── widgets/                 # Reusable UI (BriefingCard, MarketPulseCard, TopicFilterBar)
│
└── main.dart                    # App Entry Point