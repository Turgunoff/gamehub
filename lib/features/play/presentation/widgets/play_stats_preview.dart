import 'package:flutter/material.dart';

/// Play ekranidagi stats preview widget'i
/// Foydalanuvchi statistikalarini ko'rsatadi
class PlayStatsPreview extends StatelessWidget {
  const PlayStatsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xFF00D9FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'YOUR STATS',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              PlayStatItem(label: 'Rating', value: '2,847', color: Color(0xFF6C5CE7)),
              PlayStatItem(label: 'Win Rate', value: '63%', color: Color(0xFF00FB94)),
              PlayStatItem(label: 'Streak', value: '5W', color: Color(0xFFFFB800)),
              PlayStatItem(label: 'Matches', value: '512', color: Color(0xFF00D9FF)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat item widget'i
class PlayStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const PlayStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
        ),
      ],
    );
  }
}

