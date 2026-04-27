import 'dart:async';
import 'package:light_sensor/light_sensor.dart';

/// 조도 센서 측정
/// - 일정 시간 동안 샘플링해 평균 Lux 반환
class LightService {
  /// [duration] 동안 조도 값을 수집해 평균을 반환
  /// 센서가 없거나 값이 안 올 경우 -1 반환
  Future<double> measureAverage({
    Duration duration = const Duration(seconds: 3),
  }) async {
    final samples = <double>[];
    StreamSubscription<int>? sub;

    try {
      final hasSensor = await LightSensor.hasSensor();
      if (!hasSensor) return -1;

      sub = LightSensor.luxStream().listen((lux) {
        samples.add(lux.toDouble());
      });

      await Future.delayed(duration);
      await sub.cancel();

      if (samples.isEmpty) return -1;
      final avg = samples.reduce((a, b) => a + b) / samples.length;
      return avg;
    } catch (_) {
      await sub?.cancel();
      return -1;
    }
  }
}
