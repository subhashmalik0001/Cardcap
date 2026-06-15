import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:card_capture/presentation/providers/my_card_provider.dart';
import 'hexagon_clipper.dart';

class DraggablePhoto extends StatefulWidget {
  final File? photo;
  final String? photoUrl;
  final PhotoShape shape;
  final double size; // default 60.0
  final Offset position;
  final Function(Offset) onDragEnd;
  final VoidCallback onTap;
  final GlobalKey canvasKey;
  final double cardWidth;
  final double cardHeight;
  final bool isDesignerMode;
  final Function(double)? onResizeEnd;
  final bool isSelected;

  const DraggablePhoto({
    super.key,
    this.photo,
    this.photoUrl,
    required this.shape,
    required this.size,
    required this.position,
    required this.onDragEnd,
    required this.onTap,
    required this.canvasKey,
    required this.cardWidth,
    required this.cardHeight,
    this.isDesignerMode = false,
    this.onResizeEnd,
    required this.isSelected,
  });

  @override
  State<DraggablePhoto> createState() => _DraggablePhotoState();
}

class _DraggablePhotoState extends State<DraggablePhoto> {
  late double _localSize;

  @override
  void initState() {
    super.initState();
    _localSize = widget.size;
  }

  @override
  void didUpdateWidget(covariant DraggablePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      _localSize = widget.size;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: Draggable<String>(
        data: 'photo',
        feedback: Material(
          color: Colors.transparent,
          child: _buildPhotoWidget(size: _localSize * 1.1),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildPhotoWidget(size: _localSize),
        ),
        onDragEnd: (dragDetails) {
          final renderBox = widget.canvasKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final Offset localOffset = renderBox.globalToLocal(dragDetails.offset);
            final double clampedX = localOffset.dx.clamp(0.0, widget.cardWidth - _localSize);
            final double clampedY = localOffset.dy.clamp(0.0, widget.cardHeight - _localSize);
            widget.onDragEnd(Offset(clampedX, clampedY));
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: widget.isDesignerMode && widget.isSelected
                    ? BoxDecoration(
                        border: Border.all(color: const Color(0xFF6A3EEB), width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                padding: widget.isDesignerMode && widget.isSelected
                    ? const EdgeInsets.all(2)
                    : null,
                child: _buildPhotoWidget(size: _localSize),
              ),
            ),
            if (widget.isDesignerMode && widget.isSelected && widget.onResizeEnd != null)
              Positioned(
                right: -8,
                bottom: -8,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      _localSize = (_localSize + details.delta.dx).clamp(30.0, 150.0);
                    });
                  },
                  onPanEnd: (_) {
                    widget.onResizeEnd!(_localSize);
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
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoWidget({required double size}) {
    Widget imageWidget;
    if (widget.photo != null) {
      imageWidget = Image.file(
        widget.photo!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      imageWidget = Image.network(
        widget.photoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: const Color(0xFFEDE8FC),
          child: Icon(LucideIcons.user, color: const Color(0xFF6A3EEB), size: size * 0.5),
        ),
      );
    } else {
      imageWidget = Container(
        width: size,
        height: size,
        color: const Color(0xFFEDE8FC),
        child: Icon(LucideIcons.user, color: const Color(0xFF6A3EEB), size: size * 0.5),
      );
    }

    return _applyShape(imageWidget, size);
  }

  Widget _applyShape(Widget child, double size) {
    switch (widget.shape) {
      case PhotoShape.circle:
        return ClipOval(
          child: SizedBox(width: size, height: size, child: child),
        );
      case PhotoShape.roundedSquare:
        return ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.2),
          child: SizedBox(width: size, height: size, child: child),
        );
      case PhotoShape.square:
        return SizedBox(width: size, height: size, child: child);
      case PhotoShape.hexagon:
        return ClipPath(
          clipper: HexagonClipper(),
          child: SizedBox(width: size, height: size, child: child),
        );
      case PhotoShape.diamond:
        return ClipPath(
          clipper: DiamondClipper(),
          child: SizedBox(width: size, height: size, child: child),
        );
    }
  }
}

class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
