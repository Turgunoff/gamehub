import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/models/profile_model.dart';
import 'profile_header.dart';

/// Profil ekrani uchun SliverAppBar
///
/// Parallax effekt va profil header ni o'z ichiga oladi.
class ProfileAppBar extends StatelessWidget {
  final ProfileModel? profile;
  final double scrollOffset;
  final VoidCallback onSettingsTap;

  const ProfileAppBar({
    super.key,
    this.profile,
    required this.scrollOffset,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Parallax Background
            Transform.translate(
              offset: Offset(0, scrollOffset * 0.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6C5CE7).withValues(alpha: 0.6),
                      const Color(0xFF00D9FF).withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: CustomPaint(painter: _HexagonPatternPainter()),
              ),
            ),

            // Profile Header
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: ProfileHeader(profile: profile),
            ),
          ],
        ),
      ),
      actions: [
        _buildSettingsButton(),
      ],
    );
  }

  Widget _buildSettingsButton() {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: const Icon(Icons.settings, size: 20),
      ),
      onPressed: onSettingsTap,
    );
  }
}

/// Hexagon pattern painter
class _HexagonPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const hexSize = 30.0;
    final rows = (size.height / hexSize).ceil() + 1;
    final cols = (size.width / hexSize).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final centerX = col * hexSize * 1.5;
        final centerY = row * hexSize * math.sqrt(3) +
            (col % 2 == 1 ? hexSize * math.sqrt(3) / 2 : 0);

        _drawHexagon(canvas, Offset(centerX, centerY), hexSize / 2, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
