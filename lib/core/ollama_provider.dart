/*
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
}*/

/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';
import 'ollama_cloud_models.dart';

class OllamaProvider implements AIProvider {
  String _baseUrl;
  String _modelId;

  OllamaProvider({
    String? baseUrl,
    String? modelId
  }) :
        _baseUrl = baseUrl ?? OllamaCloudModels.defaultLocalUrl,
        _modelId = modelId ?? OllamaCloudModels.defaultModel.id;

  // --- MISSING IMPLEMENTATION 1: Name Getter ---
  @override
  String get name => 'Ollama';

  // Configuration Setter
  void setConfiguration(String baseUrl, String modelId) {
    if (!baseUrl.startsWith('http')) {
      baseUrl = 'http://$baseUrl';
    }
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseUrl = baseUrl;
    _modelId = modelId;
  }

  // --- STANDARD GENERATION (Text) ---
  @override
  Future<String> generate(String prompt, {String? systemPrompt}) async {
    return _callOllama(prompt, systemPrompt: systemPrompt, jsonMode: false);
  }

  // --- MISSING IMPLEMENTATION 2: JSON Generation ---
  @override
  Future<String> generateBriefingJson(String prompt, {String? systemPrompt}) async {
    // We enforce strict JSON mode for briefings
    return _callOllama(prompt, systemPrompt: systemPrompt, jsonMode: true);
  }

  // --- SHARED API LOGIC ---
  Future<String> _callOllama(String prompt, {String? systemPrompt, required bool jsonMode}) async {
    final uri = Uri.parse('$_baseUrl/api/generate');

    final effectiveSystem = systemPrompt ?? "You are a helpful AI assistant.";

    try {
      final body = {
        'model': _modelId,
        'prompt': prompt,
        'system': effectiveSystem,
        'stream': false,
        'options': {
          'temperature': jsonMode ? 0.2 : 0.7, // Lower temp for JSON
          'num_ctx': 4096,
        }
      };

      // Add format: json only if requested
      if (jsonMode) {
        body['format'] = 'json';
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawContent = data['response'] as String;
        return _cleanResponse(rawContent);
      } else {
        throw Exception('Ollama API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Ollama at $_baseUrl: $e');
    }
  }

  String _cleanResponse(String content) {
    content = content.trim();
    // Remove Markdown code blocks if present
    if (content.startsWith('```json')) {
      content = content.substring(7);
    } else if (content.startsWith('```')) {
      content = content.substring(3);
    }
    if (content.endsWith('```')) {
      content = content.substring(0, content.length - 3);
    }
    return content.trim();
  }
}*/

/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';
import 'ollama_cloud_models.dart';

class OllamaProvider implements AIProvider {
  String _baseUrl;
  String _modelId;

  // --- CONSTRUCTOR ---
  OllamaProvider({
    String? baseUrl,
    String? modelName
  }) :
        _baseUrl = baseUrl ?? OllamaCloudModels.defaultLocalUrl,
        _modelId = modelName ?? OllamaCloudModels.defaultModel.id;

  @override
  String get name => 'Ollama ($_modelId)';

  // --- CONFIGURATION ---
  // Called by AIService.setProvider to update settings dynamically
  void setConfiguration(String baseUrl, String modelId) {
    if (!baseUrl.startsWith('http')) {
      baseUrl = 'http://$baseUrl';
    }
    // Remove trailing slash if present
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseUrl = baseUrl;
    _modelId = modelId;
  }

  // --- CORE IMPLEMENTATION ---
  @override
  Future<Map<String, dynamic>> generateBriefingJson({
    required String systemPrompt,
    required String userContext,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/generate');

    // Combine context into the prompt structure Ollama expects
    // We treat 'systemPrompt' as the system instruction and 'userContext' as the prompt
    final fullPrompt = userContext.isEmpty
        ? "Generate the intelligence report."
        : "CONTEXT: $userContext\n\nTASK: Generate the intelligence report.";

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _modelId,
          'prompt': fullPrompt,
          'system': systemPrompt,
          'stream': false,
          'format': 'json', // Enforce JSON mode natively
          'options': {
            'temperature': 0.2, // Low temperature for factual adherence
            'num_ctx': 4096,    // Ensure enough context window
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String rawContent = data['response'] as String;

        // CLEANUP: Remove Markdown if the model added it (common with Llama 3)
        rawContent = _cleanJson(rawContent);

        // PARSE: Return the required Map
        return jsonDecode(rawContent);
      } else {
        throw Exception('Ollama API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Ollama at $_baseUrl: $e');
    }
  }

  // --- HELPER ---
  // Strips ```json ... ``` wrappers if the model returns them
  String _cleanJson(String content) {
    content = content.trim();
    if (content.startsWith('```json')) {
      content = content.substring(7);
    } else if (content.startsWith('```')) {
      content = content.substring(3);
    }
    if (content.endsWith('```')) {
      content = content.substring(0, content.length - 3);
    }
    return content.trim();
  }
}*/

/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';
import 'ollama_cloud_models.dart';

class OllamaProvider implements AIProvider {
  String _baseUrl;
  String _modelId;
  String? _apiKey; // NEW: Store the API Key

