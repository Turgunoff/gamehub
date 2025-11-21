import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class GameHubBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GameHubBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<GameHubBottomNavBar> createState() => _GameHubBottomNavBarState();
}

class _GameHubBottomNavBarState extends State<GameHubBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _playButtonController;

  @override
  void initState() {
    super.initState();
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1A1F3A), const Color(0xFF0A0E1A)],
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Home
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'HOME',
                isSelected: widget.currentIndex == 0,
              ),

              // Tournaments
              _buildNavItem(
                index: 1,
                icon: Icons.emoji_events_rounded,
                label: 'TOURNAMENTS',
                isSelected: widget.currentIndex == 1,
              ),

              // Play Button (Center - Special)
              const SizedBox(width: 60), // Space for play button
              // History
              _buildNavItem(
                index: 3,
                icon: Icons.history_rounded,
                label: 'HISTORY',
                isSelected: widget.currentIndex == 3,
              ),

              // Profile
              _buildNavItem(
                index: 4,
                icon: Icons.person_rounded,
                label: 'PROFILE',
                isSelected: widget.currentIndex == 4,
              ),
            ],
          ),

          // Center Play Button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 35,
            bottom: 15,
            child: GestureDetector(
              onTapDown: (_) {
                _playButtonController.forward();
                HapticFeedback.lightImpact();
              },
              onTapUp: (_) {
                _playButtonController.reverse();
                widget.onTap(2);
              },
              onTapCancel: () {
                _playButtonController.reverse();
              },
              child: AnimatedBuilder(
                animation: _playButtonController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 - (_playButtonController.value * 0.05),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C5CE7).withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: const Color(0xFF00D9FF).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated ring
                          if (widget.currentIndex == 2)
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            ),

                          // Play Icon
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.sports_esports,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'PLAY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap(index);
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6C5CE7).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF00D9FF)
                      : Colors.white.withOpacity(0.5),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
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
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D9FF),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pattern Painter for bottom bar
class BottomBarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.03);

    // Draw diagonal lines
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
