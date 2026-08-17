import 'package:flutter/material.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';

String formatVoiceDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class DsVoiceWaveform extends StatelessWidget {
  const DsVoiceWaveform({
    super.key,
    required this.levels,
    this.height = 28,
    this.progress,
    this.color = AppColor.textMedium,
    this.playedColor = AppColor.iconDefault,
  });

  /// Normalized 0–1 samples, oldest first.
  final List<double> levels;
  final double height;
  final double? progress;
  final Color color;
  final Color playedColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DsWaveformPainter(
          levels: levels,
          color: color,
          playedColor: playedColor,
          progress: progress,
        ),
      ),
    );
  }
}

class _DsWaveformPainter extends CustomPainter {
  _DsWaveformPainter({
    required this.levels,
    required this.color,
    required this.playedColor,
    required this.progress,
  });

  final List<double> levels;
  final Color color;
  final Color playedColor;
  final double? progress;

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 3.0;
    const gap = 3.0;
    final step = barWidth + gap;
    final count = (size.width / step).floor().clamp(8, 64);
    final playedUntil = progress == null
        ? -1
        : (count * progress!.clamp(0.0, 1.0)).floor();

    for (var i = 0; i < count; i++) {
      final sample = _sampleAt(i, count);
      final barHeight = (6 + sample * (size.height - 6)).clamp(
        4.0,
        size.height,
      );
      final x = i * step + barWidth / 2;
      final paint = Paint()
        ..color = i <= playedUntil ? playedColor : color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = barWidth;
      canvas.drawLine(
        Offset(x, (size.height - barHeight) / 2),
        Offset(x, (size.height + barHeight) / 2),
        paint,
      );
    }
  }

  double _sampleAt(int index, int count) {
    if (levels.isEmpty) {
      return 0.12;
    }
    if (levels.length == 1) {
      return levels.first.clamp(0.08, 1.0);
    }
    final t = index / (count - 1);
    final pos = t * (levels.length - 1);
    final lo = pos.floor();
    final hi = (lo + 1).clamp(0, levels.length - 1);
    final frac = pos - lo;
    return (levels[lo] * (1 - frac) + levels[hi] * frac).clamp(0.08, 1.0);
  }

  @override
  bool shouldRepaint(covariant _DsWaveformPainter oldDelegate) {
    return oldDelegate.levels != levels ||
        oldDelegate.color != color ||
        oldDelegate.playedColor != playedColor ||
        oldDelegate.progress != progress;
  }
}
