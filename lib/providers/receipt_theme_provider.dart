import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/receipt_themes.dart';

class ReceiptThemeNotifier extends StateNotifier<ReceiptTheme> {
  ReceiptThemeNotifier() : super(ReceiptTheme.classic) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('receipt_theme') ?? 'classic';
    state = ReceiptTheme.values.firstWhere(
      (t) => t.name == name,
      orElse: () => ReceiptTheme.classic,
    );
  }

  Future<void> setTheme(ReceiptTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('receipt_theme', theme.name);
  }
}

final receiptThemeProvider =
    StateNotifierProvider<ReceiptThemeNotifier, ReceiptTheme>(
  (_) => ReceiptThemeNotifier(),
);
