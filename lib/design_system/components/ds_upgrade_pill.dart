import 'package:flutter/material.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_radius.dart';
import 'package:vncoughalert/design_system/tokens/app_space.dart';
import 'package:vncoughalert/design_system/tokens/app_text_style.dart';

class DsUpgradePill extends StatelessWidget {
  const DsUpgradePill({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.canvas,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.sm,
            vertical: AppSpace.xxs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColor.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.diamond_outlined,
                size: 14,
                color: AppColor.accentUpgrade,
              ),
              const SizedBox(width: AppSpace.xxs),
              Text(label, style: AppTextStyle.label()),
            ],
          ),
        ),
      ),
    );
  }
}
