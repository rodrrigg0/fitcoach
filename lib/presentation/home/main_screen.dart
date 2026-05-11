import 'package:flutter/material.dart';
import 'package:fitcoach/core/theme/app_theme.dart';
import 'package:fitcoach/l10n/app_localizations.dart';
import 'package:fitcoach/presentation/home/home_screen.dart';
import 'package:fitcoach/presentation/training/training_screen.dart';
import 'package:fitcoach/presentation/nutrition/nutrition_screen.dart';
import 'package:fitcoach/presentation/chat/chat_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey _keyBottomNav = GlobalKey();

  void _onTabChange(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onTabChange: _onTabChange, bottomNavKey: _keyBottomNav),
          const TrainingScreen(),
          const NutritionScreen(),
          const ChatScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(l10n),
    );
  }

  Widget _buildBottomNav(AppLocalizations l10n) {
    return Container(
      key: _keyBottomNav,
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFF1A1A1A), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, l10n.navHome),
              _buildNavItem(1, Icons.fitness_center_outlined,
                  Icons.fitness_center, l10n.navTraining),
              _buildNavItem(2, Icons.restaurant_outlined, Icons.restaurant,
                  l10n.navNutrition),
              _buildNavItem(
                  3, Icons.chat_bubble_outline, Icons.chat_bubble, l10n.navChat),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withAlpha(31)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                selected ? activeIcon : icon,
                key: ValueKey(selected),
                color: selected ? AppColors.primary : const Color(0xFF444444),
                size: 22,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
