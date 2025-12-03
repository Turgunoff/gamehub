// lib/features/matches/presentation/widgets/empty_active_matches.dart
import 'package:flutter/material.dart';

class EmptyActiveMatches extends StatelessWidget {
  const EmptyActiveMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with glow effect
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00D26A).withOpacity(0.2),
                    const Color(0xFF00D26A).withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D26A).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 56,
                color: const Color(0xFF00D26A).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              "Hozir faol o'yin yo'q",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              "Barcha o'yinlaringiz yakunlangan.\nYangi o'yin boshlang!",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF6C5CE7).withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_esports,
                    color: const Color(0xFF6C5CE7).withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Play bo'limidan o'yin toping",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
