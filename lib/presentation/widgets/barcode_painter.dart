import 'dart:math';
import 'package:flutter/material.dart';

/// 영수증 하단의 가짜 바코드
class BarcodePainter extends CustomPainter {
  final Color color;
  final int seed;

  BarcodePainter({required this.color, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final random = Random(seed);

    double x = 0;
    while (x < size.width) {
      final width = random.nextInt(3) + 1.0; // 1~3
      final gap = random.nextInt(3) + 1.0;   // 1~3
      canvas.drawRect(
        Rect.fromLTWH(x, 0, width, size.height),
        paint,
      );
      x += width + gap;
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter oldDelegate) =>
      oldDelegate.seed != seed || oldDelegate.color != color;
}
