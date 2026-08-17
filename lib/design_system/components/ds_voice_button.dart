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
    final color = enabled ? AppColor.accentVoice : AppColor.composerFill;
    return Semantics(
      button: true,
      label: enabled ? 'Send message' : 'Send message disabled',
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          splashColor: AppColor.accentVoicePressed,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Center(
              child: IconfyIconWidget(
                IconfyIcons.message.sendMessage3.bold.regular,
                color: enabled ? AppColor.iconOnAccent : AppColor.iconMuted,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
