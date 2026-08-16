import 'package:flutter/material.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';

class DsVoiceButton extends StatelessWidget {
  const DsVoiceButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.accentVoice,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: IconfyIconWidget(
              IconfyIcons.message.sendMessage3.bold.regular,
              color: AppColor.iconOnAccent,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
