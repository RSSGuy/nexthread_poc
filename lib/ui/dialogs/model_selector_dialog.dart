
import 'package:flutter/material.dart';
import '../../core/ollama_cloud_models.dart';
import '../../secrets.dart';

class ModelSelectorDialog extends StatelessWidget {
  const ModelSelectorDialog({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ModelSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Select AI Model"),
      children: [
        // OPTION 1: OpenAI
        SimpleDialogOption(
          padding: const EdgeInsets.all(16),
          onPressed: () => Navigator.pop(context, {'key': 'openai'}),
          child: const Row(children: [Icon(Icons.cloud, color: Colors.blue), SizedBox(width: 12), Text("OpenAI (Cloud)")]),
        ),

        // OPTION 2: Ollama (Cloud / Custom)
        SimpleDialogOption(
          padding: const EdgeInsets.all(16),
          onPressed: () async {
            // ALWAYS open config dialog for Ollama to ensure Proxy is set
            final config = await showDialog<Map<String, String>>(
              context: context,
              builder: (c) => const _OllamaCloudConfigDialog(),
            );

            if (config != null && context.mounted) {
              Navigator.pop(context, {'key': 'ollama', 'config': config});
            }
          },
          child: const Row(
            children: [
              Icon(Icons.settings_ethernet, color: Colors.deepOrange),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ollama / Custom"),
                  Text("Configure URL & Proxy", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),

        // OPTION 3: Gemini
        SimpleDialogOption(
          padding: const EdgeInsets.all(16),
          onPressed: () => Navigator.pop(context, {'key': 'gemini'}),
          child: const Row(children: [Icon(Icons.auto_awesome, color: Colors.deepPurple), SizedBox(width: 12), Text("Google Gemini")]),
        ),
      ],
    );
  }
}

class _OllamaCloudConfigDialog extends StatefulWidget {
  const _OllamaCloudConfigDialog();
  @override
  State<_OllamaCloudConfigDialog> createState() => _OllamaCloudConfigDialogState();
}

class _OllamaCloudConfigDialogState extends State<_OllamaCloudConfigDialog> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _proxyController = TextEditingController();
  OllamaCloudModel? _selectedModel;
  bool _hasSecretKey = false;

  @override
  void initState() {
    super.initState();
    if (kOllamaCloudModels.isNotEmpty) _selectedModel = kOllamaCloudModels.first;

    // Default URL
    _urlController.text = "https://ollama.com";

    // Default Proxy (Stable)
    _proxyController.text = "https://corsproxy.io/?";

    if (Secrets.ollamaApiKey.isNotEmpty && !Secrets.ollamaApiKey.contains("YOUR_OLLAMA_KEY")) {
      setState(() => _hasSecretKey = true);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _apiKeyController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Configure Ollama"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. URL
            const Text("Server URL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                  hintText: "https://ollama.com",
                  border: OutlineInputBorder(), isDense: true
              ),
            ),
            const SizedBox(height: 12),

            // 2. PROXY
            Row(
              children: [
                const Text("CORS Proxy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _proxyController,
              decoration: const InputDecoration(
                  hintText: "https://corsproxy.io/?",
                  border: OutlineInputBorder(), isDense: true
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4, bottom: 12),
              child: Text("Required for Web Apps to access Cloud APIs.", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),

            // 3. API KEY
            Row(
              children: [
                const Text("API Key", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                if (_hasSecretKey)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text("(Found in secrets.dart)", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: _hasSecretKey ? "Using secrets.dart key" : "Paste your Bearer Token",
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _hasSecretKey ? const Icon(Icons.check_circle, size: 16, color: Colors.green) : null,
              ),
            ),
            const SizedBox(height: 12),

            // 4. MODEL
            const Text("Select Model", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<OllamaCloudModel>(
                  value: _selectedModel,
                  isExpanded: true,
                  items: kOllamaCloudModels.map((m) => DropdownMenuItem(value: m, child: Text(m.name, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) => setState(() => _selectedModel = val),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            // Return the Config Map
            Navigator.pop(context, {
              'url': _urlController.text.trim(),
              'proxy': _proxyController.text.trim(), // PASS PROXY
              'model': _selectedModel?.id ?? 'llama3',
              'apiKey': _apiKeyController.text.trim(),
            });
          },
          child: const Text("Connect"),
        ),
      ],
    );
  }
}