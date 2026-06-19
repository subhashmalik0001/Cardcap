import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/business_card.dart';
import '../../../data/services/card_ocr_service.dart';
import '../../../data/services/card_upload_service.dart';
import '../../../data/services/business_card_parser.dart';
import '../review/review_screen.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/modern_button.dart';

class ScanResultScreen extends StatefulWidget {
  final File croppedCardFile;
  final String scanMethod;

  const ScanResultScreen({
    super.key,
    required this.croppedCardFile,
    required this.scanMethod,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  // Services
  final CardOcrService _ocrService = CardOcrService();
  final CardUploadService _uploadService = CardUploadService();
  final BusinessCardParser _parser = BusinessCardParser();

  // Statuses
  bool _isUploading = false;
  bool _isOcrProcessing = false;
  bool _uploadComplete = false;
  bool _ocrComplete = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _processCard();
  }

  Future<void> _processCard() async {
    setState(() {
      _isUploading = true;
      _isOcrProcessing = true;
      _uploadComplete = false;
      _ocrComplete = false;
      _error = null;
    });

    String? uploadedUrl;
    BusinessCard? parsedCard;

    try {
      // 1. Get User ID from Provider or Supabase client
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?['id'] ?? Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User authentication session not found.');
      }

      // 2. Run upload and OCR concurrently
      await Future.wait([
        // Upload task
        _uploadService.uploadCardImage(
          imageFile: widget.croppedCardFile,
          userId: userId,
        ).then((url) {
          uploadedUrl = url;
          setState(() {
            _isUploading = false;
            _uploadComplete = true;
          });
        }),

        // OCR task
        _ocrService.extractOcrLines(widget.croppedCardFile.path).then((lines) {
          parsedCard = _parser.parse(lines);
          setState(() {
            _isOcrProcessing = false;
            _ocrComplete = true;
          });
        }),
      ]);

      if (uploadedUrl != null && parsedCard != null) {
        // Complete the card details mapping
        final finalCard = parsedCard!.copyWith(
          cardImageUrl: uploadedUrl,
          scanMethod: widget.scanMethod,
        );

        if (!mounted) return;

        // Redirect to review screen and replace loader
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ReviewScreen(card: finalCard),
          ),
        );
      } else {
        throw Exception('Failed to generate results.');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _isOcrProcessing = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),
              
              // Cropped card image preview
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
                  child: Image.file(
                    widget.croppedCardFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                _error != null ? 'Processing Failed' : 'Scanning Business Card',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error != null 
                    ? 'An error occurred while analyzing the card details.'
                    : 'We are processing the card image and extracting details.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Processes status indicators
              if (_error == null) ...[
                _buildStatusRow(
                  title: 'Uploading card image',
                  isProcessing: _isUploading,
                  isComplete: _uploadComplete,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildStatusRow(
                  title: 'Extracting fields with AI OCR',
                  isProcessing: _isOcrProcessing,
                  isComplete: _ocrComplete,
                ),
              ] else ...[
                // Error container
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.alertTriangle,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Bottom action buttons
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Row(
                  children: [
                    if (_error != null) ...[
                      Expanded(
                        child: ModernButton(
                          label: 'Retake Scan',
                          icon: LucideIcons.rotateCcw,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: ModernButton(
                          label: 'Cancel',
                          icon: LucideIcons.x,
                          variant: ModernButtonVariant.ghost,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required String title,
    required bool isProcessing,
    required bool isComplete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isProcessing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          else if (isComplete)
            const Icon(
              LucideIcons.checkCircle2,
              color: AppColors.success,
              size: 20,
            )
          else
            Icon(
              LucideIcons.circle,
              color: AppColors.textSecondary.withOpacity(0.3),
              size: 20,
            ),
        ],
      ),
    );
  }
}
