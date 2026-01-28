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
/*
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
}*/

/*
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class StorageService {
  static const String _boxName = 'briefings_v3'; // Bumped version for clean start

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  // SAVE: Serializes the list to a String string to avoid Type errors
  static Future<void> saveBriefing(String topicId, Map<String, dynamic> jsonResponse) async {
    final box = Hive.box(_boxName);

    // 1. Create the new entry
    final newEntry = {
      'data': jsonResponse,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 2. Get existing history (Decoded from String)
    List<dynamic> history = [];
    if (box.containsKey(topicId)) {
      final String? rawJson = box.get(topicId);
      if (rawJson != null) {
        history = json.decode(rawJson);
      }
    }

    // 3. Add new entry to the front
    history.insert(0, newEntry);

    // 4. Limit to last 10 entries
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    // 5. Save as JSON STRING (This guarantees persistence stability)
    await box.put(topicId, json.encode(history));

    print("StorageService: Persisted ${history.length} entries for $topicId");
  }

  // RETRIEVE: Reads String, Decodes, and Maps to Models
  static List<Briefing> getHistory(String topicId) {
    final box = Hive.box(_boxName);

    if (!box.containsKey(topicId)) return [];

    final List<Briefing> briefings = [];

    try {
      // 1. Get JSON String
      final String? rawJson = box.get(topicId);
      if (rawJson == null) return [];

      // 2. Decode to List
      final List<dynamic> historyList = json.decode(rawJson);

      // 3. Parse Objects
      for (var entry in historyList) {
        final Map<String, dynamic> entryMap = entry as Map<String, dynamic>;

        final String timestampStr = entryMap['timestamp'];
        final DateTime timestamp = DateTime.parse(timestampStr);

        final Map<String, dynamic> data = entryMap['data'];

        if (data['briefs'] != null) {
          final List<dynamic> briefsList = data['briefs'];
          for (var b in briefsList) {
            briefings.add(Briefing.fromJson(b, timestamp));
          }
        }
      }
    } catch (e) {
      print("StorageService: Error parsing history for $topicId: $e");
    }

    return briefings;
  }

  // SYSTEM RESET
  static Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.clear();
    print("StorageService: SYSTEM RESET - All Data Cleared");
  }
}*/
/*

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class StorageService {
  static const String _boxName = 'briefings_v4'; // Bumped version for clean slate

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
    print("StorageService: Box '$_boxName' opened. Keys found: ${Hive.box(_boxName).keys.length}");
  }

  // SAVE: Serializes to String + Forces Flush
  static Future<void> saveBriefing(String topicId, Map<String, dynamic> jsonResponse) async {
    final box = Hive.box(_boxName);

    final newEntry = {
      'data': jsonResponse,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 1. Get existing history (Decode safely)
    List<dynamic> history = [];
    if (box.containsKey(topicId)) {
      final String? rawJson = box.get(topicId);
      if (rawJson != null) {
        try {
          history = json.decode(rawJson);
        } catch (e) {
          print("StorageService: Save Error (Corrupt JSON) - resetting history for $topicId");
          history = [];
        }
      }
    }

    // 2. Add new entry
    history.insert(0, newEntry);

    // 3. Limit to last 10 entries
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    // 4. WRITE & FLUSH (Ensures data persists on crash/kill)
    await box.put(topicId, json.encode(history));
    await box.flush();

    print("StorageService: Successfully SAVED & FLUSHED ${history.length} items for $topicId");
  }

  // RETRIEVE: Safe Parsing
  static List<Briefing> getHistory(String topicId) {
    final box = Hive.box(_boxName);

    // Debug check
    if (!box.containsKey(topicId)) {
      print("StorageService: No history found for $topicId");
      return [];
    }

    final List<Briefing> briefings = [];

    try {
      final String? rawJson = box.get(topicId);
      if (rawJson == null) return [];

      final List<dynamic> historyList = json.decode(rawJson);

      for (var entry in historyList) {
        // --- THE CRITICAL FIX ---
        // Force cast using .from() to handle Hive's dynamic maps safely
        final Map<String, dynamic> entryMap = Map<String, dynamic>.from(entry);

        final String timestampStr = entryMap['timestamp'];
        final DateTime timestamp = DateTime.parse(timestampStr);

        final Map<String, dynamic> data = Map<String, dynamic>.from(entryMap['data']);

        if (data['briefs'] != null) {
          final List<dynamic> briefsList = data['briefs'];
          for (var b in briefsList) {
            // Force nested map cast
            final Map<String, dynamic> briefMap = Map<String, dynamic>.from(b);
            briefings.add(Briefing.fromJson(briefMap, timestamp));
          }
        }
      }
      print("StorageService: Loaded ${briefings.length} briefings for $topicId");

    } catch (e) {
      print("StorageService: CRITICAL READ ERROR for $topicId: $e");
      // Return whatever we managed to parse, or empty
    }

    return briefings;
  }

  static Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.clear();
    await box.flush();
    print("StorageService: SYSTEM RESET - All Data Cleared");
  }
}*/
/*

import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart'; // Required for explicit path finding
import 'models.dart';

class StorageService {
  // Bump version to v5 to ensure we are testing a fresh file creation
  static const String _boxName = 'briefings_v5';

  static Future<void> init() async {
    try {
      // 1. Explicitly find the save directory
      Directory dir = await getApplicationDocumentsDirectory();
      String path = "${dir.path}\\NexThreadData"; // Subfolder for cleanliness

      // 2. Initialize Hive manually at this path
      await Hive.initFlutter(path);

      print("----------------------------------------------------------------");
      print("📦 STORAGE PATH: $path");
      print("----------------------------------------------------------------");

      // 3. Open Box with Corruption Recovery
      try {
        await Hive.openBox(_boxName);
      } catch (e) {
        print("⚠️ StorageService: Box corrupted ($e). Deleting and recreating...");
        await Hive.deleteBoxFromDisk(_boxName);
        await Hive.openBox(_boxName);
      }

      print("StorageService: Box '$_boxName' opened successfully. Keys: ${Hive.box(_boxName).keys.length}");

    } catch (e) {
      print("❌ StorageService: CRITICAL INIT FAILURE: $e");
    }
  }

  // SAVE: Serializes to String + Forces Flush
  static Future<void> saveBriefing(String topicId, Map<String, dynamic> jsonResponse) async {
    final box = Hive.box(_boxName);

    final newEntry = {
      'data': jsonResponse,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 1. Get existing history
    List<dynamic> history = [];
    if (box.containsKey(topicId)) {
      final String? rawJson = box.get(topicId);
      if (rawJson != null) {
        try {
          history = json.decode(rawJson);
        } catch (e) {
          history = [];
        }
      }
    }

    // 2. Add new entry
    history.insert(0, newEntry);

    // 3. Limit to last 10 entries
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    // 4. WRITE & FLUSH
    await box.put(topicId, json.encode(history));
    await box.flush(); // Critical for Windows persistence

    print("StorageService: SAVED & FLUSHED ${history.length} items for $topicId");
  }

  // RETRIEVE: Safe Parsing
  static List<Briefing> getHistory(String topicId) {
    if (!Hive.isBoxOpen(_boxName)) return []; // Safety check

    final box = Hive.box(_boxName);

    if (!box.containsKey(topicId)) {
      print("StorageService: No history found for $topicId");
      return [];
    }

    final List<Briefing> briefings = [];

    try {
      final String? rawJson = box.get(topicId);
      if (rawJson == null) return [];

      final List<dynamic> historyList = json.decode(rawJson);

      for (var entry in historyList) {
        final Map<String, dynamic> entryMap = Map<String, dynamic>.from(entry);
        final String timestampStr = entryMap['timestamp'];
        final DateTime timestamp = DateTime.parse(timestampStr);
        final Map<String, dynamic> data = Map<String, dynamic>.from(entryMap['data']);

        if (data['briefs'] != null) {
          final List<dynamic> briefsList = data['briefs'];
          for (var b in briefsList) {
            final Map<String, dynamic> briefMap = Map<String, dynamic>.from(b);
            briefings.add(Briefing.fromJson(briefMap, timestamp));
          }
        }
      }
      print("StorageService: Loaded ${briefings.length} briefings for $topicId");

    } catch (e) {
      print("StorageService: READ ERROR for $topicId: $e");
    }

    return briefings;
  }

  static Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    await box.clear();
    await box.flush();
    print("StorageService: SYSTEM RESET - All Data Cleared");
  }
}*/

