import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/business_card.dart';
import '../common/avatar_initials.dart';

class ContactCard extends StatefulWidget {
  final BusinessCard card;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMenuTap;
  final int? index;

  const ContactCard({
    super.key,
    required this.card,
    this.onTap,
    this.onLongPress,
    this.onMenuTap,
    this.index,
  });

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    setState(() => _scale = 0.975);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress?.call();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xs,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  AvatarInitials(
                    name: widget.card.displayName,
                    index: widget.index,
                    size: 44,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.card.displayName,
                          style: AppTypography.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.card.designation != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.card.designation!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.card.company != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        widget.card.company!,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(width: AppSpacing.xxs),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onMenuTap?.call();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        LucideIcons.moreVertical,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),

              // Contact details
              if (widget.card.email != null ||
                  widget.card.phones.isNotEmpty ||
                  widget.card.address != null) ...[
                const SizedBox(height: AppSpacing.sm),
                const Divider(color: AppColors.borderLight, thickness: 0.5, height: 1),
                const SizedBox(height: AppSpacing.sm),
                if (widget.card.email != null)
                  _infoRow(LucideIcons.mail, widget.card.email!),
                if (widget.card.phones.isNotEmpty) ...[
                  if (widget.card.email != null)
                    const SizedBox(height: AppSpacing.xxs),
                  _infoRow(LucideIcons.phone, widget.card.phones.first),
                ],
                if (widget.card.address != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  _infoRow(LucideIcons.mapPin, widget.card.address!),
                ],
              ],

              // Footer
              const SizedBox(height: AppSpacing.sm),
              const Divider(color: AppColors.borderLight, thickness: 0.5, height: 1),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Scanned ${FormatUtils.formatDate(widget.card.createdAt)}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).slideY(
          begin: 0.05,
          end: 0,
          duration: 280.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary.withValues(alpha: 0.8)),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
