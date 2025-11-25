import 'package:flutter/material.dart';

class FootballFieldPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw field lines
    const lineSpacing = 100.0;
    for (double y = 0; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw center circle
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 80, paint);

    // Draw penalty areas
    final topPenaltyArea = Rect.fromCenter(
      center: Offset(size.width / 2, 100),
      width: 200,
      height: 100,
    );
    canvas.drawRect(topPenaltyArea, paint);

    final bottomPenaltyArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height - 100),
      width: 200,
      height: 100,
    );
    canvas.drawRect(bottomPenaltyArea, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

