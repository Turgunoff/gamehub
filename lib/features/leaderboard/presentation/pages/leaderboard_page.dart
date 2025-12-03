// lib/features/leaderboard/presentation/pages/leaderboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../bloc/leaderboard_bloc.dart';
import '../widgets/leaderboard_item_card.dart';
import '../widgets/top_three_podium.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LeaderboardBloc()..add(const LeaderboardLoadRequested(limit: 50)),
      child: const _LeaderboardView(),
    );
  }
}

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C5CE7),
              ),
            );
          }

          if (state is LeaderboardLoaded) {
            return _buildLeaderboard(context, state.players);
          }

          if (state is LeaderboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Xatolik yuz berdi',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<LeaderboardBloc>()
                          .add(const LeaderboardLoadRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                    ),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, List<LeaderboardItem> players) {
    final topThree = players.take(3).toList();
    final rest = players.skip(3).toList();

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          backgroundColor: const Color(0xFF0A0E1A),
          elevation: 0,
          pinned: true,
          expandedHeight: 60,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: const FlexibleSpaceBar(
            title: Text(
              'LEADERBOARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            centerTitle: true,
          ),
        ),

        // Top 3 podium
        if (topThree.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: TopThreePodium(players: topThree),
            ),
          ),

        // Divider
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFF6C5CE7).withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Rest of players
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final player = rest[index];
                return LeaderboardItemCard(player: player);
              },
              childCount: rest.length,
            ),
          ),
        ),

        // Empty state if no players beyond top 3
        if (rest.isEmpty && topThree.length < 3)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  "Hozircha ko'proq o'yinchi yo'q",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
