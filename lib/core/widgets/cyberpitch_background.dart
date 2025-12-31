import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// CyberPitch SVG background widget
/// Barcha screenlarda ishlatish uchun
///
/// Note: flutter_svg paketi <filter/>, <animate/>, va <animateTransform/>
/// elementlarini to'liq qo'llab-quvvatlamaydi, lekin bu xatolar ilova
/// ishlashiga ta'sir qilmaydi va e'tiborsiz qoldiriladi.
class CyberPitchBackground extends StatelessWidget {
  final Widget? child;
  final double? opacity;

  const CyberPitchBackground({super.key, this.child, this.opacity});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // SVG Background
        Positioned.fill(
          child: Opacity(opacity: opacity ?? 1.0, child: _buildSvgPicture()),
        ),
        // Content
        if (child != null) child!,
      ],
    );
  }

  Widget _buildSvgPicture() {
    return SvgPicture.asset(
      'assets/images/cyberpitch_background.svg',
      fit: BoxFit.cover,
      alignment: Alignment.center,
      allowDrawingOutsideViewBox: true,
      // Xatolarni e'tiborsiz qoldirish
      placeholderBuilder: (context) =>
          Container(color: const Color(0xFF0A0E1A)),
      // Error bo'lsa ham background ko'rsatish
      semanticsLabel: 'CyberPitch background',
    );
  }
}
