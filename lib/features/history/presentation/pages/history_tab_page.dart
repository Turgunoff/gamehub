import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;

class HistoryTabPage extends StatefulWidget {
  const HistoryTabPage({super.key});

  @override
  State<HistoryTabPage> createState() => _HistoryTabPageState();
}

class _HistoryTabPageState extends State<HistoryTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Stats Overview
                _buildStatsOverview(),

                // Tab Bar
                _buildTabBar(),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildMatchesTab(), _buildStatisticsTab()],
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1F3A), Color(0xFF0A0E1A)],
        ),
      ),
      child: CustomPaint(painter: GridPatternPainter(), child: Container()),
    );
  }

  Widget _buildHeader() {
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
              value: _selectedPeriod,
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
                setState(() => _selectedPeriod = value!);
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat('Played', '48', Icons.sports_esports),
              _buildQuickStat('Won', '31', Icons.emoji_events),
              _buildQuickStat('Lost', '15', Icons.close),
              _buildQuickStat('Draw', '2', Icons.handshake),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
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

  Widget _buildQuickStat(String label, String value, IconData icon) {
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'MATCHES'),
          Tab(text: 'STATISTICS'),
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 10,
      itemBuilder: (context, index) {
        // Mock data for different match results
        final results = [
          {
            'opponent': 'ProGamer_23',
            'score': '3-1',
            'result': 'WIN',
            'points': '+28',
            'mode': 'Ranked',
          },
          {
            'opponent': 'xElite99',
            'score': '2-2',
            'result': 'DRAW',
            'points': '+5',
            'mode': 'Ranked',
          },
          {
            'opponent': 'FutbolKing',
            'score': '1-2',
            'result': 'LOSS',
            'points': '-22',
            'mode': 'Ranked',
          },
          {
            'opponent': 'QuickShot',
            'score': '4-0',
            'result': 'WIN',
            'points': '+30',
            'mode': 'Tournament',
          },
          {
            'opponent': 'DefMaster',
            'score': '0-0',
            'result': 'DRAW',
            'points': '+3',
            'mode': 'Friendly',
          },
          {
            'opponent': 'SpeedRun7',
            'score': '2-3',
            'result': 'LOSS',
            'points': '-18',
            'mode': 'Ranked',
          },
          {
            'opponent': 'GoalMachine',
            'score': '5-2',
            'result': 'WIN',
            'points': '+25',
            'mode': 'Tournament',
          },
          {
            'opponent': 'TacticPro',
            'score': '1-0',
            'result': 'WIN',
            'points': '+20',
            'mode': 'Ranked',
          },
          {
            'opponent': 'ChampX',
            'score': '2-4',
            'result': 'LOSS',
            'points': '-25',
            'mode': 'Tournament',
          },
          {
            'opponent': 'NewPlayer1',
            'score': '3-1',
            'result': 'WIN',
            'points': '+15',
            'mode': 'Friendly',
          },
        ];

        final match = results[index % results.length];
        return _buildMatchCard(
          date: index == 0
              ? 'Today, 15:30'
              : index == 1
              ? 'Today, 12:00'
              : 'Yesterday',
          opponent: match['opponent']!,
          score: match['score']!,
          result: match['result']!,
          points: match['points']!,
          mode: match['mode']!,
          index: index,
        );
      },
    );
  }

  Widget _buildMatchCard({
    required String date,
    required String opponent,
    required String score,
    required String result,
    required String points,
    required String mode,
    required int index,
  }) {
    Color resultColor = result == 'WIN'
        ? const Color(0xFF00FB94)
        : result == 'LOSS'
        ? const Color(0xFFFF6B6B)
        : Colors.orange;

    IconData resultIcon = result == 'WIN'
        ? Icons.emoji_events
        : result == 'LOSS'
        ? Icons.close
        : Icons.handshake;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Card Background
          Container(
            margin: const EdgeInsets.only(left: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: resultColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: mode == 'Tournament'
                            ? const Color(0xFFFFB800).withOpacity(0.2)
                            : mode == 'Ranked'
                            ? const Color(0xFF6C5CE7).withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        mode,
                        style: TextStyle(
                          color: mode == 'Tournament'
                              ? const Color(0xFFFFB800)
                              : mode == 'Ranked'
                              ? const Color(0xFF6C5CE7)
                              : Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Match Details
                Row(
                  children: [
                    // Your Team
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'You',
                            style: TextStyle(
                              color: Color(0xFF00D9FF),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Team: 4,285',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            score,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: resultColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              result,
                              style: TextStyle(
                                color: resultColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Opponent
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            opponent,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Team: 4,150',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Points and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          points.startsWith('+')
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: points.startsWith('+')
                              ? Colors.green
                              : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$points pts',
                          style: TextStyle(
                            color: points.startsWith('+')
                                ? Colors.green
                                : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                          },
                          icon: Icon(
                            Icons.replay,
                            color: Colors.white.withOpacity(0.5),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                          },
                          icon: Icon(
                            Icons.share,
                            color: Colors.white.withOpacity(0.5),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Match Number Indicator
          Positioned(
            left: 0,
            top: 35,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: resultColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: resultColor.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(resultIcon, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Performance Chart
          _buildPerformanceChart(),
          const SizedBox(height: 20),

          // Goals Statistics
          _buildStatCard(
            title: 'GOALS STATISTICS',
            icon: Icons.sports_soccer,
            color: const Color(0xFFFFB800),
            stats: [
              {'label': 'Goals Scored', 'value': '142'},
              {'label': 'Goals Conceded', 'value': '87'},
              {'label': 'Avg Goals/Match', 'value': '2.96'},
              {'label': 'Clean Sheets', 'value': '12'},
            ],
          ),
          const SizedBox(height: 16),

          // Match Statistics
          _buildStatCard(
            title: 'MATCH PERFORMANCE',
            icon: Icons.analytics,
            color: const Color(0xFF6C5CE7),
            stats: [
              {'label': 'Longest Win Streak', 'value': '8'},
              {'label': 'Current Streak', 'value': '3W'},
              {'label': 'Best Score', 'value': '7-0'},
              {'label': 'Rage Quits', 'value': '2'},
            ],
          ),
          const SizedBox(height: 16),

          // Tournament Stats
          _buildStatCard(
            title: 'TOURNAMENT STATS',
            icon: Icons.emoji_events,
            color: const Color(0xFF00D9FF),
            stats: [
              {'label': 'Tournaments Played', 'value': '15'},
              {'label': 'Tournaments Won', 'value': '3'},
              {'label': 'Best Position', 'value': '1st'},
              {'label': 'Total Earnings', 'value': '125,000'},
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RATING TREND',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Color(0xFF00FB94),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '+285',
                    style: TextStyle(
                      color: Color(0xFF00FB94),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(painter: ChartPainter(), child: Container()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, String>> stats,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...stats
              .map(
                (stat) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stat['label']!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        stat['value']!,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

// Pattern Painter
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 50.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Chart Painter
class ChartPainter extends CustomPainter {
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
      const Offset(0, 0.9),
      const Offset(0.15, 0.7),
      const Offset(0.3, 0.75),
      const Offset(0.45, 0.5),
      const Offset(0.6, 0.4),
      const Offset(0.75, 0.35),
      const Offset(0.9, 0.25),
      const Offset(1, 0.2),
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
      colors: [Color(0xFF00D9FF), Color(0xFF00FB94)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Draw area under curve
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00D9FF).withOpacity(0.3),
          const Color(0xFF00D9FF).withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF00FB94)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        4,
        pointPaint,
      );
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        4,
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
