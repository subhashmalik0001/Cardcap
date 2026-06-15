import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/permission_utils.dart';
import '../../../data/models/business_card.dart';
import '../../providers/cards_provider.dart';
import '../../widgets/common/modern_input.dart';
import '../../widgets/common/modern_button.dart';
import '../../widgets/review/wallet_card_preview.dart';

class ReviewScreen extends StatefulWidget {
  final BusinessCard card;

  const ReviewScreen({
    super.key,
    required this.card,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late BusinessCard _currentCard;
  bool _isNewCard = true;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _linkedinController;
  late TextEditingController _twitterController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
    
    // Check if card already exists in local list
    final cardsProvider = context.read<CardsProvider>();
    _isNewCard = !cardsProvider.cards.any((c) => c.id == widget.card.id);

    // Initialize controllers
    _nameController = TextEditingController(text: _currentCard.name ?? '');
    _designationController = TextEditingController(text: _currentCard.designation ?? '');
    _companyController = TextEditingController(text: _currentCard.company ?? '');
    _phoneController = TextEditingController(
      text: _currentCard.phones.isNotEmpty ? _currentCard.phones.first : '',
    );
    _emailController = TextEditingController(text: _currentCard.email ?? '');
    _websiteController = TextEditingController(text: _currentCard.website ?? '');
    _addressController = TextEditingController(text: _currentCard.address ?? '');
    _linkedinController = TextEditingController(text: _currentCard.linkedin ?? '');
    _twitterController = TextEditingController(text: _currentCard.twitter ?? '');
    _notesController = TextEditingController(text: _currentCard.notes ?? '');
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
    _linkedinController.dispose();
    _twitterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateCardField() {
    setState(() {
      _currentCard = _currentCard.copyWith(
        name: _nameController.text.trim(),
        designation: _designationController.text.trim().isEmpty ? null : _designationController.text.trim(),
        company: _companyController.text.trim().isEmpty ? null : _companyController.text.trim(),
        phones: _phoneController.text.trim().isEmpty ? [] : [_phoneController.text.trim()],
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        linkedin: _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
        twitter: _twitterController.text.trim().isEmpty ? null : _twitterController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
    });
  }

  Future<void> _saveCard() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required to save contact'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final provider = context.read<CardsProvider>();
      if (_isNewCard) {
        await provider.addCard(_currentCard);
      } else {
        await provider.updateCard(_currentCard);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isNewCard ? 'Contact saved successfully' : 'Contact updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _exportToPhoneContacts() async {
    final granted = await PermissionUtils.requestContacts(context);
    if (!granted) return;

    try {
      final contact = Contact(
        name: Name(first: _currentCard.name ?? ''),
        phones: _currentCard.phones.map((p) => Phone(p)).toList(),
        emails: _currentCard.email != null ? [Email(_currentCard.email!)] : [],
        organizations: _currentCard.company != null
            ? [
                Organization(
                  company: _currentCard.company!,
                  title: _currentCard.designation ?? '',
                )
              ]
            : [],
        addresses: _currentCard.address != null ? [Address(_currentCard.address!)] : [],
        websites: _currentCard.website != null ? [Website(_currentCard.website!)] : [],
      );
      await FlutterContacts.openExternalInsert(contact);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export contact: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: AppColors.cardShadow,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          _isNewCard ? 'Review Card' : 'Contact Details',
          style: AppTypography.titleLarge,
        ),
        actions: [
          if (!_isNewCard)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md, top: 8, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.cardShadow,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(LucideIcons.userPlus, size: 20, color: AppColors.primary),
                  onPressed: _exportToPhoneContacts,
                  tooltip: 'Export to Contacts',
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    
                    // Live Card Preview
                    WalletCardPreview(card: _currentCard),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Fields form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CONTACT DETAILS',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          ModernInput(
                            label: 'Full Name',
                            icon: LucideIcons.user,
                            controller: _nameController,
                            onChanged: (_) => _updateCardField(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          
                          ModernInput(
                            label: 'Job Title / Designation',
                            icon: LucideIcons.briefcase,
                            controller: _designationController,
                            onChanged: (_) => _updateCardField(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          
                          ModernInput(
                            label: 'Company Name',
                            icon: LucideIcons.building,
                            controller: _companyController,
                            onChanged: (_) => _updateCardField(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          
                          ModernInput(
                            label: 'Phone Number',
                            icon: LucideIcons.phone,
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => _updateCardField(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          
                          ModernInput(
                            label: 'Email Address',
                            icon: LucideIcons.mail,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => _updateCardField(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          
                          ModernInput(
                            label: 'Website',
                            icon: LucideIcons.globe,
                            controller: _websiteController,
                            keyboardType: TextInputType.url,
                            onChanged: (_) => _updateCardField(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          
                          ModernInput(
                            label: 'Address',
                            icon: LucideIcons.mapPin,
                            controller: _addressController,
                            multiline: true,
                            maxLines: 2,
                            onChanged: (_) => _updateCardField(),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          Text(
                            'SOCIALS & NOTES',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          
                          ModernInput(
                            label: 'LinkedIn URL',
                            icon: LucideIcons.linkedin,
                            controller: _linkedinController,
                            onChanged: (_) => _updateCardField(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          
                          ModernInput(
                            label: 'Twitter Handle / URL',
                            icon: LucideIcons.twitter,
                            controller: _twitterController,
                            onChanged: (_) => _updateCardField(),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          
                          ModernInput(
                            label: 'Notes',
                            icon: LucideIcons.stickyNote,
                            controller: _notesController,
                            multiline: true,
                            maxLines: 3,
                            onChanged: (_) => _updateCardField(),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Sticky Bottom CTA Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  if (_isNewCard) ...[
                    Expanded(
                      child: ModernButton(
                        label: 'Save to Wallet',
                        icon: LucideIcons.check,
                        isLoading: _isSaving,
                        onPressed: _saveCard,
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ModernButton(
                        label: 'Save Changes',
                        icon: LucideIcons.check,
                        isLoading: _isSaving,
                        onPressed: _saveCard,
                      ),
                    ),
                  ],
                  if (_isNewCard) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ModernButton(
                        label: 'Add to Contacts',
                        icon: LucideIcons.userPlus,
                        variant: ModernButtonVariant.ghost,
                        onPressed: _exportToPhoneContacts,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
