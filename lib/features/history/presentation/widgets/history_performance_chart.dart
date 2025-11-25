import 'package:flutter/material.dart';

/// History ekranidagi performance chart widget'i
/// Rating trendini ko'rsatadi
class HistoryPerformanceChart extends StatelessWidget {
  const HistoryPerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RATING TREND',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: const [
                  Icon(
                    Icons.trending_up,
                    color: Color(0xFF00FB94),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '+285',
                    style: TextStyle(
                      color: Color(0xFF00FB94),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              painter: HistoryChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chart painter widget'i
class HistoryChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Mock data points (rating over time)
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.45),
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

