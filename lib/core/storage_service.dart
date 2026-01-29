
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb check
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class StorageService {
  static const String _boxName = 'briefings_v2';
  static const String _commentsBoxName = 'comments_v1';

  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(_boxName);
    await Hive.openBox(_commentsBoxName);

    if (kIsWeb) {
      print("StorageService: Initialized for Web (IndexedDB persistence active)");
    } else {
      print("StorageService: Initialized for Mobile/Desktop");
    }
  }

  // SAVE: Appends new briefing to the list
  static Future<void> saveBriefing(String topicId, Map<String, dynamic> jsonResponse) async {
    final box = Hive.box(_boxName);

    final newEntry = {
      'data': jsonResponse,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // CRITICAL FIX: explicitly cast to List<dynamic> and create a NEW mutable list.
    // box.get() can return an immutable view or specific HiveList type on web.
    final rawList = box.get(topicId);
    List<dynamic> history = rawList != null ? List<dynamic>.from(rawList) : [];

    // Add new entry to the FRONT (Newest first)
    history.insert(0, newEntry);

    // Limit to last 10 entries to save space
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await box.put(topicId, history);
    print("StorageService: Saved new entry for $topicId. History length: ${history.length}");
  }

  // RETRIEVE: Returns a List of Briefing objects (History)
  static List<Briefing> getHistory(String topicId) {
    final box = Hive.box(_boxName);

    if (!box.containsKey(topicId)) {
      print("StorageService: No history found for key: $topicId");
      return [];
    }

    final dynamic rawHistory = box.get(topicId);
    if (rawHistory == null) return [];

    // Ensure we are working with a List
    final List<dynamic> historyDynamic = rawHistory as List<dynamic>;
    final List<Briefing> briefings = [];

    for (var i = 0; i < historyDynamic.length; i++) {
      try {
        final entry = historyDynamic[i];

        // 1. Convert Hive's LinkedMap to a Standard Map
        // We use jsonEncode/Decode as a reliable way to strip Hive-specific types on Web
        final Map<String, dynamic> entryMap = json.decode(json.encode(entry));

        // 2. Extract Timestamp
        final String timestampStr = entryMap['timestamp'];
        final DateTime timestamp = DateTime.parse(timestampStr);

        // 3. Extract Data
        final Map<String, dynamic> data = entryMap['data'];

        // 4. Parse Briefings
        if (data['briefs'] != null) {
          final List<dynamic> briefsList = data['briefs'];
          for (var b in briefsList) {
            briefings.add(Briefing.fromJson(b, timestamp));
          }
        }
      } catch (e) {
        // Log error but continue processing other entries
        print("StorageService: Error parsing entry $i for $topicId: $e");
      }
    }

    print("StorageService: Retrieved ${briefings.length} briefings for $topicId");
    return briefings;
  }

  // --- COMMENTS SUBSYSTEM ---

  static String _generateCommentKey(String topicId, DateTime generatedAt) {
    return "${topicId}_${generatedAt.millisecondsSinceEpoch}";
  }

  static Future<void> addComment(String topicId, DateTime generatedAt, String text) async {
    final box = Hive.box(_commentsBoxName);
    final key = _generateCommentKey(topicId, generatedAt);

    final newComment = Comment(text: text, createdAt: DateTime.now());

    // CRITICAL FIX: Same mutable list safety as saveBriefing
    final rawList = box.get(key);
    List<dynamic> commentList = rawList != null ? List<dynamic>.from(rawList) : [];

    commentList.add(newComment.toJson());

    await box.put(key, commentList);
    print("StorageService: Added comment to $key");
  }

  static List<Comment> getComments(String topicId, DateTime generatedAt) {
    final box = Hive.box(_commentsBoxName);
    final key = _generateCommentKey(topicId, generatedAt);

    if (!box.containsKey(key)) return [];

    final dynamic rawList = box.get(key);
    if (rawList == null) return [];

    // Robust conversion
    final List<dynamic> list = rawList as List<dynamic>;

    return list.map((item) {
      final Map<String, dynamic> jsonMap = json.decode(json.encode(item));
      return Comment.fromJson(jsonMap);
    }).toList();
  }

  // SYSTEM RESET: Clears everything
  static Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    final commentsBox = Hive.box(_commentsBoxName);
    await box.clear();
    await commentsBox.clear();
    print("StorageService: SYSTEM RESET - Cache Cleared");
  }
}