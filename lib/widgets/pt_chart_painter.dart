import 'package:flutter/material.dart';

import '../calculators/hvac_calculator.dart';
import '../theme/app_theme.dart';

/// CustomPainter rendering the Refrigerant Pressure-Temperature (P-T)
/// saturation curve (-20°C to +60°C) with live Evaporator and Condenser points.
class PtChartPainter extends CustomPainter {
  final RefrigerantType refrigerant;
  final double evapSatTempC;
  final double suctionPsig;
  final double condSatTempC;
  final double liquidPsig;
  final Color curveColor;

  const PtChartPainter({
    required this.refrigerant,
    required this.evapSatTempC,
    required this.suctionPsig,
    required this.condSatTempC,
    required this.liquidPsig,
    required this.curveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 36.0;
    const rightPad = 16.0;
    const topPad = 14.0;
    const bottomPad = 24.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    if (chartWidth <= 10 || chartHeight <= 10) return;

    const minTemp = -20.0;
    const maxTemp = 60.0;
    final maxPsig =
        HvacCalculator.saturationPressurePsig(refrigerant, maxTemp) * 1.08;

    Offset mapPoint(double tempC, double psig) {
      final xRatio = ((tempC - minTemp) / (maxTemp - minTemp)).clamp(0.0, 1.0);
      final yRatio = (psig / maxPsig).clamp(0.0, 1.0);
      return Offset(
        leftPad + xRatio * chartWidth,
        topPad + chartHeight * (1.0 - yRatio),
      );
    }

    // 1. Subtle Grid Lines
    final gridPaint = Paint()
      ..color = AppColors.borderSubtle.withValues(alpha: 0.7)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 4; i++) {
      final y = topPad + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );
    }
    for (int i = 0; i <= 4; i++) {
      final x = leftPad + (chartWidth / 4) * i;
      canvas.drawLine(
        Offset(x, topPad),
        Offset(x, topPad + chartHeight),
        gridPaint,
      );
    }

    // 2. Saturation Curve Path
    final path = Path();
    final fillPath = Path();
    const steps = 40;
    for (int i = 0; i <= steps; i++) {
      final t = minTemp + (maxTemp - minTemp) * (i / steps);
      final p = HvacCalculator.saturationPressurePsig(refrigerant, t);
      final pt = mapPoint(t, p);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
        fillPath.moveTo(pt.dx, topPad + chartHeight);
        fillPath.lineTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
        fillPath.lineTo(pt.dx, pt.dy);
      }
      if (i == steps) {
        fillPath.lineTo(pt.dx, topPad + chartHeight);
        fillPath.close();
      }
    }

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            curveColor.withValues(alpha: 0.30),
            curveColor.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(leftPad, topPad, chartWidth, chartHeight)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = curveColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    // 3. Evaporator Operating Point (Ice Blue)
    final evapPt = mapPoint(evapSatTempC, suctionPsig);
    canvas.drawCircle(
      evapPt,
      8,
      Paint()..color = AppColors.iceBlue.withValues(alpha: 0.3),
    );
    canvas.drawCircle(evapPt, 5, Paint()..color = AppColors.iceBlue);

    // 4. Condenser Operating Point (Amber/Orange)
    final condPt = mapPoint(condSatTempC, liquidPsig);
    canvas.drawCircle(
      condPt,
      8,
      Paint()..color = AppColors.caution.withValues(alpha: 0.3),
    );
    canvas.drawCircle(condPt, 5, Paint()..color = AppColors.caution);
  }

  @override
  bool shouldRepaint(covariant PtChartPainter oldDelegate) {
    return oldDelegate.refrigerant != refrigerant ||
        oldDelegate.evapSatTempC != evapSatTempC ||
        oldDelegate.condSatTempC != condSatTempC ||
        oldDelegate.suctionPsig != suctionPsig ||
        oldDelegate.liquidPsig != liquidPsig;
  }
}
