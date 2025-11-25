import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gamehub/core/gen/assets/assets.gen.dart';
import 'package:gamehub/core/widgets/optimized_image.dart';
import '../widgets/quick_play_section.dart';
import '../widgets/live_tournaments_section.dart';
import '../widgets/daily_challenges_section.dart';
import '../widgets/team_stats_section.dart';
import '../widgets/recent_matches_section.dart';
import '../widgets/leaderboard_preview_section.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  int onlineUsers = 2847;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Background
          _buildBackground(),

          // Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        QuickPlaySection(onlineUsers: onlineUsers),
                        const SizedBox(height: 32),
                        const LiveTournamentsSection(),
                        const SizedBox(height: 32),
                        const DailyChallengesSection(),
                        const SizedBox(height: 32),
                        const TeamStatsSection(),
                        const SizedBox(height: 32),
                        const RecentMatchesSection(),
                        const SizedBox(height: 32),
                        const LeaderboardPreviewSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1F3A), Color(0xFF0A0E1A)],
            ),
          ),
        ),

        // SVG Football Field - markazlashgan va shaffof
        Positioned.fill(
          child: Opacity(
            opacity: 0.15, // Subtle background effect
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFF00D9FF), // Cyan neon rang
                BlendMode.srcATop,
              ),
              child: SvgPicture.asset(
                Assets.images.cyberpitchBackground.path,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                placeholderBuilder: (context) =>
                    Container(color: Colors.transparent),
              ),
            ),
          ),
        ),

        // Glow effect - tepadan
        Positioned(
          top: -100,
          left: 0,
          right: 0,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6C5CE7).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Glow effect - pastdan
        Positioned(
          bottom: -50,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00D9FF).withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Overlay gradient for better readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                const Color(0xFF0A0E1A).withOpacity(0.5),
                const Color(0xFF0A0E1A).withOpacity(0.8),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          // User Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1F3A),
              ),
              child: ClipOval(
                child: OptimizedImage(
                  imageUrl: 'https://via.placeholder.com/45',
                  fit: BoxFit.cover,
                  width: 45,
                  height: 45,
                  errorWidget: const Icon(
                    Icons.person,
                    color: Color(0xFF6C5CE7),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome back!',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF6C5CE7)],
                  ).createShader(bounds),
                  child: const Text(
                    'CYBER_STRIKER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Coins Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Color(0xFFFFB800),
                size: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                '12,500',
                style: TextStyle(
                  color: Color(0xFFFFB800),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Notifications
        Stack(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B6B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
