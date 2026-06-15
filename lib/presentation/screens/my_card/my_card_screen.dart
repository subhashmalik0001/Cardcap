import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/business_card.dart';
import '../../providers/cards_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/modern_button.dart';
import '../../widgets/common/modern_input.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/avatar_initials.dart';

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardScreenState();
}

class _MyCardScreenState extends State<MyCardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardsProvider>().loadMyCard();
    });
  }

  String _generateVCard(BusinessCard card) {
    final phone = card.phones.isNotEmpty ? card.phones.first : '';
    return 'BEGIN:VCARD\n'
        'VERSION:3.0\n'
        'N:${card.name ?? ''}\n'
        'FN:${card.name ?? ''}\n'
        'ORG:${card.company ?? ''}\n'
        'TITLE:${card.designation ?? ''}\n'
        'TEL:$phone\n'
        'EMAIL:${card.email ?? ''}\n'
        'URL:${card.website ?? ''}\n'
        'ADR:${card.address ?? ''}\n'
        'END:VCARD';
  }

  void _showCardEditor(BuildContext context, [BusinessCard? existingCard]) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (ctx) => _MyCardEditorSheet(
        existingCard: existingCard,
        onSave: (card) {
          context.read<CardsProvider>().saveMyCard(card);
        },
      ),
    );
  }

  void _deletePersonalCard() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Delete Personal Card', style: AppTypography.titleLarge),
        content: Text(
          'Are you sure you want to delete your personal digital card?',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<CardsProvider>().deleteMyCard();
              HapticFeedback.mediumImpact();
            },
            child: Text(
              'Delete',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<CardsProvider>(
          builder: (context, provider, _) {
            final myCard = provider.myCard;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      AppHeader(
                        title: 'My Card',
                        subtitle: 'Share your contact details instantly',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (myCard != null)
                              IconButton(
                                onPressed: _deletePersonalCard,
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
                                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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

                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
                if (myCard == null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        children: [
                          _buildPersonalCard(myCard),
                          const SizedBox(height: AppSpacing.xl),
                          _buildQrSection(myCard),
                          const SizedBox(height: AppSpacing.xxl),
                          ModernButton(
                            label: 'Edit Details',
                            icon: LucideIcons.edit3,
                            variant: ModernButtonVariant.ghost,
                            onPressed: () => _showCardEditor(context, myCard),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
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
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.creditCard,
                size: 36,
                color: AppColors.primary,
              ),
            )
                .animate()
                .scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Your Digital Card',
              style: AppTypography.titleLarge,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Create a digital business card to share your details instantly via a live QR code.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.xxl),
            ModernButton(
              label: 'Create My Card',
              icon: LucideIcons.plus,
              onPressed: () => _showCardEditor(context),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalCard(BusinessCard card) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.walletGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarInitials(
                  name: card.name,
                  size: 52,
                  fontSize: 20,
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
                          fontSize: 20,
                          color: AppColors.textOnPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (card.designation != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          card.designation!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (card.company != null) ...[
              Text(
                card.company!.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textOnPrimary,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
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
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildQrSection(BusinessCard card) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: _generateVCard(card),
              version: QrVersions.auto,
              size: 160.0,
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
          const SizedBox(height: AppSpacing.md),
          Text(
            'Scan to connect',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Others can scan this code using their phone camera to instantly save your contact details.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}

class _MyCardEditorSheet extends StatefulWidget {
  final BusinessCard? existingCard;
  final ValueChanged<BusinessCard> onSave;

  const _MyCardEditorSheet({
    this.existingCard,
    required this.onSave,
  });

  @override
  State<_MyCardEditorSheet> createState() => _MyCardEditorSheetState();
}

class _MyCardEditorSheetState extends State<_MyCardEditorSheet> {
  final _uuid = const Uuid();
  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final card = widget.existingCard;
    _nameController = TextEditingController(text: card?.name ?? '');
    _designationController = TextEditingController(text: card?.designation ?? '');
    _companyController = TextEditingController(text: card?.company ?? '');
    _phoneController = TextEditingController(
      text: (card?.phones.isNotEmpty ?? false) ? card!.phones.first : '',
    );
    _emailController = TextEditingController(text: card?.email ?? '');
    _websiteController = TextEditingController(text: card?.website ?? '');
    _addressController = TextEditingController(text: card?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final card = BusinessCard(
      id: widget.existingCard?.id ?? _uuid.v4(),
      name: name,
      designation: _designationController.text.trim().isEmpty ? null : _designationController.text.trim(),
      company: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
      phones: _phoneController.text.trim().isEmpty ? [] : [_phoneController.text.trim()],
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      createdAt: widget.existingCard?.createdAt ?? DateTime.now(),
    );

    widget.onSave(card);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.existingCard == null ? 'Create Personal Card' : 'Edit Personal Card',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    ModernInput(
                      label: 'Full Name',
                      icon: LucideIcons.user,
                      controller: _nameController,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ModernInput(
                      label: 'Job Title / Designation',
                      icon: LucideIcons.briefcase,
                      controller: _designationController,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ModernInput(
                      label: 'Company Name',
                      icon: LucideIcons.building,
                      controller: _companyController,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ModernInput(
                      label: 'Phone Number',
                      icon: LucideIcons.phone,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ModernInput(
                      label: 'Email Address',
                      icon: LucideIcons.mail,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ModernInput(
                      label: 'Website',
                      icon: LucideIcons.globe,
                      controller: _websiteController,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ModernInput(
                      label: 'Address',
                      icon: LucideIcons.mapPin,
                      controller: _addressController,
                      multiline: true,
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ModernButton(
                      label: 'Save Card',
                      icon: LucideIcons.check,
                      onPressed: _save,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
