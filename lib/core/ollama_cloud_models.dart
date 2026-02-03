// lib/core/ollama_cloud_models.dart
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
];