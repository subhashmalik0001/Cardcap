import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DraggableField extends StatelessWidget {
  final String fieldKey;      // 'name', 'title', 'company', 'phone', 'email', 'website', 'address'
  final String value;
  final Offset position;
  final Function(Offset) onDragEnd;
  final Color textColor;
  final bool showIcon;
  final GlobalKey canvasKey;
  final double cardWidth;
  final double cardHeight;

  const DraggableField({
    super.key,
    required this.fieldKey,
    required this.value,
    required this.position,
    required this.onDragEnd,
    required this.textColor,
    required this.showIcon,
    required this.canvasKey,
    required this.cardWidth,
    required this.cardHeight,
  });

  IconData _getIconForField(String key) {
    switch (key) {
      case 'name':
        return LucideIcons.user;
      case 'title':
        return LucideIcons.briefcase;
      case 'company':
        return LucideIcons.building;
      case 'phone':
        return LucideIcons.phone;
      case 'email':
        return LucideIcons.mail;
      case 'website':
        return LucideIcons.globe;
      case 'address':
        return LucideIcons.mapPin;
      default:
        return LucideIcons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable<String>(
        data: fieldKey,
        feedback: Material(
          color: Colors.transparent,
          child: _buildFieldWidget(isDragging: true),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildFieldWidget(),
        ),
        onDragEnd: (dragDetails) {
          final renderBox = canvasKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final Offset localOffset = renderBox.globalToLocal(dragDetails.offset);
            // Clamp top-left within card limits (leave a small margin so it doesn't clip)
            final double clampedX = localOffset.dx.clamp(0.0, cardWidth - 80.0);
            final double clampedY = localOffset.dy.clamp(0.0, cardHeight - 24.0);
            onDragEnd(Offset(clampedX, clampedY));
          }
        },
        child: _buildFieldWidget(),
      ),
    );
  }

  Widget _buildFieldWidget({bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: isDragging
          ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF6A3EEB), width: 1),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_getIconForField(fieldKey), size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: fieldKey == 'name' ? 14 : 11,
              fontWeight: fieldKey == 'name' ? FontWeight.bold : FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
