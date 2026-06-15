import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

enum ModernButtonVariant { filled, outlined, ghost }

class ModernButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ModernButtonVariant variant;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final bool fullWidth;
  final double? width;

  const ModernButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = ModernButtonVariant.filled,
    this.height = 52,
    this.borderRadius = 14,
    this.isLoading = false,
    this.fullWidth = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isDisabled || isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(
            decoration: _decoration(isDisabled),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: variant == ModernButtonVariant.filled
                            ? AppColors.textOnPrimary
                            : AppColors.primary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 18,
                            color: _iconColor(isDisabled),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Text(
                          label,
                          style: AppTypography.labelLarge.copyWith(
                            color: _textColor(isDisabled),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration(bool disabled) {
    switch (variant) {
      case ModernButtonVariant.filled:
        return BoxDecoration(
          color: disabled
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.primary,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: disabled
              ? null
              : [
                  const BoxShadow(
                    color: Color(0x336A3EEB),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
        );
      case ModernButtonVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        );
      case ModernButtonVariant.ghost:
        return BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.border, width: 1),
        );
    }
  }

  Color _textColor(bool disabled) {
    switch (variant) {
      case ModernButtonVariant.filled:
        return disabled
            ? AppColors.textOnPrimary.withValues(alpha: 0.6)
            : AppColors.textOnPrimary;
      case ModernButtonVariant.outlined:
      case ModernButtonVariant.ghost:
        return disabled
            ? AppColors.textPrimary.withValues(alpha: 0.4)
            : AppColors.textPrimary;
    }
  }

  Color _iconColor(bool disabled) {
    switch (variant) {
      case ModernButtonVariant.filled:
        return disabled
            ? AppColors.textOnPrimary.withValues(alpha: 0.6)
            : AppColors.textOnPrimary;
      case ModernButtonVariant.outlined:
      case ModernButtonVariant.ghost:
        return disabled
            ? AppColors.primary.withValues(alpha: 0.4)
            : AppColors.primary;
    }
  }
}
