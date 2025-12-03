// lib/features/leaderboard/presentation/widgets/leaderboard_item_card.dart
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class LeaderboardItemCard extends StatelessWidget {
  final LeaderboardItem player;

  const LeaderboardItemCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF1A1F3A),
            const Color(0xFF252B4A).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C5CE7).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _getRankColor().withOpacity(0.5),
              ),
            ),
            child: Center(
              child: Text(
                '${player.rank}',
                style: TextStyle(
                  color: _getRankColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: player.avatarUrl != null && player.avatarUrl!.isNotEmpty
                  ? Image.network(
                      player.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),

          const SizedBox(width: 12),

          // Player info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lvl ${player.level}',
                        style: TextStyle(
                          color: Colors.amber.withOpacity(0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.sports_esports,
                      size: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player.totalMatches} o\'yin',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.emoji_events,
                      size: 12,
                      color: Colors.amber.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${player.wins} g\'alaba',
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

          // Win rate
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getWinRateColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getWinRateColor().withOpacity(0.5),
              ),
            ),
            child: Text(
              '${player.winRate.toStringAsFixed(1)}%',
              style: TextStyle(
                color: _getWinRateColor(),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF6C5CE7),
      child: Center(
        child: Text(
          player.nickname.isNotEmpty ? player.nickname[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getRankColor() {
    if (player.rank <= 3) {
      return const Color(0xFFFFD700);
    } else if (player.rank <= 10) {
      return const Color(0xFF6C5CE7);
    } else if (player.rank <= 25) {
      return const Color(0xFF00D26A);
    } else {
      return Colors.grey;
    }
  }

  Color _getWinRateColor() {
    if (player.winRate >= 70) {
      return const Color(0xFF00D26A);
    } else if (player.winRate >= 50) {
      return const Color(0xFFFFB800);
    } else {
      return const Color(0xFFFF6B6B);
    }
  }
}