import 'dart:convert';
import 'package:flutter/foundation.dart'; // REQUIRED for kIsWeb
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class StorageService {
  // Version bumping ensures a clean database start if schema changes
  static const String _boxName = 'briefings_v5';

  // --- 1. UNIVERSAL INITIALIZATION ---
  static Future<void> init() async {
    try {
      // WEB SUPPORT: Hive uses IndexedDB (Browser Database) automatically.
      // We must NOT provide a path on Web.
      if (kIsWeb) {
        print("🌐 StorageService: Running on Web (IndexedDB).");
        await Hive.initFlutter();
      }
      // DESKTOP/MOBILE SUPPORT: We need a valid file path.
      else {
        String path;
        try {
          // Try to get the secure Documents folder
          final dir = await getApplicationDocumentsDirectory();
          path = "${dir.path}\\NexThreadData";
        } catch (e) {
          // If Plugin fails (common in debug/hot-restart), fallback to a local string path
          print("⚠️ StorageService: PathPlugin failed. Using local fallback.");
          path = "NexThreadData_Local";
        }

        await Hive.initFlutter(path);
        print("📦 Storage Path: $path");
      }

      // Open the box safely
      await _ensureBoxOpen();

    } catch (e) {
      print("❌ StorageService: CRITICAL INIT FAILURE: $e");
    }
  }

  // --- 2. SELF-HEALING OPENER ---
  // Checks if box is open. If not (or corrupted), re-opens it.
  static Future<void> _ensureBoxOpen() async {
    if (!Hive.isBoxOpen(_boxName)) {
      print("StorageService: Opening box '$_boxName'...");
      try {
        await Hive.openBox(_boxName);
      } catch (e) {
        print("⚠️ Box corrupted. Deleting and recreating...");
        // If the file is locked or broken, delete it and start fresh
        if (!kIsWeb) await Hive.deleteBoxFromDisk(_boxName);
        await Hive.openBox(_boxName);
      }
    }
  }

  // --- 3. SAVE (Serialized JSON String) ---
  static Future<void> saveBriefing(String topicId, Map<String, dynamic> jsonResponse) async {
    await _ensureBoxOpen();

    final box = Hive.box(_boxName);

    final newEntry = {
      'data': jsonResponse,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 1. Get existing history
    List<dynamic> history = [];
    if (box.containsKey(topicId)) {
      final String? rawJson = box.get(topicId);
      if (rawJson != null) {
        try {
          history = json.decode(rawJson);
        } catch (e) {
          history = []; // Reset if corrupt
        }
      }
    }

    // 2. Add new entry to the top
    history.insert(0, newEntry);

    // 3. Limit to last 10 entries (Storage Optimization)
    if (history.length > 10) history = history.sublist(0, 10);

    // 4. Save as JSON STRING
    // This bypasses Hive's "LinkedMap" type issues completely.
    await box.put(topicId, json.encode(history));

    // 5. Force Flush (Desktop only) ensures data hits the disk immediately
    if (!kIsWeb) await box.flush();

    print("StorageService: SAVED ${history.length} items for $topicId");
  }

  // --- 4. RETRIEVE (Safe Parsing) ---
  static List<Briefing> getHistory(String topicId) {
    if (!Hive.isBoxOpen(_boxName)) {
      print("⚠️ StorageService: Box closed during getHistory.");
      return [];
    }

    final box = Hive.box(_boxName);
    if (!box.containsKey(topicId)) return [];

    final List<Briefing> briefings = [];

    try {
      // 1. Get JSON String
      final String? rawJson = box.get(topicId);
      if (rawJson == null) return [];

      // 2. Decode String -> List
      final List<dynamic> historyList = json.decode(rawJson);

      // 3. Map to Objects (With Paranoid Type Casting)
      for (var entry in historyList) {
        // Force every step to be a Map<String, dynamic>
        final Map<String, dynamic> entryMap = Map<String, dynamic>.from(entry);

        final DateTime timestamp = DateTime.parse(entryMap['timestamp']);
        final Map<String, dynamic> data = Map<String, dynamic>.from(entryMap['data']);

        if (data['briefs'] != null) {
          final List<dynamic> briefsList = data['briefs'];
          for (var b in briefsList) {
            // Force nested objects to be Maps
            final Map<String, dynamic> bMap = Map<String, dynamic>.from(b);
            briefings.add(Briefing.fromJson(bMap, timestamp));
          }
        }
      }
    } catch (e) {
      print("StorageService: READ ERROR: $e");
    }

    return briefings;
  }

  // --- 5. SYSTEM RESET ---
  static Future<void> clearAll() async {
    await _ensureBoxOpen();
    final box = Hive.box(_boxName);
    await box.clear();
    if (!kIsWeb) await box.flush();
    print("StorageService: SYSTEM RESET - Cache Cleared");
  }
}