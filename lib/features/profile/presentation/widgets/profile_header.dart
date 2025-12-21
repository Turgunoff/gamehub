import 'package:flutter/material.dart';
import 'package:cyberpitch/core/widgets/optimized_image.dart';
import 'package:cyberpitch/core/models/profile_model.dart';

/// Profile ekranining header qismi
/// Avatar, username va online statusni ko'rsatadi
class ProfileHeader extends StatelessWidget {
  final UserMeModel? user;

  const ProfileHeader({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final nickname = user?.nickname ?? 'GAMER';
    final level = user?.level ?? 1;
    final avatarUrl = user?.avatarUrl;
    final isVerified = user?.isVerified ?? false;

    return Column(
      children: [
        // Avatar with static glow
        Stack(
          alignment: Alignment.center,
          children: [
            // Static Glow Ring
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [
                    Color(0xFF00D9FF),
                    Color(0xFF6C5CE7),
                    Color(0xFFFFB800),
                    Color(0xFF00D9FF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Avatar Container
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1F3A),
                border: Border.all(color: const Color(0xFF0A0E1A), width: 4),
              ),
              child: ClipOval(
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? OptimizedImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        width: 130,
                        height: 130,
                        errorWidget: const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFF6C5CE7),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF6C5CE7),
                      ),
              ),
            ),
            // Level Badge
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB800), Color(0xFFFF6B6B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB800).withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'LVL $level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Verified Badge
            if (isVerified)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00FB94),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        // Username with gradient
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00D9FF), Color(0xFF6C5CE7)],
          ).createShader(bounds),
          child: Text(
            nickname.toUpperCase(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Online Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ONLINE',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
