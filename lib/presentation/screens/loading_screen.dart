import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/vibe_provider.dart';
import 'result_screen.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _steps = const [
    '조도 센서 감지 중...',
    '공간 소음 측정 중...',
    '무드 매칭 중...',
  ];
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // 로딩 텍스트 순환
    _cycleSteps();

    // 프레임 이후 측정 시작
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
      // 실패 → 이전 화면으로 되돌아가며 스낵바
      final msg = state.errorMessage ?? '측정에 실패했습니다';
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
              // 스피너 - 회전하는 점선 원
              RotationTransition(
                turns: _controller,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
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
                '잠시만 기다려 주세요',
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
