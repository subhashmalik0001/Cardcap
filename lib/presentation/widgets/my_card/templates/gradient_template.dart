import 'package:flutter/material.dart';

class GradientTemplate extends StatelessWidget {
  const GradientTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6A3EEB),
            Color(0xFF9B6EF5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const CustomPaint(
        painter: HexagonPatternPainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class HexagonPatternPainter extends CustomPainter {
  const HexagonPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double hexSize = 25.0;
    const double h = hexSize * 2.0;
    const double w = hexSize * 1.732;

    for (double y = -h; y < size.height + h; y += h * 0.75) {
      final double xOffset = ((y / (h * 0.75)).round() % 2 == 0) ? 0.0 : w * 0.5;
      for (double x = -w; x < size.width + w; x += w) {
        final path = Path();
        path.moveTo(x + xOffset + w * 0.5, y);
        path.lineTo(x + xOffset + w, y + h * 0.25);
        path.lineTo(x + xOffset + w, y + h * 0.75);
        path.lineTo(x + xOffset + w * 0.5, y + h);
        path.lineTo(x + xOffset, y + h * 0.75);
        path.lineTo(x + xOffset, y + h * 0.25);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
