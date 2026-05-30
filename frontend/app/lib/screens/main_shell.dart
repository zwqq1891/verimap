import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/verimap_logo.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Callback to switch page (e.g. from HomeScreen to HistoryScreen)
  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 600;

    final List<Widget> screens = [
      HomeScreen(onNavigate: _navigateToPage),
      HistoryScreen(),
      ProfileScreen(),
    ];

    // Main Scaffold
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Row(
          children: [
            const VeriMapLogo(size: 28, hasGlow: false),
            const SizedBox(width: 8),
            Text(
              'VeriMap',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: isDesktop
            ? [
                _buildDesktopNavItem('首頁', 0),
                _buildDesktopNavItem('歷史記錄', 1),
                _buildDesktopNavItem('個人檔案', 2),
                const SizedBox(width: 16),
              ]
            : null,
      ),
      body: SafeArea(
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: !isDesktop
          ? Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: AppTheme.surfaceColor,
                selectedItemColor: AppTheme.primaryColor,
                unselectedItemColor: AppTheme.secondaryColor,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home, color: AppTheme.primaryColor),
                    label: '首頁',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_outlined),
                    activeIcon: Icon(Icons.history, color: AppTheme.primaryColor),
                    label: '歷史記錄',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person, color: AppTheme.primaryColor),
                    label: '個人檔案',
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildDesktopNavItem(String label, int index) {
    final theme = Theme.of(context);
    final isActive = _currentIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: () {
          setState(() {
            _currentIndex = index;
          });
        },
        style: TextButton.styleFrom(
          backgroundColor: isActive ? AppTheme.surfaceContainerLow : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppTheme.primaryColor : AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
