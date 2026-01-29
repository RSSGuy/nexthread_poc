import 'package:flutter/material.dart';

class ModelSelectorDialog extends StatelessWidget {
  const ModelSelectorDialog({super.key});

  /// Static helper to show the dialog and wait for a result
  /// Returns the provider key ('openai', 'ollama', 'gemini') or null
  static Future<String?> show(BuildContext context) async {
    return await showDialog<String>(
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
          onPressed: () => Navigator.pop(context, 'openai'),
          child: const Row(
            children: [
              Icon(Icons.cloud, color: Colors.blue),
              SizedBox(width: 12),
              Text("OpenAI (Cloud)"),
            ],
          ),
        ),

        // OPTION 2: Ollama
        SimpleDialogOption(
          padding: const EdgeInsets.all(16),
          onPressed: () => Navigator.pop(context, 'ollama'),
          child: const Row(
            children: [
              Icon(Icons.computer, color: Colors.orange),
              SizedBox(width: 12),
              Text("Ollama (Localhost)"),
            ],
          ),
        ),

        // OPTION 3: Gemini
        SimpleDialogOption(
          padding: const EdgeInsets.all(16),
          onPressed: () => Navigator.pop(context, 'gemini'),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.deepPurple),
              SizedBox(width: 12),
              Text("Google Gemini (Flash)"),
            ],
          ),
        ),
      ],
    );
  }
}