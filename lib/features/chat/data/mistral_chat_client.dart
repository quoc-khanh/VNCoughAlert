import 'package:mistralai_dart/mistralai_dart.dart' as mistral;
import 'package:vncoughalert/features/chat/data/mistral_config.dart';

abstract interface class ChatLlmClient {
  Stream<String> stream(List<mistral.ChatMessage> messages);
}

final class MistralMissingApiKeyException implements Exception {
  const MistralMissingApiKeyException();
}

class MistralChatClient implements ChatLlmClient {
  MistralChatClient({required this.config});

  final MistralChatConfig config;
  mistral.MistralClient? _sdk;

  @override
  Stream<String> stream(List<mistral.ChatMessage> messages) async* {
    if (!config.hasApiKey) {
      throw const MistralMissingApiKeyException();
    }

    final sdk = _sdk ??= mistral.MistralClient.withApiKey(config.apiKey);
    final chunks = sdk.chat.createStream(
      request: mistral.ChatCompletionRequest(
        model: config.model,
        messages: messages,
      ),
    );

    await for (final chunk in chunks) {
      final token = chunk.text;
      if (token == null || token.isEmpty) {
        continue;
      }
      yield token;
    }
  }

  void close() {
    _sdk?.close();
    _sdk = null;
  }
}
