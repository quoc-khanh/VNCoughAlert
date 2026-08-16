import 'package:flutter/material.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:vncoughalert/design_system/components/ds_icon_button.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_radius.dart';
import 'package:vncoughalert/design_system/tokens/app_space.dart';
import 'package:vncoughalert/design_system/tokens/app_text_style.dart';

class DsComposer extends StatelessWidget {
  const DsComposer({
    super.key,
    required this.controller,
    required this.hintText,
    this.onAttach,
    this.onMic,
    this.onSubmitted,
    this.enabled = true,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onAttach;
  final VoidCallback? onMic;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DsIconButton(
          icon: IconfyIcons.essential.plus.outline.regular,
          tooltip: 'Attach',
          onPressed: enabled ? onAttach : null,
        ),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: AppColor.composerFill,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: enabled,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: onSubmitted,
                    style: AppTextStyle.body(),
                    cursorColor: AppColor.accentVoice,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AppTextStyle.body(
                        color: AppColor.textPlaceholder,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpace.sm,
                      ),
                    ),
                  ),
                ),
                DsIconButton(
                  icon: IconfyIcons.ai.voiceWaveAi.light.regular,
                  tooltip: 'Voice input',
                  iconSize: 22,
                  onPressed: enabled ? onMic : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
