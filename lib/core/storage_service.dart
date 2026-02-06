


import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models.dart';

class StorageService {
  static const String _boxName = 'briefings_v2';
  static const String _commentsBoxName = 'comments_v1';
  static const String _userBoxName = 'user_data_v1';
  static const String _diagnosticsBoxName = 'diagnostics_v1';

  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(_boxName);
    await Hive.openBox(_commentsBoxName);
    await Hive.openBox(_userBoxName);
    await Hive.openBox(_diagnosticsBoxName);

    if (kIsWeb) {
      print("StorageService: Initialized for Web");
    } else {
      print("StorageService: Initialized for Mobile/Desktop");
    }
  }

  // --- BRIEFING HISTORY ---

  static Future<void> saveBriefing(String topicId, Map<String, dynamic> jsonResponse) async {
    final box = Hive.box(_boxName);

    final newEntry = {
      'data': jsonResponse,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final rawList = box.get(topicId);
    List<dynamic> history = rawList != null ? List<dynamic>.from(rawList) : [];

    history.insert(0, newEntry);

    if (history.length > 10) {
      history = history.sublist(0, 10);
    }

    await box.put(topicId, history);
  }

  static List<Briefing> getHistory(String topicId) {
    final box = Hive.box(_boxName);

    if (!box.containsKey(topicId)) return [];

    final dynamic rawHistory = box.get(topicId);
    if (rawHistory == null) return [];

    final List<dynamic> historyDynamic = rawHistory as List<dynamic>;
    final List<Briefing> briefings = [];

    for (var i = 0; i < historyDynamic.length; i++) {
      try {
        final entry = historyDynamic[i];
        final Map<String, dynamic> entryMap = json.decode(json.encode(entry));

        final String timestampStr = entryMap['timestamp'];
        final DateTime timestamp = DateTime.parse(timestampStr);
        final Map<String, dynamic> data = entryMap['data'];

        if (data['briefs'] != null) {
          final List<dynamic> briefsList = data['briefs'];
          for (var b in briefsList) {
            briefings.add(Briefing.fromJson(b, timestamp));
          }
        }
      } catch (e) {
        print("StorageService: Error parsing entry $i for $topicId: $e");
      }
    }

    return briefings;
  }

  // --- GLOBAL ANALYSIS (NEW - DIFFERENT APPROACH) ---
  // Using the main _boxName since we know it is active and working.

  static Future<void> saveGlobalAnalysis(String analysis) async {
    final box = Hive.box(_boxName);
    final data = {
      'content': analysis,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await box.put('global_analysis_snapshot', data);
    print("StorageService: Saved global analysis to $_boxName");
  }

  static Map<String, dynamic>? getGlobalAnalysis() {
    final box = Hive.box(_boxName);
    final dynamic rawData = box.get('global_analysis_snapshot');

    if (rawData == null) return null;

    return json.decode(json.encode(rawData));
  }

  // --- COMMENTS SUBSYSTEM ---

  static String _generateCommentKey(String topicId, DateTime generatedAt) {
    return "${topicId}_${generatedAt.millisecondsSinceEpoch}";
  }

  static Future<void> addComment(String topicId, DateTime generatedAt, String text, {bool isAi = false}) async {
    final box = Hive.box(_commentsBoxName);
    final key = _generateCommentKey(topicId, generatedAt);

    final newComment = Comment(text: text, createdAt: DateTime.now(), isAi: isAi);

    final rawList = box.get(key);
    List<dynamic> commentList = rawList != null ? List<dynamic>.from(rawList) : [];

    commentList.add(newComment.toJson());

    await box.put(key, commentList);
  }

  static List<Comment> getComments(String topicId, DateTime generatedAt) {
    final box = Hive.box(_commentsBoxName);
    final key = _generateCommentKey(topicId, generatedAt);

    if (!box.containsKey(key)) return [];

    final dynamic rawList = box.get(key);
    if (rawList == null) return [];

    final List<dynamic> list = rawList as List<dynamic>;

    return list.map((item) {
      final Map<String, dynamic> jsonMap = json.decode(json.encode(item));
      return Comment.fromJson(jsonMap);
    }).toList();
  }

  // --- GAMIFICATION / POINTS SYSTEM ---

  static int getPoints() {
    final box = Hive.box(_userBoxName);
    return box.get('points', defaultValue: 5000);
  }

  static Future<bool> deductPoints(int amount) async {
    final box = Hive.box(_userBoxName);
    int current = getPoints();

    if (current >= amount) {
      await box.put('points', current - amount);
      return true;
    } else {
      return false;
    }
  }

  static Future<void> addPoints(int amount) async {
    final box = Hive.box(_userBoxName);
    int current = getPoints();
    await box.put('points', current + amount);
  }

  // --- FEED DIAGNOSTICS ---

  static Future<void> saveFeedHealthResults(List<FeedHealthResult> results) async {
    final box = Hive.box(_diagnosticsBoxName);
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'results': results.map((r) => r.toJson()).toList(),
    };
    await box.put('last_run', data);
  }

  static Map<String, dynamic>? getLastFeedHealthResults() {
    final box = Hive.box(_diagnosticsBoxName);
    final dynamic data = box.get('last_run');
    if (data == null) return null;
    final Map<String, dynamic> map = json.decode(json.encode(data));
    return {
      'timestamp': DateTime.parse(map['timestamp']),
      'results': (map['results'] as List).map((x) => FeedHealthResult.fromJson(x)).toList(),
    };
  }

  // SYSTEM RESET
  static Future<void> clearAll() async {
    final box = Hive.box(_boxName);
    final commentsBox = Hive.box(_commentsBoxName);
    final userBox = Hive.box(_userBoxName);
    final diagBox = Hive.box(_diagnosticsBoxName);

    await box.clear();
    await commentsBox.clear();
    await userBox.clear();
    await diagBox.clear();
    print("StorageService: SYSTEM RESET - All Cache Cleared");
  }
}