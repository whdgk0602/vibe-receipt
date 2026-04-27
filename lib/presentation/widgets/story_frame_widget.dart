import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/receipt_themes.dart';
import '../../data/models/receipt_model.dart';
import 'receipt_widget.dart';

/// 인스타 스토리 포맷(9:16)으로 영수증을 감싸는 위젯
class StoryFrameWidget extends StatelessWidget {
  final ReceiptModel receipt;
  final ReceiptTheme theme;

  const StoryFrameWidget({
    super.key,
    required this.receipt,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final style = receipt.style;

    return SizedBox(
      width: 540,
      height: 960,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              style.gradientStart,
              style.gradientEnd,
              style.gradientStart.withValues(alpha: 0.7),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            // 상단 브랜딩
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 60, 32, 0),
              child: Text(
                'VIBE RECEIPT',
                style: GoogleFonts.vt323(
                  fontSize: 26,
                  color: const Color(0xFF2B2B2B).withValues(alpha: 0.4),
                  letterSpacing: 6,
                ),
              ),
            ),

            // 영수증
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ReceiptWidget(receipt: receipt, theme: theme),
                ),
              ),
            ),

            // 하단 해시태그
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 44),
              child: Text(
                '#VibeReceipt  #바이브영수증',
                style: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  color: const Color(0xFF2B2B2B).withValues(alpha: 0.45),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
