import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:vncoughalert/design_system/components/ds_composer.dart';
import 'package:vncoughalert/design_system/components/ds_icon_button.dart';
import 'package:vncoughalert/design_system/components/ds_message_bubble.dart';
import 'package:vncoughalert/design_system/components/ds_sidebar.dart';
import 'package:vncoughalert/design_system/components/ds_upgrade_pill.dart';
import 'package:vncoughalert/design_system/components/ds_voice_button.dart';
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
  return dsPreviewShell(
    child: const DsVoiceButton(onPressed: null),
  );
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

@Preview(name: 'User bubble', group: 'Design System')
Widget previewUserBubble() {
  return dsPreviewShell(
    child: const DsMessageBubble(
      role: DsMessageRole.user,
      text: 'Ho khan kéo dài 2 tuần thì sao?',
    ),
  );
}

@Preview(name: 'Assistant bubble', group: 'Design System')
Widget previewAssistantBubble() {
  return dsPreviewShell(
    child: const DsMessageBubble(
      role: DsMessageRole.assistant,
      text: 'Đây là phản hồi mẫu từ VNCoughAlert.',
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
