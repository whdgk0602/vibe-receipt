import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isReview;

  const OnboardingScreen({super.key, this.isReview = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      icon: Icons.sensors_rounded,
      accent: Color(0xFFD6F2E6),
      iconColor: Color(0xFF3A7D5F),
      tag: 'SENSE',
      title: '공간의 바이브를\n읽어드려요',
      body: '빛의 밝기, 주변 소음, 현재 시간\n세 가지 데이터로 지금 이 공간의\n분위기를 분석합니다',
    ),
    _Slide(
      icon: Icons.receipt_long_outlined,
      accent: Color(0xFFFFF3B0),
      iconColor: Color(0xFF8B7A1A),
      tag: 'RECEIPT',
      title: '감성 영수증으로\n즉시 발급해요',
      body: '6가지 무드 중 하나로 매칭된 결과를\n실제 영수증처럼 출력합니다\n저장하고 SNS에 공유할 수 있어요',
    ),
    _Slide(
      icon: Icons.auto_awesome_mosaic_outlined,
      accent: Color(0xFFE0C9F5),
      iconColor: Color(0xFF6B3FA0),
      tag: 'ARCHIVE',
      title: '기록을 모아\n컬렉션을 완성해요',
      body: '발급된 영수증은 자동으로 저장됩니다\n장소별로 묶어보고, 6가지 무드 도장을\n모두 모아 컬렉션을 완성해 보세요',
    ),
  ];

  Future<void> _finish() async {
    if (!widget.isReview) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } else {
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 건너뛰기
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  widget.isReview ? '닫기' : '건너뛰기',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),

            // 슬라이드
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _SlidePage(slide: _slides[i]),
              ),
            ),

            // 하단: 도트 + 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _page ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? AppColors.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLast
                          ? _finish
                          : () => _controller.nextPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          isLast
                              ? (widget.isReview ? '닫기' : '시작하기')
                              : '다음',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final Color accent;
  final Color iconColor;
  final String tag;
  final String title;
  final String body;

  const _Slide({
    required this.icon,
    required this.accent,
    required this.iconColor,
    required this.tag,
    required this.title,
    required this.body,
  });
}

class _SlidePage extends StatelessWidget {
  final _Slide slide;

  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: slide.accent,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(slide.icon, size: 48, color: slide.iconColor),
          ),
          const SizedBox(height: 40),
          Text(
            slide.tag,
            style: GoogleFonts.courierPrime(
              fontSize: 11,
              letterSpacing: 5,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.secondary,
              height: 1.85,
            ),
          ),
        ],
      ),
    );
  }
}
