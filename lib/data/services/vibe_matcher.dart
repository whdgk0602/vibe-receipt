import 'dart:math';
import '../../core/constants/vibe_phrases.dart';
import '../../core/utils/time_helper.dart';
import '../models/receipt_model.dart';
import '../models/vibe_data.dart';

enum Level { low, mid, high }

class VibeMatcher {
  /// 조도 레벨 분류 (일반 실내/실외 체감 기준)
  Level luxLevel(double lux) {
    if (lux < 0) return Level.mid; // 측정 실패 시 중간값
    if (lux < 50) return Level.low;       // 어둑한 실내
    if (lux < 500) return Level.mid;      // 일반 실내
    return Level.high;                    // 밝은 실내 / 야외
  }

  /// 소음 레벨 분류 (생활 소음 기준 dB)
  Level dbLevel(double db) {
    if (db < 0) return Level.mid;
    if (db < 40) return Level.low;        // 조용한 방
    if (db < 65) return Level.mid;        // 일반 대화
    return Level.high;                    // 시끌벅적
  }

  /// 조도·소음·시간대 조합 → 무드 매핑
  VibeMood matchMood(VibeData data) {
    final l = luxLevel(data.lux);
    final n = dbLevel(data.decibel);
    final t = TimeHelper.bandOf(data.measuredAt);

    // 심야
    if (t == TimeBand.latenight) {
      if (l == Level.low && n == Level.low) return VibeMood.dreamy;
      if (l == Level.low && n == Level.mid) return VibeMood.sentimental;
      if (n == Level.high) return VibeMood.energetic;
      return VibeMood.dreamy;
    }

    // 새벽
    if (t == TimeBand.dawn) {
      if (n == Level.low) return VibeMood.calm;
      return VibeMood.dreamy;
    }

    // 아침
    if (t == TimeBand.morning) {
      if (l == Level.high && n == Level.low) return VibeMood.focused;
      if (l == Level.high && n == Level.high) return VibeMood.joyful;
      return VibeMood.calm;
    }

    // 낮
    if (t == TimeBand.day) {
      if (l == Level.high && n == Level.high) return VibeMood.joyful;
      if (l == Level.high && n == Level.low) return VibeMood.focused;
      if (n == Level.mid) return VibeMood.focused;
      return VibeMood.joyful;
    }

    // 저녁
    if (t == TimeBand.evening) {
      if (l == Level.low && n == Level.low) return VibeMood.sentimental;
      if (n == Level.high) return VibeMood.energetic;
      if (l == Level.low) return VibeMood.sentimental;
      return VibeMood.joyful;
    }

    return VibeMood.calm;
  }

  /// 무드에서 임의의 문구를 하나 뽑아 반환
  String pickPhrase(VibeMood mood, {int? seed}) {
    final phrases = vibeMoodStyles[mood]!.phrases;
    final random = seed != null ? Random(seed) : Random();
    return phrases[random.nextInt(phrases.length)];
  }

  /// VibeData → ReceiptModel 변환 (최종 매칭 결과)
  ReceiptModel buildReceipt(VibeData data) {
    final mood = matchMood(data);
    final phrase = pickPhrase(mood, seed: data.measuredAt.millisecondsSinceEpoch);
    final receiptNumber =
        'VR-${data.measuredAt.millisecondsSinceEpoch.toString().substring(5)}';
    return ReceiptModel(
      data: data,
      mood: mood,
      phrase: phrase,
      receiptNumber: receiptNumber,
    );
  }
}
