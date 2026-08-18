import 'package:vncoughalert/features/chat/domain/models/chat_models.dart';
import 'package:vncoughalert/features/chat/domain/models/diagnosis_models.dart';

class MockChatRepository {
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

  ChatMessage addUserMessage({
    required String chatId,
    required String text,
    List<ChatAudio> audios = const [],
  }) {
    final titleSource = text.trim().isEmpty ? 'Ghi âm tiếng ho' : text;
    ensureSession(id: chatId, firstUserText: titleSource);
    final message = ChatMessage(
      id: 'msg_${++_seq}',
      role: ChatRole.user,
      text: text,
      createdAt: DateTime.now(),
      audios: audios,
    );
    _messages.putIfAbsent(chatId, () => []);
    _messages[chatId]!.add(message);
    return message;
  }

  ChatMessage addAssistantMessage({
    required String chatId,
    required String text,
    List<DiagnosisResult> diagnoses = const [],
  }) {
    ensureSession(id: chatId, firstUserText: 'Chẩn đoán mới');
    final message = ChatMessage(
      id: 'msg_${++_seq}',
      role: ChatRole.assistant,
      text: text,
      createdAt: DateTime.now(),
      diagnoses: diagnoses,
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

  void updateAssistant({
    required String chatId,
    required String messageId,
    required String text,
  }) {
    _replaceAssistant(
      chatId: chatId,
      messageId: messageId,
      text: text,
      isPending: true,
    );
  }

  void completeAssistant({
    required String chatId,
    required String messageId,
    required String text,
    List<DiagnosisResult> diagnoses = const [],
  }) {
    _replaceAssistant(
      chatId: chatId,
      messageId: messageId,
      text: text,
      isPending: false,
      diagnoses: diagnoses,
    );
  }

  void failAssistant({
    required String chatId,
    required String messageId,
    required String text,
  }) {
    _replaceAssistant(
      chatId: chatId,
      messageId: messageId,
      text: text,
      isPending: false,
    );
  }

  void _replaceAssistant({
    required String chatId,
    required String messageId,
    required String text,
    required bool isPending,
    List<DiagnosisResult> diagnoses = const [],
  }) {
    final list = _messages[chatId];
    if (list == null) {
      return;
    }
    final index = list.indexWhere((m) => m.id == messageId);
    if (index < 0) {
      return;
    }
    list[index] = list[index].copyWith(
      text: text,
      isPending: isPending,
      diagnoses: diagnoses,
    );
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
}
