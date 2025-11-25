import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamehub/core/widgets/section_header.dart';

class RecentMatchesSection extends StatelessWidget {
  final VoidCallback? onViewAllTap;

  const RecentMatchesSection({super.key, this.onViewAllTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'RECENT MATCHES',
          actionText: 'View All',
          onActionTap: onViewAllTap,
        ),
        const SizedBox(height: 16),
        const MatchCard(
          opponent: 'xPro_Gamer',
          opponentRating: '4,150',
          score: '3 - 1',
          result: 'WIN',
          points: '+28',
          time: '15 min ago',
          isWin: true,
        ),
        const SizedBox(height: 12),
        const MatchCard(
          opponent: 'FutbolKing',
          opponentRating: '4,420',
          score: '2 - 2',
          result: 'DRAW',
          points: '+5',
          time: '1 hour ago',
          isWin: null,
        ),
        const SizedBox(height: 12),
        const MatchCard(
          opponent: 'ElitePlayer99',
          opponentRating: '4,580',
          score: '1 - 2',
          result: 'LOSS',
          points: '-18',
          time: '3 hours ago',
          isWin: false,
        ),
      ],
    );
  }
}

class MatchCard extends StatelessWidget {
  final String opponent;
  final String opponentRating;
  final String score;
  final String result;
  final String points;
  final String time;
  final bool? isWin;

  const MatchCard({
    super.key,
    required this.opponent,
    required this.opponentRating,
    required this.score,
    required this.result,
    required this.points,
    required this.time,
    required this.isWin,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = isWin == null
        ? Colors.orange
        : (isWin == true ? const Color(0xFF00FB94) : const Color(0xFFFF6B6B));

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: resultColor.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Opponent Info
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opponent,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Strength: $opponentRating',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Match Result
            Column(
              children: [
                Text(
                  score,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: resultColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result,
                    style: TextStyle(
                      color: resultColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Points & Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  points,
                  style: TextStyle(
                    color: resultColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
