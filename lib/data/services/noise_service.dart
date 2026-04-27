import 'dart:async';
import 'package:noise_meter/noise_meter.dart';

/// 소음 측정
/// - NoiseMeter로 샘플링 후 평균 dB 반환
class NoiseService {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _sub;

  /// [duration] 동안 소음을 수집해 평균 dB를 반환
  Future<double> measureAverage({
    Duration duration = const Duration(seconds: 4),
  }) async {
    final samples = <double>[];
    _noiseMeter = NoiseMeter();

    try {
      _sub = _noiseMeter!.noise.listen(
        (reading) {
          final db = reading.meanDecibel;
          if (!db.isNaN && !db.isInfinite && db > 0) {
            samples.add(db);
          }
        },
        onError: (_) {},
      );

      await Future.delayed(duration);
      await _sub?.cancel();

      if (samples.isEmpty) return -1;
      final avg = samples.reduce((a, b) => a + b) / samples.length;
      return avg;
    } catch (_) {
      await _sub?.cancel();
      return -1;
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
