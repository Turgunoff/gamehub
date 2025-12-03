// lib/features/matches/presentation/widgets/active_match_card.dart
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class ActiveMatchCard extends StatelessWidget {
  final ActiveMatch match;
  final VoidCallback onSubmitResult;

  const ActiveMatchCard({
    super.key,
    required this.match,
    required this.onSubmitResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1F3A),
            Color(0xFF252B4A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _getTimeAgo(match.acceptedAt ?? match.createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Match info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Opponent avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: match.opponent.avatarUrl != null &&
                          match.opponent.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            match.opponent.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
                const SizedBox(width: 16),

                // Opponent info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.opponent.nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.sports_esports,
                            size: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getModeName(match.mode),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          if (match.opponent.level != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lvl ${match.opponent.level}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // VS badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF6B6B).withOpacity(0.5),
                    ),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bet amount (if any)
          if (match.betAmount != null && match.betAmount! > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFB800).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFFFB800),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Stavka: ${match.betAmount} coin',
                    style: const TextStyle(
                      color: Color(0xFFFFB800),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Submit result button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSubmitResult,
                icon: const Icon(Icons.scoreboard, size: 20),
                label: const Text(
                  'Natija yuborish',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF6C5CE7).withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        match.opponent.nickname.isNotEmpty
            ? match.opponent.nickname[0].toUpperCase()
            : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (match.status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF00D26A);
      case 'playing':
        return const Color(0xFFFFB800);
      case 'result_submitted':
        return const Color(0xFF6C5CE7);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (match.status.toLowerCase()) {
      case 'accepted':
        return 'O\'yin boshlang';
      case 'playing':
        return 'O\'yin davom etmoqda';
      case 'result_submitted':
        return 'Opponent javobini kutmoqda';
      default:
        return match.status;
    }
  }

  String _getModeName(String mode) {
    switch (mode.toLowerCase()) {
      case 'friendly':
        return "Do'stona o'yin";
      case 'ranked':
        return 'Reytingli';
      case 'bet':
        return 'Stavkali';
      default:
        return mode;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Hozirgina';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} daqiqa oldin';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} soat oldin';
    } else {
      return '${difference.inDays} kun oldin';
    }
  }
}
