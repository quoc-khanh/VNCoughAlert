import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceClip {
  const VoiceClip({
    required this.path,
    required this.duration,
    required this.levels,
  });

  final String path;
  final Duration duration;
  final List<double> levels;
}

class VoiceRecorder {
  VoiceRecorder({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final _levelsController = StreamController<double>.broadcast();
  final List<double> _levels = [];
  StreamSubscription<Amplitude>? _amplitudeSub;
  DateTime? _startedAt;
  String? _path;

  Stream<double> get amplitudes => _levelsController.stream;

  List<double> get levels => List.unmodifiable(_levels);

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<bool> start() async {
    final allowed = await _recorder.hasPermission();
    if (!allowed) {
      return false;
    }
    if (await _recorder.isRecording()) {
      await cancel();
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _path = path;
    _startedAt = DateTime.now();
    _levels.clear();
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    _amplitudeSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 70))
        .listen((amplitude) {
          final level = _normalize(amplitude.current);
          _levels.add(level);
          if (_levels.length > 48) {
            _levels.removeAt(0);
          }
          _levelsController.add(level);
        });
    return true;
  }

  Future<VoiceClip?> stop() async {
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    final path = await _recorder.stop() ?? _path;
    final startedAt = _startedAt;
    _startedAt = null;
    _path = null;
    if (path == null || startedAt == null) {
      return null;
    }
    var duration = DateTime.now().difference(startedAt);
    if (duration < const Duration(milliseconds: 400)) {
      duration = const Duration(milliseconds: 400);
    }
    return VoiceClip(
      path: path,
      duration: duration,
      levels: List<double>.from(_levels),
    );
  }

  Future<void> cancel() async {
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    String? path;
    if (await _recorder.isRecording()) {
      path = await _recorder.stop() ?? _path;
    } else {
      path = _path;
    }
    _startedAt = null;
    _path = null;
    _levels.clear();
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> deleteClip(VoiceClip clip) async {
    final file = File(clip.path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> dispose() async {
    await cancel();
    await _levelsController.close();
    await _recorder.dispose();
  }

  static double _normalize(double db) {
    const minDb = -45.0;
    const maxDb = 0.0;
    if (db.isNaN) {
      return 0.12;
    }
    return ((db - minDb) / (maxDb - minDb)).clamp(0.08, 1.0);
  }
}
