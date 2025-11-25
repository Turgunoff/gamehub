import 'package:flutter/material.dart';
import 'profile_stat_card.dart';

/// Profile ekranining stats section qismi
/// Umumiy statistikalarni ko'rsatadi (Wins, Matches, Win Rate, Rating)
class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: ProfileStatCard(
                  icon: Icons.emoji_events,
                  title: 'WINS',
                  value: '324',
                  color: Color(0xFFFFB800),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: ProfileStatCard(
                  icon: Icons.sports_esports,
                  title: 'MATCHES',
                  value: '512',
                  color: Color(0xFF00D9FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: ProfileStatCard(
                  icon: Icons.trending_up,
                  title: 'WIN RATE',
                  value: '63%',
                  color: Color(0xFF00FB94),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: ProfileStatCard(
                  icon: Icons.star,
                  title: 'RATING',
                  value: '2,847',
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

