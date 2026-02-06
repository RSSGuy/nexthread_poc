

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';
import 'ollama_cloud_models.dart';
import '../../secrets.dart';

class OllamaProvider implements AIProvider {
  String _baseUrl;
  String _modelId;
  String? _apiKey;
  String? _proxyUrl;

  OllamaProvider({
    String? baseUrl,
    String? modelName,
    String? apiKey,
    String? proxyUrl,
  }) :
        _baseUrl = (baseUrl != null && baseUrl.isNotEmpty)
            ? baseUrl
            : 'https://ollama.com',

        _modelId = modelName ?? OllamaCloudModels.defaultModel.id,

        _apiKey = (apiKey != null && apiKey.isNotEmpty)
            ? apiKey
            : (Secrets.ollamaApiKey.isNotEmpty ? Secrets.ollamaApiKey : null),

  // Ensure proxy ends with '/' or '?'
        _proxyUrl = (proxyUrl != null && proxyUrl.isNotEmpty)
            ? (proxyUrl.endsWith('/') || proxyUrl.endsWith('?') ? proxyUrl : '$proxyUrl/')
            : proxyUrl;

  @override
  String get name => 'Ollama Cloud ($_modelId)';

  @override
  void setConfiguration(String baseUrl, String modelId, {String? apiKey, String? proxyUrl}) {
    if (baseUrl.isEmpty) {
      baseUrl = 'https://ollama.com';
    } else if (!baseUrl.startsWith('http')) {
      baseUrl = 'https://$baseUrl';
    }

    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    if (proxyUrl != null && proxyUrl.isNotEmpty) {
      if (!proxyUrl.endsWith('/') && !proxyUrl.endsWith('?')) {
        proxyUrl = '$proxyUrl/';
      }
    }

    _baseUrl = baseUrl;
    _modelId = modelId;
    _apiKey = apiKey;
    _proxyUrl = proxyUrl;
  }

  @override
  Future<Map<String, dynamic>> generateBriefingJson({
    required String systemPrompt,
    required String userContext,
  }) async {
    String targetUrl = '$_baseUrl/api/generate';

    // APPLY PROXY
    if (_proxyUrl != null && _proxyUrl!.isNotEmpty) {
      targetUrl = '$_proxyUrl$targetUrl';
    }

    final uri = Uri.parse(targetUrl);

    final fullPrompt = userContext.isEmpty
        ? "Generate the intelligence report."
        : "CONTEXT: $userContext\n\nTASK: Generate the intelligence report.";

    // 1. HEADERS
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // 2. PROXY-SPECIFIC HEADERS
    // Only 'cors-anywhere' strictly requires X-Requested-With.
    // Others might block if unexpected headers are present.
    if (_proxyUrl != null && _proxyUrl!.contains("cors-anywhere")) {
      headers['X-Requested-With'] = 'XMLHttpRequest';
    }

    // 3. AUTH
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }

    try {
      print('OllamaCloud: POSTing to $uri (Model: $_modelId)...');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'model': _modelId,
          'prompt': fullPrompt,
          'system': systemPrompt,
          'stream': false,
          'format': 'json',
          'options': {
            'temperature': 0.2,
            'num_ctx': 4096,
          }
        }),
      );

      // DEBUG: Print status
      print('OllamaCloud Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // SAFETY CHECK: Did we get HTML (the website) instead of JSON?
        // This happens if the Proxy works, but the URL points to the Homepage, not the API.
        if (response.body.trim().startsWith('<')) {
          throw Exception(
              "Target Error: The server returned HTML instead of JSON.\n"
                  "You are likely hitting the website '$_baseUrl' instead of an API Endpoint.\n"
                  "Check your Server URL."
          );
        }

        final data = jsonDecode(response.body);
        String rawContent = data['response'] as String;
        return jsonDecode(_cleanJson(rawContent));
      } else {
        // Pass specific error details
        throw Exception('Server Error ${response.statusCode}: ${response.body.take(200)}...');
      }
    } catch (e) {
      print("OllamaCloud Connection Failed: $e");

      if (e.toString().contains("ClientException") || e.toString().contains("XMLHttpRequest")) {
        if (_proxyUrl == null || _proxyUrl!.isEmpty) {
          throw Exception("CORS Blocked: No Proxy set in Model Dialog.");
        } else {
          // Show the RAW error to help debug
          throw Exception("Proxy Connection Failed: $e");
        }
      }

      // Rethrow other errors (like the HTML check above)
      rethrow;
    }
  }

  String _cleanJson(String content) {
    content = content.trim();
    if (content.startsWith('```json')) content = content.substring(7);
    else if (content.startsWith('```')) content = content.substring(3);
    if (content.endsWith('```')) content = content.substring(0, content.length - 3);

    final firstBrace = content.indexOf('{');
    final lastBrace = content.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1) {
      content = content.substring(firstBrace, lastBrace + 1);
    }
    return content.trim();
  }
}

extension StringExtension on String {
  String take(int n) {
    if (length <= n) return this;
    return substring(0, n);
  }
}