import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../common/glass_card.dart';

class OcrProgressOverlay extends StatefulWidget {
  final bool isVisible;

  const OcrProgressOverlay({
    super.key,
    required this.isVisible,
  });

  @override
  State<OcrProgressOverlay> createState() => _OcrProgressOverlayState();
}

class _OcrProgressOverlayState extends State<OcrProgressOverlay> {
  int _statusIndex = 0;

  static const _statuses = [
    'Enhancing image...',
    'Running OCR...',
    'Extracting fields...',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) _startCycling();
  }

  @override
  void didUpdateWidget(OcrProgressOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _statusIndex = 0;
      _startCycling();
    }
  }

  void _startCycling() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && widget.isVisible) {
        setState(() {
          _statusIndex = (_statusIndex + 1) % _statuses.length;
        });
        _startCycling();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Container(
      color: AppColors.surface.withValues(alpha: 0.95),
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.xxxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _statuses[_statusIndex],
                  key: ValueKey(_statusIndex),
                  style: AppTypography.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'This usually takes 2–4 seconds',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.0, 1.0),
              duration: 300.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
