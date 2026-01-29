import 'models.dart';

/// The contract that all AI services must satisfy.
abstract class AIProvider {
  String get name;

  /// Takes the raw context (Market Data + News + Rules) and returns the parsed Briefing JSON.
  /// Throws an exception if generation fails.
  Future<Map<String, dynamic>> generateBriefingJson({
    required String systemPrompt,
    required String userContext,
  });
}