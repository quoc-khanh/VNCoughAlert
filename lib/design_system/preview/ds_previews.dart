import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:vncoughalert/design_system/components/ds_composer.dart';
import 'package:vncoughalert/design_system/components/ds_icon_button.dart';
import 'package:vncoughalert/design_system/components/ds_markdown_body.dart';
import 'package:vncoughalert/design_system/components/ds_message_bubble.dart';
import 'package:vncoughalert/design_system/components/ds_sidebar.dart';
import 'package:vncoughalert/design_system/components/ds_upgrade_pill.dart';
import 'package:vncoughalert/design_system/components/ds_voice_button.dart';
import 'package:vncoughalert/design_system/components/ds_voice_draft_card.dart';
import 'package:vncoughalert/design_system/components/ds_voice_player.dart';
import 'package:vncoughalert/design_system/components/ds_voice_waveform.dart';
import 'package:vncoughalert/design_system/theme/app_theme.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_space.dart';

Widget dsPreviewShell({required Widget child}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: Scaffold(
      backgroundColor: AppColor.canvas,
      body: Padding(padding: const EdgeInsets.all(AppSpace.md), child: child),
    ),
  );
}

@Preview(name: 'Icon button', group: 'Design System')
Widget previewIconButton() {
  return dsPreviewShell(
    child: DsIconButton(
      icon: IconfyIcons.editor.hamburgerMenu.outline.regular,
      onPressed: null,
    ),
  );
}

@Preview(name: 'Upgrade pill', group: 'Design System')
Widget previewUpgradePill() {
  return dsPreviewShell(child: const DsUpgradePill(label: 'Upgrade'));
}

@Preview(name: 'Voice button', group: 'Design System')
Widget previewVoiceButton() {
  return dsPreviewShell(child: const DsVoiceButton(onPressed: null));
}

@Preview(name: 'Composer empty', group: 'Design System')
Widget previewComposerEmpty() {
  return dsPreviewShell(
    child: DsComposer(
      controller: TextEditingController(),
      hintText: 'Ask VNCoughAlert',
    ),
  );
}

@Preview(name: 'Composer disabled', group: 'Design System')
Widget previewComposerDisabled() {
  return dsPreviewShell(
    child: DsComposer(
      controller: TextEditingController(text: 'Hello'),
      hintText: 'Ask VNCoughAlert',
      enabled: false,
    ),
  );
}

@Preview(name: 'Composer recording', group: 'Design System')
Widget previewComposerRecording() {
  return dsPreviewShell(
    child: DsComposer(
      controller: TextEditingController(),
      hintText: 'Ask VNCoughAlert',
      isRecording: true,
      waveformLevels: const [0.2, 0.55, 0.3, 0.8, 0.4, 0.65, 0.25, 0.5],
    ),
  );
}

@Preview(name: 'Voice waveform', group: 'Design System')
Widget previewVoiceWaveform() {
  return dsPreviewShell(
    child: const SizedBox(
      width: 240,
      child: DsVoiceWaveform(
        levels: [0.2, 0.55, 0.3, 0.8, 0.4, 0.65, 0.25, 0.5, 0.7, 0.35],
      ),
    ),
  );
}

@Preview(name: 'Voice draft card', group: 'Design System')
Widget previewVoiceDraftCard() {
  return dsPreviewShell(
    child: DsVoiceDraftCard(
      duration: const Duration(seconds: 12),
      onRemove: () {},
    ),
  );
}

@Preview(name: 'Voice draft strip', group: 'Design System')
Widget previewVoiceDraftStrip() {
  return dsPreviewShell(
    child: SizedBox(
      height: DsVoiceDraftCard.extentHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          DsVoiceDraftCard(
            duration: const Duration(seconds: 4),
            onRemove: () {},
          ),
          const SizedBox(width: AppSpace.xs),
          DsVoiceDraftCard(
            duration: const Duration(seconds: 12),
            onRemove: () {},
          ),
          const SizedBox(width: AppSpace.xs),
          DsVoiceDraftCard(
            duration: const Duration(seconds: 21),
            onRemove: () {},
          ),
        ],
      ),
    ),
  );
}

