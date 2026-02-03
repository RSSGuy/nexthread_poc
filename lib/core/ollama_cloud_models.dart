/*
class OllamaModelConfig {
  final String id;
  final String label;
  final bool recommended;
  final int contextWindow;
  final bool supportsSystemSchema; // Helpful to know if model follows complex system prompts well

  const OllamaModelConfig({
    required this.id,
    required this.label,
    this.recommended = false,
    this.contextWindow = 4096,
    this.supportsSystemSchema = true,
  });
}

class OllamaCloudModels {
  // DEFAULT ENDPOINTS
  static const String defaultLocalUrl = 'http://localhost:11434';
  static const String defaultCloudUrl = ''; // User can override this

  // MODEL REGISTRY
  static const List<OllamaModelConfig> registry = [
    OllamaModelConfig(
        id: 'llama3.2',
        label: 'Llama 3.2 (3B)',
        recommended: true,
        contextWindow: 128000
    ),
    OllamaModelConfig(
        id: 'llama3.1',
        label: 'Llama 3.1 (8B)',
        recommended: true,
        contextWindow: 128000
    ),
    OllamaModelConfig(
        id: 'mistral',
        label: 'Mistral (7B)',
        contextWindow: 8192
    ),
    OllamaModelConfig(
        id: 'gemma2',
        label: 'Gemma 2 (9B)',
        contextWindow: 8192
    ),
    OllamaModelConfig(
        id: 'phi3.5',
        label: 'Phi 3.5 (3.8B)',
        contextWindow: 128000
    ),
    OllamaModelConfig(
        id: 'qwen2.5',
        label: 'Qwen 2.5 (7B)',
        recommended: true,
        contextWindow: 32000
    ),
  ];

  static OllamaModelConfig get defaultModel => registry.first;

  /// Helper to find a model configuration by ID
  static OllamaModelConfig findById(String id) {
    return registry.firstWhere(
            (m) => m.id == id,
        orElse: () => defaultModel
    );
  }
}*/

/// Reference list of Ollama Cloud Models
/// Source: https://ollama.com/search?c=cloud

class OllamaCloudModel {
  final String id;
  final String name;
  final String description;

  const OllamaCloudModel({
    required this.id,
    required this.name,
    required this.description,
  });
}

/// Official list of Cloud Models available via Ollama
const List<OllamaCloudModel> kOllamaCloudModels = [
  OllamaCloudModel(
    id: 'deepseek-v3.1:671b-cloud',
    name: 'DeepSeek v3.1 (671B)',
    description: 'Hybrid model with thinking & non-thinking modes.',
  ),
  OllamaCloudModel(
    id: 'gpt-oss:120b-cloud',
    name: 'GPT-OSS (120B)',
    description: 'OpenAI open-weight reasoning model.',
  ),
  OllamaCloudModel(
    id: 'gpt-oss:20b-cloud',
    name: 'GPT-OSS (20B)',
    description: 'Efficient reasoning model.',
  ),
  OllamaCloudModel(
    id: 'qwen3-coder:480b-cloud',
    name: 'Qwen3 Coder (480B)',
    description: 'Massive code-specific model.',
  ),
  OllamaCloudModel(
    id: 'qwen3-vl:235b-cloud',
    name: 'Qwen3 Vision (235B)',
    description: 'Powerful vision-language model.',
  ),
  OllamaCloudModel(
    id: 'kimi-k2:1t-cloud',
    name: 'Kimi K2 (1T)',
    description: '1-Trillion parameter MoE model.',
  ),
  OllamaCloudModel(
    id: 'kimi-k2.5:cloud',
    name: 'Kimi K2.5',
    description: 'Multimodal agentic model with thinking mode.',
  ),
  OllamaCloudModel(
    id: 'glm-4.6:cloud',
    name: 'GLM 4.6',
    description: 'Advanced agentic & reasoning capabilities.',
  ),
  OllamaCloudModel(
    id: 'gemini-3-pro-preview:cloud',
    name: 'Gemini 3 Pro Preview',
    description: 'Google SOTA reasoning & multimodal model.',
  ),
  OllamaCloudModel(
    id: 'mistral-large-3:cloud',
    name: 'Mistral Large 3',
    description: 'Production-grade enterprise model.',
  ),
  OllamaCloudModel(
    id: 'minimax-m2.1:cloud',
    name: 'MiniMax M2.1',
    description: 'Multilingual code engineering model.',
  ),
  // Fallback / Local Defaults
  OllamaCloudModel(
    id: 'llama3',
    name: 'Llama 3 (Local/Default)',
    description: 'Standard local model.',
  ),
];

/// Helper class for Provider compatibility
/// This ensures 'OllamaProvider' can still find default values
class OllamaCloudModels {
  static const String defaultLocalUrl = 'http://localhost:11434';

  // Returns the first model in the list as the default
  static OllamaCloudModel get defaultModel => kOllamaCloudModels.isNotEmpty
      ? kOllamaCloudModels.first
      : const OllamaCloudModel(id: 'llama3', name: 'Llama 3', description: 'Fallback');
}