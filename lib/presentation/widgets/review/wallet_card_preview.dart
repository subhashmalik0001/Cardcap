import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/business_card.dart';
import '../common/avatar_initials.dart';

class WalletCardPreview extends StatelessWidget {
  final BusinessCard card;

  const WalletCardPreview({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.walletGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name
          Row(
            children: [
              AvatarInitials(
                name: card.displayName,
                size: 48,
                fontSize: 18,
                backgroundColor: Colors.white,
                textColor: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.displayName,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (card.designation != null)
                      Text(
                        card.designation!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (card.company != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    card.company!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textOnPrimary,
                      letterSpacing: 0,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                  ),
                ),
            ],
          ),

          const Spacer(),

          // Contact details
          Row(
            children: [
              if (card.email != null)
                Expanded(
                  child: Text(
                    card.email!,
                    style: AppTypography.mono.copyWith(
                      fontSize: 11,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (card.phones.isNotEmpty)
                Text(
                  card.phones.first,
                  style: AppTypography.mono.copyWith(
                    fontSize: 11,
                    color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // OCR badge
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFB300),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'OCR extracted · verify before saving',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                  fontSize: 9,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