@Preview(name: 'Voice player', group: 'Design System')
Widget previewVoicePlayer() {
  return dsPreviewShell(
    child: const DsVoicePlayer(duration: Duration(seconds: 18)),
  );
}

@Preview(name: 'User bubble', group: 'Design System')
Widget previewUserBubble() {
  return dsPreviewShell(
    child: const DsMessageBubble(
      role: DsMessageRole.user,
      text: 'Ho khan kéo dài 2 tuần thì sao?',
    ),
  );
}

@Preview(name: 'User bubble with voice', group: 'Design System')
Widget previewUserBubbleVoice() {
  return dsPreviewShell(
    child: const DsMessageBubble(
      role: DsMessageRole.user,
      text: 'Nghe giúp đoạn này.',
      audios: [
        DsVoiceAttachment(
          duration: Duration(seconds: 8),
          levels: [0.2, 0.5, 0.3, 0.7, 0.4, 0.6],
        ),
      ],
    ),
  );
}

@Preview(name: 'Markdown body', group: 'Design System')
Widget previewMarkdownBody() {
  return dsPreviewShell(
    child: const DsMarkdownBody(
      data: '''
**In đậm** và *nghiêng*

- Mục một
- Mục hai

Dùng `inline code` hoặc:

```
fenced block
```
''',
    ),
  );
}

@Preview(name: 'Assistant bubble', group: 'Design System')
Widget previewAssistantBubble() {
  return dsPreviewShell(
    child: const DsMessageBubble(
      role: DsMessageRole.assistant,
      text:
          '**Gợi ý:**\n\n- Uống đủ nước\n- Nghỉ ngơi\n\nNếu ho kéo dài, hãy gặp bác sĩ.',
    ),
  );
}

@Preview(name: 'Assistant bubble streaming', group: 'Design System')
Widget previewAssistantBubbleStreaming() {
  return dsPreviewShell(
    child: const DsMessageBubble(
      role: DsMessageRole.assistant,
      text: 'Đang trả lời **markdown**…',
      isPending: true,
    ),
  );
}

@Preview(name: 'Assistant bubble pending', group: 'Design System')
Widget previewAssistantBubblePending() {
  return dsPreviewShell(
    child: const DsMessageBubble(
      role: DsMessageRole.assistant,
      text: '',
      isPending: true,
    ),
  );
}

@Preview(name: 'Sidebar nav item', group: 'Design System')
Widget previewSidebarNav() {
  return dsPreviewShell(
    child: DsSidebarNavItem(
      icon: IconfyIcons.essential.document.outline.regular,
      label: 'Library',
      selected: true,
    ),
  );
}

@Preview(name: 'Recent row', group: 'Design System')
Widget previewRecentRow() {
  return dsPreviewShell(
    child: const DsRecentRow(
      title: 'Chống rung X100VI vs X-E5',
      selected: true,
    ),
  );
}

@Preview(name: 'Sidebar search collapsed', group: 'Design System')
Widget previewSidebarSearchCollapsed() {
  return dsPreviewShell(
    child: SizedBox(
      width: DsSidebarSearch.collapsedWidth,
      child: DsSidebarSearch(
        controller: TextEditingController(),
        hintText: 'Search',
        focusNode: FocusNode(),
        expand: 0,
      ),
    ),
  );
}

@Preview(name: 'Sidebar search expanded', group: 'Design System')
Widget previewSidebarSearchExpanded() {
  return dsPreviewShell(
    child: DsSidebarSearch(
      controller: TextEditingController(),
      hintText: 'Search',
      focusNode: FocusNode(),
      expand: 1,
    ),
  );
}

@Preview(name: 'Sidebar panel', group: 'Design System')
Widget previewSidebarPanel() {
  return dsPreviewShell(
    child: SizedBox(
      width: 320,
      height: 480,
      child: DsSidebarPanel(
        title: 'VNCoughAlert',
        searchHint: 'Search',
        searchController: TextEditingController(),
        onSearchChanged: (_) {},
        recentsLabel: 'Recents',
        navItems: [
          DsSidebarNavItem(
            icon: IconfyIcons.essential.document.outline.regular,
            label: 'Library',
          ),
        ],
        recents: const [DsRecentRow(title: 'Chống rung X100VI vs X-E5')],
      ),
    ),
  );
}
