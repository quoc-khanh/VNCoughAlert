import 'package:flutter/material.dart';
import 'package:motor/motor.dart';
import 'package:vncoughalert/design_system/components/ds_diagnosis_card.dart';
import 'package:vncoughalert/design_system/components/ds_markdown_body.dart';
import 'package:vncoughalert/design_system/components/ds_voice_player.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_radius.dart';
import 'package:vncoughalert/design_system/tokens/app_space.dart';
import 'package:vncoughalert/design_system/tokens/app_text_style.dart';

enum DsMessageRole { user, assistant }

class DsVoiceAttachment {
  const DsVoiceAttachment({
    this.path,
    required this.duration,
    this.levels = const [],
  });

  final String? path;
  final Duration duration;
  final List<double> levels;
}

class DsMessageBubble extends StatefulWidget {
  const DsMessageBubble({
    super.key,
    required this.role,
    required this.text,
    this.isPending = false,
    this.audios = const [],
    this.diagnoses = const [],
    this.onCaseStudy,
    this.onConnectDoctor,
  });

  final DsMessageRole role;
  final String text;
  final bool isPending;
  final List<DsVoiceAttachment> audios;
  final List<DsDiagnosisSummary> diagnoses;
  final VoidCallback? onCaseStudy;
  final VoidCallback? onConnectDoctor;

  @override
  State<DsMessageBubble> createState() => _DsMessageBubbleState();
}

class _DsMessageBubbleState extends State<DsMessageBubble> {
  var _entered = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _entered = 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.role == DsMessageRole.user;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser ? AppColor.userBubble : AppColor.assistantBubble;
    final shape = AppRadius.superellipse(AppRadius.bubble);
    final textColor = isUser ? AppColor.textOnAccent : AppColor.textHigh;

    return Align(
      alignment: align,
      child: SingleMotionBuilder(
        motion: const CupertinoMotion.snappy(),
        value: _entered,
        builder: (context, t, child) {
          final progress = t.clamp(0.0, 1.0);
          return Opacity(
            opacity: progress,
            child: Transform.translate(
              offset: Offset(
                isUser ? 10 * (1 - progress) : -6 * (1 - progress),
                12 * (1 - progress),
              ),
              child: Transform.scale(
                alignment: isUser
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                scale: 0.94 + 0.06 * progress,
                child: child,
              ),
            ),
          );
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.sizeOf(context).width.clamp(0.0, 880.0).toDouble() *
                0.78,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.xxs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isUser) ...[
                  Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(right: AppSpace.xs),
                    decoration: const BoxDecoration(
                      color: AppColor.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'V',
                        style: TextStyle(
                          color: AppColor.accentVoice,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
                Flexible(
                  child: Material(
                    color: color,
                    shape: shape,
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        border: isUser
                            ? null
                            : Border.all(color: AppColor.border),
                        borderRadius: BorderRadius.circular(AppRadius.bubble),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.md,
                        vertical: AppSpace.sm,
                      ),
                      child: widget.isPending && widget.text.trim().isEmpty
                          ? const DsTypingDots()
                          : _MessageBody(
                              role: widget.role,
                              text: widget.text,
                              textColor: textColor,
                              audios: widget.audios,
                              diagnoses: widget.diagnoses,
                              onCaseStudy: widget.onCaseStudy,
                              onConnectDoctor: widget.onConnectDoctor,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({
    required this.role,
    required this.text,
    required this.textColor,
    required this.audios,
    required this.diagnoses,
    this.onCaseStudy,
    this.onConnectDoctor,
  });

  final DsMessageRole role;
  final String text;
  final Color textColor;
  final List<DsVoiceAttachment> audios;
  final List<DsDiagnosisSummary> diagnoses;
  final VoidCallback? onCaseStudy;
  final VoidCallback? onConnectDoctor;

  @override
  Widget build(BuildContext context) {
    final hasText = text.trim().isNotEmpty;
    final isAssistant = role == DsMessageRole.assistant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < audios.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpace.sm),
          DsVoicePlayer(
            audioPath: audios[i].path,
            duration: audios[i].duration,
            levels: audios[i].levels,
          ),
        ],
        if (audios.isNotEmpty && hasText) const SizedBox(height: AppSpace.sm),
        if (hasText)
          isAssistant
              ? DsMarkdownBody(data: text)
              : Text(text, style: AppTextStyle.body(color: textColor)),
        if (isAssistant && diagnoses.isNotEmpty) ...[
          if (hasText) const SizedBox(height: AppSpace.sm),
          for (var i = 0; i < diagnoses.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpace.sm),
            DsDiagnosisCard(
              data: diagnoses[i],
              showActions: i == diagnoses.length - 1,
              onCaseStudy: onCaseStudy,
              onConnectDoctor: onConnectDoctor,
            ),
          ],
        ],
      ],
    );
  }
}

class DsTypingDots extends StatelessWidget {
  const DsTypingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 36,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DsTypingDot(delay: Duration.zero),
          SizedBox(width: 4),
          _DsTypingDot(delay: Duration(milliseconds: 120)),
          SizedBox(width: 4),
          _DsTypingDot(delay: Duration(milliseconds: 240)),
        ],
      ),
    );
  }
}

class _DsTypingDot extends StatefulWidget {
  const _DsTypingDot({required this.delay});

  final Duration delay;

  @override
  State<_DsTypingDot> createState() => _DsTypingDotState();
}

class _DsTypingDotState extends State<_DsTypingDot> {
  var _playing = false;

  static final _sequence = MotionSequence.steps(
    const [0.0, -4.0, 0.0],
    motion: const CupertinoMotion.snappy(),
    loop: LoopMode.loop,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _playing = true;
      return;
    }
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _playing = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SequenceMotionBuilder<int, double>(
      sequence: _sequence,
      converter: MotionConverter.single,
      playing: _playing,
      builder: (context, y, phase, child) {
        return Transform.translate(offset: Offset(0, y), child: child);
      },
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColor.textMedium,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
