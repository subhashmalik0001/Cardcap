import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();
    
    // Check auth state in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkAuth();
    });

    _transitionTimer = Timer(AppConstants.splashDuration, () {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/shell');
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }


  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo image asset on violet background
            Image.asset(
              'assets/images/Logo.png',
              width: 120,
              height: 120,
            )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                  delay: 200.ms,
                )
                .fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: AppSpacing.xl),

            // App name — white on violet
            Text(
              AppConstants.appName,
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.textOnPrimary,
                fontSize: 32,
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, delay: 700.ms, duration: 400.ms),

            const SizedBox(height: AppSpacing.xs),

            // Tagline — white at 70%
            Text(
              AppConstants.appTagline,
              style: AppTypography.labelSmall.copyWith(
                letterSpacing: 0.15 * 11,
                color: AppColors.textOnPrimary.withValues(alpha: 0.7),
              ),
            ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
          ],
        ),
      ),
      // Bottom pulsing dots — white
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.textOnPrimary,
                shape: BoxShape.circle,
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .fadeIn(delay: (1100 + index * 200).ms)
                .then()
                .fade(
                  begin: 0.3,
                  end: 1.0,
                  duration: 800.ms,
                  delay: (index * 200).ms,
                );
          }),
        ),
      ),
    );
  }
}
