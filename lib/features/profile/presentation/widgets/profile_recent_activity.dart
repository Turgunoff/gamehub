import 'package:flutter/material.dart';

/// Profile ekranidagi recent activity section widget'i
/// So'nggi faoliyatlarni ko'rsatadi
class ProfileRecentActivity extends StatelessWidget {
  const ProfileRecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECENT ACTIVITY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) {
            return ProfileActivityItem(
              index: index,
            );
          }),
        ],
      ),
    );
  }
}

/// Activity item widget'i
class ProfileActivityItem extends StatelessWidget {
  final int index;

  const ProfileActivityItem({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final activities = [
      {'title': 'Victory vs ProPlayer', 'time': '1 hours ago', 'points': '+25', 'color': Colors.green, 'icon': Icons.emoji_events},
      {'title': 'Tournament Started', 'time': '2 hours ago', 'points': '0', 'color': Colors.orange, 'icon': Icons.sports_esports},
      {'title': 'Defeat vs Champion', 'time': '3 hours ago', 'points': '-15', 'color': Colors.red, 'icon': Icons.close},
    ];

    final activity = activities[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (activity['color'] as Color),
                  (activity['color'] as Color).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['points'] as String,
            style: TextStyle(
              color: activity['color'] as Color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

