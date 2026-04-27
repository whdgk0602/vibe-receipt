import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/receipt_themes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/time_helper.dart';
import '../../data/models/receipt_model.dart';
import 'barcode_painter.dart';
import 'zigzag_edge_painter.dart';

class ReceiptWidget extends StatelessWidget {
  final ReceiptModel receipt;
  final ReceiptTheme theme;

  const ReceiptWidget({
    super.key,
    required this.receipt,
    this.theme = ReceiptTheme.classic,
  });

  @override
  Widget build(BuildContext context) {
    final d = receipt.data;
    final style = receipt.style;
    final ts = receiptThemeStyles[theme]!;
    final textColor = ts.textColor;
    final dateText = DateFormat('yyyy.MM.dd HH:mm').format(d.measuredAt);
    final timeBand = TimeHelper.labelOf(TimeHelper.bandOf(d.measuredAt));

    final decoration = ts.usesMoodGradient
        ? BoxDecoration(
            gradient: style.gradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          )
        : BoxDecoration(
            color: ts.paperColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          );

    final zigzagColor =
        ts.usesMoodGradient ? style.gradientEnd : ts.paperColor;

    return Container(
      decoration: decoration,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 헤더
                Center(
                  child: Text(
                    'VIBE RECEIPT',
                    style: AppTheme.receiptTitleFont(
                        size: 32, color: textColor),
                  ),
                ),
                const SizedBox(height: 2),
                Center(
                  child: Text(
                    style.englishLabel,
                    style: AppTheme.receiptFont(
                      size: 11,
                      letterSpacing: 4,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '- ${style.label} -',
                    style: AppTheme.receiptFont(size: 12, color: textColor),
                  ),
                ),
                const SizedBox(height: 20),
                _dashedLine(textColor),
                const SizedBox(height: 16),

                // 사진
                if (d.photo != null && d.photo!.existsSync()) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      d.photo!,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 장소 / 날짜 / 시간대 / 번호
                _row('PLACE', d.placeName, textColor),
                const SizedBox(height: 6),
                _row('DATE', dateText, textColor),
                const SizedBox(height: 6),
                _row('TIME', timeBand, textColor),
                const SizedBox(height: 6),
                _row('NO.', receipt.receiptNumber, textColor),

                const SizedBox(height: 16),
                _dashedLine(textColor),
                const SizedBox(height: 16),

                // 측정 수치
                _row(
                  'LIGHT',
                  d.lux < 0 ? '-- lux' : '${d.lux.toStringAsFixed(0)} lux',
                  textColor,
                ),
                const SizedBox(height: 6),
                _row(
                  'NOISE',
                  d.decibel < 0
                      ? '-- dB'
                      : '${d.decibel.toStringAsFixed(1)} dB',
                  textColor,
                ),

                const SizedBox(height: 16),
                _dashedLine(textColor),
                const SizedBox(height: 20),

                // 감성 문구
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '"${receipt.phrase}"',
                      textAlign: TextAlign.center,
                      style: AppTheme.receiptFont(
                        size: 15,
                        weight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),

                // 한 줄 코멘트
                if (d.comment != null && d.comment!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '* ${d.comment} *',
                      textAlign: TextAlign.center,
                      style: AppTheme.receiptFont(
                        size: 12,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                _dashedLine(textColor),
                const SizedBox(height: 20),

                // 바코드
                CustomPaint(
                  size: const Size(double.infinity, 40),
                  painter: BarcodePainter(
                    color: textColor,
                    seed: d.measuredAt.millisecondsSinceEpoch,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    receipt.receiptNumber,
                    style: AppTheme.receiptFont(
                      size: 10,
                      letterSpacing: 2,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 하단 문구
                Center(
                  child: Text(
                    'thank you for your vibe.',
                    style: AppTheme.receiptFont(
                      size: 11,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '@ VIBE RECEIPT',
                    style: AppTheme.receiptFont(
                      size: 10,
                      letterSpacing: 3,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 하단 지그재그 절취선
          SizedBox(
            height: 12,
            child: CustomPaint(
              size: const Size(double.infinity, 12),
              painter: ZigzagEdgePainter(
                color: zigzagColor,
                pointsDown: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.receiptFont(
              size: 12, weight: FontWeight.w700, color: textColor),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTheme.receiptFont(size: 13, color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _dashedLine(Color textColor) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter:
          _DashedLinePainter(color: textColor.withValues(alpha: 0.5)),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 4.0;
    const gap = 4.0;
    double x = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
