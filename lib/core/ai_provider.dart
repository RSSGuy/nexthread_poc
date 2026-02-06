
import 'dart:async';

/// The contract that all AI services must satisfy.
abstract class AIProvider {
  /// Returns the display name of the provider (e.g., "OpenAI", "Ollama").
  String get name;

  /// Generates a response strictly formatted as JSON.
  ///
  /// [systemPrompt]: The schema definition, rules, and main instructions.
  /// [userContext]: Additional context (e.g., user simulation scenarios) to append to the prompt.
  Future<Map<String, dynamic>> generateBriefingJson({
    required String systemPrompt,
    required String userContext,
  });
}