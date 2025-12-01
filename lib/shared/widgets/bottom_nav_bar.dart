import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// CyberPitch Bottom Navigation Bar
/// 4 ta tab: Home, Tournaments, History, Profile
class GameHubBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GameHubBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1F3A), Color(0xFF0A0E1A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          CustomPaint(painter: BottomBarPatternPainter(), child: Container()),

          // Navigation Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'HOME',
                isSelected: currentIndex == 0,
                onTap: () => _handleTap(0),
              ),
              _NavItem(
                index: 1,
                icon: Icons.emoji_events_rounded,
                label: 'TURNIRLAR',
                isSelected: currentIndex == 1,
                onTap: () => _handleTap(1),
              ),
              _NavItem(
                index: 2,
                icon: Icons.history_rounded,
                label: 'TARIX',
                isSelected: currentIndex == 2,
                onTap: () => _handleTap(2),
              ),
              _NavItem(
                index: 3,
                icon: Icons.person_rounded,
                label: 'PROFIL',
                isSelected: currentIndex == 3,
                onTap: () => _handleTap(3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTap(int index) {
    HapticFeedback.lightImpact();
    onTap(index);
  }
}

/// Navigation item widget
class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with background
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),

              // Label
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF00D9FF)
                      : Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Background pattern painter
class BottomBarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.03);

    // Diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
