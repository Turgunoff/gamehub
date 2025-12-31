import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// CyberPitch SVG background widget
/// Barcha screenlarda ishlatish uchun
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
          child: Opacity(
            opacity: opacity ?? 1.0,
            child: SvgPicture.asset(
              'assets/images/cyberpitch_background.svg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        ),
        // Content
        if (child != null) child!,
      ],
    );
  }
}
