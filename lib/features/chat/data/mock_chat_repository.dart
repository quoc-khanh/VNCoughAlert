import 'package:vncoughalert/features/chat/domain/models/chat_models.dart';

class MockChatRepository {
  MockChatRepository() {
    _seed();
  }

  final List<ChatSession> _sessions = [];
  final Map<String, List<ChatMessage>> _messages = {};
  int _seq = 0;

  List<ChatSession> get sessions => List.unmodifiable(_sessions);

  List<ChatMessage> messagesOf(String chatId) {
    return List.unmodifiable(_messages[chatId] ?? const []);
  }

  String createChatId() {
    _seq += 1;
    return 'chat_${DateTime.now().microsecondsSinceEpoch}_$_seq';
  }

  ChatSession ensureSession({
    required String id,
    required String firstUserText,
  }) {
    final existingIndex = _sessions.indexWhere((s) => s.id == id);
    final title = _titleFrom(firstUserText);
    final now = DateTime.now();
    if (existingIndex >= 0) {
      _sessions[existingIndex] = _sessions[existingIndex].copyWith(
        title: _sessions[existingIndex].title,
        updatedAt: now,
      );
      _sort();
      return _sessions[existingIndex];
    }
    final session = ChatSession(id: id, title: title, updatedAt: now);
    _sessions.insert(0, session);
    _messages.putIfAbsent(id, () => []);
    return session;
  }

  ChatMessage addUserMessage({required String chatId, required String text}) {
    ensureSession(id: chatId, firstUserText: text);
    final message = ChatMessage(
      id: 'msg_${++_seq}',
      role: ChatRole.user,
      text: text,
      createdAt: DateTime.now(),
    );
    _messages.putIfAbsent(chatId, () => []);
    _messages[chatId]!.add(message);
    return message;
  }

  ChatMessage addPendingAssistant(String chatId) {
    final message = ChatMessage(
      id: 'msg_${++_seq}',
      role: ChatRole.assistant,
      text: '',
      createdAt: DateTime.now(),
      isPending: true,
    );
    _messages.putIfAbsent(chatId, () => []);
    _messages[chatId]!.add(message);
    return message;
  }

  void completeAssistant({
    required String chatId,
    required String messageId,
    required String text,
  }) {
    final list = _messages[chatId];
    if (list == null) {
      return;
    }
    final index = list.indexWhere((m) => m.id == messageId);
    if (index < 0) {
      return;
    }
    list[index] = list[index].copyWith(text: text, isPending: false);
  }

  String cannedReply(String userText) {
    return 'Đây là phản hồi mẫu (mock) cho: "$userText"';
  }

  void _sort() {
    _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  String _titleFrom(String text) {
    final trimmed = text.trim();
    if (trimmed.length <= 42) {
      return trimmed;
    }
    return '${trimmed.substring(0, 42)}…';
  }

  void _seed() {
    final now = DateTime.now();
    const seeds = [
      ('s1', 'Chống rung X100VI vs X-E5'),
      ('s2', 'Tai nghe Sony Logitech'),
      ('s3', 'Bữa sáng calo bao nhiêu'),
      ('s4', 'Su telo dane nghĩa gì'),
    ];
    for (final (id, title) in seeds) {
      _sessions.add(
        ChatSession(
          id: id,
          title: title,
          updatedAt: now.subtract(Duration(minutes: _sessions.length * 12)),
        ),
      );
      _messages[id] = [
        ChatMessage(
          id: '${id}_u',
          role: ChatRole.user,
          text: title,
          createdAt: now,
        ),
        ChatMessage(
          id: '${id}_a',
          role: ChatRole.assistant,
          text: cannedReply(title),
          createdAt: now,
        ),
      ];
    }
  }
}
