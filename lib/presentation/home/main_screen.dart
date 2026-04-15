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
          HomeScreen(onTabChange: _onTabChange),
          const TrainingScreen(),
          const NutritionScreen(),
          const ChatScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabChange,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF444444),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.fitness_center_outlined),
              activeIcon: const Icon(Icons.fitness_center),
              label: l10n.navTraining,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.restaurant_outlined),
              activeIcon: const Icon(Icons.restaurant),
              label: l10n.navNutrition,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline),
              activeIcon: const Icon(Icons.chat_bubble),
              label: l10n.navChat,
            ),
          ],
        ),
      ),
    );
  }
}
