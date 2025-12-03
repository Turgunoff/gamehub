// lib/features/tournaments/presentation/widgets/bracket_match_card.dart
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class BracketMatchCard extends StatelessWidget {
  final BracketMatch match;

  const BracketMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor().withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor().withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Player 1
          _buildPlayerRow(
            nickname: match.player1Nickname,
            score: match.player1Score,
            isWinner: match.winnerId == match.player1Id,
            isEmpty: match.player1Id == null,
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),

          // Player 2
          _buildPlayerRow(
            nickname: match.player2Nickname,
            score: match.player2Score,
            isWinner: match.winnerId == match.player2Id,
            isEmpty: match.player2Id == null,
          ),

          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(11),
              ),
            ),
            child: Center(
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerRow({
    required String? nickname,
    required int? score,
    required bool isWinner,
    required bool isEmpty,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isWinner ? const Color(0xFF00D26A).withOpacity(0.1) : null,
      ),
      child: Row(
        children: [
          // Player name
          Expanded(
            child: Text(
              isEmpty ? 'TBD' : (nickname ?? 'Unknown'),
              style: TextStyle(
                color: isEmpty
                    ? Colors.white.withOpacity(0.3)
                    : isWinner
                        ? const Color(0xFF00D26A)
                        : Colors.white.withOpacity(0.8),
                fontSize: 13,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Score
          if (score != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isWinner
                    ? const Color(0xFF00D26A).withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$score',
                style: TextStyle(
                  color: isWinner ? const Color(0xFF00D26A) : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Winner indicator
          if (isWinner) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFD700),
              size: 14,
            ),
          ],
        ],
      ),
    );
  }

  Color _getBorderColor() {
    switch (match.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF00D26A);
      case 'playing':
        return const Color(0xFFFFB800);
      case 'ready':
        return const Color(0xFF6C5CE7);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor() {
    switch (match.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF00D26A);
      case 'playing':
        return const Color(0xFFFFB800);
      case 'ready':
        return const Color(0xFF6C5CE7);
      case 'waiting':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (match.status.toLowerCase()) {
      case 'completed':
        return 'YAKUNLANGAN';
      case 'playing':
        return 'O\'YNALMOQDA';
      case 'ready':
        return 'TAYYOR';
      case 'waiting':
        return 'KUTILMOQDA';
      default:
        return match.status.toUpperCase();
    }
  }
}
