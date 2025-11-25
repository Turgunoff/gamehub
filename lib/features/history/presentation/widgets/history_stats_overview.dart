import 'package:flutter/material.dart';

/// History ekranining stats overview qismi
/// Umumiy statistikalarni ko'rsatadi (Played, Won, Lost, Draw, Win Rate)
class HistoryStatsOverview extends StatelessWidget {
  const HistoryStatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quick stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              HistoryQuickStat(label: 'Played', value: '48', icon: Icons.sports_esports),
              HistoryQuickStat(label: 'Won', value: '31', icon: Icons.emoji_events),
              HistoryQuickStat(label: 'Lost', value: '15', icon: Icons.close),
              HistoryQuickStat(label: 'Draw', value: '2', icon: Icons.handshake),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          // Win rate row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Win Rate: ',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Text(
                '64.6%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.greenAccent,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+2.4%',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick stat widget'i
class HistoryQuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const HistoryQuickStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
        ),
      ],
    );
  }
}

