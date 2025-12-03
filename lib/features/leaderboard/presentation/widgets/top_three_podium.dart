// lib/features/leaderboard/presentation/widgets/top_three_podium.dart
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class TopThreePodium extends StatelessWidget {
  final List<LeaderboardItem> players;

  const TopThreePodium({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    // Ensure we have at least some players
    if (players.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 280,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place (left)
          if (players.length > 1)
            Expanded(
              child: _buildPodiumItem(
                player: players[1],
                rank: 2,
                height: 180,
                color: const Color(0xFFC0C0C0), // Silver
              ),
            )
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: 8),

          // 1st place (center)
          Expanded(
            child: _buildPodiumItem(
              player: players[0],
              rank: 1,
              height: 220,
              color: const Color(0xFFFFD700), // Gold
              isFirst: true,
            ),
          ),

          const SizedBox(width: 8),

          // 3rd place (right)
          if (players.length > 2)
            Expanded(
              child: _buildPodiumItem(
                player: players[2],
                rank: 3,
                height: 150,
                color: const Color(0xFFCD7F32), // Bronze
              ),
            )
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required LeaderboardItem player,
    required int rank,
    required double height,
    required Color color,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Crown for 1st place
        if (isFirst)
          Icon(
            Icons.emoji_events,
            color: color,
            size: 32,
          ),

        const SizedBox(height: 8),

        // Avatar
        Container(
          width: isFirst ? 80 : 64,
          height: isFirst ? 80 : 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: player.avatarUrl != null && player.avatarUrl!.isNotEmpty
                ? Image.network(
                    player.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(player),
                  )
                : _buildDefaultAvatar(player),
          ),
        ),

        const SizedBox(height: 8),

        // Nickname
        Text(
          player.nickname,
          style: TextStyle(
            color: Colors.white,
            fontSize: isFirst ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        // Win rate
        Text(
          '${player.winRate.toStringAsFixed(1)}% WR',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        // Podium
        Container(
          height: height - 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(LeaderboardItem player) {
    return Container(
      color: const Color(0xFF6C5CE7),
      child: Center(
        child: Text(
          player.nickname.isNotEmpty ? player.nickname[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
