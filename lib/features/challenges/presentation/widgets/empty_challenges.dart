// lib/features/challenges/presentation/widgets/empty_challenges.dart
import 'package:flutter/material.dart';

class EmptyChallenges extends StatelessWidget {
  const EmptyChallenges({super.key});

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
                    const Color(0xFF6C5CE7).withOpacity(0.2),
                    const Color(0xFFA29BFE).withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.sports_esports_outlined,
                size: 56,
                color: const Color(0xFF6C5CE7).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              "Hozircha challenge yo'q",
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
              "Sizga hali hech kim challenge yubormagan.\nO'zingiz do'stlaringizni o'yinga chaqiring!",
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
                    Icons.lightbulb_outline,
                    color: const Color(0xFFFFB800).withOpacity(0.8),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "O'yinchi profilidan challenge yuboring",
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
