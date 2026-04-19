import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'chat_screen.dart';
import 'extrato_screen.dart';
import 'home_screen.dart';
import 'perfil_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onProfileTap: () => setState(() => _currentIndex = 3)),
      const ExtratoScreen(),
      const ChatScreen(),
      const PerfilScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: colors.accent,
        shape: const CircleBorder(),
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Preguiça.')));
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: colors.card,
        elevation: 10,
        shadowColor: Colors.black12,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Início',
                index: 0,
                colors: colors,
              ),
              _buildNavItem(
                icon: Icons.receipt_long_rounded,
                label: 'Extrato',
                index: 1,
                colors: colors,
              ),
              const SizedBox(width: 32),
              _buildNavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chat',
                index: 2,
                colors: colors,
              ),
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Perfil',
                index: 3,
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required AppColors colors,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? colors.accent
        : colors.textSecondary.withValues(alpha: 0.6);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
