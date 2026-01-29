# AI Service Documentation (`ai_service.dart`)

## Overview
The `AIService` class is the intelligence engine of the NexThread application. It acts as the orchestrator between raw data sources (Market Data, News Feeds) and the Large Language Model (OpenAI GPT-4). Its primary responsibility is to construct a context-rich prompt and parse the AI's unstructured response into a structured `Briefing` model.

## Dependencies
- `dart_openai`: Handles the HTTP connection to OpenAI's API.
- `feed_service`: Fetches live news.
- `local_feed_service`: Fetches fallback/simulation news.
- `storage_service`: Persists the generated intelligence.

## Core Methods

### `generateBriefing(TopicConfig topic, {String? manualFeedPath})`
This is the main entry point for generating intelligence.

**Logic Flow:**
1.  **Environment Check:** Detects if a valid API Key is present. If not (or if key is "YOUR_KEY"), it defaults to a dummy response to prevent crashes during testing.
2.  **Source Determination:**
    * If `manualFeedPath` is provided (via the Dashboard "Crisis" menu), it uses `LocalFeedService`.
    * Otherwise, it attempts to fetch live news via `FeedService`.
3.  **Parallel Execution:** Uses `Future.wait` to fetch **Market Data** (from the Topic's service) and **News Headlines** simultaneously to minimize latency.
4.  **Prompt Construction:** Assembles the "Analyst Prompt" (see below).
5.  **LLM Invocation:** Calls `OpenAI.instance.chat.create` with `response_format: {"type": "json_object"}` to ensure machine-readable output.
6.  **Parsing & Persistence:** Decodes the JSON response, injects the real chart data (Line Data) into the briefing object, and saves it to local storage.

## The Analyst Prompt Structure
The system prompt is engineered to force the AI into a specific role. It consists of three injected data blocks:

1.  **[MARKET DATA]:** The raw price, trend percentage, and status (e.g., "Rising").
2.  **[NEWS STREAM]:** A newline-separated list of the top 15-20 relevant headlines.
3.  **[ANALYSIS RULES]:** The specific `RiskRules` string defined in the `TopicConfig`.

**Objective:** The AI is instructed to compare the hard data (Step 1) against the sentiment (Step 2) using the rules (Step 3) to detect "Divergence" or "Risks."

## Error Handling
* **JSON Parsing:** Wrapped in a try-catch block to handle cases where the AI might return malformed JSON.
* **Network Timeouts:** The API call has a strict 60-second timeout.