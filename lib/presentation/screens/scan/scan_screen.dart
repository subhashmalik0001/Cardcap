import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/modern_button.dart';
import '../../widgets/scan/card_preview_widget.dart';
import '../../widgets/scan/ocr_progress_overlay.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late ScanProvider _scanProvider;

  @override
  void initState() {
    super.initState();
    _scanProvider = context.read<ScanProvider>();
    _scanProvider.addListener(_onScanStateChange);
  }

  @override
  void dispose() {
    _scanProvider.removeListener(_onScanStateChange);
    super.dispose();
  }

  void _onScanStateChange() {
    if (!mounted) return;
    final state = _scanProvider.state;
    final card = _scanProvider.parsedCard;
    final error = _scanProvider.errorMessage;

    if (state == ScanState.done && card != null) {
      HapticFeedback.heavyImpact();
      Navigator.of(context).pushNamed(
        '/review',
        arguments: card,
      ).then((_) {
        _scanProvider.reset();
      });
    } else if (state == ScanState.error && error != null) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
      _scanProvider.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScanProvider>(
      builder: (context, provider, _) {
        final isProcessing = provider.isProcessing;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    AppHeader(
                      title: 'Scan Card',
                      subtitle: 'Extract contact details with high-precision OCR',
                      trailing: provider.capturedImagePath != null
                          ? IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                provider.reset();
                              },
                              icon: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: const Icon(
                                  LucideIcons.rotateCcw,
                                  size: 18,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const Spacer(),

                    // Viewfinder preview
                    CardPreviewWidget(
                      imagePath: provider.capturedImagePath,
                      isIdle: provider.state == ScanState.idle,
                    ),

                    const Spacer(),

                    // Tips card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          children: [
                            _buildTipRow(
                              '1',
                              'Position',
                              'Place the card on a flat, well-lit surface.',
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildTipRow(
                              '2',
                              'Scan',
                              'Take a photo or import from your photo gallery.',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          ModernButton(
                            label: 'Scan Card',
                            icon: LucideIcons.camera,
                            onPressed: isProcessing
                                ? null
                                : () => provider.captureFromCamera(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ModernButton(
                            label: 'Upload from Gallery',
                            icon: LucideIcons.image,
                            variant: ModernButtonVariant.ghost,
                            onPressed: isProcessing
                                ? null
                                : () => provider.pickFromGallery(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),

              // Progress overlay
              OcrProgressOverlay(isVisible: isProcessing),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipRow(String num, String title, String desc) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            desc,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
