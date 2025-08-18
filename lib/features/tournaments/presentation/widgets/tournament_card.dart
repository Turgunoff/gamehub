import 'package:flutter/material.dart';
import '../../domain/entities/tournament.dart';
import '../../../../core/theme/app_colors.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onJoinPressed;
  final VoidCallback? onViewDetailsPressed;

  const TournamentCard({
    super.key,
    required this.tournament,
    this.onJoinPressed,
    this.onViewDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool canJoin =
        tournament.currentParticipants < tournament.maxParticipants;
    final bool isLive = tournament.isLive;

    return GestureDetector(
      onTap: onViewDetailsPressed,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.bgCardLight.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            tournament.game,
                            style: const TextStyle(
                              color: Color(0xFF8892B0),
                              fontSize: 14,
                            ),
                          ),
                          if (isLive) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (tournament.isPremium) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.emoji_events,
                              color: AppColors.warning,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.bgCardLight,
                  ),
                  child: Icon(
                    _getGameIcon(tournament.game),
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                  Icons.access_time,
                  tournament.time,
                  const Color(0xFF8892B0),
                ),
                const SizedBox(width: 24),
                _buildInfoItem(
                  Icons.people,
                  '${tournament.currentParticipants}/${tournament.maxParticipants}',
                  const Color(0xFF8892B0),
                ),
                const SizedBox(width: 24),
                _buildInfoItem(
                  Icons.account_balance_wallet,
                  '\$${tournament.entryFee.toStringAsFixed(0)}',
                  const Color(0xFF8892B0),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Color(0xFF8892B0),
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Prize Pool',
                  style: TextStyle(color: Color(0xFF8892B0), fontSize: 14),
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF6B46C1), // Deep purple-blue
                      Color(0xFF06B6D4), // Vibrant cyan-blue
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Text(
                    '\$${tournament.prizePool.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6B46C1), // Deep purple-blue
                    Color(0xFF06B6D4), // Vibrant cyan-blue
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: canJoin ? onJoinPressed : onViewDetailsPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  canJoin ? 'Join Tournament' : 'View Details',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8892B0), size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getGameIcon(String game) {
    switch (game.toLowerCase()) {
      case 'cs:go':
        return Icons.sports_esports;
      case 'valorant':
        return Icons.games;
      case 'pubg':
        return Icons.sports_esports;
      case 'league of legends':
        return Icons.games;
      default:
        return Icons.sports_esports;
    }
  }
}
