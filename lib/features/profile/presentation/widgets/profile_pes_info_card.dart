import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:gamehub/core/models/profile_model.dart';

/// Profile ekranidagi PES info card widget'i
/// PES ID va Team Strength ma'lumotlarini ko'rsatadi
class ProfilePESInfoCard extends StatelessWidget {
  final ProfileModel? profile;

  const ProfilePESInfoCard({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final pesId = profile?.pesId ?? '-';
    final teamStrength = profile?.teamStrength;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PES MOBILE INFO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          // PES ID Card with glassmorphism
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  children: [
                    // PES ID Row
                    _buildPESIDRow(context, pesId),
                    const SizedBox(height: 20),
                    Container(height: 1, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 20),
                    // Team Strength Row
                    _buildTeamStrengthRow(teamStrength),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// PES ID qatorini ko'rsatuvchi widget
  Widget _buildPESIDRow(BuildContext context, String pesId) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.fingerprint,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PES ID',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pesId,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        if (pesId != '-')
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(text: pesId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('PES ID nusxalandi'),
                  backgroundColor: const Color(0xFF1A1F3A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.copy,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  /// Team Strength qatorini ko'rsatuvchi widget
  Widget _buildTeamStrengthRow(int? teamStrength) {
    final strengthValue = teamStrength != null
        ? _formatNumber(teamStrength)
        : '-';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB800), Color(0xFFFF6B6B)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.flash_on,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TEAM STRENGTH',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                strengthValue,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K'.replaceAll('.', ',');
    }
    return number.toString();
  }
}

