import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _resetOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_done');
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '설정',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // 앱 정보 섹션
          _SectionHeader(label: '앱 정보'),
          _InfoTile(
            title: 'VIBE RECEIPT',
            subtitle: '공간 무드 영수증',
            trailing: Text(
              'v1.0.0',
              style: AppTheme.receiptFont(
                size: 12,
                color: AppColors.secondary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 도움말 섹션
          _SectionHeader(label: '도움말'),
          _ActionTile(
            icon: Icons.slideshow_rounded,
            title: '온보딩 다시 보기',
            subtitle: '앱 소개 슬라이드를 다시 확인해요',
            onTap: () => _resetOnboarding(context),
          ),

          const SizedBox(height: 8),

          // 라이선스 섹션
          _SectionHeader(label: '오픈소스'),
          _ActionTile(
            icon: Icons.description_outlined,
            title: '오픈소스 라이선스',
            subtitle: '사용된 패키지의 라이선스 정보',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Vibe Receipt',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2026 Vibe Receipt',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Text(
        label,
        style: AppTheme.receiptFont(
          size: 11,
          letterSpacing: 2,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.receiptFont(
                    size: 14,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
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
          ?trailing,
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: 14),
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
              const Icon(Icons.chevron_right, size: 18, color: AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
