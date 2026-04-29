import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/home_shell.dart';
import 'presentation/screens/onboarding_screen.dart';

final _onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_done') ?? false;
});

class VibeReceiptApp extends ConsumerWidget {
  const VibeReceiptApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingAsync = ref.watch(_onboardingDoneProvider);

    return MaterialApp(
      title: 'Vibe Receipt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: onboardingAsync.when(
        data: (done) => done ? const HomeShell() : const OnboardingScreen(),
        loading: () => const Scaffold(
          backgroundColor: Color(0xFFF7F5F0),
          body: SizedBox.shrink(),
        ),
        error: (_, e) => const HomeShell(),
      ),
    );
  }
}
