import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// History ekranidagi match kartasi widget'i
/// O'tgan o'yinlar haqida ma'lumotni ko'rsatadi
class HistoryMatchCard extends StatelessWidget {
  final String date;
  final String opponent;
  final String score;
  final String result;
  final String points;
  final String mode;
  final int index;

  const HistoryMatchCard({
    super.key,
    required this.date,
    required this.opponent,
    required this.score,
    required this.result,
    required this.points,
    required this.mode,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final resultColor = _getResultColor(result);
    final resultIcon = _getResultIcon(result);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Card Background
          Container(
            margin: const EdgeInsets.only(left: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: resultColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                    _buildModeBadge(mode),
                  ],
                ),
                const SizedBox(height: 12),
                // Match Details
                Row(
                  children: [
                    // Your Team
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'You',
                            style: TextStyle(
                              color: Color(0xFF00D9FF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Team: 4,285',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Score
                    _buildScoreSection(score, result, resultColor),
                    // Opponent
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            opponent,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Team: 4,150',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Points and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPointsSection(points),
                    _buildActionButtons(),
                  ],
                ),
              ],
            ),
          ),
          // Match Number Indicator
          Positioned(
            left: 0,
            top: 35,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: resultColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: resultColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(resultIcon, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Natija bo'yicha rangni aniqlash
  Color _getResultColor(String result) {
    switch (result) {
      case 'WIN':
        return const Color(0xFF00FB94);
      case 'LOSS':
        return const Color(0xFFFF6B6B);
      default:
        return Colors.orange;
    }
  }

  /// Natija bo'yicha ikonkani aniqlash
  IconData _getResultIcon(String result) {
    switch (result) {
      case 'WIN':
        return Icons.emoji_events;
      case 'LOSS':
        return Icons.close;
      default:
        return Icons.handshake;
    }
  }

  /// Mode badge widget'i
  Widget _buildModeBadge(String mode) {
    Color badgeColor;
    Color textColor;

    switch (mode) {
      case 'Tournament':
        badgeColor = const Color(0xFFFFB800).withOpacity(0.2);
        textColor = const Color(0xFFFFB800);
        break;
      case 'Ranked':
        badgeColor = const Color(0xFF6C5CE7).withOpacity(0.2);
        textColor = const Color(0xFF6C5CE7);
        break;
      default:
        badgeColor = Colors.white.withOpacity(0.1);
        textColor = Colors.white54;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        mode,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Score section widget'i
  Widget _buildScoreSection(String score, String result, Color resultColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            score,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
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
    );
  }

  /// Points section widget'i
  Widget _buildPointsSection(String points) {
    final isPositive = points.startsWith('+');
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '$points pts',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Action buttons widget'i
  Widget _buildActionButtons() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
          },
          icon: Icon(
            Icons.replay,
            color: Colors.white.withOpacity(0.5),
            size: 20,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
          },
          icon: Icon(
            Icons.share,
            color: Colors.white.withOpacity(0.5),
            size: 20,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