  // --- CONSTRUCTOR ---
  OllamaProvider({
    String? baseUrl,
    String? modelName,
    String? apiKey, // NEW: Accept key in constructor
  }) :
        _baseUrl = baseUrl ?? OllamaCloudModels.defaultLocalUrl,
        _modelId = modelName ?? OllamaCloudModels.defaultModel.id,
        _apiKey = apiKey;

  @override
  String get name => 'Ollama ($_modelId)';

  // --- CONFIGURATION ---
  void setConfiguration(String baseUrl, String modelId, {String? apiKey}) {
    if (!baseUrl.startsWith('http')) {
      baseUrl = 'http://$baseUrl';
    }
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseUrl = baseUrl;
    _modelId = modelId;
    _apiKey = apiKey;
  }

  // --- CORE IMPLEMENTATION ---
  @override
  Future<Map<String, dynamic>> generateBriefingJson({
    required String systemPrompt,
    required String userContext,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/generate');

    final fullPrompt = userContext.isEmpty
        ? "Generate the intelligence report."
        : "CONTEXT: $userContext\n\nTASK: Generate the intelligence report.";

    // NEW: Prepare Headers
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // Inject Authorization if Key exists
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }

    try {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String rawContent = data['response'] as String;
        return jsonDecode(_cleanJson(rawContent));
      } else {
        throw Exception('Ollama API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Ollama at $_baseUrl: $e');
    }
  }

