import 'package:flutter/material.dart';

/// Profile ekranidagi performance chart widget'i
/// Performance grafikini ko'rsatadi
class ProfilePerformanceChart extends StatelessWidget {
  const ProfilePerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1F3A).withOpacity(0.8),
              const Color(0xFF0A0E1A).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERFORMANCE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: CustomPaint(
                painter: ProfilePerformanceChartPainter(),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Performance chart painter widget'i
class ProfilePerformanceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Mock data points
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width, size.height * 0.35),
    ];

    // Draw filled area
    final path = Path();
    path.moveTo(points[0].dx, size.height);
    for (var point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

