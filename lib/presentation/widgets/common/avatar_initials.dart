import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final String? imageUrl; // Optional custom override
  final int? index; // Optional index to assign avatar in a series

  static const List<String> premiumAvatars = [
    'https://i.pinimg.com/736x/5b/ba/d7/5bbad7a9c58728957824ad9b683a00ab.jpg',
    'https://i.pinimg.com/736x/8e/03/4c/8e034c2df507c615a970de2c46e549f8.jpg',
    'https://i.pinimg.com/1200x/3e/5a/3e/3e5a3e5a6b5fe29e59a8278f25124088.jpg',
    'https://i.pinimg.com/736x/f0/ae/91/f0ae91b8f72db7efbef0d3946f59b62f.jpg',
    'https://i.pinimg.com/736x/dd/55/4a/dd554a81302c28d748380d176023ce56.jpg',
    'https://i.pinimg.com/1200x/90/c8/ec/90c8ec0c5647aff64f824fb51bea7dba.jpg',
  ];

  const AvatarInitials({
    super.key,
    this.name,
    this.size = 44,
    this.fontSize = 15,
    this.showRing = false,
    this.backgroundColor,
    this.textColor,
    this.imageUrl,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the avatar image URL
    String? avatarUrl = imageUrl;
    if ((avatarUrl == null || avatarUrl.isEmpty) && name != null && name!.isNotEmpty) {
      final idx = index ?? name.hashCode.abs();
      avatarUrl = premiumAvatars[idx % premiumAvatars.length];
    }

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
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: avatarUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildInitials(initials),
                errorWidget: (context, url, error) => _buildInitials(initials),
              )
            : _buildInitials(initials),
      ),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: AppTypography.labelLarge.copyWith(
          color: textColor ?? AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

