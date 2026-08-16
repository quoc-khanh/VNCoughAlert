import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vncoughalert/features/chat/data/mock_chat_repository.dart';
import 'package:vncoughalert/features/chat/domain/models/chat_models.dart';

class ChatStoreState {
  const ChatStoreState({required this.sessions, required this.messagesByChat});

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

  Future<void> send({required String chatId, required String text}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _repo.addUserMessage(chatId: chatId, text: trimmed);
    final pending = _repo.addPendingAssistant(chatId);
    _sync();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _repo.completeAssistant(
      chatId: chatId,
      messageId: pending.id,
      text: _repo.cannedReply(trimmed),
    );
    _sync();
  }
}

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
