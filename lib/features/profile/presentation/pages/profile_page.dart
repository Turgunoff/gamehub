import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_section.dart';
import '../widgets/profile_pes_info_card.dart';
import '../widgets/profile_performance_chart.dart';
import '../widgets/profile_achievements_section.dart';
import '../widgets/profile_recent_activity.dart';
import '../widgets/profile_floating_edit_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Static Background (No animation)
          _buildStaticBackground(),

          // Main Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom App Bar with parallax effect
              _buildSliverAppBar(),

              // Profile Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Stats Cards
                    const ProfileStatsSection(),

                    // PES Info Cards
                    const ProfilePESInfoCard(),

                    // Performance Chart
                    const ProfilePerformanceChart(),

                    // Achievements
                    const ProfileAchievementsSection(),

                    // Recent Activity
                    const ProfileRecentActivity(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // Floating Action Button (No animation)
          const ProfileFloatingEditButton(),
        ],
      ),
    );
  }

  Widget _buildStaticBackground() {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0E1A), Color(0xFF1A1F3A), Color(0xFF0A0E1A)],
            ),
          ),
        ),

        // Static Mesh Pattern
        CustomPaint(painter: StaticMeshPatternPainter(), child: Container()),

        // Static gradient overlays for visual depth
        Positioned(
          top: 100,
          left: 50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00D9FF).withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 300,
          right: 50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6C5CE7).withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Parallax Background
            Transform.translate(
              offset: Offset(0, _scrollOffset * 0.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6C5CE7).withOpacity(0.6),
                      const Color(0xFF00D9FF).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: CustomPaint(painter: HexagonPatternPainter()),
              ),
            ),

            // Profile Info
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: const ProfileHeader(),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(Icons.settings, size: 20),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/settings');
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
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
                child: Image.network(
                  'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF6C5CE7),
                    );
                  },
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'LVL 42',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
          child: const Text(
            'CYBER_STRIKER',
            style: TextStyle(
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

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events,
                  title: 'WINS',
                  value: '324',
                  color: const Color(0xFFFFB800),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.sports_esports,
                  title: 'MATCHES',
                  value: '512',
                  color: const Color(0xFF00D9FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  title: 'WIN RATE',
                  value: '63%',
                  color: const Color(0xFF00FB94),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  title: 'RATING',
                  value: '2,847',
                  color: const Color(0xFF6C5CE7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPESInfoCards() {
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
                    Row(
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
                              const Text(
                                '123-456-789',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            // Copy to clipboard logic here
                          },
                          icon: Icon(
                            Icons.copy,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 20),
                    Row(
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    '4,285',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.trending_up,
                                          size: 12,
                                          color: Colors.green,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '+125',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green,
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1F3A).withOpacity(0.8),
              const Color(0xFF0A0E1A).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERFORMANCE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: CustomPaint(
                painter: PerformanceChartPainter(),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = [
      {'icon': '🏆', 'name': 'Champion', 'desc': '100 Wins'},
      {'icon': '⚡', 'name': 'Speed Demon', 'desc': 'Quick Wins'},
      {'icon': '🎯', 'name': 'Sharpshooter', 'desc': '90% Accuracy'},
      {'icon': '💎', 'name': 'Diamond', 'desc': 'Top Rank'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACHIEVEMENTS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF6C5CE7).withOpacity(0.3),
                        const Color(0xFF00D9FF).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        achievement['icon']!,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        achievement['name']!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achievement['desc']!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECENT ACTIVITY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: index == 0
                            ? [Colors.green, Colors.green.shade700]
                            : index == 1
                            ? [Colors.orange, Colors.orange.shade700]
                            : [Colors.red, Colors.red.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      index == 0
                          ? Icons.emoji_events
                          : index == 1
                          ? Icons.sports_esports
                          : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          index == 0
                              ? 'Victory vs ProPlayer'
                              : index == 1
                              ? 'Tournament Started'
                              : 'Defeat vs Champion',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${index + 1} hours ago',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    index == 0
                        ? '+25'
                        : index == 1
                        ? '0'
                        : '-15',
                    style: TextStyle(
                      color: index == 0
                          ? Colors.green
                          : index == 1
                          ? Colors.orange
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFloatingEditButton() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.push('/edit-profile');
          },
          backgroundColor: const Color(0xFF6C5CE7),
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text(
            'EDIT PROFILE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// Static Mesh Pattern Painter
class StaticMeshPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    // Static gradient circles
    final circle1 = Offset(size.width * 0.3, size.height * 0.2);
    final circle2 = Offset(size.width * 0.7, size.height * 0.4);
    final circle3 = Offset(size.width * 0.5, size.height * 0.6);

    paint.shader = RadialGradient(
      colors: [const Color(0xFF6C5CE7).withOpacity(0.2), Colors.transparent],
    ).createShader(Rect.fromCircle(center: circle1, radius: 150));
    canvas.drawCircle(circle1, 150, paint);

    paint.shader = RadialGradient(
      colors: [const Color(0xFF00D9FF).withOpacity(0.2), Colors.transparent],
    ).createShader(Rect.fromCircle(center: circle2, radius: 120));
    canvas.drawCircle(circle2, 120, paint);

    paint.shader = RadialGradient(
      colors: [const Color(0xFFFFB800).withOpacity(0.15), Colors.transparent],
    ).createShader(Rect.fromCircle(center: circle3, radius: 100));
    canvas.drawCircle(circle3, 100, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Hexagon Pattern Painter
class HexagonPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const hexSize = 30.0;
    final rows = (size.height / hexSize).ceil() + 1;
    final cols = (size.width / hexSize).ceil() + 1;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final centerX = col * hexSize * 1.5;
        final centerY =
            row * hexSize * math.sqrt(3) +
            (col % 2 == 1 ? hexSize * math.sqrt(3) / 2 : 0);

        _drawHexagon(canvas, Offset(centerX, centerY), hexSize / 2, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Performance Chart Painter
class PerformanceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Chart line
    final path = Path();
    final points = [
      const Offset(0, 0.8),
      const Offset(0.2, 0.6),
      const Offset(0.4, 0.4),
      const Offset(0.6, 0.3),
      const Offset(0.8, 0.2),
      const Offset(1, 0.15),
    ];

    for (int i = 0; i < points.length; i++) {
      final point = Offset(
        points[i].dx * size.width,
        points[i].dy * size.height,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        final previous = Offset(
          points[i - 1].dx * size.width,
          points[i - 1].dy * size.height,
        );
        final controlPoint1 = Offset(
          previous.dx + (point.dx - previous.dx) / 2,
          previous.dy,
        );
        final controlPoint2 = Offset(
          previous.dx + (point.dx - previous.dx) / 2,
          point.dy,
        );
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          point.dx,
          point.dy,
        );
      }
    }

    // Gradient for line
    paint.shader = const LinearGradient(
      colors: [Color(0xFF00D9FF), Color(0xFF6C5CE7)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF6C5CE7)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        5,
        pointPaint,
      );
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
