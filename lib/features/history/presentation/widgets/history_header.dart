import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// History ekranining header qismi
/// Sarlavha va davr tanlovini ko'rsatadi
class HistoryHeader extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const HistoryHeader({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
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
                  'MATCH HISTORY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your performance analysis',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Period Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6C5CE7).withOpacity(0.5),
              ),
            ),
            child: DropdownButton<String>(
              value: selectedPeriod,
              dropdownColor: const Color(0xFF1A1F3A),
              style: const TextStyle(color: Color(0xFF6C5CE7)),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6C5CE7)),
              items: const [
                DropdownMenuItem(value: 'today', child: Text('Today')),
                DropdownMenuItem(value: 'week', child: Text('Week')),
                DropdownMenuItem(value: 'month', child: Text('Month')),
                DropdownMenuItem(value: 'all', child: Text('All Time')),
              ],
              onChanged: (value) {
                HapticFeedback.lightImpact();
                onPeriodChanged(value!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

