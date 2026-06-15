import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/permission_utils.dart';
import '../../../data/models/business_card.dart';
import '../../providers/cards_provider.dart';
import '../../providers/my_card_provider.dart';
import '../../widgets/common/avatar_initials.dart';
import '../../widgets/contacts/search_bar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToScan;
  final VoidCallback? onNavigateToContacts;
  final VoidCallback? onNavigateToMyCard;
  final VoidCallback? onNavigateToStatistics;

  const HomeScreen({
    super.key,
    this.onNavigateToScan,
    this.onNavigateToContacts,
    this.onNavigateToMyCard,
    this.onNavigateToStatistics,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardsProvider>().loadCards();
      context.read<CardsProvider>().loadMyCard();
      context.read<MyCardProvider>().init();
    });
  }

  void _showCardBottomSheet(BuildContext context, BusinessCard card) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CardBottomSheet(
        card: card,
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
        emails: card.email != null ? [Email(card.email!)] : [],
        organizations: card.company != null
            ? [
                Organization(
                  company: card.company!,
                  title: card.designation ?? '',
                )
              ]
            : [],
        addresses: card.address != null ? [Address(card.address!)] : [],
        websites: card.website != null ? [Website(card.website!)] : [],
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
            final recentCards = provider.filteredCards.take(3).toList();
            final quickContacts = provider.filteredCards.take(5).toList();

            return RefreshIndicator(
              onRefresh: () async {
                await provider.loadCards();
                await provider.loadMyCard();
              },
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Custom App Bar
                    _buildCustomAppBar(),

                    // Search Bar
                    ContactSearchBar(
                      value: provider.searchQuery,
                      onChanged: provider.setSearch,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Hero Card Stack
                    _buildCardStack(provider),

                    // Quick Contacts Section
                    _buildQuickContactsSection(quickContacts),

                    // Recent Cards Section
                    _buildRecentCardsSection(recentCards),

                    // Bottom Padding
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (widget.onNavigateToStatistics != null) {
                widget.onNavigateToStatistics!();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: AppColors.cardShadow,
              ),
              child: const Icon(
                LucideIcons.menu,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          // App Title
          Column(
            children: [
              Text(
                'CardCapture',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'My Cards & Contacts',
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Plus button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (widget.onNavigateToScan != null) {
                widget.onNavigateToScan!();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: AppColors.cardShadow,
              ),
              child: const Icon(
                LucideIcons.plus,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _currentIndex = 0;

  Widget _buildCardStack(CardsProvider cardsProvider) {
    final userProvider = Provider.of<MyCardProvider>(context);
    final double cardWidth = MediaQuery.of(context).size.width - 32;
    final double cardHeight = userProvider.cardRatio == 'square' ? cardWidth : cardWidth / 1.75;
    
    // Create card widgets list
    final List<Widget> cardWidgets = [];

    // 1. User Card
    Widget userCardWidget;
    if (userProvider.savedCardImage != null) {
      userCardWidget = ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.memory(
          userProvider.savedCardImage!,
          height: cardHeight,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
      );
    } else if (userProvider.cardImageUrl != null && userProvider.cardImageUrl!.isNotEmpty) {
      userCardWidget = ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.network(
          userProvider.cardImageUrl!,
          height: cardHeight,
          width: double.infinity,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) => _buildDefaultUserCard(userProvider, cardHeight),
        ),
      );
    } else {
      userCardWidget = _buildDefaultUserCard(userProvider, cardHeight);
    }

    final userCardContainer = Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: userCardWidget,
    );

    cardWidgets.add(userCardContainer);

    // 2. Scanned Cards
    for (final card in cardsProvider.cards) {
      cardWidgets.add(
        _buildScannedCardInStack(card, cardHeight),
      );
    }

    final int total = cardWidgets.length;
    if (total == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      height: cardHeight + 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 3D Card 3 (backmost) - only if total >= 3
          if (total >= 3)
            Positioned(
              left: 0,
              right: 0,
              top: 4,
              child: Opacity(
                opacity: 0.4,
                child: Transform.rotate(
                  angle: -6 * 3.141592653589793 / 180,
                  child: Transform.scale(
                    scale: 0.88,
                    child: cardWidgets[(_currentIndex + 2) % total],
                  ),
                ),
              ),
            ),
          
          // 3D Card 2 (middle) - only if total >= 2
          if (total >= 2)
            Positioned(
              left: 0,
              right: 0,
              top: 12,
              child: Opacity(
                opacity: 0.7,
                child: Transform.rotate(
                  angle: -3 * 3.141592653589793 / 180,
                  child: Transform.scale(
                    scale: 0.94,
                    child: cardWidgets[(_currentIndex + 1) % total],
                  ),
                ),
              ),
            ),

          // 3D Card 1 (frontmost)
          Positioned(
            left: 0,
            right: 0,
            top: 20,
            child: Dismissible(
              key: ValueKey('swipeable_card_$_currentIndex'),
              direction: total > 1 ? DismissDirection.horizontal : DismissDirection.none,
              onDismissed: (direction) {
                HapticFeedback.lightImpact();
                setState(() {
                  _currentIndex = (_currentIndex + 1) % total;
                });
              },
              child: cardWidgets[_currentIndex % total],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedCardInStack(BusinessCard card, double height) {
    if (card.cardImageUrl != null && card.cardImageUrl!.isNotEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.network(
            card.cardImageUrl!,
            height: height,
            width: double.infinity,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) =>
                _buildScannedCardPlaceholder(card, height),
          ),
        ),
      );
    }
    return _buildScannedCardPlaceholder(card, height);
  }

  Widget _buildScannedCardPlaceholder(BusinessCard card, double height) {
    // Generate a beautiful consistent gradient based on the card id hash
    final gradients = [
      const [Color(0xFF2C3E50), Color(0xFF3498DB)], // Dark Blue
      const [Color(0xFF13A664), Color(0xFF118C55)], // Green Teal
      const [Color(0xFF8E44AD), Color(0xFF9B59B6)], // Purple
      const [Color(0xFFD35400), Color(0xFFE67E22)], // Orange/Rust
      const [Color(0xFF1D1D1D), Color(0xFF4A4A4A)], // Dark Charcoal
      const [Color(0xFF1E3C72), Color(0xFF2A5298)], // Royal Navy
    ];
    final gradientIndex = card.id.hashCode.abs() % gradients.length;
    final colors = gradients[gradientIndex];

    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  card.company ?? 'Business Contact',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.scan, size: 12, color: Colors.white70),
                  SizedBox(width: 4),
                  Text(
                    'Scanned',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            card.displayName,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (card.designation != null && card.designation!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              card.designation!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
          const Spacer(),
          if (card.phones.isNotEmpty) ...[
            Row(
              children: [
                const Icon(LucideIcons.phone, size: 12, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  card.phones.first,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (card.email != null && card.email!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(LucideIcons.mail, size: 12, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  card.email!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (card.website != null && card.website!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(LucideIcons.globe, size: 12, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  card.website!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultUserCard(MyCardProvider provider, double height) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B68F0), Color(0xFF4A25C9)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Card',
                style: AppTypography.titleLarge.copyWith(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(LucideIcons.wallet, color: Colors.white70, size: 18),
            ],
          ),
          const Spacer(),
          Text(
            provider.details?.name.isNotEmpty == true ? provider.details!.name : 'Your Name',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            provider.details?.title?.isNotEmpty == true ? provider.details!.title! : 'Tap Redesign below to customize',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  if (widget.onNavigateToMyCard != null) {
                    widget.onNavigateToMyCard!();
                  }
                },
                icon: const Icon(LucideIcons.palette, size: 14),
                label: const Text('Redesign', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6A3EEB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContactsSection(List<BusinessCard> quickContacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Contacts',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (widget.onNavigateToContacts != null) {
                    widget.onNavigateToContacts!();
                  }
                },
                child: Text(
                  'See more',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Add button (Dashed border)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (widget.onNavigateToScan != null) {
                    widget.onNavigateToScan!();
                  }
                },
                child: Column(
                  children: [
                    CustomPaint(
                      painter: DashedCirclePainter(
                        color: AppColors.primary,
                        strokeWidth: 1.5,
                      ),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight,
                        ),
                        child: const Icon(
                          LucideIcons.plus,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add',
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 56,
                color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              // Contacts list
              if (quickContacts.isEmpty)
                // Shimmer placeholders if no cards
                Row(
                  children: List.generate(4, (index) => _buildShimmerAvatar()),
                )
              else
                Row(
                  children: quickContacts.map((card) {
                    final firstName = (card.name ?? '').split(' ').first;
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: AvatarInitials(
                              name: card.name,
                              size: 52,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 56,
                            child: Text(
                              firstName.isNotEmpty ? firstName : 'Unknown',
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerAvatar() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE8E8E8),
        highlightColor: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 40,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCardsSection(List<BusinessCard> recentCards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Cards',
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (widget.onNavigateToContacts != null) {
                    widget.onNavigateToContacts!();
                  }
                },
                child: Text(
                  'See more',
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(3, (index) {
              if (index < recentCards.length) {
                final card = recentCards[index];
                final formattedDate = DateFormat('MMMM dd, yyyy').format(card.createdAt);
                final initials = _getInitials(card.name);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _showCardBottomSheet(context, card),
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInput,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryLight,
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: AppTypography.labelLarge.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            card.displayName,
                            style: AppTypography.displayMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedDate,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            card.company ?? card.designation ?? '—',
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: card.company != null
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                // Shimmer card if less than 3 cards scanned
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                    child: _buildShimmerTile(),
                  ),
                );
              }
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerTile() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8E8),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 60,
              height: 12,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: 10,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 12,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  DashedCirclePainter({required this.color, this.strokeWidth = 1.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const int dashCount = 12;
    const double dashLength = 6.0;
    const double gapLength = 4.0;
    final double circumference = 2 * 3.141592653589793 * radius;
    final double arcLength = (dashLength / circumference) * 2 * 3.141592653589793;
    final double gapArcLength = (gapLength / circumference) * 2 * 3.141592653589793;

    double startAngle = 0.0;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcLength,
        false,
        paint,
      );
      startAngle += arcLength + gapArcLength;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardBottomSheet extends StatelessWidget {
  final BusinessCard card;
  final VoidCallback onSaveToContacts;
  final VoidCallback onDelete;

  const _CardBottomSheet({
    required this.card,
    required this.onSaveToContacts,
    required this.onDelete,
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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              AvatarInitials(name: card.name, size: 44),
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
