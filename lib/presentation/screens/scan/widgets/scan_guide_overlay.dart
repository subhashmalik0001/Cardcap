import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class ScanGuideOverlay extends StatefulWidget {
  final String tipText;

  const ScanGuideOverlay({
    super.key,
    this.tipText = 'Align your card inside the frame',
  });

  @override
  State<ScanGuideOverlay> createState() => _ScanGuideOverlayState();
}

class _ScanGuideOverlayState extends State<ScanGuideOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent overlay with cutout
        CustomPaint(
          size: Size.infinite,
          painter: _CutoutPainter(),
        ),
        // Positioned instructions text
        Positioned(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).size.height * 0.22,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.5 + (_pulseController.value * 0.5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.tipText,
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Detection starts automatically when aligned',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CutoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    // Define alignment card size
    final double cardWidth = size.width * 0.85;
    final double cardHeight = cardWidth / 1.58; // Standard card aspect ratio (credit card size)
    final double cardLeft = (size.width - cardWidth) / 2;
    final double cardTop = (size.height - cardHeight) / 2 - 40; // Shifted up slightly for center of action

    final cardRect = Rect.fromLTWH(cardLeft, cardTop, cardWidth, cardHeight);
    final cardRRect = RRect.fromRectAndRadius(cardRect, const Radius.circular(16));

    // Combine paths to create a cutout
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(cardRRect);

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(overlayPath, backgroundPaint);

    // Draw viewport guide border (dashed or subtle outline)
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(cardRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
