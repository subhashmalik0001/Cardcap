import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/format_utils.dart';

class AvatarInitials extends StatelessWidget {
  final String? name;
  final double size;
  final double fontSize;
  final bool showRing;
  final Color? backgroundColor;
  final Color? textColor;

  const AvatarInitials({
    super.key,
    this.name,
    this.size = 44,
    this.fontSize = 15,
    this.showRing = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = FormatUtils.initials(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? AppColors.primaryLight,
        border: showRing
            ? Border.all(
                color: (textColor ?? AppColors.primary).withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.labelLarge.copyWith(
            color: textColor ?? AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
