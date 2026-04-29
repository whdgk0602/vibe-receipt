import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/receipt_themes.dart';
import '../../providers/receipt_theme_provider.dart';
import '../../providers/vibe_provider.dart';
import 'loading_screen.dart';
import 'onboarding_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final _placeController = TextEditingController();
  final _commentController = TextEditingController();
  final _picker = ImagePicker();
  bool _showOptions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<VibeState>(vibeNotifierProvider, (prev, next) {
        if ((prev?.status != MeasureStatus.idle) &&
            next.status == MeasureStatus.idle) {
          _placeController.clear();
          _commentController.clear();
          setState(() => _showOptions = false);
        }
      });
    });
  }

  @override
  void dispose() {
    _placeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked != null) {
      ref.read(vibeNotifierProvider.notifier).setPhoto(File(picked.path));
    }
  }

  void _onStart() async {
    final notifier = ref.read(vibeNotifierProvider.notifier);
    notifier.setPlaceName(_placeController.text);
    notifier.setComment(_commentController.text);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoadingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vibeNotifierProvider);
    final currentTheme = ref.watch(receiptThemeProvider);
    final hasOptions = state.photo != null ||
        _commentController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 스크롤 콘텐츠 ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),

                    // 타이틀 + ? 버튼 (좌우 균형 Row)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 40), // 우측 버튼과 균형
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Vibe Receipt',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '공간 무드 영수증',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 12,
                                  color: AppColors.secondary,
                                  letterSpacing: 3.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ? 버튼 — 타이틀 우측, 좌측 SizedBox와 균형
                        IconButton(
                          icon: const Icon(
                              Icons.help_outline_rounded, size: 20),
                          color: AppColors.secondary,
                          tooltip: '앱 소개 보기',
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const OnboardingScreen(isReview: true),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    // 장소 입력
                    Text(
                      '어디에 머물고 있나요?',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _placeController,
                      decoration: const InputDecoration(
                        hintText: '예) 스타벅스 강남점, 내 방 침대',
                      ),
                      onChanged: (v) => ref
                          .read(vibeNotifierProvider.notifier)
                          .setPlaceName(v),
                    ),
                    const SizedBox(height: 28),

                    // 테마 선택
                    Text(
                      '영수증 테마',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ThemeSelector(
                      selected: currentTheme,
                      onSelect: (t) =>
                          ref.read(receiptThemeProvider.notifier).setTheme(t),
                    ),
                    const SizedBox(height: 24),

                    // 옵션 추가 토글
                    _OptionToggle(
                      expanded: _showOptions,
                      hasContent: hasOptions,
                      onTap: () =>
                          setState(() => _showOptions = !_showOptions),
                    ),

                    // 접히는 옵션 영역
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                      child: _showOptions
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  '사진 추가',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _PhotoPickerArea(
                                  photo: state.photo,
                                  onCamera: () =>
                                      _pickPhoto(ImageSource.camera),
                                  onGallery: () =>
                                      _pickPhoto(ImageSource.gallery),
                                  onRemove: () => ref
                                      .read(vibeNotifierProvider.notifier)
                                      .setPhoto(null),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '한 마디 남기기',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _commentController,
                                  decoration: const InputDecoration(
                                    hintText: '이 순간을 한 줄로 표현한다면...',
                                    counterText: '',
                                  ),
                                  maxLength: 40,
                                  onChanged: (v) => ref
                                      .read(vibeNotifierProvider.notifier)
                                      .setComment(v),
                                ),
                                const SizedBox(height: 4),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── 하단 고정 CTA ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: ElevatedButton(
                onPressed: _onStart,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('바이브 측정하기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 옵션 토글 버튼 ───────────────────────────────────────────────────

class _OptionToggle extends StatelessWidget {
  final bool expanded;
  final bool hasContent;
  final VoidCallback onTap;

  const _OptionToggle({
    required this.expanded,
    required this.hasContent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasContent && !expanded
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              expanded
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              size: 18,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 10),
            Text(
              expanded ? '옵션 닫기' : '사진 · 한 마디 추가',
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasContent && !expanded) ...[
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ],
            const Spacer(),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 280),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 테마 시각 선택기 ─────────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  final ReceiptTheme selected;
  final ValueChanged<ReceiptTheme> onSelect;

  const _ThemeSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ReceiptTheme.values.map((theme) {
        final isSelected = theme == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: theme != ReceiptTheme.values.last ? 10 : 0,
            ),
            child: _ThemeCard(
              theme: theme,
              isSelected: isSelected,
              onTap: () => onSelect(theme),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final ReceiptTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  static const _lineColors = {
    ReceiptTheme.classic: Color(0x222B2B2B),
    ReceiptTheme.dark: Color(0x33E5E5E5),
    ReceiptTheme.kraft: Color(0x333E2B1A),
  };

  // 기본 테마는 무드 그라디언트를 쓰므로 대표 그라디언트로 미리보기
  static const _classicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8D5F2), Color(0xFFD6F2E6)],
  );

  @override
  Widget build(BuildContext context) {
    final ts = receiptThemeStyles[theme]!;
    final lineColor = _lineColors[theme]!;

    BoxDecoration paperDecoration;

    if (theme == ReceiptTheme.classic) {
      paperDecoration = const BoxDecoration(gradient: _classicGradient);
    } else {
      paperDecoration = BoxDecoration(color: ts.paperColor);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Column(
            children: [
              // 페이퍼 미리보기 영역
              Container(
                height: 72,
                decoration: paperDecoration,
                child: Stack(
                  children: [
                    // 영수증 라인 시뮬레이션
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 헤더 라인 (짧게)
                          Center(
                            child: Container(
                              width: 40,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: lineColor,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 구분선
                          Container(height: 0.5, color: lineColor),
                          const SizedBox(height: 6),
                          // 데이터 라인들
                          _miniLine(lineColor, 0.7),
                          const SizedBox(height: 4),
                          _miniLine(lineColor, 0.5),
                          const SizedBox(height: 4),
                          _miniLine(lineColor, 0.85),
                        ],
                      ),
                    ),
                    // 선택 체크
                    if (isSelected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 라벨
              Container(
                color: AppColors.surface,
                padding:
                    const EdgeInsets.symmetric(vertical: 7),
                child: Center(
                  child: Text(
                    ts.label,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniLine(Color color, double widthFactor) {
    return LayoutBuilder(
      builder: (_, constraints) => Container(
        width: constraints.maxWidth * widthFactor,
        height: 2,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ─── 사진 피커 ────────────────────────────────────────────────────────

class _PhotoPickerArea extends StatelessWidget {
  final File? photo;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onRemove;

  const _PhotoPickerArea({
    required this.photo,
    required this.onCamera,
    required this.onGallery,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (photo != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              photo!,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _PickerButton(
            icon: Icons.camera_alt_outlined,
            label: '촬영',
            onTap: onCamera,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PickerButton(
            icon: Icons.photo_library_outlined,
            label: '갤러리',
            onTap: onGallery,
          ),
        ),
      ],
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
