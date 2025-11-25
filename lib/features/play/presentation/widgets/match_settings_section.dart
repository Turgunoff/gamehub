import 'package:flutter/material.dart';

/// Match sozlamalari section widget'i
/// Half duration va opponent range sozlamalarini ko'rsatadi
class MatchSettingsSection extends StatelessWidget {
  const MatchSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: Color(0xFF6C5CE7), size: 20),
              const SizedBox(width: 8),
              Text(
                'MATCH SETTINGS',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Half Duration setting
          _buildSettingRow(
            label: 'Half Duration',
            value: '6 Minutes',
            valueColor: const Color(0xFF6C5CE7),
          ),
          const SizedBox(height: 16),
          // Opponent Range setting
          _buildSettingRow(
            label: 'Opponent Range',
            value: '±300 Strength',
            valueColor: const Color(0xFFFFB800),
          ),
        ],
      ),
    );
  }

  /// Sozlama qatorini ko'rsatuvchi widget
  Widget _buildSettingRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: valueColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: valueColor.withOpacity(0.5),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

