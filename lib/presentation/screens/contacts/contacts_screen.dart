import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/permission_utils.dart';
import '../../../data/models/business_card.dart';
import '../../providers/cards_provider.dart';
import '../../widgets/common/app_header.dart';
import '../../widgets/common/shimmer_card.dart';
import '../../widgets/common/avatar_initials.dart';
import '../../widgets/contacts/contact_card.dart';
import '../../widgets/contacts/search_bar.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardsProvider>().loadCards();
    });
  }

  void _showCardBottomSheet(BuildContext context, BusinessCard card, {int? index}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CardBottomSheet(
        card: card,
        index: index,
        onSaveToContacts: () => _saveToPhoneContacts(card),
        onDelete: () => _deleteCard(card),
      ),
    );
  }

  Future<void> _saveToPhoneContacts(BusinessCard card) async {
    Navigator.of(context).pop(); // Close bottom sheet

    if (!mounted) return;
    final granted = await PermissionUtils.requestContacts(context);
    if (!granted) return;

    try {
      final contact = Contact(
        name: Name(first: card.name ?? ''),
        phones: card.phones.map((p) => Phone(p)).toList(),
        emails:
            card.email != null ? [Email(card.email!)] : [],
        organizations: card.company != null
            ? [
                Organization(
                  company: card.company!,
                  title: card.designation ?? '',
                )
              ]
            : [],
        addresses:
            card.address != null ? [Address(card.address!)] : [],
        websites:
            card.website != null ? [Website(card.website!)] : [],
      );
      await FlutterContacts.openExternalInsert(contact);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open contacts: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _deleteCard(BusinessCard card) {
    Navigator.of(context).pop(); // Close bottom sheet
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Delete Card', style: AppTypography.titleLarge),
        content: Text(
          'Are you sure you want to delete ${card.displayName}?',
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
              context.read<CardsProvider>().deleteCard(card.id);
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
            return RefreshIndicator(
              onRefresh: () => provider.loadCards(),
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        AppHeader(
                          title: 'Contacts',
                          subtitle: '${provider.cardCount} business cards',
                          trailing: IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
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
                                LucideIcons.arrowUpDown,
                                size: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ContactSearchBar(
                          value: provider.searchQuery,
                          onChanged: provider.setSearch,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),

                  // Content
                  if (provider.isLoading)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, _i) => const ShimmerCard(),
                        childCount: 4,
                      ),
                    )
                  else if (provider.filteredCards.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(provider.searchQuery.isNotEmpty),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final card = provider.filteredCards[index];
                          return ContactCard(
                            key: ValueKey(card.id),
                            card: card,
                            index: index,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/review',
                                arguments: card,
                              );
                            },
                            onLongPress: () =>
                                _showCardBottomSheet(context, card, index: index),
                            onMenuTap: () =>
                                _showCardBottomSheet(context, card, index: index),
                          );
                        },
                        childCount: provider.filteredCards.length,
                      ),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearch) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearch ? LucideIcons.searchX : LucideIcons.folderOpen,
              size: 32,
              color: AppColors.primary,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 400.ms,
              ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isSearch ? 'No results found' : 'No cards yet',
            style: AppTypography.titleLarge,
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isSearch
                ? 'Try a different search term'
                : 'Tap Scan to capture your first business card',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

class _CardBottomSheet extends StatelessWidget {
  final BusinessCard card;
  final VoidCallback onSaveToContacts;
  final VoidCallback onDelete;
  final int? index;

  const _CardBottomSheet({
    required this.card,
    required this.onSaveToContacts,
    required this.onDelete,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Avatar + Name
          Row(
            children: [
              AvatarInitials(
                name: card.displayName,
                index: index,
                size: 44,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.displayName, style: AppTypography.titleLarge),
                    if (card.designation != null)
                      Text(
                        card.designation!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.borderLight, thickness: 0.5),
          const SizedBox(height: AppSpacing.xs),

          // Save to contacts
          ListTile(
            leading: const Icon(
              LucideIcons.userPlus,
              size: 20,
              color: AppColors.primary,
            ),
            title: Text(
              'Save to Phone Contacts',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            onTap: onSaveToContacts,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),

          // Delete
          ListTile(
            leading: const Icon(
              LucideIcons.trash2,
              size: 20,
              color: AppColors.error,
            ),
            title: Text(
              'Delete Card',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
            ),
            onTap: onDelete,
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Cancel
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
