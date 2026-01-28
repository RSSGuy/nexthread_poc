/*
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class StorageService {
  static const String _boxName = 'briefings_v2'; // Bumped version to v2 to ensure clean state

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // SAVE: Appends new briefing to the list
  static Future<void> saveBriefing(String topicId, Map<String, dynamic> jsonResponse) async {
    final box = Hive.box(_boxName);

    // Create new entry
    final newEntry = {
      'data': jsonResponse,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Get existing history
    List<dynamic> history = box.get(topicId, defaultValue: []);

    // Add new entry to the FRONT of the list (Newest first)
    history.insert(0, newEntry);

    // Optional: Limit history to last 10 entries to save space
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await box.put(topicId, history);
    print("StorageService: Saved new entry for $topicId. Total entries: ${history.length}");
  }

  // RETRIEVE: Returns a List of Briefing objects (History)
  static List<Briefing> getHistory(String topicId) {
    final box = Hive.box(_boxName);

    if (!box.containsKey(topicId)) return [];

    // Hive stores Lists as dynamic, need to cast
    final List<dynamic> historyDynamic = box.get(topicId);
    final List<Briefing> briefings = [];

    for (var entry in historyDynamic) {
      try {
        final Map<dynamic, dynamic> map = entry as Map<dynamic, dynamic>;
        final String timestampStr = map['timestamp'];
        final DateTime timestamp = DateTime.parse(timestampStr);

        final Map<dynamic, dynamic> dataDynamic = map['data'];
        final Map<String, dynamic> data = dataDynamic.map((key, value) => MapEntry(key.toString(), value));

        // Parse the "briefs" array inside the JSON
        if (data['briefs'] != null) {
          final List<dynamic> briefsList = data['briefs'];
          for (var b in briefsList) {
            briefings.add(Briefing.fromJson(b, timestamp));
          }
        }
      } catch (e) {
        print("StorageService: Error parsing entry: $e");
      }
    }

    return briefings;
  }

  // SYSTEM RESET: Clears everything
  static Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.clear();
    print("StorageService: SYSTEM RESET - Cache Cleared");
  }
}*/
import 'dart:convert'; // REQUIRED for deep type conversion
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class StorageService {
  static const String _boxName = 'briefings_v2';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // SAVE: Appends new briefing to the list
  static Future<void> saveBriefing(String topicId, Map<String, dynamic> jsonResponse) async {
    final box = Hive.box(_boxName);

    final newEntry = {
      'data': jsonResponse,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Get existing history or empty list
    // Hive returns dynamic lists, so we cast safely
    List<dynamic> history = box.get(topicId, defaultValue: []);

    // Add new entry to the FRONT (Newest first)
    history.insert(0, newEntry);

    // Limit to last 10 entries to save space
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await box.put(topicId, history);
    print("StorageService: Saved new entry for $topicId. Total entries: ${history.length}");
  }

  // RETRIEVE: Returns a List of Briefing objects (History)
  static List<Briefing> getHistory(String topicId) {
    final box = Hive.box(_boxName);

    if (!box.containsKey(topicId)) return [];

    final List<dynamic> historyDynamic = box.get(topicId);
    final List<Briefing> briefings = [];

    for (var entry in historyDynamic) {
      try {
        // 1. Safe Cast the Entry
        final Map<dynamic, dynamic> entryMap = entry as Map<dynamic, dynamic>;

        // 2. Extract Timestamp
        final String timestampStr = entryMap['timestamp'];
        final DateTime timestamp = DateTime.parse(timestampStr);

        // 3. Extract and Sanitize Data
        // Hive returns nested Maps as LinkedMap<dynamic, dynamic>.
        // We use jsonEncode/jsonDecode to force a DEEP convert to Map<String, dynamic>.
        final dynamic rawData = entryMap['data'];
        final Map<String, dynamic> data = json.decode(json.encode(rawData));

        // 4. Parse Briefings
        if (data['briefs'] != null) {
          final List<dynamic> briefsList = data['briefs'];
          for (var b in briefsList) {
            briefings.add(Briefing.fromJson(b, timestamp));
          }
        }
      } catch (e) {
        print("StorageService: Error parsing entry for $topicId: $e");
      }
    }

    return briefings;
  }

  // SYSTEM RESET: Clears everything
  static Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.clear();
    print("StorageService: SYSTEM RESET - Cache Cleared");
  }
}