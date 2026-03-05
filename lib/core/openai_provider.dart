

import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import '../../secrets.dart';
import 'ai_provider.dart';
import '../ui/widgets/console_log_widget.dart'; // Import Logger

import 'package:http/http.dart' as http;

class OpenAIProvider implements AIProvider {
  @override
  String get name => "OpenAI (GPT-4)";

  OpenAIProvider() {
    OpenAI.apiKey = Secrets.openAiApiKey;
    OpenAI.requestsTimeOut = const Duration(seconds: 60);
  }

  @override
  Future<Map<String, dynamic>> generateBriefingJson({
    required String systemPrompt,
    required String userContext,
  }) async {
    // Log to UI Console
    ConsoleLogger.log("OpenAI: Sending request to gpt-4-turbo...", type: 'system');

    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-4-turbo",
        temperature: 0.0,
        seed: 42,
        responseFormat: {"type": "json_object"},
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
            role: OpenAIChatMessageRole.system,
          ),
          if (userContext.isNotEmpty)
            OpenAIChatCompletionChoiceMessageModel(
              content: [OpenAIChatCompletionChoiceMessageContentItemModel.text("Context: $userContext")],
              role: OpenAIChatMessageRole.user,
            ),
        ],
      );

      ConsoleLogger.success("OpenAI: Response received (${chatCompletion.usage?.totalTokens ?? '?'} tokens).");

      final content = chatCompletion.choices.first.message.content?.first.text;
      return json.decode(content ?? "{}");
    } catch (e) {
      ConsoleLogger.error("OpenAI Error: $e");
      rethrow;
    }
  }



  // lib/core/openai_provider.dart
// (Add this method inside your OpenAIProvider class)
/*  @override
  Future<String?> generateImage({required String prompt}) async {
    final url = Uri.parse('https://api.openai.com/v1/images/generations');

    final enhancedPrompt = "A professional, minimalist corporate data visualization or conceptual illustration representing: $prompt. Clean white background, modern corporate style, no text or words.";

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // FIXED: Using Secrets.openAiApiKey
          'Authorization': 'Bearer ${Secrets.openAiApiKey}',
        },
        body: jsonEncode({
          "model": "dall-e-3",
          "prompt": enhancedPrompt,
          "n": 1,
          "size": "1024x1024",
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'][0]['url'];
      } else {
        print("DALL-E Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("DALL-E Exception: $e");
      return null;
    }
  }*/


  @override
  Future<String?> generateImage({required String prompt}) async {
    final url = Uri.parse('https://api.openai.com/v1/images/generations');

    final enhancedPrompt = "A professional, minimalist corporate data visualization or conceptual illustration representing: $prompt. Clean white background, modern corporate style, no text or words.";

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Secrets.openAiApiKey}',
        },
        body: jsonEncode({
          "model": "dall-e-3",
          "prompt": enhancedPrompt,
          "n": 1,
          "size": "1024x1024",
          "response_format": "b64_json" // <-- NEW: Ask for raw data, not a URL
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'][0]['b64_json']; // <-- NEW: Extract the base64 string
      } else {
        print("DALL-E Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("DALL-E Exception: $e");
      return null;
    }
  }
}