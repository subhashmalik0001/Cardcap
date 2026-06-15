import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../common/glass_card.dart';

class CardPreviewWidget extends StatelessWidget {
  final String? imagePath;
  final bool isIdle;

  const CardPreviewWidget({
    super.key,
    this.imagePath,
    this.isIdle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: GlassCard(
        height: 220,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: imagePath != null
              ? _buildCapturedPreview()
              : _buildIdlePreview(),
        ),
      ),
    );
  }

  Widget _buildIdlePreview() {
    return Stack(
      children: [
        // Simulated card lines
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _shimmerLine(width: 120, height: 8),
              const SizedBox(height: 10),
              _shimmerLine(width: 90, height: 6),
              const SizedBox(height: 8),
              _shimmerLine(width: 60, height: 6),
              const SizedBox(height: 24),
              Text(
                'Point camera at a business card',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // OCR corner brackets
        ..._buildCornerBrackets(),
      ],
    );
  }

  Widget _buildCapturedPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
        )
            .animate()
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.0, 1.0),
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: 300.ms),

        // Success badge
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successBadgeBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'Card Captured',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 300.ms)
              .slideX(begin: -0.1, end: 0),
        ),
      ],
    );
  }

  Widget _shimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const size = 24.0;
    const stroke = 2.0;
    const color = AppColors.primary;
    const inset = 16.0;

    return [
      // Top-left
      Positioned(
        left: inset,
        top: inset,
        child: _cornerBracket(
          topBorder: true,
          leftBorder: true,
          size: size,
          stroke: stroke,
          color: color,
        ),
      ),
      // Top-right
      Positioned(
        right: inset,
        top: inset,
        child: _cornerBracket(
          topBorder: true,
          rightBorder: true,
          size: size,
          stroke: stroke,
          color: color,
        ),
      ),
      // Bottom-left
      Positioned(
        left: inset,
        bottom: inset,
        child: _cornerBracket(
          bottomBorder: true,
          leftBorder: true,
          size: size,
          stroke: stroke,
          color: color,
        ),
      ),
      // Bottom-right
      Positioned(
        right: inset,
        bottom: inset,
        child: _cornerBracket(
          bottomBorder: true,
          rightBorder: true,
          size: size,
          stroke: stroke,
          color: color,
        ),
      ),
    ].map((w) {
      return Positioned(
        left: w.left,
        right: w.right,
        top: w.top,
        bottom: w.bottom,
        child: w.child
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 1200.ms)
            .then()
            .fadeOut(duration: 1200.ms),
      );
    }).toList();
  }

  Widget _cornerBracket({
    bool topBorder = false,
    bool bottomBorder = false,
    bool leftBorder = false,
    bool rightBorder = false,
    required double size,
    required double stroke,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: topBorder
              ? BorderSide(color: color, width: stroke)
              : BorderSide.none,
          bottom: bottomBorder
              ? BorderSide(color: color, width: stroke)
              : BorderSide.none,
          left: leftBorder
              ? BorderSide(color: color, width: stroke)
              : BorderSide.none,
          right: rightBorder
              ? BorderSide(color: color, width: stroke)
              : BorderSide.none,
        ),
      ),
    );
  }
}
