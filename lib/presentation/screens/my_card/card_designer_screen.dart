import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/my_card_provider.dart';
import '../../widgets/my_card/card_canvas.dart';
import '../../../data/models/card_template.dart';
import '../../../data/models/my_card_details.dart';

class CardDesignerScreen extends StatefulWidget {
  const CardDesignerScreen({super.key});

  @override
  State<CardDesignerScreen> createState() => _CardDesignerScreenState();
}

class _CardDesignerScreenState extends State<CardDesignerScreen> {
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _canvasKey = GlobalKey();
  final _picker = ImagePicker();
  bool _isSaving = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    // Default ratio to standard on entry and clear selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MyCardProvider>();
      provider.setCardRatio('standard');
      provider.selectField(null);
    });
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        if (mounted) {
          context.read<MyCardProvider>().setPhoto(File(pickedFile.path));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo added to card'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showPhotoOptions() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(LucideIcons.camera, color: Color(0xFF6A3EEB)),
              title: const Text('Take Photo', style: TextStyle(fontFamily: 'Inter')),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: Color(0xFF6A3EEB)),
              title: const Text('Choose from Gallery', style: TextStyle(fontFamily: 'Inter')),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            if (context.read<MyCardProvider>().userPhoto != null ||
                context.read<MyCardProvider>().photoUrl != null)
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: AppColors.error),
                title: const Text('Remove Photo', style: TextStyle(fontFamily: 'Inter', color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<MyCardProvider>().removePhoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showShapePicker() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer<MyCardProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Photo Shape',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: PhotoShape.values.map((shape) {
                      final isSelected = provider.photoShape == shape;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          provider.setPhotoShape(shape);
                          Navigator.pop(ctx);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEDE8FC)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF6A3EEB)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: _buildShapeIcon(shape),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getShapeLabel(shape),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: isSelected
                                    ? const Color(0xFF6A3EEB)
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShapeIcon(PhotoShape shape) {
    switch (shape) {
      case PhotoShape.circle:
        return const Icon(LucideIcons.circle, color: Color(0xFF6A3EEB), size: 20);
      case PhotoShape.roundedSquare:
        return const Icon(LucideIcons.square, color: Color(0xFF6A3EEB), size: 20); // Rounded square approximation
      case PhotoShape.square:
        return const Icon(LucideIcons.square, color: Color(0xFF6A3EEB), size: 20);
      case PhotoShape.hexagon:
        return const Icon(LucideIcons.hexagon, color: Color(0xFF6A3EEB), size: 20);
      case PhotoShape.diamond:
        return Transform.rotate(
          angle: math.pi / 4,
          child: const Icon(LucideIcons.square, color: Color(0xFF6A3EEB), size: 18),
        );
    }
  }

  String _getShapeLabel(PhotoShape shape) {
    switch (shape) {
      case PhotoShape.circle:
        return 'Circle';
      case PhotoShape.roundedSquare:
        return 'Rounded';
      case PhotoShape.square:
        return 'Square';
      case PhotoShape.hexagon:
        return 'Hexagon';
      case PhotoShape.diamond:
        return 'Diamond';
    }
  }

  void _showColorPicker() {
    HapticFeedback.mediumImpact();
    final presets = [
      Colors.white,
      Colors.black,
      const Color(0xFF6A3EEB),
      const Color(0xFFE84040),
      const Color(0xFF12A664),
      const Color(0xFFF0B31B),
      const Color(0xFFFF4500),
      const Color(0xFF1A1A2E),
      const Color(0xFF6B6B6B),
      const Color(0xFFEDE8FC),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Text Color',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final color = presets[index];
                    final isSelected = Provider.of<MyCardProvider>(context).textColor.value == color.value;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Provider.of<MyCardProvider>(context, listen: false).setTextColor(color);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6A3EEB)
                                : color == Colors.white
                                    ? Colors.grey[300]!
                                    : Colors.transparent,
                            width: isSelected ? 3.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                LucideIcons.check,
                                color: color == Colors.white || color == const Color(0xFFEDE8FC)
                                    ? const Color(0xFF6A3EEB)
                                    : Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    
    // Clear selection so handles/outline deselect instantly
    context.read<MyCardProvider>().selectField(null);

    setState(() {
      _isSaving = true;
      _isCapturing = true;
    });
    HapticFeedback.mediumImpact();

    // Brief delay to allow handles to hide
    await Future.delayed(const Duration(milliseconds: 100));

    // Show loading indicator dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6A3EEB),
          ),
        ),
      );
    }

    try {
      // 1. Capture the RepaintBoundary as PNG
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Canvas render object was not found.');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Could not extract image data.');
      }
      final cardImageBytes = byteData.buffer.asUint8List();

      // 2. Save inside provider
      final provider = context.read<MyCardProvider>();
      await provider.saveCard(
        details: provider.details!,
        cardImageBytes: cardImageBytes,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card saved successfully! Syncing with server...'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate back to Home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save card design: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isCapturing = false;
        });
      }
    }
  }

  Widget _buildStepPill(String label, bool isActive) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6A3EEB) : const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateThumbnail(CardTemplate template, bool isSelected) {
    Widget miniBg;
    if (template.backgroundImageUrl != null && template.backgroundImageUrl!.isNotEmpty) {
      miniBg = Image.network(
        template.backgroundImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(color: template.backgroundColor),
      );
    } else {
      switch (template.id) {
        case 'classic':
          miniBg = Container(
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 5,
                  child: Container(color: const Color(0xFF6A3EEB)),
                ),
              ],
            ),
          );
          break;
        case 'dark_pro':
          miniBg = Container(
            color: const Color(0xFF1A1A2E),
            child: Stack(
              children: [
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0B31B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 3,
                  child: Container(
                    color: const Color(0xFF6A3EEB),
                  ),
                ),
              ],
            ),
          );
          break;
        case 'gradient':
          miniBg = Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A3EEB), Color(0xFF9B6EF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          );
          break;
        case 'cream':
          miniBg = Container(
            color: const Color(0xFFFAF7F2),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 2,
                  child: Container(color: const Color(0xFF6A3EEB)),
                ),
              ],
            ),
          );
          break;
        case 'split':
          miniBg = Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(color: const Color(0xFF6A3EEB)),
              ),
              Expanded(
                flex: 1,
                child: Container(color: Colors.white),
              ),
            ],
          );
          break;
        case 'fire':
          miniBg = Container(
            color: Colors.white,
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 28,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
          break;
        default:
          miniBg = Container(color: template.backgroundColor);
      }
    }

    return Container(
      width: 80,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF6A3EEB) : const Color(0xFFE0E0E0),
          width: isSelected ? 2.5 : 0.8,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF6A3EEB).withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: miniBg,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 68,
        leading: Center(
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              icon: const Icon(
                LucideIcons.arrowLeft,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Design Your Card',
              style: AppTypography.headlineMedium.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Step 2 of 2',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6A3EEB),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Save',
                  style: AppTypography.labelLarge.copyWith(
                    color: const Color(0xFF6A3EEB),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<MyCardProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepPill('○ Step 1: Details', false),
                      const SizedBox(width: AppSpacing.sm),
                      _buildStepPill('● Step 2: Design', true),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 1. Template picker strip
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: CardTemplate.templates.length,
                      itemBuilder: (context, index) {
                        final temp = CardTemplate.templates[index];
                        final isSelected = provider.template.id == temp.id;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            provider.selectTemplate(temp);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                _buildTemplateThumbnail(temp, isSelected),
                                const SizedBox(height: 6),
                                Text(
                                  temp.name,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFF6A3EEB)
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 2. Design canvas inside RepaintBoundary
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      provider.selectField(null);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: CardCanvas(
                          key: _canvasKey,
                          template: provider.template,
                          fields: provider.visibleFields,
                          fieldPositions: provider.fieldPositions,
                          userPhoto: provider.userPhoto,
                          photoUrl: provider.photoUrl,
                          photoShape: provider.photoShape,
                          userDetails: provider.details ?? const MyCardDetails(name: ''),
                          textColor: provider.textColor,
                          cardRatio: provider.cardRatio,
                          onUpdatePosition: (field, offset) {
                            provider.updateFieldPosition(field, offset);
                          },
                          onPhotoTap: _showPhotoOptions,
                          canvasKey: _canvasKey,
                          isDesignerMode: !_isCapturing,
                          showIcons: provider.showIcons,
                          photoSize: provider.photoSize,
                          textSizes: provider.textSizes,
                          onResizePhoto: (newSize) => provider.setPhotoSize(newSize),
                          onResizeField: (field, newSize) => provider.updateTextSize(field, newSize),
                          selectedField: provider.selectedField,
                          onSelectField: (field) => provider.selectField(field),
                          fieldColors: provider.fieldColors,
                          fieldFonts: provider.fieldFonts,
                          fieldStyles: provider.fieldStyles,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 3. Conditional Customization Panel / Fields toggle panel
                  if (provider.selectedField != null)
                    _buildSelectedFieldPanel(provider)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Fields on Card',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Icons',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Transform.scale(
                                      scale: 0.75,
                                      child: Switch(
                                        value: provider.showIcons,
                                        activeThumbColor: const Color(0xFF6A3EEB),
                                        activeTrackColor: const Color(0xFFEDE8FC),
                                        onChanged: (val) {
                                          HapticFeedback.selectionClick();
                                          provider.setShowIcons(val);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: provider.visibleFields.keys.map((fieldKey) {
                                final isVisible = provider.visibleFields[fieldKey] == true;
                                String label = fieldKey.toUpperCase();
                                if (fieldKey == 'name') label = 'NAME *';

                                return FilterChip(
                                  label: Text(
                                    label,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: isVisible ? FontWeight.w600 : FontWeight.w500,
                                      color: isVisible
                                          ? const Color(0xFF6A3EEB)
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  selected: isVisible,
                                  selectedColor: const Color(0xFFEDE8FC),
                                  checkmarkColor: const Color(0xFF6A3EEB),
                                  showCheckmark: isVisible,
                                  side: BorderSide(
                                    color: isVisible
                                        ? const Color(0xFF6A3EEB)
                                        : const Color(0xFFE0E0E0),
                                    width: isVisible ? 1.5 : 0.8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  onSelected: (val) {
                                    if (fieldKey == 'name') return; // Cannot disable name
                                    HapticFeedback.selectionClick();
                                    provider.toggleField(fieldKey, val);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),

                  // 4. Tools row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Photo tool
                        _buildToolButton(
                          icon: LucideIcons.camera,
                          label: 'Photo',
                          onTap: _showPhotoOptions,
                        ),
                        // Shape tool
                        _buildToolButton(
                          icon: LucideIcons.shapes,
                          label: 'Shape',
                          onTap: _showShapePicker,
                        ),
                        // Text color tool
                        _buildToolButton(
                          icon: LucideIcons.palette,
                          label: 'Color',
                          onTap: _showColorPicker,
                        ),
                        // Card size ratio tool
                        _buildToolButton(
                          icon: provider.cardRatio == 'square'
                              ? LucideIcons.minimize2
                              : LucideIcons.maximize2,
                          label: provider.cardRatio == 'square' ? 'Standard' : 'Square',
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            provider.setCardRatio(
                              provider.cardRatio == 'square' ? 'standard' : 'square',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: const Color(0xFF6A3EEB),
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFieldPanel(MyCardProvider provider) {
    final field = provider.selectedField!;
    final isPhoto = field == 'photo';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isPhoto ? LucideIcons.camera : LucideIcons.type,
                      color: const Color(0xFF6A3EEB),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isPhoto ? 'Edit Photo Layout' : 'Style Field: ${field.toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    provider.selectField(null);
                  },
                  icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textTertiary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isPhoto) ...[
              const Text(
                'Manual Size (Height & Width)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: provider.photoSize.clamp(30.0, 150.0),
                      min: 30.0,
                      max: 150.0,
                      activeColor: const Color(0xFF6A3EEB),
                      inactiveColor: const Color(0xFFEDE8FC),
                      onChanged: (newSize) {
                        provider.setPhotoSize(newSize);
                      },
                    ),
                  ),
                  Text(
                    '${provider.photoSize.round()}px',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Photo Shape',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: PhotoShape.values.map((shape) {
                  final isSelected = provider.photoShape == shape;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      provider.setPhotoShape(shape);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEDE8FC) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF6A3EEB) : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getShapeLabel(shape),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF6A3EEB) : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              const Text(
                'Manual Text Size',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: (provider.textSizes[field] ?? (field == 'name' ? 14.0 : 11.0)).clamp(8.0, 36.0),
                      min: 8.0,
                      max: 36.0,
                      activeColor: const Color(0xFF6A3EEB),
                      inactiveColor: const Color(0xFFEDE8FC),
                      onChanged: (newSize) {
                        provider.updateTextSize(field, newSize);
                      },
                    ),
                  ),
                  Text(
                    '${(provider.textSizes[field] ?? (field == 'name' ? 14.0 : 11.0)).round()}pt',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Font Family',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    'Inter',
                    'Plus Jakarta Sans',
                    'Outfit',
                    'Playfair Display',
                    'Courier Prime',
                    'Pacifico',
                    'Lora'
                  ].map((font) {
                    final currentFont = provider.fieldFonts[field] ?? 'Inter';
                    final isSelected = currentFont == font;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        provider.updateFieldFont(field, font);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEDE8FC) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6A3EEB) : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            font,
                            style: TextStyle(
                              fontFamily: font == 'Plus Jakarta Sans' ? 'PlusJakartaSans' : (font == 'Inter' ? 'Inter' : 'Courier'),
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF6A3EEB) : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Font Style',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStyleButton(provider, field, 'normal', 'Normal'),
                  const SizedBox(width: 8),
                  _buildStyleButton(provider, field, 'bold', 'Bold'),
                  const SizedBox(width: 8),
                  _buildStyleButton(provider, field, 'italic', 'Italic'),
                  const SizedBox(width: 8),
                  _buildStyleButton(provider, field, 'bold_italic', 'Bold Italic'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Text Color',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Colors.black,
                    Colors.white,
                    const Color(0xFF6A3EEB),
                    const Color(0xFFE84040),
                    const Color(0xFF12A664),
                    const Color(0xFFF0B31B),
                    const Color(0xFFFF4500),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF6B6B6B),
                    const Color(0xFFEDE8FC),
                  ].map((color) {
                    final currentHex = provider.fieldColors[field];
                    final bool isSelected = currentHex != null
                        ? currentHex.value == color.value
                        : provider.textColor.value == color.value;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        provider.updateFieldColor(field, color);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6A3EEB)
                                : color == Colors.white
                                    ? Colors.grey[300]!
                                    : Colors.transparent,
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(
                                LucideIcons.check,
                                color: color == Colors.white || color == const Color(0xFFEDE8FC)
                                    ? const Color(0xFF6A3EEB)
                                    : Colors.white,
                                size: 12,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStyleButton(MyCardProvider provider, String field, String styleVal, String label) {
    final currentStyle = provider.fieldStyles[field] ?? 'normal';
    final isSelected = currentStyle == styleVal;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          provider.updateFieldStyle(field, styleVal);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEDE8FC) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF6A3EEB) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF6A3EEB) : AppColors.textSecondary,
                fontStyle: styleVal.contains('italic') ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
