import 'package:flutter/material.dart';
import 'package:gamehub/core/models/profile_model.dart';
import 'profile_stat_card.dart';

/// Profile ekranining stats section qismi
/// Umumiy statistikalarni ko'rsatadi (Wins, Matches, Win Rate, Rating)
class ProfileStatsSection extends StatelessWidget {
  final ProfileModel? profile;

  const ProfileStatsSection({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final wins = profile?.wins ?? 0;
    final totalMatches = profile?.totalMatches ?? 0;
    final winRate = profile?.winRate ?? 0.0;
    final level = profile?.level ?? 1;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ProfileStatCard(
                  icon: Icons.emoji_events,
                  title: 'WINS',
                  value: wins.toString(),
                  color: const Color(0xFFFFB800),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ProfileStatCard(
                  icon: Icons.sports_esports,
                  title: 'MATCHES',
                  value: totalMatches.toString(),
                  color: const Color(0xFF00D9FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ProfileStatCard(
                  icon: Icons.trending_up,
                  title: 'WIN RATE',
                  value: '${winRate.toStringAsFixed(0)}%',
                  color: const Color(0xFF00FB94),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ProfileStatCard(
                  icon: Icons.star,
                  title: 'LEVEL',
                  value: level.toString(),
                  color: const Color(0xFF6C5CE7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

