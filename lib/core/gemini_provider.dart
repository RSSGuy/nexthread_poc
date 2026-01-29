import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../secrets.dart';
import 'ai_provider.dart';

class GeminiProvider implements AIProvider {
  late final GenerativeModel _model;

  @override
  String get name => "Google Gemini (Flash)";

  GeminiProvider() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: Secrets.geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json', // Force JSON output
        temperature: 0.0,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> generateBriefingJson({
    required String systemPrompt,
    required String userContext,
  }) async {
    // Gemini doesn't strictly separate "System" vs "User" roles in the same way
    // OpenAI does in the high-level SDK, but we can prepend the instructions.

    final fullPrompt = '''
    $systemPrompt
    
    [ADDITIONAL CONTEXT]
    $userContext
    ''';

    final content = [Content.text(fullPrompt)];

    try {
      final response = await _model.generateContent(content);

      final text = response.text;
      if (text == null) throw Exception("Empty response from Gemini");

      // Clean markdown code blocks if present (e.g. ```json ... ```)
      final cleanText = text.replaceAll(RegExp(r'^```json\s*|\s*```$'), '');

      return json.decode(cleanText);
    } catch (e) {
      print("Gemini Error: $e");
      rethrow;
    }
  }
}