import 'package:flutter/material.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_space.dart';

class DsIconButton extends StatelessWidget {
  const DsIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 40,
    this.iconSize = 22,
  });

  final IconfyIconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: IconfyIconWidget(
          icon,
          size: iconSize,
          color: onPressed == null ? AppColor.iconMuted : AppColor.iconDefault,
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Tight padding helper for header rows.
class DsHeaderGap extends StatelessWidget {
  const DsHeaderGap({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: AppSpace.xs);
  }
}
