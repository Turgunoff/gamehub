import 'package:flutter/material.dart';

/// Tournaments ekranining header qismi
/// Sarlavha va filter tugmasini ko'rsatadi
class TournamentsHeader extends StatelessWidget {
  final VoidCallback? onFilterTap;

  const TournamentsHeader({
    super.key,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOURNAMENTS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Compete and win prizes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Filter Button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6C5CE7).withOpacity(0.5),
              ),
            ),
            child: IconButton(
              onPressed: onFilterTap,
              icon: const Icon(
                Icons.filter_list,
                color: Color(0xFF6C5CE7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