  String _cleanJson(String content) {
    content = content.trim();
    if (content.startsWith('```json')) content = content.substring(7);
    else if (content.startsWith('```')) content = content.substring(3);
    if (content.endsWith('```')) content = content.substring(0, content.length - 3);
    return content.trim();
  }
}*/

/*
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';
import 'ollama_cloud_models.dart';
import '../../secrets.dart';

class OllamaProvider implements AIProvider {
  String _baseUrl;
  String _modelId;
  String? _apiKey;

  // --- CONSTRUCTOR ---
  OllamaProvider({
    String? baseUrl,
    String? modelName,
    String? apiKey,
  }) :
  // 1. Adapter for "host": "https://ollama.com"
  // Checks Argument -> Defaults to Localhost. Never Secrets (per your rule).
        _baseUrl = (baseUrl != null && baseUrl.isNotEmpty)
            ? baseUrl
            : OllamaCloudModels.defaultLocalUrl,

  // 2. Adapter for "model": "gpt-oss:120b"
        _modelId = modelName ?? OllamaCloudModels.defaultModel.id,

  // 3. Adapter for process.env.OLLAMA_API_KEY
  // Checks Argument -> Fallbacks to Secrets.dart
        _apiKey = (apiKey != null && apiKey.isNotEmpty)
            ? apiKey
            : (Secrets.ollamaApiKey.isNotEmpty ? Secrets.ollamaApiKey : null);

  @override
  String get name => 'Ollama ($_modelId)';

  // --- CONFIGURATION ---
  void setConfiguration(String baseUrl, String modelId, {String? apiKey}) {
    if (!baseUrl.startsWith('http')) {
      baseUrl = 'http://$baseUrl';
    }
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _baseUrl = baseUrl;
    _modelId = modelId;
    _apiKey = apiKey;
  }

  // --- CORE IMPLEMENTATION ---
  @override
  Future<Map<String, dynamic>> generateBriefingJson({
    required String systemPrompt,
    required String userContext,
  }) async {
    // Adapter for method: ollama.chat / api/generate
    final uri = Uri.parse('$_baseUrl/api/generate');

    // Logic to combine context, similar to messages: [{ role: "user", ... }]
    final fullPrompt = userContext.isEmpty
        ? "Generate the intelligence report."
        : "CONTEXT: $userContext\n\nTASK: Generate the intelligence report.";

    // --- ADAPTING THE HEADERS ---
    // JS: headers: { Authorization: "Bearer " + key }
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (_apiKey != null && _apiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_apiKey';
    }

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'model': _modelId,
          'prompt': fullPrompt,
          'system': systemPrompt,
          'stream': false, // We use false to get the full JSON object at once
          'format': 'json', // Force JSON mode
          'options': {
            'temperature': 0.2,
            'num_ctx': 4096,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String rawContent = data['response'] as String;
        return jsonDecode(_cleanJson(rawContent));
      } else {
        throw Exception('Ollama API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to Ollama at $_baseUrl: $e');
    }
  }

  String _cleanJson(String content) {
    content = content.trim();
    if (content.startsWith('```json')) content = content.substring(7);
    else if (content.startsWith('```')) content = content.substring(3);
    if (content.endsWith('```')) content = content.substring(0, content.length - 3);
    return content.trim();
  }
}*/

/*
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
  // CORRECT DEFAULT: https://ollama.com
        _baseUrl = (baseUrl != null && baseUrl.isNotEmpty)
            ? baseUrl
            : 'https://ollama.com',

        _modelId = modelName ?? OllamaCloudModels.defaultModel.id,

  // API Key: Arg -> Secret
        _apiKey = (apiKey != null && apiKey.isNotEmpty)
            ? apiKey
            : (Secrets.ollamaApiKey.isNotEmpty ? Secrets.ollamaApiKey : null),

        _proxyUrl = proxyUrl;

  @override
  String get name => 'Ollama Cloud ($_modelId)';

  @override
  void setConfiguration(String baseUrl, String modelId, {String? apiKey, String? proxyUrl}) {
    // If user leaves URL blank, default to official cloud
    if (baseUrl.isEmpty) {
      baseUrl = 'https://ollama.com';
    } else if (!baseUrl.startsWith('http')) {
      baseUrl = 'https://$baseUrl';
    }

    // Cleanup trailing slash
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
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
    // 1. Construct the Official API URL
    String targetUrl = '$_baseUrl/api/generate';

    // 2. APPLY PROXY (CRITICAL FOR WEB APPS)
    // Browsers will block 'https://ollama.com/api/generate' directly.
    // We must route via a CORS proxy if configured.
    if (_proxyUrl != null && _proxyUrl!.isNotEmpty) {
      targetUrl = '$_proxyUrl$targetUrl';
    }

    final uri = Uri.parse(targetUrl);

    final fullPrompt = userContext.isEmpty
        ? "Generate the intelligence report."
        : "CONTEXT: $userContext\n\nTASK: Generate the intelligence report.";

    // 3. HEADERS
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String rawContent = data['response'] as String;
        return jsonDecode(_cleanJson(rawContent));
      } else {
        print("OllamaCloud Error: ${response.statusCode} - ${response.body}");
        throw Exception('Cloud Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print("OllamaCloud Connection Failed: $e");

      // 4. DETECT WEB CORS ERROR
      if (e.toString().contains("ClientException") || e.toString().contains("XMLHttpRequest")) {
        throw Exception(
            "Browser Security Blocked the Request (CORS).\n"
                "You must set a Proxy in the Model Dialog.\n"
                "Try: https://cors-anywhere.herokuapp.com/"
        );
      }

      throw Exception('Connection failed: $e');
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
}*/
/*

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

  // FIX: Ensure proxy ends with '/'
        _proxyUrl = (proxyUrl != null && proxyUrl.isNotEmpty && !proxyUrl.endsWith('/'))
            ? '$proxyUrl/'
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

    // FIX: Ensure proxy ends with '/'
    if (proxyUrl != null && proxyUrl.isNotEmpty && !proxyUrl.endsWith('/')) {
      proxyUrl = '$proxyUrl/';
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

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String rawContent = data['response'] as String;
        return jsonDecode(_cleanJson(rawContent));
      } else {
        print("OllamaCloud Error: ${response.statusCode} - ${response.body}");
        throw Exception('Cloud Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print("OllamaCloud Connection Failed: $e");

      // SMART ERROR HANDLING
      if (e.toString().contains("ClientException") || e.toString().contains("XMLHttpRequest")) {
        if (_proxyUrl == null || _proxyUrl!.isEmpty) {
          throw Exception(
              "CORS Blocked: You are on Web but no Proxy is set.\n"
                  "Open Settings > Model > Ollama Cloud and add:\n"
                  "https://cors-anywhere.herokuapp.com/"
          );
        } else {
          throw Exception(
              "Proxy Blocked: The connection failed even with a proxy.\n"
                  "If using cors-anywhere, visit this link to activate it:\n"
                  "https://cors-anywhere.herokuapp.com/corsdemo"
          );
        }
      }

      throw Exception('Connection failed: $e');
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
}*/

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