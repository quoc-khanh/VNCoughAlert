import 'package:mistralai_dart/mistralai_dart.dart' as mistral;
import 'package:vncoughalert/features/chat/data/mistral_config.dart';
import 'package:vncoughalert/features/chat/domain/models/chat_models.dart';

List<mistral.ChatMessage> mapChatHistory(
  List<ChatMessage> messages, {
  String systemPrompt = MistralChatConfig.systemPrompt,
  int maxHistoryMessages = MistralChatConfig.maxHistoryMessages,
}) {
  final conversation = <mistral.ChatMessage>[];
  for (final message in messages) {
    if (message.isPending) {
      continue;
    }
    final content = _contentFor(message);
    if (content.isEmpty) {
      continue;
    }
    conversation.add(_toApi(message.role, content));
  }

  final recent = conversation.length <= maxHistoryMessages
      ? conversation
      : conversation.sublist(conversation.length - maxHistoryMessages);

  return [mistral.ChatMessage.system(systemPrompt), ...recent];
}

mistral.ChatMessage _toApi(ChatRole role, String content) {
  return switch (role) {
    ChatRole.user => mistral.ChatMessage.user(content),
    ChatRole.assistant => mistral.ChatMessage.assistant(content),
  };
}

String _contentFor(ChatMessage message) {
  final trimmed = message.text.trim();
  final parts = <String>[];
  if (trimmed.isNotEmpty) {
    parts.add(trimmed);
  }
  if (message.audios.isNotEmpty) {
    parts.add(
      '${MistralChatConfig.voicePlaceholder} '
      'Thời lượng: ${message.audios.first.duration.inSeconds} giây.',
    );
  }
  return parts.join('\n\n');
}
