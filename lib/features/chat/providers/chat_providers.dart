import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vncoughalert/features/chat/data/mistral_chat_client.dart';
import 'package:vncoughalert/features/chat/data/mistral_config.dart';
import 'package:vncoughalert/features/chat/data/mistral_message_mapper.dart';
import 'package:vncoughalert/features/chat/data/mock_chat_repository.dart';
import 'package:vncoughalert/features/chat/domain/models/chat_models.dart';

class ChatStoreState {
  const ChatStoreState({
    required this.sessions,
    required this.messagesByChat,
  });

  final List<ChatSession> sessions;
  final Map<String, List<ChatMessage>> messagesByChat;

  List<ChatMessage> messagesOf(String? chatId) {
    if (chatId == null) {
      return const [];
    }
    return messagesByChat[chatId] ?? const [];
  }

}

class ChatStore extends Notifier<ChatStoreState> {
  late final MockChatRepository _repo;

  MockChatRepository get repository => _repo;

  ChatLlmClient get _llm => ref.read(chatLlmClientProvider);

  @override
  ChatStoreState build() {
    _repo = MockChatRepository();
    return ChatStoreState(
      sessions: _repo.sessions,
      messagesByChat: {
        for (final session in _repo.sessions)
          session.id: _repo.messagesOf(session.id),
      },
    );
  }

  String newChatId() => _repo.createChatId();

  void _sync() {
    state = ChatStoreState(
      sessions: _repo.sessions,
      messagesByChat: {
        for (final session in _repo.sessions)
          session.id: _repo.messagesOf(session.id),
      },
    );
  }

  Future<void> send({
    required String chatId,
    required String text,
    List<ChatAudio> audios = const [],
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && audios.isEmpty) {
      return;
    }

    _repo.addUserMessage(chatId: chatId, text: trimmed, audios: audios);
    final pending = _repo.addPendingAssistant(chatId);
    _sync();

    final history = mapChatHistory(_repo.messagesOf(chatId));
    final buffer = StringBuffer();
    try {
      await for (final token in _llm.stream(history)) {
        if (token.isEmpty) {
          continue;
        }
        buffer.write(token);
        _repo.updateAssistant(
          chatId: chatId,
          messageId: pending.id,
          text: buffer.toString(),
        );
        _sync();
      }
      final reply = buffer.toString().trim();
      if (reply.isEmpty) {
        _repo.failAssistant(
          chatId: chatId,
          messageId: pending.id,
          text: MistralChatConfig.emptyReplyMessage,
        );
      } else {
        _repo.completeAssistant(
          chatId: chatId,
          messageId: pending.id,
          text: reply,
        );
      }
    } on MistralMissingApiKeyException {
      _repo.failAssistant(
        chatId: chatId,
        messageId: pending.id,
        text: MistralChatConfig.missingApiKeyMessage,
      );
    } catch (_) {
      _repo.failAssistant(
        chatId: chatId,
        messageId: pending.id,
        text: MistralChatConfig.requestFailedMessage,
      );
    }
    _sync();
  }
}

final mistralChatConfigProvider = Provider<MistralChatConfig>((ref) {
  return const MistralChatConfig();
});

final chatLlmClientProvider = Provider<ChatLlmClient>((ref) {
  final config = ref.watch(mistralChatConfigProvider);
  final client = MistralChatClient(config: config);
  ref.onDispose(client.close);
  return client;
});

final chatStoreProvider = NotifierProvider<ChatStore, ChatStoreState>(
  ChatStore.new,
);

class SidebarOpen extends Notifier<bool> {
  @override
  bool build() => false;

  void open() => state = true;

  void close() => state = false;
}

final sidebarOpenProvider = NotifierProvider<SidebarOpen, bool>(
  SidebarOpen.new,
);
