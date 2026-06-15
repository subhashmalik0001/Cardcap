import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../home/home_screen.dart';
import '../contacts/contacts_screen.dart';
import '../scan/scan_screen.dart';
import '../statistics/statistics_screen.dart';
import '../my_card/my_card_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onNavigateToScan: () => _onTabTap(2),
        onNavigateToContacts: () => _onTabTap(1),
        onNavigateToMyCard: () => _onTabTap(4),
        onNavigateToStatistics: () => _onTabTap(3),
      ),
      const ContactsScreen(),
      const ScanScreen(),
      const StatisticsScreen(),
      const MyCardScreen(),
    ];
  }

  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(bottomPadding),
    );
  }

  Widget _buildBottomNav(double bottomPadding) {
    return Container(
      height: 72 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Home tab
          Expanded(
            child: _buildTab(
              index: 0,
              icon: LucideIcons.home,
              label: 'Home',
            ),
          ),
          // Contacts tab
          Expanded(
            child: _buildTab(
              index: 1,
              icon: LucideIcons.contact,
              label: 'Contacts',
            ),
          ),
          // Scan tab (elevated center FAB)
          Expanded(
            child: _buildScanTab(),
          ),
          // Statistic tab
          Expanded(
            child: _buildTab(
              index: 3,
              icon: LucideIcons.barChart2,
              label: 'Statistic',
            ),
          ),
          // My Card tab
          Expanded(
            child: _buildTab(
              index: 4,
              icon: LucideIcons.creditCard,
              label: 'My Card',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 11,
              color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          // Active indicator dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 4 : 0,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return GestureDetector(
      onTap: () => _onTabTap(2),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -10),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: AppColors.fabShadow,
            ),
            child: const Icon(
              LucideIcons.scanLine,
              size: 24,
              color: AppColors.textOnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
