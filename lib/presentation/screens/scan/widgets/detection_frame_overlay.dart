import 'dart:math';
import 'package:flutter/material.dart';

class DetectionFrameOverlay extends StatefulWidget {
  final Rect? normalizedRect; // 0.0–1.0 normalized coordinates of detected card
  final double stabilityProgress; // 0.0 to 1.0 (1.5 seconds countdown)

  const DetectionFrameOverlay({
    super.key,
    required this.normalizedRect,
    required this.stabilityProgress,
  });

  @override
  State<DetectionFrameOverlay> createState() => _DetectionFrameOverlayState();
}

class _DetectionFrameOverlayState extends State<DetectionFrameOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sweepController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _CardFramePainter(
            normalizedRect: widget.normalizedRect,
            stabilityProgress: widget.stabilityProgress,
            sweepValue: _sweepController.value,
          ),
        );
      },
    );
  }
}

class _CardFramePainter extends CustomPainter {
  final Rect? normalizedRect;
  final double stabilityProgress;
  final double sweepValue;

  _CardFramePainter({
    required this.normalizedRect,
    required this.stabilityProgress,
    required this.sweepValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (normalizedRect == null) return;

    // Convert normalized rect to actual pixel coordinates
    final rect = Rect.fromLTRB(
      normalizedRect!.left * size.width,
      normalizedRect!.top * size.height,
      normalizedRect!.right * size.width,
      normalizedRect!.bottom * size.height,
    );

    final paint = Paint()
      ..color = const Color(0xFF10B981) // premium vibrant green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final double bracketLength = min(rect.width, rect.height) * 0.15;
    final double radius = 12.0;

    // Draw the 4 corner brackets
    // Top-Left Corner
    Path topLeftPath = Path()
      ..moveTo(rect.left, rect.top + bracketLength)
      ..lineTo(rect.left, rect.top + radius)
      ..arcToPoint(
        Offset(rect.left + radius, rect.top),
        radius: Radius.circular(radius),
      )
      ..lineTo(rect.left + bracketLength, rect.top);
    canvas.drawPath(topLeftPath, paint);

    // Top-Right Corner
    Path topRightPath = Path()
      ..moveTo(rect.right - bracketLength, rect.top)
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(rect.right, rect.top + bracketLength);
    canvas.drawPath(topRightPath, paint);

    // Bottom-Left Corner
    Path bottomLeftPath = Path()
      ..moveTo(rect.left, rect.bottom - bracketLength)
      ..lineTo(rect.left, rect.bottom - radius)
      ..arcToPoint(
        Offset(rect.left + radius, rect.bottom),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(rect.left + bracketLength, rect.bottom);
    canvas.drawPath(bottomLeftPath, paint);

    // Bottom-Right Corner
    Path bottomRightPath = Path()
      ..moveTo(rect.right - bracketLength, rect.bottom)
      ..lineTo(rect.right - radius, rect.bottom)
      ..arcToPoint(
        Offset(rect.right, rect.bottom - radius),
        radius: Radius.circular(radius),
        clockwise: true,
      )
      ..lineTo(rect.right, rect.bottom - bracketLength);
    canvas.drawPath(bottomRightPath, paint);

    // Fill overlay background with extremely subtle green tint
    final fillPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.04)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      fillPaint,
    );

    // Draw sweeping laser line inside detected card area
    final double sweepY = rect.top + (rect.height * sweepValue);
    final laserPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF10B981).withOpacity(0.0),
          const Color(0xFF10B981).withOpacity(0.5),
          const Color(0xFF10B981).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(rect.left, sweepY - 10, rect.right, sweepY + 10));

    final laserLinePaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.8)
      ..strokeWidth = 2.0;

    canvas.drawRect(
      Rect.fromLTRB(rect.left + 4, sweepY - 8, rect.right - 4, sweepY + 8),
      laserPaint,
    );
    canvas.drawLine(
      Offset(rect.left + 8, sweepY),
      Offset(rect.right - 8, sweepY),
      laserLinePaint,
    );

    // If stabilizing, draw a circular countdown in the center of the card
    if (stabilityProgress > 0.0) {
      final center = rect.center;
      final double ringRadius = 24.0;

      // Draw background gray circle
      final bgCirclePaint = Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, ringRadius + 8, bgCirclePaint);

      // Draw progress arc
      final arcPaint = Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        -pi / 2,
        2 * pi * stabilityProgress,
        false,
        arcPaint,
      );

      // Draw percentage or checkmark inside
      if (stabilityProgress >= 1.0) {
        // Draw green checkmark
        final checkPaint = Paint()
          ..color = const Color(0xFF10B981)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;

        final path = Path()
          ..moveTo(center.dx - 6, center.dy)
          ..lineTo(center.dx - 2, center.dy + 4)
          ..lineTo(center.dx + 6, center.dy - 4);
        canvas.drawPath(path, checkPaint);
      } else {
        // Draw small pulse animation inside
        final pulsePaint = Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 4 + (4 * stabilityProgress), pulsePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CardFramePainter oldDelegate) {
    return oldDelegate.normalizedRect != normalizedRect ||
        oldDelegate.stabilityProgress != stabilityProgress ||
        oldDelegate.sweepValue != sweepValue;
  }
}
