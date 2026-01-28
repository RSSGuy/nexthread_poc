/*
import 'dart:convert';
import 'package:flutter/services.dart';

class LocalFeedService {

  // Updated to accept 'keywords' for smarter matching
  static Future<List<String>> getRelevantItems(String topicName, List<String> keywords) async {
    try {
      final String response = await rootBundle.loadString('assets/scraped_feed.json');
      final List<dynamic> data = json.decode(response);

      List<String> hits = [];

      for (var item in data) {
        // --- 1. PARSE YOUR SPECIFIC SCHEMA ---
        final String title = item['Article Title'] ?? item['title'] ?? "";
        final String body = item['Article Content'] ?? item['body'] ?? "";
        final String category = item['Category'] ?? item['topic'] ?? "";

        final String fullText = "$title $body $category".toLowerCase();

        // --- 2. SMART MATCHING LOGIC ---
        // Match if:
        // A. The JSON 'Category' matches the Topic Name (e.g., "Agriculture")
        // B. OR... The text contains the Topic Name
        // C. OR... The text contains any of the Topic's Keywords (Best for "BASF" -> "Chemicals")

        bool isMatch = false;

        if (category.toLowerCase() == topicName.toLowerCase()) isMatch = true;
        if (fullText.contains(topicName.toLowerCase())) isMatch = true;

        // Check keywords (Robust)
        if (!isMatch) {
          for (var k in keywords) {
            if (fullText.contains(k.toLowerCase())) {
              isMatch = true;
              break;
            }
          }
        }

        if (isMatch) {
          // Format it for the AI to read
          hits.add("[JSON-SOURCE] $title: $body");
        }
      }

      return hits;

    } catch (e) {
      print("⚠️ LocalFeedService Error: $e");
      return [];
    }
  }
}*/

import 'dart:convert';
import 'dart:math'; // Import Math for min()
import 'package:flutter/services.dart';

class LocalFeedService {

  static Future<List<String>> getRelevantItems(String topicName, List<String> keywords) async {
    try {
      final String response = await rootBundle.loadString('assets/scraped_feed.json');
      final List<dynamic> data = json.decode(response);

      List<String> hits = [];

      for (var item in data) {
        // 1. Parse Schema
        final String title = item['Article Title'] ?? item['title'] ?? "";
        final String rawBody = item['Article Content'] ?? item['body'] ?? "";
        final String category = item['Category'] ?? item['topic'] ?? "";

        // 2. Cleaning & Truncation (CRITICAL FOR TOKENS)
        // Remove newlines and limit to 250 characters
        String body = rawBody.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
        if (body.length > 250) {
          body = "${body.substring(0, 250)}...";
        }

        final String fullText = "$title $body $category".toLowerCase();

        // 3. Match Logic
        bool isMatch = false;
        if (category.toLowerCase() == topicName.toLowerCase()) isMatch = true;
        if (fullText.contains(topicName.toLowerCase())) isMatch = true;

        if (!isMatch) {
          for (var k in keywords) {
            if (fullText.contains(k.toLowerCase())) {
              isMatch = true;
              break;
            }
          }
        }

        if (isMatch) {
          hits.add("[JSON-SOURCE] $title: $body");

          // 4. HARD STOP (Prevent Token Explosion)
          // Only take the top 5 matches from the local file
          if (hits.length >= 5) break;
        }
      }

      return hits;

    } catch (e) {
      print("⚠️ LocalFeedService Error: $e");
      return [];
    }
  }
}