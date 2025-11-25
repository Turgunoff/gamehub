import 'package:flutter/material.dart';

/// Tugallangan turnir kartasi widget'i
/// O'tgan turnirlarda olingan o'rin va mukofotni ko'rsatadi
class CompletedTournamentCard extends StatelessWidget {
  final String title;
  final String position;
  final String prize;
  final String date;
  final String participants;

  const CompletedTournamentCard({
    super.key,
    required this.title,
    required this.position,
    required this.prize,
    required this.date,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final positionColor = _getPositionColor(position);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Position badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: positionColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: positionColor,
                  size: 24,
                ),
                Text(
                  position,
                  style: TextStyle(
                    color: positionColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Tournament info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$participants players',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Prize info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFFFB800),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    prize,
                    style: const TextStyle(
                      color: Color(0xFFFFB800),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Won',
                style: TextStyle(
                  color: const Color(0xFF00FB94),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// O'rin bo'yicha rangni aniqlash
  Color _getPositionColor(String position) {
    switch (position) {
      case '1st':
        return const Color(0xFFFFD700); // Gold
      case '2nd':
        return const Color(0xFFC0C0C0); // Silver
      case '3rd':
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white54;
    }
  }
}

