import 'package:flutter/material.dart';

class FireTemplate extends StatelessWidget {
  const FireTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const CustomPaint(
        painter: OrangeFirePainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class OrangeFirePainter extends CustomPainter {
  const OrangeFirePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Gradient for the geometric shapes
    final gradient = LinearGradient(
      colors: [
        const Color(0xFFFF4500).withValues(alpha: 0.95), // OrangeRed
        const Color(0xFFFF8C00).withValues(alpha: 0.95), // DarkOrange
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
    final rect = Rect.fromLTWH(w * 0.5, 0, w * 0.5, h);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Draw primary angular background polygon on the right
    final path1 = Path();
    path1.moveTo(w * 0.55, 0);
    path1.lineTo(w, 0);
    path1.lineTo(w, h);
    path1.lineTo(w * 0.65, h);
    path1.lineTo(w * 0.5, h * 0.5);
    path1.close();
    canvas.drawPath(path1, paint);

    // Draw secondary darker accent triangle/polygon for depth
    final path2 = Path();
    final darkPaint = Paint()
      ..color = const Color(0xFFE03000).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    path2.moveTo(w * 0.55, 0);
    path2.lineTo(w * 0.70, 0);
    path2.lineTo(w * 0.5, h * 0.5);
    path2.close();
    canvas.drawPath(path2, darkPaint);

    // Draw tiny light geometric orange triangle at the bottom right corner
    final path3 = Path();
    final lightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    path3.moveTo(w * 0.85, h);
    path3.lineTo(w, h * 0.70);
    path3.lineTo(w, h);
    path3.close();
    canvas.drawPath(path3, lightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
