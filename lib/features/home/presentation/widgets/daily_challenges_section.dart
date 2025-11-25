import 'package:flutter/material.dart';
import 'package:gamehub/core/widgets/section_header.dart';

class DailyChallengesSection extends StatelessWidget {
  const DailyChallengesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'DAILY CHALLENGES',
          icon: Icons.emoji_events,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              ChallengeCard(
                title: 'First Win',
                progress: 0,
                total: 1,
                reward: '500',
                icon: Icons.emoji_events,
                color: Color(0xFFFFB800),
              ),
              SizedBox(width: 12),
              ChallengeCard(
                title: 'Score 5 Goals',
                progress: 3,
                total: 5,
                reward: '1000',
                icon: Icons.sports_soccer,
                color: Color(0xFF00FB94),
              ),
              SizedBox(width: 12),
              ChallengeCard(
                title: 'Play 3 Matches',
                progress: 1,
                total: 3,
                reward: '750',
                icon: Icons.sports_esports,
                color: Color(0xFF6C5CE7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final String title;
  final int progress;
  final int total;
  final String reward;
  final IconData icon;
  final Color color;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.progress,
    required this.total,
    required this.reward,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = progress / total;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFFFB800),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    reward,
                    style: const TextStyle(
                      color: Color(0xFFFFB800),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$progress/$total',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${(progressPercent * 100).toInt()}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progressPercent,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

