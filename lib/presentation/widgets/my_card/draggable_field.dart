import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class DraggableField extends StatefulWidget {
  final String fieldKey;      // 'name', 'title', 'company', 'phone', 'email', 'website', 'address'
  final String value;
  final Offset position;
  final Function(Offset) onDragEnd;
  final Color textColor;
  final bool showIcon;
  final GlobalKey canvasKey;
  final double cardWidth;
  final double cardHeight;
  final bool isDesignerMode;
  final double fontSize;
  final Function(double)? onResizeEnd;
  final bool isSelected;
  final VoidCallback onTap;
  final String? fontFamily;
  final String? fontStyle;

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
    this.isDesignerMode = false,
    required this.fontSize,
    this.onResizeEnd,
    required this.isSelected,
    required this.onTap,
    this.fontFamily,
    this.fontStyle,
  });

  @override
  State<DraggableField> createState() => _DraggableFieldState();
}

class _DraggableFieldState extends State<DraggableField> {
  late double _localFontSize;

  @override
  void initState() {
    super.initState();
    _localFontSize = widget.fontSize;
  }

  @override
  void didUpdateWidget(covariant DraggableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fontSize != widget.fontSize) {
      _localFontSize = widget.fontSize;
    }
  }

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
      left: widget.position.dx,
      top: widget.position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Draggable<String>(
          data: widget.fieldKey,
          feedback: Material(
            color: Colors.transparent,
            child: _buildFieldWidget(isDragging: true),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildFieldWidget(),
          ),
          onDragEnd: (dragDetails) {
            final renderBox = widget.canvasKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final Offset localOffset = renderBox.globalToLocal(dragDetails.offset);
              // Clamp top-left within card limits
              final double clampedX = localOffset.dx.clamp(0.0, widget.cardWidth - 60.0);
              final double clampedY = localOffset.dy.clamp(0.0, widget.cardHeight - 16.0);
              widget.onDragEnd(Offset(clampedX, clampedY));
            }
          },
          child: _buildFieldWidget(),
        ),
      ),
    );
  }

  Widget _buildFieldWidget({bool isDragging = false}) {
    final bool showEditBorder = widget.isDesignerMode && widget.isSelected && !isDragging;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: isDragging
              ? BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF6A3EEB), width: 1.5),
                )
              : showEditBorder
                  ? BoxDecoration(
                      color: const Color(0xFF6A3EEB).withValues(alpha: 0.05),
                      border: Border.all(color: const Color(0xFF6A3EEB), width: 1.5),
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showIcon) ...[
                Icon(_getIconForField(widget.fieldKey), size: _localFontSize * 0.85, color: widget.textColor),
                const SizedBox(width: 4),
              ],
              Text(
                widget.value,
                style: () {
                  FontWeight fontWeight = widget.fieldKey == 'name' ? FontWeight.bold : FontWeight.w500;
                  FontStyle fontStyleVal = FontStyle.normal;

                  if (widget.fontStyle != null) {
                    switch (widget.fontStyle) {
                      case 'bold':
                        fontWeight = FontWeight.bold;
                        fontStyleVal = FontStyle.normal;
                        break;
                      case 'italic':
                        fontWeight = FontWeight.normal;
                        fontStyleVal = FontStyle.italic;
                        break;
                      case 'bold_italic':
                        fontWeight = FontWeight.bold;
                        fontStyleVal = FontStyle.italic;
                        break;
                      case 'normal':
                        fontWeight = FontWeight.normal;
                        fontStyleVal = FontStyle.normal;
                        break;
                    }
                  }

                  if (widget.fontFamily != null && widget.fontFamily!.isNotEmpty) {
                    try {
                      return GoogleFonts.getFont(
                        widget.fontFamily!,
                        color: widget.textColor,
                        fontSize: _localFontSize,
                        fontWeight: fontWeight,
                        fontStyle: fontStyleVal,
                        decoration: TextDecoration.none,
                      );
                    } catch (e) {
                      // Fallback below
                    }
                  }
                  return TextStyle(
                    color: widget.textColor,
                    fontSize: _localFontSize,
                    fontWeight: fontWeight,
                    fontStyle: fontStyleVal,
                    fontFamily: 'Inter',
                    decoration: TextDecoration.none,
                  );
                }(),
              ),
            ],
          ),
        ),
        if (showEditBorder && widget.onResizeEnd != null)
          Positioned(
            right: -8,
            bottom: -8,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                setState(() {
                  _localFontSize = (_localFontSize + details.delta.dx * 0.25).clamp(8.0, 36.0);
                });
              },
              onPanEnd: (_) {
                widget.onResizeEnd!(_localFontSize);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF6A3EEB),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.open_in_full,
                  size: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
