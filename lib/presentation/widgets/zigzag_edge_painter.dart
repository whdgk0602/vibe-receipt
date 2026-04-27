import 'package:flutter/material.dart';

/// 영수증 위/아래의 지그재그 절취선
class ZigzagEdgePainter extends CustomPainter {
  final Color color;
  final double toothWidth;
  final double toothHeight;
  final bool pointsDown;

  ZigzagEdgePainter({
    required this.color,
    this.toothWidth = 12,
    this.toothHeight = 8,
    this.pointsDown = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();

    if (pointsDown) {
      // 위쪽이 평평, 아래쪽이 뾰족
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height - toothHeight);
      double x = size.width;
      while (x > 0) {
        x -= toothWidth / 2;
        path.lineTo(x, size.height);
        x -= toothWidth / 2;
        path.lineTo(x, size.height - toothHeight);
      }
      path.close();
    } else {
      // 위쪽이 뾰족, 아래쪽이 평평
      path.moveTo(0, toothHeight);
      double x = 0;
      while (x < size.width) {
        x += toothWidth / 2;
        path.lineTo(x, 0);
        x += toothWidth / 2;
        path.lineTo(x, toothHeight);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ZigzagEdgePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.toothWidth != toothWidth ||
      oldDelegate.toothHeight != toothHeight ||
      oldDelegate.pointsDown != pointsDown;
}
