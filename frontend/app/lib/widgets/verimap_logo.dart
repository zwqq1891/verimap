import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class VeriMapLogo extends StatelessWidget {
  final double size;
  final bool hasGlow;

  const VeriMapLogo({
    Key? key,
    this.size = 100,
    this.hasGlow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: hasGlow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A73E8).withOpacity(0.35),
                  blurRadius: size * 0.25,
                  spreadRadius: 2,
                )
              ],
            )
          : null,
      child: CustomPaint(
        size: Size(size, size),
        painter: _LogoPainter(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1A73E8), Color(0xFF1557B0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Draw Map Pin Path matching the SVG exactly
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, h * 0.15);
    path.cubicTo(w * 0.334, h * 0.15, w * 0.2, h * 0.284, w * 0.2, h * 0.45);
    path.cubicTo(w * 0.2, h * 0.675, w * 0.5, h * 0.85, w * 0.5, h * 0.85);
    path.cubicTo(w * 0.5, h * 0.85, w * 0.8, h * 0.675, w * 0.8, h * 0.45);
    path.cubicTo(w * 0.8, h * 0.284, w * 0.666, h * 0.15, w * 0.5, h * 0.15);
    path.close();

    canvas.drawPath(path, paint);

    // Draw White circle in center
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), w * 0.12, circlePaint);

    // Draw Blue checkmark
    final checkPaint = Paint()
      ..color = const Color(0xFF1A73E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    
    final checkPath = Path()
      ..moveTo(w * 0.46, h * 0.45)
      ..lineTo(w * 0.49, h * 0.48)
      ..lineTo(w * 0.55, h * 0.42);
    
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
