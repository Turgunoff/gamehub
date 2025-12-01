import 'package:flutter/material.dart';

/// Bo'sh holat uchun universal widget
/// History, Tournaments, va boshqa ekranlarda ishlatiladi
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with glow effect
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    (iconColor ?? const Color(0xFF6C5CE7)).withOpacity(0.2),
                    (iconColor ?? const Color(0xFF00D9FF)).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (iconColor ?? const Color(0xFF6C5CE7)).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 56,
                color: iconColor ?? const Color(0xFF6C5CE7),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            // Optional action button
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onButtonPressed,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            buttonText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// History ekrani uchun empty state
class HistoryEmptyState extends StatelessWidget {
  final VoidCallback? onPlayNow;

  const HistoryEmptyState({super.key, this.onPlayNow});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.sports_esports_outlined,
      title: 'Hali o\'yin o\'ynamadingiz',
      subtitle: 'Birinchi o\'yiningizni o\'ynang va natijalaringizni shu yerda ko\'ring',
      buttonText: 'O\'yin boshlash',
      onButtonPressed: onPlayNow,
      iconColor: const Color(0xFF00D9FF),
    );
  }
}

/// Tournaments (My Tournaments) uchun empty state
class TournamentsEmptyState extends StatelessWidget {
  final VoidCallback? onBrowseTournaments;

  const TournamentsEmptyState({super.key, this.onBrowseTournaments});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.emoji_events_outlined,
      title: 'Hali turnirlarda qatnashmadingiz',
      subtitle: 'Turnirlarga qo\'shiling va g\'olib bo\'ling!',
      buttonText: 'Turnirlarni ko\'rish',
      onButtonPressed: onBrowseTournaments,
      iconColor: const Color(0xFFFFB800),
    );
  }
}

/// Statistics empty state
class StatsEmptyState extends StatelessWidget {
  const StatsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.analytics_outlined,
      title: 'Statistika mavjud emas',
      subtitle: 'O\'yin o\'ynang va statistikangizni kuzating',
      iconColor: const Color(0xFF6C5CE7),
    );
  }
}
