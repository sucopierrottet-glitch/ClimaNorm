import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// CustomPainter rendering an industrial radial HVAC BTU/h & Tonnage Gauge
/// with segmented thermal load zones, calibration ticks, and glowing needle.
class BtuGaugePainter extends CustomPainter {
  final double totalBtuPerHour;
  final double recommendedTons;
  final double utilizationPercent;

  const BtuGaugePainter({
    required this.totalBtuPerHour,
    required this.recommendedTons,
    required this.utilizationPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.66);
    final radius = math.min(size.width * 0.42, size.height * 0.56);

    const startAngle = math.pi * 0.80;
    const totalSweep = math.pi * 1.40;

    // 1. Background Track Arc
    final bgTrackPaint = Paint()
      ..color = AppColors.surfaceElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(arcRect, startAngle, totalSweep, false, bgTrackPaint);

    // 2. Segmented Zones (Ice Blue 0-65%, Compliant Green 65-92%, Caution Amber 92-105%, Critical Red >105%)
    void drawZone(double startRatio, double endRatio, Color color) {
      final paint = Paint()
        ..color = color.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        arcRect,
        startAngle + totalSweep * startRatio,
        totalSweep * (endRatio - startRatio),
        false,
        paint,
      );
    }

    drawZone(0.0, 0.55, AppColors.iceBlue);
    drawZone(0.55, 0.85, AppColors.compliant);
    drawZone(0.85, 0.95, AppColors.caution);
    drawZone(0.95, 1.00, AppColors.critical);

    // 3. Active Value Arc (Normalized to 60,000 BTU/h = 5.0 Tons max scale)
    final normalizedRatio = (totalBtuPerHour / 60000.0).clamp(0.02, 1.0);
    final Color activeColor;
    if (utilizationPercent <= 92.0) {
      activeColor = AppColors.iceBlue;
    } else if (utilizationPercent <= 102.0) {
      activeColor = AppColors.compliant;
    } else {
      activeColor = AppColors.caution;
    }

    final activeArcPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      startAngle,
      totalSweep * normalizedRatio,
      false,
      activeArcPaint,
    );

    // 4. Calibration Tick Marks around inner perimeter
    final tickPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.55)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const tickCount = 10;
    for (int i = 0; i <= tickCount; i++) {
      final tRatio = i / tickCount;
      final angle = startAngle + totalSweep * tRatio;
      final innerR = radius - 14;
      final outerR = radius - (i.isEven ? 24 : 19);
      final p1 = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 5. Needle Pointer
    final needleAngle = startAngle + totalSweep * normalizedRatio;
    final needleLength = radius - 26;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleTip, needlePaint);

    // Center hub cap
    canvas.drawCircle(
      center,
      9,
      Paint()..color = activeColor,
    );
    canvas.drawCircle(
      center,
      4,
      Paint()..color = AppColors.bgDark,
    );
  }

  @override
  bool shouldRepaint(covariant BtuGaugePainter oldDelegate) {
    return oldDelegate.totalBtuPerHour != totalBtuPerHour ||
        oldDelegate.recommendedTons != recommendedTons ||
        oldDelegate.utilizationPercent != utilizationPercent;
  }
}
