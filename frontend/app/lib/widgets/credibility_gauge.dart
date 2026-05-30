import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CredibilityGauge extends StatelessWidget {
  final double score; // 0 to 100
  final double size;

  const CredibilityGauge({
    Key? key,
    required this.score,
    this.size = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayScore = score.clamp(0.0, 100.0);

    return SizedBox(
      width: size,
      height: size * 0.75, // Since it's a semi-circle, we don't need full height
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(score: displayScore),
          ),
          Positioned(
            bottom: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${displayScore.toInt()}%',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: displayScore < 40 ? AppTheme.tertiaryColor : AppTheme.primaryColor,
                  ),
                ),
                Text(
                  'VeriScore 可信度',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;

  _GaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.8);
    final radius = size.width * 0.45;
    const strokeWidth = 16.0;

    // Define the angles in radians (180 degrees from Left to Right)
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // 1. Draw Background Track (Gray)
    final trackPaint = Paint()
      ..color = AppTheme.surfaceContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // 2. Draw Colored Progress Arc with Gradient
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressSweepAngle = sweepAngle * (score / 100.0);

    if (progressSweepAngle > 0) {
      final gradient = SweepGradient(
        colors: const [
          AppTheme.tertiaryColor,       // 0% Crimson
          Color(0xFFFFA726),            // 50% Orange
          AppTheme.primaryContainerColor, // 100% Google Blue
        ],
        stops: const [0.0, 0.5, 1.0],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        startAngle,
        progressSweepAngle,
        false,
        progressPaint,
      );
    }


  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
