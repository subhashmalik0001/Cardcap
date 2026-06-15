import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:card_capture/presentation/providers/my_card_provider.dart';
import 'hexagon_clipper.dart';

class DraggablePhoto extends StatelessWidget {
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
  final Function(double)? onResize;

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
    this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable<String>(
        data: 'photo',
        feedback: Material(
          color: Colors.transparent,
          child: _buildPhotoWidget(size: size * 1.1),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildPhotoWidget(size: size),
        ),
        onDragEnd: (dragDetails) {
          final renderBox = canvasKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final Offset localOffset = renderBox.globalToLocal(dragDetails.offset);
            final double clampedX = localOffset.dx.clamp(0.0, cardWidth - size);
            final double clampedY = localOffset.dy.clamp(0.0, cardHeight - size);
            onDragEnd(Offset(clampedX, clampedY));
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: isDesignerMode
                    ? BoxDecoration(
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 0.5),
                      )
                    : null,
                child: _buildPhotoWidget(size: size),
              ),
            ),
            if (isDesignerMode && onResize != null)
              Positioned(
                right: -8,
                bottom: -8,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    final newSize = (size + details.delta.dx).clamp(30.0, 150.0);
                    onResize!(newSize);
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
    if (photo != null) {
      imageWidget = Image.file(
        photo!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      imageWidget = Image.network(
        photoUrl!,
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
    switch (shape) {
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
