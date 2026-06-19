import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../contacts/contacts_screen.dart';
import '../scan/smart_scan_screen.dart';
import '../statistics/statistics_screen.dart';
import '../my_card/my_card_screen.dart';
import '../../../widgets/custom_bottom_navbar.dart';

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
      const SizedBox.shrink(), // Placeholder since Scan opens fullscreen
      const StatisticsScreen(),
      const MyCardScreen(),
    ];
  }

  void _onTabTap(int index) {
    HapticFeedback.lightImpact();
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const SmartScanScreen(),
        ),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTabSelected: _onTabTap,
              onScanTap: () => _onTabTap(2),
            ),
          ),
        ],
      ),
    );
  }
}
