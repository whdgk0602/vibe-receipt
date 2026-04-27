import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/image_export_service.dart';
import '../../providers/receipt_theme_provider.dart';
import '../../providers/vibe_provider.dart';
import '../widgets/receipt_widget.dart';
import '../widgets/story_frame_widget.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  final _screenshotController = ScreenshotController();
  final _exportService = ImageExportService();

  late final AnimationController _animController;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final bytes = await _screenshotController.capture(pixelRatio: 3);
    if (bytes == null) return;
    final ok = await _exportService.saveToGallery(bytes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(ok ? '갤러리에 저장되었어요' : '저장에 실패했어요. 권한을 확인해 주세요'),
    ));
  }

  void _onShare() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ShareSheet(
        onImageShare: _shareImage,
        onStoryShare: _shareStory,
        onTextShare: _shareText,
      ),
    );
  }

  Future<void> _shareImage() async {
    Navigator.of(context).pop();
    final bytes = await _screenshotController.capture(pixelRatio: 3);
    if (bytes == null) return;
    await _exportService.share(bytes);
  }

  Future<void> _shareStory() async {
    Navigator.of(context).pop();
    final receipt = ref.read(vibeNotifierProvider).receipt;
    if (receipt == null) return;
    final currentTheme = ref.read(receiptThemeProvider);

    final bytes = await ScreenshotController().captureFromWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: StoryFrameWidget(receipt: receipt, theme: currentTheme),
        ),
      ),
      delay: const Duration(milliseconds: 150),
      pixelRatio: 2.0,
    );
    await _exportService.share(bytes,
        text: '나의 오늘 공간 바이브 🧾 #VibeReceipt');
  }

  Future<void> _shareText() async {
    Navigator.of(context).pop();
    final receipt = ref.read(vibeNotifierProvider).receipt;
    if (receipt == null) return;
    await _exportService.shareAsText(receipt);
  }

  void _onRestart() {
    ref.read(vibeNotifierProvider.notifier).reset();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final receipt = ref.watch(vibeNotifierProvider).receipt;
    final theme = ref.watch(receiptThemeProvider);

    if (receipt == null) {
      return const Scaffold(body: Center(child: Text('데이터가 없습니다')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Your Vibe Receipt',
          style: GoogleFonts.vt323(fontSize: 24, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            onPressed: _onRestart,
            icon: const Icon(Icons.refresh),
            tooltip: '다시 측정',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12),
                child: SlideTransition(
                  position: _slideAnim,
                  child: Screenshot(
                    controller: _screenshotController,
                    child: ReceiptWidget(receipt: receipt, theme: theme),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _onSave,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('저장'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _onShare,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('공유'),
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

class _ShareSheet extends StatelessWidget {
  final VoidCallback onImageShare;
  final VoidCallback onStoryShare;
  final VoidCallback onTextShare;

  const _ShareSheet({
    required this.onImageShare,
    required this.onStoryShare,
    required this.onTextShare,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '공유 방식 선택',
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _ShareOption(
              icon: Icons.image_outlined,
              title: '이미지 공유',
              subtitle: '영수증 이미지를 SNS에 공유해요',
              onTap: onImageShare,
            ),
            const SizedBox(height: 12),
            _ShareOption(
              icon: Icons.crop_portrait_rounded,
              title: '스토리 형식 공유',
              subtitle: '인스타 스토리 최적화 9:16 비율',
              onTap: onStoryShare,
            ),
            const SizedBox(height: 12),
            _ShareOption(
              icon: Icons.text_snippet_outlined,
              title: '텍스트 공유',
              subtitle: '카카오톡·문자에 텍스트 카드로 공유해요',
              onTap: onTextShare,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      color: AppColors.secondary,
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
