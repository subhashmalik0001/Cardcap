import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';

class ScanStatusBar extends StatelessWidget {
  final VoidCallback onBackPressed;
  final bool isFlashOn;
  final VoidCallback onFlashToggle;
  final String statusText;

  const ScanStatusBar({
    super.key,
    required this.onBackPressed,
    required this.isFlashOn,
    required this.onFlashToggle,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: const Icon(
                LucideIcons.x,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          // Status Pill
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  statusText,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          // Flash button
          GestureDetector(
            onTap: onFlashToggle,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Icon(
                isFlashOn ? LucideIcons.zap : LucideIcons.zapOff,
                color: isFlashOn ? const Color(0xFFFFB000) : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
