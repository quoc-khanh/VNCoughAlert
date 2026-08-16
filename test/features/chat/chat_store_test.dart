import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vncoughalert/features/chat/domain/models/chat_models.dart';
import 'package:vncoughalert/features/chat/providers/chat_providers.dart';

void main() {
  late ProviderContainer container;
  late ChatStore store;

  setUp(() {
    container = ProviderContainer();
    store = container.read(chatStoreProvider.notifier);
  });

  tearDown(() => container.dispose());

  ChatStoreState state() => container.read(chatStoreProvider);

  test('first send creates one session and completes pending reply', () async {
    final id = store.newChatId();
    final pending = store.send(chatId: id, text: 'Ping the mock');

    expect(state().sessions.where((s) => s.id == id), hasLength(1));
    expect(state().sessions.first.id, id);
    expect(state().sessions.first.title, 'Ping the mock');

    var messages = state().messagesOf(id);
    expect(messages, hasLength(2));
    expect(messages.first.role, ChatRole.user);
    expect(messages.first.text, 'Ping the mock');
    expect(messages.last.isPending, isTrue);

    await pending;
    messages = state().messagesOf(id);
    expect(messages, hasLength(2));
    expect(messages.last.isPending, isFalse);
    expect(
      messages.last.text,
      'Đây là phản hồi mẫu (mock) cho: "Ping the mock"',
    );
  });

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
}
