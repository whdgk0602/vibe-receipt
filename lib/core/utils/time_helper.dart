/// 하루의 시간대를 5구간으로 분류
enum TimeBand {
  dawn,      // 새벽 0~5
  morning,   // 아침 6~10
  day,       // 낮 11~16
  evening,   // 저녁 17~20
  latenight, // 심야 21~23
}

class TimeHelper {
  TimeHelper._();

  static TimeBand bandOf(DateTime now) {
    final h = now.hour;
    if (h <= 5) return TimeBand.dawn;
    if (h <= 10) return TimeBand.morning;
    if (h <= 16) return TimeBand.day;
    if (h <= 20) return TimeBand.evening;
    return TimeBand.latenight;
  }

  static String labelOf(TimeBand band) {
    switch (band) {
      case TimeBand.dawn:
        return '새벽';
      case TimeBand.morning:
        return '아침';
      case TimeBand.day:
        return '낮';
      case TimeBand.evening:
        return '저녁';
      case TimeBand.latenight:
        return '심야';
    }
  }
}
