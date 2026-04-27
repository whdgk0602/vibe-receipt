import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/receipt_themes.dart';
import '../../providers/receipt_theme_provider.dart';
import '../../providers/vibe_provider.dart';
import '../screens/history_screen.dart';
import 'loading_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final _placeController = TextEditingController();
  final _commentController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 다시 측정 시 리셋 감지 → 입력 필드 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<VibeState>(vibeNotifierProvider, (prev, next) {
        if ((prev?.status != MeasureStatus.idle) &&
            next.status == MeasureStatus.idle) {
          _placeController.clear();
          _commentController.clear();
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // 타이틀 + 히스토리 버튼
              Row(
                children: [
                  const SizedBox(width: 48),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'VIBE RECEIPT',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.vt323(
                            fontSize: 44,
                            color: AppColors.primary,
                            letterSpacing: 2.4,
                          ),
                        ),
                        Text(
                          '공간 무드 영수증',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 13,
                            color: AppColors.secondary,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      ),
                      icon: const Icon(Icons.receipt_long_outlined),
                      color: AppColors.primary,
                      tooltip: '내 영수증 아카이브',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 장소 입력
              Text(
                '어디에 머물고 있나요?',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
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
                onChanged: (v) =>
                    ref.read(vibeNotifierProvider.notifier).setPlaceName(v),
              ),
              const SizedBox(height: 24),

              // 사진 (옵션)
              Text(
                '사진 추가 (선택)',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              _PhotoPickerArea(
                photo: state.photo,
                onCamera: () => _pickPhoto(ImageSource.camera),
                onGallery: () => _pickPhoto(ImageSource.gallery),
                onRemove: () =>
                    ref.read(vibeNotifierProvider.notifier).setPhoto(null),
              ),
              const SizedBox(height: 24),

              // 한 마디 코멘트 (옵션)
              Text(
                '한 마디 남기기 (선택)',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
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
                onChanged: (v) =>
                    ref.read(vibeNotifierProvider.notifier).setComment(v),
              ),
              const SizedBox(height: 24),

              // 영수증 테마 선택
              Text(
                '영수증 테마',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ReceiptTheme.values.map((t) {
                  final ts = receiptThemeStyles[t]!;
                  final selected = currentTheme == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        ts.label,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      selected: selected,
                      onSelected: (_) => ref
                          .read(receiptThemeProvider.notifier)
                          .setTheme(t),
                      selectedColor: AppColors.primary.withValues(alpha: 0.12),
                      checkmarkColor: AppColors.primary,
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                      backgroundColor: AppColors.surface,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // CTA
              ElevatedButton(
                onPressed: _onStart,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('바이브 측정하기'),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                '센서로 현재 공간의 빛 · 소음 · 시간을 수집해\n감성 영수증을 발급합니다',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  color: AppColors.secondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
              height: 180,
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
                child: const Icon(Icons.close,
                    color: Colors.white, size: 18),
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
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
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
