import 'package:flutter/material.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:motor/motor.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_radius.dart';
import 'package:vncoughalert/design_system/tokens/app_space.dart';
import 'package:vncoughalert/design_system/tokens/app_text_style.dart';

class DsSidebarSearch extends StatelessWidget {
  const DsSidebarSearch({
    super.key,
    required this.controller,
    required this.hintText,
    required this.focusNode,
    required this.expand,
    this.onChanged,
    this.onTap,
  });

  final TextEditingController controller;
  final String hintText;
  final FocusNode focusNode;
  final double expand;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  static const double collapsedWidth = 40;

  @override
  Widget build(BuildContext context) {
    final t = expand.clamp(0.0, 1.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColor.composerFill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColor.border.withValues(alpha: t)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onTap: onTap,
        onTapOutside: (_) => focusNode.unfocus(),
        style: AppTextStyle.body(),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: AppTextStyle.body(
            color: AppColor.textPlaceholder.withValues(alpha: t),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(AppSpace.xs),
            child: IconfyIconWidget(
              IconfyIcons.essential.search.outline.regular,
              size: 20,
              color: AppColor.iconMuted,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: collapsedWidth,
            minHeight: collapsedWidth,
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpace.sm,
            vertical: AppSpace.xs,
          ),
        ),
      ),
    );
  }
}

class DsSidebarNavItem extends StatelessWidget {
  const DsSidebarNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.selected = false,
  });

  final IconfyIconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      selected: selected,
      selectedTileColor: AppColor.accentSoft,
      selectedColor: AppColor.accentVoice,
      leading: IconfyIconWidget(
        icon,
        color: selected ? AppColor.accentVoice : AppColor.iconDefault,
        size: 22,
      ),
      title: Text(
        label,
        style: AppTextStyle.label(
          color: selected ? AppColor.accentVoice : AppColor.textHigh,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
    );
  }
}

class DsRecentRow extends StatelessWidget {
  const DsRecentRow({
    super.key,
    required this.title,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      selected: selected,
      selectedTileColor: AppColor.canvas,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.bodySm(
          color: selected ? AppColor.textHigh : AppColor.textMedium,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
    );
  }
}

class DsSidebarPanel extends StatefulWidget {
  const DsSidebarPanel({
    super.key,
    required this.title,
    required this.searchHint,
    required this.searchController,
    required this.onSearchChanged,
    required this.navItems,
    required this.recentsLabel,
    required this.recents,
    this.footer,
  });

  final String title;
  final String searchHint;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<Widget> navItems;
  final String recentsLabel;
  final List<Widget> recents;
  final Widget? footer;

  @override
  State<DsSidebarPanel> createState() => _DsSidebarPanelState();
}

class _DsSidebarPanelState extends State<DsSidebarPanel> {
  final FocusNode _searchFocus = FocusNode();
  late bool _searchOpen;

  @override
  void initState() {
    super.initState();
    _searchOpen = _searchFocus.hasFocus;
    _searchFocus.addListener(_syncSearchOpen);
  }

  @override
  void dispose() {
    _searchFocus.removeListener(_syncSearchOpen);
    _searchFocus.dispose();
    super.dispose();
  }

  void _syncSearchOpen() {
    final open = _searchFocus.hasFocus;
    if (open == _searchOpen) {
      return;
    }
    setState(() => _searchOpen = open);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.sidebar,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.md,
                AppSpace.sm,
                AppSpace.xs,
                AppSpace.sm,
              ),
              child: SingleMotionBuilder(
                motion: const CupertinoMotion.snappy(),
                value: _searchOpen ? 1.0 : 0.0,
                builder: (context, t, child) {
                  final progress = t.clamp(0.0, 1.0);
                  final hideTitle = 1 - progress;
                  return Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: AppColor.accentVoice,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.health_and_safety_outlined,
                          color: AppColor.iconOnAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: hideTitle,
                          child: Opacity(
                            opacity: hideTitle,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: AppSpace.sm * hideTitle,
                              ),
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                softWrap: false,
                                style: AppTextStyle.titleSm(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final available = constraints.maxWidth;
                            if (!available.isFinite || available <= 0) {
                              return const SizedBox.shrink();
                            }
                            final collapsed = DsSidebarSearch.collapsedWidth;
                            final width = available <= collapsed
                                ? available
                                : collapsed +
                                      (available - collapsed) * progress;
                            return Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: width,
                                child: ClipRect(
                                  child: DsSidebarSearch(
                                    controller: widget.searchController,
                                    hintText: widget.searchHint,
                                    focusNode: _searchFocus,
                                    expand: progress,
                                    onChanged: widget.onSearchChanged,
                                    onTap: () => _searchFocus.requestFocus(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ...widget.navItems,
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.md,
                AppSpace.md,
                AppSpace.md,
                AppSpace.xs,
              ),
              child: Text(
                widget.recentsLabel,
                style: AppTextStyle.caption(color: AppColor.textMedium),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpace.lg),
                children: widget.recents,
              ),
            ),
            if (widget.footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.md,
                  AppSpace.xs,
                  AppSpace.md,
                  AppSpace.lg,
                ),
                child: widget.footer,
              ),
          ],
        ),
      ),
    );
  }
}
