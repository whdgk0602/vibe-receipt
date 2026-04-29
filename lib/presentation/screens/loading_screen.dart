import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/vibe_provider.dart';
import 'result_screen.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _paperController;
  late final AnimationController _dotsController;
  late final Animation<double> _paperSlide;

  final _steps = const [
    '조도 센서 감지 중...',
    '공간 소음 측정 중...',
    '무드 매칭 중...',
  ];
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();

    // 영수증 용지가 위에서 프린트되듯 내려오는 애니메이션
    _paperController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _paperSlide = CurvedAnimation(
      parent: _paperController,
      curve: Curves.easeOutCubic,
    );
    _paperController.repeat(reverse: true);

    // 점(dot) 깜빡임
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _cycleSteps();

    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _cycleSteps() async {
    while (mounted) {
      final status = ref.read(vibeNotifierProvider).status;
      if (status != MeasureStatus.measuring &&
          status != MeasureStatus.idle) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      setState(() {
        _stepIndex = (_stepIndex + 1) % _steps.length;
      });
    }
  }

  Future<void> _start() async {
    await ref.read(vibeNotifierProvider.notifier).startMeasure();
    if (!mounted) return;

    final state = ref.read(vibeNotifierProvider);
    if (state.status == MeasureStatus.success && state.receipt != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    } else {
      final msg = state.errorMessage ?? '측정에 실패했습니다';
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  void dispose() {
    _paperController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 프린터 프레임 + 용지 애니메이션
              SizedBox(
                width: 120,
                height: 160,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 프린터 몸체
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _dotsController,
                            builder: (context, child) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(3, (i) {
                                final delay = i / 3;
                                final t = (_dotsController.value - delay)
                                    .clamp(0.0, 1.0);
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white
                                        .withValues(alpha: 0.3 + t * 0.7),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 용지가 나오는 슬롯
                    Positioned(
                      top: 34,
                      child: Container(
                        width: 80,
                        height: 6,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),

                    // 나오는 용지
                    Positioned(
                      top: 36,
                      child: AnimatedBuilder(
                        animation: _paperSlide,
                        builder: (context, child) {
                          final paperH = 60 + _paperSlide.value * 40;
                          return Container(
                            width: 72,
                            height: paperH,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VIBE',
                                    style: AppTheme.receiptFont(
                                      size: 9,
                                      weight: FontWeight.w700,
                                      letterSpacing: 2,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ...List.generate(
                                    4,
                                    (i) => Container(
                                      margin: const EdgeInsets.only(bottom: 3),
                                      height: 2,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.divider,
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _steps[_stepIndex],
                  key: ValueKey(_stepIndex),
                  style: GoogleFonts.notoSansKr(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '공간의 숨결을 읽는 중...',
                style: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
