import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vncoughalert/design_system/components/ds_message_bubble.dart';
import 'package:vncoughalert/design_system/theme/app_theme.dart';

void main() {
  Future<void> pumpBubble(
    WidgetTester tester, {
    required DsMessageRole role,
    required String text,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: DsMessageBubble(role: role, text: text),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('assistant bubble renders markdown bold without asterisks', (
    tester,
  ) async {
    await pumpBubble(tester, role: DsMessageRole.assistant, text: '**in đậm**');

    expect(find.text('**in đậm**'), findsNothing);
    expect(find.text('in đậm'), findsOneWidget);
    expect(find.byType(MarkdownBody), findsOneWidget);
  });

  testWidgets('user bubble keeps plain text', (tester) async {
    await pumpBubble(tester, role: DsMessageRole.user, text: '**không parse**');

    expect(find.text('**không parse**'), findsOneWidget);
    expect(find.byType(MarkdownBody), findsNothing);
  });

  testWidgets('pending assistant with text shows markdown instead of dots', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: DsMessageBubble(
            role: DsMessageRole.assistant,
            text: '**stream**',
            isPending: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DsTypingDots), findsNothing);
    expect(find.text('stream'), findsOneWidget);
  });
}
