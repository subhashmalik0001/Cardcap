import 'dart:io';
import 'package:flutter/material.dart';
import 'package:card_capture/data/models/my_card_details.dart';
import 'package:card_capture/data/models/card_template.dart';
import 'package:card_capture/presentation/providers/my_card_provider.dart';
import 'draggable_field.dart';
import 'draggable_photo.dart';
import 'templates/classic_template.dart';
import 'templates/dark_pro_template.dart';
import 'templates/gradient_template.dart';
import 'templates/cream_template.dart';
import 'templates/split_template.dart';
import 'templates/fire_template.dart';

class CardCanvas extends StatelessWidget {
  final CardTemplate template;
  final Map<String, bool> fields;
  final Map<String, Offset> fieldPositions;
  final File? userPhoto;
  final String? photoUrl;
  final PhotoShape photoShape;
  final MyCardDetails userDetails;
  final Color textColor;
  final String cardRatio; // 'standard' (1.75:1) or 'square' (1:1)
  final Function(String, Offset) onUpdatePosition;
  final VoidCallback onPhotoTap;
  final GlobalKey canvasKey;
  final bool isDesignerMode;
  final bool showIcons;
  final double photoSize;
  final Map<String, double> textSizes;
  final Function(double)? onResizePhoto;
  final Function(String, double)? onResizeField;
  final String? selectedField;
  final Function(String?)? onSelectField;

  const CardCanvas({
    super.key,
    required this.template,
    required this.fields,
    required this.fieldPositions,
    this.userPhoto,
    this.photoUrl,
    required this.photoShape,
    required this.userDetails,
    required this.textColor,
    required this.cardRatio,
    required this.onUpdatePosition,
    required this.onPhotoTap,
    required this.canvasKey,
    this.isDesignerMode = false,
    this.showIcons = true,
    this.photoSize = 56.0,
    this.textSizes = const {},
    this.onResizePhoto,
    this.onResizeField,
    this.selectedField,
    this.onSelectField,
  });

  Offset _getFieldPosition(String key, double cardWidth, double cardHeight) {
    if (fieldPositions.containsKey(key)) {
      return fieldPositions[key]!;
    }
    // Return default coordinate offsets relative to card dimensions
    switch (key) {
      case 'name':
        return Offset(cardWidth * 0.08, cardHeight * 0.12);
      case 'title':
        return Offset(cardWidth * 0.08, cardHeight * 0.30);
      case 'company':
        return Offset(cardWidth * 0.08, cardHeight * 0.46);
      case 'phone':
        return Offset(cardWidth * 0.08, cardHeight * 0.62);
      case 'email':
        return Offset(cardWidth * 0.08, cardHeight * 0.74);
      case 'website':
        return Offset(cardWidth * 0.52, cardHeight * 0.62);
      case 'address':
        return Offset(cardWidth * 0.08, cardHeight * 0.86);
      case 'photo':
        return Offset(cardWidth * 0.72, cardHeight * 0.18);
      default:
        return Offset.zero;
    }
  }

  Widget _buildBackground() {
    if (template.backgroundImageUrl != null && template.backgroundImageUrl!.isNotEmpty) {
      return Image.network(
        template.backgroundImageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: template.backgroundColor,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }

    switch (template.id) {
      case 'classic':
        return const ClassicTemplate();
      case 'dark_pro':
        return const DarkProTemplate();
      case 'gradient':
        return const GradientTemplate();
      case 'cream':
        return const CreamTemplate();
      case 'split':
        return const SplitTemplate();
      case 'fire':
        return const FireTemplate();
      default:
        return Container(color: template.backgroundColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth;
        final double cardHeight = cardRatio == 'square' ? cardWidth : cardWidth / 1.75;

        // Collect available text values
        final Map<String, String> fieldValues = {
          'name': userDetails.name,
          'title': userDetails.title ?? '',
          'company': userDetails.company ?? '',
          'phone': userDetails.phone ?? '',
          'email': userDetails.email ?? '',
          'website': userDetails.website ?? '',
          'address': userDetails.address ?? '',
        };

        return Container(
          key: canvasKey,
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              clipBehavior: Clip.antiAlias,
              children: [
                // 1. Template Background Layer
                Positioned.fill(
                  child: _buildBackground(),
                ),

                // 2. User Photo Layer (if visible)
                if (fields['photo'] == true)
                  DraggablePhoto(
                    photo: userPhoto,
                    photoUrl: photoUrl,
                    shape: photoShape,
                    size: photoSize,
                    position: _getFieldPosition('photo', cardWidth, cardHeight),
                    onDragEnd: (offset) => onUpdatePosition('photo', offset),
                    onTap: () {
                      onPhotoTap();
                      if (isDesignerMode && onSelectField != null) {
                        onSelectField!('photo');
                      }
                    },
                    canvasKey: canvasKey,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    isDesignerMode: isDesignerMode,
                    onResizeEnd: onResizePhoto,
                    isSelected: selectedField == 'photo',
                  ),

                // 3. Text Fields Layers
                ...fieldValues.entries.map((entry) {
                  final String key = entry.key;
                  final String val = entry.value;

                  // Render if toggled visible and holds data
                  if (fields[key] == true && val.isNotEmpty) {
                    // Split template sets left side text to white, right side to dark text
                    Color displayColor = textColor;
                    if (template.id == 'split') {
                      final Offset pos = _getFieldPosition(key, cardWidth, cardHeight);
                      if (pos.dx < cardWidth * 0.5) {
                        displayColor = Colors.white;
                      } else {
                        displayColor = const Color(0xFF1D1D1D);
                      }
                    }

                    final double fieldFontSize = textSizes[key] ?? (key == 'name' ? 14.0 : 11.0);

                    return DraggableField(
                      fieldKey: key,
                      value: val,
                      position: _getFieldPosition(key, cardWidth, cardHeight),
                      onDragEnd: (offset) => onUpdatePosition(key, offset),
                      textColor: displayColor,
                      showIcon: showIcons && key != 'name', // No icon for the person's name
                      canvasKey: canvasKey,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      isDesignerMode: isDesignerMode,
                      fontSize: fieldFontSize,
                      onResizeEnd: onResizeField != null ? (newSize) => onResizeField!(key, newSize) : null,
                      isSelected: selectedField == key,
                      onTap: () {
                        if (isDesignerMode && onSelectField != null) {
                          onSelectField!(key);
                        }
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
