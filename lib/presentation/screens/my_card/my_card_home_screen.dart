import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/my_card_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/modern_button.dart';

class MyCardHomeScreen extends StatefulWidget {
  const MyCardHomeScreen({super.key});

  @override
  State<MyCardHomeScreen> createState() => _MyCardHomeScreenState();
}

class _MyCardHomeScreenState extends State<MyCardHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load the personal card design on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyCardProvider>().init();
    });
  }

  String _generateVCard(MyCardProvider provider) {
    final details = provider.details;
    if (details == null) return '';
    return 'BEGIN:VCARD\n'
        'VERSION:3.0\n'
        'N:${details.name}\n'
        'FN:${details.name}\n'
        'ORG:${details.company ?? ''}\n'
        'TITLE:${details.title ?? ''}\n'
        'TEL:${details.phone ?? ''}\n'
        'EMAIL:${details.email ?? ''}\n'
        'URL:${details.website ?? ''}\n'
        'ADR:${details.address ?? ''}\n'
        'END:VCARD';
  }

  void _showQrCodeDialog(MyCardProvider provider) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Center(
          child: Text(
            'Scan to Connect',
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: QrImageView(
                data: _generateVCard(provider),
                version: QrVersions.auto,
                size: 200.0,
                gapless: false,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scan with any phone camera to instantly add ${provider.details?.name ?? "me"} to contacts.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Close',
                style: AppTypography.labelLarge.copyWith(color: const Color(0xFF6A3EEB)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyDeepLink(MyCardProvider provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?['id'] ?? 'user';
    final deepLink = provider.cardImageUrl ?? 'https://cardcap.app/card/$userId';
    
    await Clipboard.setData(ClipboardData(text: deepLink));
    HapticFeedback.lightImpact();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deep link copied to clipboard!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _shareCard(MyCardProvider provider) async {
    HapticFeedback.lightImpact();
    final name = provider.details?.name ?? 'My Business Card';
    final link = provider.cardImageUrl ?? 'Check out my digital business card';
    
    if (provider.savedCardImage != null) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/business_card.png';
      final file = File(path);
      await file.writeAsBytes(provider.savedCardImage!);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'Check out my digital business card! — $name',
      );
    } else {
      await Share.share(
        'Check out my digital business card:\nName: $name\nLink: $link',
      );
    }
  }

  Future<void> _saveAsImage(MyCardProvider provider) async {
    if (provider.savedCardImage == null) return;
    HapticFeedback.mediumImpact();

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/my_business_card_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(provider.savedCardImage!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card saved successfully to: $path'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save card: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showShareBottomSheet(MyCardProvider provider) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share My Card',
                style: AppTypography.headlineMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              
              // Share options grid/list
              _buildShareTile(
                icon: LucideIcons.qrCode,
                label: 'Show QR Code',
                onTap: () {
                  Navigator.pop(ctx);
                  _showQrCodeDialog(provider);
                },
              ),
              _buildShareTile(
                icon: LucideIcons.link2,
                label: 'Copy Link',
                onTap: () {
                  Navigator.pop(ctx);
                  _copyDeepLink(provider);
                },
              ),
              _buildShareTile(
                icon: LucideIcons.share2,
                label: 'Share via...',
                onTap: () {
                  Navigator.pop(ctx);
                  _shareCard(provider);
                },
              ),
              _buildShareTile(
                icon: LucideIcons.download,
                label: 'Save as Image',
                onTap: () {
                  Navigator.pop(ctx);
                  _saveAsImage(provider);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6A3EEB)),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF6A3EEB),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.creditCard,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Create Your Card',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Design a professional business card to share with anyone',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pushNamed('/my-card/details');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A3EEB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  '+ Create My Card',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewState(MyCardProvider provider) {
    final double cardWidth = MediaQuery.of(context).size.width - 32;
    final double cardHeight = provider.cardRatio == 'square' ? cardWidth : cardWidth / 1.75;

    Widget imageWidget;
    if (provider.savedCardImage != null) {
      imageWidget = Image.memory(
        provider.savedCardImage!,
        width: cardWidth,
        height: cardHeight,
        fit: BoxFit.cover,
      );
    } else if (provider.cardImageUrl != null && provider.cardImageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        provider.cardImageUrl!,
        width: cardWidth,
        height: cardHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        ),
      );
    } else {
      imageWidget = Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(LucideIcons.creditCard, size: 40, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          // Rendered business card image container
          Container(
            width: cardWidth,
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageWidget,
            ),
          ),
          const SizedBox(height: 32),

          // Actions row
          ModernButton(
            label: 'Share Card',
            icon: LucideIcons.share2,
            onPressed: () => _showShareBottomSheet(provider),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: ModernButton(
                  label: 'Edit Details',
                  icon: LucideIcons.edit3,
                  variant: ModernButtonVariant.outlined,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pushNamed('/my-card/details');
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ModernButton(
                  label: 'Redesign',
                  icon: LucideIcons.palette,
                  variant: ModernButtonVariant.ghost,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pushNamed('/my-card/designer');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _deleteCard() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Delete Card Design', style: AppTypography.titleLarge),
        content: Text(
          'Are you sure you want to delete your personal card design and details?',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              HapticFeedback.mediumImpact();
              await context.read<MyCardProvider>().deleteCard();
            },
            child: Text(
              'Delete',
              style: AppTypography.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Consumer<MyCardProvider>(
          builder: (context, provider, _) {
            final hasCard = provider.hasCard;

            return Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                AppHeader(
                  title: 'My Card',
                  subtitle: 'Share your contact details instantly',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasCard)
                        IconButton(
                          onPressed: _deleteCard,
                          icon: const Icon(
                            LucideIcons.trash2,
                            size: 20,
                            color: AppColors.error,
                          ),
                        ),
                      IconButton(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.logout();
                          if (mounted) {
                            Navigator.of(context, rootNavigator: true)
                                .pushNamedAndRemoveUntil('/login', (route) => false);
                          }
                        },
                        icon: const Icon(
                          LucideIcons.logOut,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF6A3EEB)),
                        )
                      : hasCard
                          ? _buildPreviewState(provider)
                          : _buildEmptyState(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
