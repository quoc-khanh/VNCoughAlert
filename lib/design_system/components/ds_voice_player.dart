import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:iconfy_icon/iconfy_icon.dart';
import 'package:vncoughalert/design_system/components/ds_voice_waveform.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_space.dart';
import 'package:vncoughalert/design_system/tokens/app_text_style.dart';

class DsVoicePlayer extends StatefulWidget {
  const DsVoicePlayer({
    super.key,
    required this.duration,
    this.audioPath,
    this.levels = const [],
  });

  final String? audioPath;
  final Duration duration;
  final List<double> levels;

  @override
  State<DsVoicePlayer> createState() => _DsVoicePlayerState();
}

class _DsVoicePlayerState extends State<DsVoicePlayer> {
  AudioPlayer? _player;
  var _playing = false;
  var _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    final path = widget.audioPath;
    if (path == null) {
      return;
    }
    final player = AudioPlayer();
    _player = player;
    player.onPlayerStateChanged.listen((state) {
      if (!mounted) {
        return;
      }
      setState(() => _playing = state == PlayerState.playing);
    });
    player.onPositionChanged.listen((position) {
      if (!mounted) {
        return;
      }
      setState(() => _position = position);
    });
    player.onPlayerComplete.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _playing = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final player = _player;
    final path = widget.audioPath;
    if (player == null || path == null) {
      return;
    }
    if (_playing) {
      await player.pause();
      return;
    }
    if (_position == Duration.zero) {
      await player.play(DeviceFileSource(path));
      return;
    }
    await player.resume();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.duration.inMilliseconds;
    final progress = totalMs <= 0
        ? 0.0
        : (_position.inMilliseconds / totalMs).clamp(0.0, 1.0);
    final remaining = widget.duration - _position;
    final display = remaining.isNegative ? widget.duration : remaining;

    return Row(
      children: [
        Material(
          color: AppColor.iconDefault,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _toggle,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: IconfyIconWidget(
                  _playing
                      ? IconfyIcons.audio.pause.bold.regular
                      : IconfyIcons.audio.play.bold.regular,
                  size: 18,
                  color: AppColor.iconOnAccent,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: DsVoiceWaveform(
            levels: widget.levels.isEmpty
                ? const [0.2, 0.45, 0.3, 0.6, 0.35, 0.5]
                : widget.levels,
            progress: progress,
            height: 24,
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        Text(formatVoiceDuration(display), style: AppTextStyle.caption()),
      ],
    );
  }
}
