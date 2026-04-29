import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import 'history_screen.dart';
import 'main_screen.dart';
import 'settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          MainScreen(),
          HistoryScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.secondary,
          selectedLabelStyle: GoogleFonts.notoSansKr(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.notoSansKr(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: '아카이브',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }
}
