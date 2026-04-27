import 'package:flutter/material.dart';

enum ReceiptTheme { classic, dark, kraft }

class ReceiptThemeStyle {
  final String label;
  final Color paperColor;
  final Color textColor;
  final bool usesMoodGradient;

  const ReceiptThemeStyle({
    required this.label,
    required this.paperColor,
    required this.textColor,
    required this.usesMoodGradient,
  });
}

const Map<ReceiptTheme, ReceiptThemeStyle> receiptThemeStyles = {
  ReceiptTheme.classic: ReceiptThemeStyle(
    label: '기본',
    paperColor: Colors.transparent,
    textColor: Color(0xFF2B2B2B),
    usesMoodGradient: true,
  ),
  ReceiptTheme.dark: ReceiptThemeStyle(
    label: '다크',
    paperColor: Color(0xFF1C1C1E),
    textColor: Color(0xFFE5E5E5),
    usesMoodGradient: false,
  ),
  ReceiptTheme.kraft: ReceiptThemeStyle(
    label: '크래프트',
    paperColor: Color(0xFFCEA882),
    textColor: Color(0xFF3E2B1A),
    usesMoodGradient: false,
  ),
};
