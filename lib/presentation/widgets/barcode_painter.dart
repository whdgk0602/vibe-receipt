import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/constants/vibe_phrases.dart';

/// 무드별 고유 리듬 패턴을 가진 영수증 바코드
class BarcodePainter extends CustomPainter {
  final Color color;
  final int seed;
  final VibeMood mood;

  BarcodePainter({
    required this.color,
    required this.seed,
    required this.mood,
  });

  // 무드별 (막대 너비, 간격) 시퀀스 — 리듬이 무드의 성격을 반영
  List<(double, double)> _rhythm() {
    switch (mood) {
      case VibeMood.sentimental:
        // 느린 물결 — 넓은 막대, 넉넉한 간격
        return [(3, 5), (1, 4), (2, 5), (1, 6), (3, 4), (1, 5)];
      case VibeMood.joyful:
        // 경쾌한 리듬 — 얇은 막대, 촘촘한 간격
        return [(1, 1), (2, 1), (1, 2), (3, 1), (1, 1), (2, 1)];
      case VibeMood.calm:
        // 균일한 호흡 — 일정한 막대, 일정한 간격
        return [(2, 3), (2, 3), (1, 3), (2, 3), (2, 3), (1, 3)];
      case VibeMood.energetic:
        // 강렬한 밀도 — 굵은 막대, 최소 간격
        return [(4, 1), (3, 1), (5, 1), (3, 1), (4, 1), (2, 1)];
      case VibeMood.dreamy:
        // 흩어진 점 — 매우 얇은 막대, 넓은 공백
        return [(1, 7), (1, 5), (1, 8), (2, 6), (1, 7), (1, 5)];
      case VibeMood.focused:
        // 정밀 교차 — 얇은·굵은 막대가 규칙적으로 교차
        return [(2, 2), (4, 2), (2, 2), (4, 2), (2, 2), (4, 2)];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final random = Random(seed);
    final rhythm = _rhythm();
    int i = 0;
    double x = 0;

    while (x < size.width) {
      final (barW, gapW) = rhythm[i % rhythm.length];
      // 시드 기반 미세 변화 — 같은 무드도 매 영수증마다 조금씩 다름
      final jitter = (random.nextDouble() - 0.5) * 0.8;
      final bar = (barW + jitter).clamp(0.5, barW + 1.5);
      canvas.drawRect(Rect.fromLTWH(x, 0, bar, size.height), paint);
      x += bar + gapW;
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter old) =>
      old.seed != seed || old.color != color || old.mood != mood;
}
