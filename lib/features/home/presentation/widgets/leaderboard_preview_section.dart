import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cyberpitch/core/widgets/section_header.dart';

class LeaderboardPreviewSection extends StatelessWidget {
  final VoidCallback? onFullLeaderboardTap;

  const LeaderboardPreviewSection({
    super.key,
    this.onFullLeaderboardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'TOP PLAYERS',
          actionText: 'Full Leaderboard',
          onActionTap: onFullLeaderboardTap,
          icon: Icons.leaderboard,
        ),
        const SizedBox(height: 16),
        const LeaderboardItem(
          rank: 1,
          name: 'Legend27',
          rating: '5,420',
          winRate: '92%',
        ),
        const SizedBox(height: 8),
        const LeaderboardItem(
          rank: 2,
          name: 'ProMaster',
          rating: '5,385',
          winRate: '88%',
        ),
        const SizedBox(height: 8),
        const LeaderboardItem(
          rank: 3,
          name: 'ChampionX',
          rating: '5,350',
          winRate: '85%',
        ),
        const SizedBox(height: 8),
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.1),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        const LeaderboardItem(
          rank: 42,
          name: 'You',
          rating: '4,285',
          winRate: '63%',
          isCurrentUser: true,
        ),
      ],
    );
  }
}

class LeaderboardItem extends StatelessWidget {
  final int rank;
  final String name;
  final String rating;
  final String winRate;
  final bool isCurrentUser;

  const LeaderboardItem({
    super.key,
    required this.rank,
    required this.name,
    required this.rating,
    required this.winRate,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : Colors.white54;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isCurrentUser
            ? LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7).withOpacity(0.2),
                  const Color(0xFF00D9FF).withOpacity(0.1),
                ],
              )
            : null,
        color: !isCurrentUser ? Colors.white.withOpacity(0.03) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF6C5CE7).withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: rankColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: isCurrentUser ? const Color(0xFF00D9FF) : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Stats
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rating,
                    style: const TextStyle(
                      color: Color(0xFFFFB800),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rating',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    winRate,
                    style: const TextStyle(
                      color: Color(0xFF00FB94),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Win',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

