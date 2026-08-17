import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mistralai_dart/mistralai_dart.dart' as mistral;
import 'package:vncoughalert/app.dart';
import 'package:vncoughalert/design_system/components/ds_composer.dart';
import 'package:vncoughalert/design_system/components/ds_message_bubble.dart';
import 'package:vncoughalert/design_system/components/ds_sidebar.dart';
import 'package:vncoughalert/design_system/components/ds_voice_button.dart';
import 'package:vncoughalert/features/chat/data/mistral_chat_client.dart';
import 'package:vncoughalert/features/chat/providers/chat_providers.dart';
import 'package:vncoughalert/router/app_coordinator.dart';

class _WidgetFakeLlm implements ChatLlmClient {
  @override
  Stream<String> stream(List<mistral.ChatMessage> messages) async* {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final lastUser = messages.reversed.firstWhere((m) => m.role == 'user');
    final content = lastUser.toJson()['content'] as String;
    yield 'Đây là phản hồi mẫu (mock) cho: "$content"';
  }
}

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      VnCoughAlertRoot(
        coordinator: AppCoordinator(),
        overrides: [chatLlmClientProvider.overrideWithValue(_WidgetFakeLlm())],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> sendComposer(WidgetTester tester, String text) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(DsComposer),
        matching: find.byType(TextField),
      ),
      text,
    );
    await tester.pump();
    await tester.tap(find.byType(DsVoiceButton));
    await tester.pump();
  }

  Future<void> openSidebar(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
  }

  Future<void> tapRecent(WidgetTester tester, String title) async {
    await tester.tap(
      find.descendant(
        of: find.byType(DsSidebarPanel),
        matching: find.text(title),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder bubbleText(String text) {
    return find.descendant(
      of: find.byType(DsMessageBubble),
      matching: find.text(text),
    );
  }

  Finder recentText(String text) {
    return find.descendant(
      of: find.byType(DsRecentRow),
      matching: find.text(text),
    );
  }

  testWidgets('chat smoke: composer and sidebar recents', (tester) async {
    await pumpApp(tester);

    expect(find.text('Nhập tin nhắn...'), findsOneWidget);

    await openSidebar(tester);

    expect(find.text('Recents'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Ho khan kéo dài 2 tuần'), findsOneWidget);
  });

  testWidgets('first send stays on this screen with user then mock reply', (
    tester,
  ) async {
    await pumpApp(tester);
    await sendComposer(tester, 'Unique ping 42');

    expect(bubbleText('Unique ping 42'), findsOneWidget);
    expect(recentText('Unique ping 42'), findsOneWidget);
    expect(find.byType(DsTypingDots), findsOneWidget);
    expect(find.text('Nhập tin nhắn...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.byType(DsTypingDots), findsNothing);
    expect(
      bubbleText('Đây là phản hồi mẫu (mock) cho: "Unique ping 42"'),
      findsOneWidget,
    );
    expect(find.text('Nhập tin nhắn...'), findsOneWidget);
  });

  testWidgets('second send on empty chat stays on one composer', (
    tester,
  ) async {
    await pumpApp(tester);
    await sendComposer(tester, 'First unique');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    await sendComposer(tester, 'Second unique');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(bubbleText('First unique'), findsOneWidget);
    expect(bubbleText('Second unique'), findsOneWidget);
    expect(find.text('Nhập tin nhắn...'), findsOneWidget);
  });

  testWidgets('new chat after send keeps session in recents', (tester) async {
    await pumpApp(tester);
    await sendComposer(tester, 'Keep this thread');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    await tester.tap(find.byTooltip('New chat'));
    await tester.pumpAndSettle();

    expect(bubbleText('Keep this thread'), findsNothing);
    expect(find.byType(DsMessageBubble), findsNothing);
    expect(recentText('Keep this thread'), findsOneWidget);

    await openSidebar(tester);
    expect(find.byType(DsRecentRow), findsNWidgets(5));
    await tapRecent(tester, 'Keep this thread');

    expect(bubbleText('Keep this thread'), findsOneWidget);
    expect(
      bubbleText('Đây là phản hồi mẫu (mock) cho: "Keep this thread"'),
      findsOneWidget,
    );
  });

  testWidgets('new chat before send does not add an empty session', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('New chat'));
    await tester.pumpAndSettle();

    expect(find.byType(DsRecentRow), findsNWidgets(4));
  });

  testWidgets('new chat during pending still saves the reply', (tester) async {
    await pumpApp(tester);
    await sendComposer(tester, 'Pending then new');

    expect(find.byType(DsTypingDots), findsOneWidget);

    await tester.tap(find.byTooltip('New chat'));
    await tester.pump();

    expect(bubbleText('Pending then new'), findsNothing);
    expect(find.byType(DsMessageBubble), findsNothing);
    expect(recentText('Pending then new'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    await openSidebar(tester);
    await tapRecent(tester, 'Pending then new');

    expect(bubbleText('Pending then new'), findsOneWidget);
    expect(
      bubbleText('Đây là phản hồi mẫu (mock) cho: "Pending then new"'),
      findsOneWidget,
    );
  });

  testWidgets('tapping the open draft recent does not drop messages', (
    tester,
  ) async {
    await pumpApp(tester);
    await sendComposer(tester, 'Stay on draft');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    await openSidebar(tester);
    await tapRecent(tester, 'Stay on draft');

    expect(bubbleText('Stay on draft'), findsOneWidget);
    expect(
      bubbleText('Đây là phản hồi mẫu (mock) cho: "Stay on draft"'),
      findsOneWidget,
    );
    expect(find.text('Nhập tin nhắn...'), findsOneWidget);
  });

  testWidgets('new chat after opening a seed then send keeps the seed', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSidebar(tester);
    await tapRecent(tester, 'Khó thở nhẹ buổi tối');

    expect(bubbleText('Khó thở nhẹ buổi tối'), findsOneWidget);

    await tester.tap(find.byTooltip('New chat'));
    await tester.pumpAndSettle();
    await sendComposer(tester, 'Brand new thread');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    await openSidebar(tester);
    expect(recentText('Khó thở nhẹ buổi tối'), findsOneWidget);
    expect(recentText('Brand new thread'), findsOneWidget);
    expect(bubbleText('Brand new thread'), findsOneWidget);
  });
}
