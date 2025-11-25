import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_mode_card.dart';

/// O'yin rejimlari grid widget'i
/// Ranked, Friendly, VS AI, Custom rejimlarini ko'rsatadi
class GameModesGrid extends StatelessWidget {
  final String selectedMode;
  final Function(String) onModeSelected;

  const GameModesGrid({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GAME MODES',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            GameModeCard(
              title: 'RANKED',
              subtitle: 'Competitive',
              icon: Icons.trending_up,
              color: const Color(0xFFFFB800),
              description: 'Affect your rating',
              isSelected: selectedMode == 'ranked',
              onTap: () {
                HapticFeedback.lightImpact();
                onModeSelected('ranked');
              },
            ),
            GameModeCard(
              title: 'FRIENDLY',
              subtitle: 'Casual Play',
              icon: Icons.favorite,
              color: const Color(0xFF00FB94),
              description: 'No rating change',
              isSelected: selectedMode == 'friendly',
              onTap: () {
                HapticFeedback.lightImpact();
                onModeSelected('friendly');
              },
            ),
            GameModeCard(
              title: 'VS AI',
              subtitle: 'Practice',
              icon: Icons.computer,
              color: const Color(0xFF6C5CE7),
              description: 'Train offline',
              isSelected: selectedMode == 'ai',
              onTap: () {
                HapticFeedback.lightImpact();
                onModeSelected('ai');
              },
            ),
            GameModeCard(
              title: 'CUSTOM',
              subtitle: 'With Friends',
              icon: Icons.group,
              color: const Color(0xFFFF6B6B),
              description: 'Invite players',
              isSelected: selectedMode == 'custom',
              onTap: () {
                HapticFeedback.lightImpact();
                onModeSelected('custom');
              },
            ),
          ],
        ),
      ],
    );
  }
}

