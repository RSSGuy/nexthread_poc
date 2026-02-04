/*
import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import '../../secrets.dart';
import 'ai_provider.dart';

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
    required String userContext, // Not used heavily in OpenAI system-role setup, but kept for interface consistency
  }) async {

    // OpenAI prefers the prompt in the "system" role
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
      ],
    );

    final content = chatCompletion.choices.first.message.content?.first.text;
    return json.decode(content ?? "{}");
  }
}*/

import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';
import '../../secrets.dart';
import 'ai_provider.dart';
import '../ui/widgets/console_log_widget.dart'; // Import Logger

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
}