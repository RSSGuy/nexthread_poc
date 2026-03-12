import 'dart:convert';
import 'package:flutter/services.dart';

class FeedConfigManager {
  static Map<String, dynamic> _config = {};

  static Future<void> loadConfig() async {
    try {
      final jsonString = await rootBundle.loadString('assets/config/feed_config.json');
      _config = jsonDecode(jsonString);
    } catch (e) {
      print('Error loading local feed config: $e');
      // Set a safe fallback if the file fails to load
      _config = {};
    }
  }

  static Map<String, dynamic> get config => _config;
}