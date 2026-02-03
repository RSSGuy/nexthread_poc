import 'dart:convert';
import 'package:ollama_dart/ollama_dart.dart';
import 'ai_provider.dart';

class OllamaProvider implements AIProvider {
  final String baseUrl;
  final String modelName;
  late final OllamaClient _client;

  /// Remote Access Provider
  /// Requires an explicit [baseUrl] pointing to the remote Ollama instance.
  /// Example: 'https://my-gpu-server.com/api'
  OllamaProvider({
    required this.baseUrl,
    required this.modelName,
  }) {
    // Ensure the URL does not end with a slash for consistency if the client expects it,
    // though ollama_dart typically handles it.
    // We treat the input as the absolute source of truth.
    _client = OllamaClient(baseUrl: baseUrl);
  }

  @override
  String get name => "Ollama Remote ($modelName)";

  @override
  Future<Map<String, dynamic>> generateBriefingJson({
    required String systemPrompt,
    required String userContext,
  }) async {
    print("--- REMOTE OLLAMA REQUEST ($modelName @ $baseUrl) ---");

    try {
      final response = await _client.generateChatCompletion(
        request: GenerateChatCompletionRequest(
          model: modelName,
          // FIXED: Call the factory constructor with the required Enum
          format: GenerateChatCompletionRequestFormat.json(
              GenerateChatCompletionRequestFormatEnum.json
          ),
          messages: [
            Message(
              role: MessageRole.system,
              content: systemPrompt,
            ),
            Message(
              role: MessageRole.user,
              content: "Context: $userContext\n\nGenerate the intelligence briefing JSON.",
            ),
          ],
          stream: false,
        ),
      );

      print("--- REMOTE OLLAMA RESPONSE RECEIVED ---");

      final content = response.message?.content ?? "{}";
      final cleanJson = _cleanJsonString(content);

      return jsonDecode(cleanJson) as Map<String, dynamic>;

    } catch (e) {
      print("Remote Ollama Error: $e");
      return {
        "briefs": [
          {
            "id": "ollama_remote_error",
            "subsector": "Error",
            "title": "Remote Connection Failed",
            "summary": "Could not reach Ollama at $baseUrl. Verify your server address, network connection, and that the server allows external connections (OLLAMA_HOST=0.0.0.0).",
            "severity": "High",
            "divergence_tag": "Network Error",
            "divergence_desc": e.toString(),
            "metrics": {"commodity": "N/A", "price": "0.00", "trend": "0%"},
            "headlines": [],
            "chart_data": [],
            "is_fallback": true
          }
        ]
      };
    }
  }

  String _cleanJsonString(String raw) {
    String clean = raw.replaceAll(RegExp(r'^```json\s*', multiLine: true), '');
    clean = clean.replaceAll(RegExp(r'^```\s*', multiLine: true), '');
    clean = clean.replaceAll(RegExp(r'```$', multiLine: true), '');
    return clean.trim();
  }
}