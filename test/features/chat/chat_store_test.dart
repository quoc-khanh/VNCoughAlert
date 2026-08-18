import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mistralai_dart/mistralai_dart.dart' as mistral;
import 'package:vncoughalert/features/chat/data/mistral_chat_client.dart';
import 'package:vncoughalert/features/chat/data/mistral_config.dart';
import 'package:vncoughalert/features/chat/domain/models/chat_models.dart';
import 'package:vncoughalert/features/chat/providers/chat_providers.dart';

class _FakeChatLlmClient implements ChatLlmClient {
  _FakeChatLlmClient({this.tokens = const ['streamed reply'], this.error});

  final List<String> tokens;
  final Object? error;
  List<mistral.ChatMessage>? lastMessages;

  @override
  Stream<String> stream(List<mistral.ChatMessage> messages) async* {
    lastMessages = messages;
    final thrown = error;
    if (thrown != null) {
      throw thrown;
    }
    for (final token in tokens) {
      yield token;
    }
  }
}

void main() {
  late ProviderContainer container;
  late ChatStore store;
  late _FakeChatLlmClient llm;

  setUp(() {
    llm = _FakeChatLlmClient(tokens: const ['streamed ', 'reply']);
    container = ProviderContainer(
      overrides: [chatLlmClientProvider.overrideWithValue(llm)],
    );
    store = container.read(chatStoreProvider.notifier);
  });

  tearDown(() => container.dispose());

  ChatStoreState state() => container.read(chatStoreProvider);

  test(
    'first send creates one session and streams the assistant reply',
    () async {
      final id = store.newChatId();
      final pending = store.send(chatId: id, text: 'Ping the model');

      expect(state().sessions.where((s) => s.id == id), hasLength(1));
      expect(state().sessions.first.id, id);
      expect(state().sessions.first.title, 'Ping the model');

      var messages = state().messagesOf(id);
      expect(messages, hasLength(2));
      expect(messages.first.role, ChatRole.user);
      expect(messages.first.text, 'Ping the model');
      expect(messages.last.isPending, isTrue);

      await pending;
      messages = state().messagesOf(id);
      expect(messages, hasLength(2));
      expect(messages.last.isPending, isFalse);
      expect(messages.last.text, 'streamed reply');
      expect(llm.lastMessages, isNotNull);
      expect(llm.lastMessages!.first.role, 'system');
    },
  );

  test('second send on same chatId does not duplicate the session', () async {
    final id = store.newChatId();
    await store.send(chatId: id, text: 'first');
    await store.send(chatId: id, text: 'second');

    expect(state().sessions.where((s) => s.id == id), hasLength(1));
    expect(
      state().messagesOf(id).where((m) => m.role == ChatRole.user),
      hasLength(2),
    );
    expect(state().messagesOf(id).where((m) => m.isPending), isEmpty);
  });

  test('two newChatId values stay independent sessions', () async {
    final seedCount = state().sessions.length;
    final a = store.newChatId();
    final b = store.newChatId();
    expect(a, isNot(b));

    await Future.wait([
      store.send(chatId: a, text: 'alpha'),
      store.send(chatId: b, text: 'beta'),
    ]);

    expect(state().sessions, hasLength(seedCount + 2));
    expect(state().messagesOf(a).first.text, 'alpha');
    expect(state().messagesOf(b).first.text, 'beta');
  });

  test('missing API key completes the pending bubble with an error', () async {
    final missingKey = ProviderContainer();
    addTearDown(missingKey.dispose);
    final missingStore = missingKey.read(chatStoreProvider.notifier);
    final id = missingStore.newChatId();

    await missingStore.send(chatId: id, text: 'hello');

    final messages = missingKey.read(chatStoreProvider).messagesOf(id);
    expect(messages.last.isPending, isFalse);
    expect(messages.last.text, MistralChatConfig.missingApiKeyMessage);
  });

  test('LLM failure completes the pending bubble with an error', () async {
    llm = _FakeChatLlmClient(error: Exception('network'));
    container.dispose();
    container = ProviderContainer(
      overrides: [chatLlmClientProvider.overrideWithValue(llm)],
    );
    store = container.read(chatStoreProvider.notifier);

    final id = store.newChatId();
    await store.send(chatId: id, text: 'hello');

    final messages = state().messagesOf(id);
    expect(messages.last.isPending, isFalse);
    expect(messages.last.text, MistralChatConfig.requestFailedMessage);
  });

  test(
    'every chat message, including voice placeholders, uses Mistral',
    () async {
      final id = store.newChatId();
      await store.send(
        chatId: id,
        text: 'Tôi bị ho và khó thở nhẹ.',
        audios: [
          ChatAudio(path: '/tmp/demo.m4a', duration: Duration(seconds: 5)),
        ],
      );

      final messages = state().messagesOf(id);
      expect(messages.last.isPending, isFalse);
      expect(messages.last.text, 'streamed reply');
      expect(llm.lastMessages, isNotNull);
    },
  );
}
