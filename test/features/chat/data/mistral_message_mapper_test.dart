import 'package:flutter_test/flutter_test.dart';
import 'package:mistralai_dart/mistralai_dart.dart' as mistral;
import 'package:vncoughalert/features/chat/data/mistral_config.dart';
import 'package:vncoughalert/features/chat/data/mistral_message_mapper.dart';
import 'package:vncoughalert/features/chat/domain/models/chat_models.dart';

void main() {
  final createdAt = DateTime(2026, 8, 17);

  ChatMessage user(
    String id,
    String text, {
    List<ChatAudio> audios = const [],
  }) {
    return ChatMessage(
      id: id,
      role: ChatRole.user,
      text: text,
      createdAt: createdAt,
      audios: audios,
    );
  }

  ChatMessage assistant(String id, String text, {bool isPending = false}) {
    return ChatMessage(
      id: id,
      role: ChatRole.assistant,
      text: text,
      createdAt: createdAt,
      isPending: isPending,
    );
  }

  group('mapChatHistory', () {
    test('prepends system prompt and maps user/assistant roles', () {
      final mapped = mapChatHistory([
        user('u1', 'Xin chào'),
        assistant('a1', 'Chào bạn'),
      ]);

      expect(mapped, hasLength(3));
      expect(mapped[0].role, 'system');
      expect(mapped[0].toJson()['content'], MistralChatConfig.systemPrompt);
      expect(mapped[1].role, 'user');
      expect(mapped[1].toJson()['content'], 'Xin chào');
      expect(mapped[2].role, 'assistant');
      expect(mapped[2].toJson()['content'], 'Chào bạn');
    });

    test('drops pending and empty assistant messages', () {
      final mapped = mapChatHistory([
        user('u1', 'Ping'),
        assistant('pending', '', isPending: true),
        assistant('empty', '   '),
        assistant('a1', 'Pong'),
      ]);

      expect(mapped.map((m) => m.role), ['system', 'user', 'assistant']);
      expect(mapped[2].toJson()['content'], 'Pong');
    });

    test('uses voice placeholder when user text is empty', () {
      final mapped = mapChatHistory([
        user(
          'u1',
          '',
          audios: const [
            ChatAudio(path: '/tmp/note.m4a', duration: Duration(seconds: 3)),
          ],
        ),
      ]);

      expect(mapped, hasLength(2));
      expect(mapped[1], isA<mistral.UserMessage>());
      expect(mapped[1].toJson()['content'], MistralChatConfig.voicePlaceholder);
    });

    test('keeps system prompt and the last N conversation messages', () {
      final messages = <ChatMessage>[
        for (var i = 0; i < 45; i++) user('u$i', 'msg $i'),
      ];

      final mapped = mapChatHistory(messages, maxHistoryMessages: 40);

      expect(mapped, hasLength(41));
      expect(mapped.first.role, 'system');
      expect(mapped[1].toJson()['content'], 'msg 5');
      expect(mapped.last.toJson()['content'], 'msg 44');
    });
  });
}
