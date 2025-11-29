import 'package:flutter/material.dart';

/// Profil ekrani uchun background
///
/// Gradient va mesh pattern bilan chiroyli fon yaratadi.
class ProfileBackground extends StatelessWidget {
  const ProfileBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0E1A),
                Color(0xFF1A1F3A),
                Color(0xFF0A0E1A),
              ],
            ),
          ),
        ),

        // Mesh Pattern
        CustomPaint(
          painter: _MeshPatternPainter(),
          child: Container(),
        ),

        // Gradient Overlays
        _buildGradientOverlay(
          top: 100,
          left: 50,
          size: 200,
          color: const Color(0xFF00D9FF),
        ),
        _buildGradientOverlay(
          top: 300,
          right: 50,
          size: 150,
          color: const Color(0xFF6C5CE7),
        ),
      ],
    );
  }

  Widget _buildGradientOverlay({
    double? top,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.15),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

/// Mesh pattern painter
class _MeshPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    // Gradient circles
    final circles = [
      _CircleConfig(
        offset: Offset(size.width * 0.3, size.height * 0.2),
        radius: 150,
        color: const Color(0xFF6C5CE7),
      ),
      _CircleConfig(
        offset: Offset(size.width * 0.7, size.height * 0.4),
        radius: 120,
        color: const Color(0xFF00D9FF),
      ),
      _CircleConfig(
        offset: Offset(size.width * 0.5, size.height * 0.6),
        radius: 100,
        color: const Color(0xFFFFB800),
      ),
    ];

    for (final circle in circles) {
      paint.shader = RadialGradient(
        colors: [circle.color.withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromCircle(center: circle.offset, radius: circle.radius));
      canvas.drawCircle(circle.offset, circle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleConfig {
  final Offset offset;
  final double radius;
  final Color color;

  _CircleConfig({
    required this.offset,
    required this.radius,
    required this.color,
  });
}
