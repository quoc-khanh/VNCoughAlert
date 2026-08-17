import 'package:flutter/material.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:vncoughalert/design_system/components/ds_icon_button.dart';
import 'package:vncoughalert/design_system/components/ds_voice_waveform.dart';
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
    this.isRecording = false,
    this.waveformLevels = const [],
    this.onCancelRecording,
    this.onStopRecording,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onAttach;
  final VoidCallback? onMic;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final FocusNode? focusNode;
  final bool isRecording;
  final List<double> waveformLevels;
  final VoidCallback? onCancelRecording;
  final VoidCallback? onStopRecording;

  @override
  Widget build(BuildContext context) {
    if (isRecording) {
      return _RecordingBar(
        levels: waveformLevels,
        onCancel: onCancelRecording,
        onStop: onStopRecording,
      );
    }
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

class _RecordingBar extends StatelessWidget {
  const _RecordingBar({required this.levels, this.onCancel, this.onStop});

  final List<double> levels;
  final VoidCallback? onCancel;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: AppColor.composerFill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
      child: Row(
        children: [
          DsIconButton(
            icon: IconfyIcons.alert.closeRemove.bold.regular,
            tooltip: 'Cancel recording',
            onPressed: onCancel,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
              child: DsVoiceWaveform(levels: levels),
            ),
          ),
          _StopRecordingButton(onPressed: onStop),
        ],
      ),
    );
  }
}

class _StopRecordingButton extends StatelessWidget {
  const _StopRecordingButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Stop',
      child: Material(
        color: AppColor.border,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColor.iconDefault,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
