import 'package:flutter/material.dart';

/// Profile ekranidagi achievements section widget'i
/// Foydalanuvchi yutuglarini ko'rsatadi
class ProfileAchievementsSection extends StatelessWidget {
  const ProfileAchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      {'icon': '🏆', 'name': 'Champion', 'desc': '100 Wins'},
      {'icon': '⚡', 'name': 'Speed Demon', 'desc': 'Quick Wins'},
      {'icon': '🎯', 'name': 'Sharpshooter', 'desc': '90% Accuracy'},
      {'icon': '💎', 'name': 'Diamond', 'desc': 'Top Rank'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACHIEVEMENTS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return ProfileAchievementCard(
                  icon: achievement['icon']!,
                  name: achievement['name']!,
                  description: achievement['desc']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Achievement card widget'i
class ProfileAchievementCard extends StatelessWidget {
  final String icon;
  final String name;
  final String description;

  const ProfileAchievementCard({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.3),
            const Color(0xFF00D9FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6C5CE7).withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

