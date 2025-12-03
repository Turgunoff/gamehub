import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gamehub/core/gen/assets/assets.gen.dart';
import 'package:gamehub/core/widgets/optimized_image.dart';
import 'package:gamehub/core/services/api_service.dart';
import 'package:gamehub/core/services/onesignal_service.dart';
import '../bloc/home_bloc.dart';
import '../widgets/quick_play_section.dart';
import '../../../chat/presentation/pages/conversations_page.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  int _notificationCount = 0;
  int _unreadMessagesCount = 0;
  StreamSubscription<NotificationEvent>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    // Ma'lumotlarni yuklash
    context.read<HomeBloc>().add(const HomeLoadRequested());
    _loadNotificationCount();
    _loadUnreadMessagesCount();

    // Real-time notification listener
    _notificationSubscription = OneSignalService().onNotificationReceived.listen((event) {
      // Notification kelganda badge ni yangilash
      _loadNotificationCount();
      if (event.type == 'chat_message') {
        _loadUnreadMessagesCount();
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadNotificationCount() async {
    try {
      final results = await Future.wait([
        ApiService().getPendingChallenges(),
        ApiService().getFriendRequests(),
      ]);
      if (mounted) {
        setState(() {
          _notificationCount =
              (results[0] as PendingChallengesResponse).count +
              (results[1] as FriendRequestsResponse).count;
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _loadUnreadMessagesCount() async {
    try {
      final count = await ApiService().getUnreadMessagesCount();
      if (mounted) {
        setState(() {
          _unreadMessagesCount = count;
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00D9FF),
                    ),
                  );
                }

                if (state is HomeError) {
                  return _buildErrorState(state.message);
                }

                if (state is HomeLoaded) {
                  return _buildContent(state.data);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HomeDashboardResponse data) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const HomeRefreshRequested());
      },
      color: const Color(0xFF00D9FF),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildSliverAppBar(data.user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Play Section
                  QuickPlaySection(
                    onlineUsers: data.onlineUsers,
                    onQuickMatchTap: () {
                      context.push('/quick-match', extra: 'ranked');
                    },
                    onRankedTap: () {
                      context.push('/quick-match', extra: 'ranked');
                    },
                    onFriendlyTap: () {
                      context.push('/quick-match', extra: 'friendly');
                    },
                  ),
                  const SizedBox(height: 24),

                  // User Stats Section
                  _buildUserStatsSection(data.stats),
                  const SizedBox(height: 24),

                  // Active Tournaments
                  if (data.tournaments.isNotEmpty) ...[
                    _buildSectionTitle('Aktiv Turnirlar', Icons.emoji_events),
                    const SizedBox(height: 12),
                    _buildTournamentsList(data.tournaments),
                    const SizedBox(height: 24),
                  ],

                  // Recent Matches
                  _buildSectionTitle('Oxirgi O\'yinlar', Icons.history),
                  const SizedBox(height: 12),
                  if (data.recentMatches.isEmpty)
                    _buildEmptyMatches()
                  else
                    _buildRecentMatchesList(data.recentMatches),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFFF6B6B),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Xatolik yuz berdi',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<HomeBloc>().add(const HomeLoadRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Qayta urinish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1F3A), Color(0xFF0A0E1A)],
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xFF00D9FF),
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

  Widget _buildSliverAppBar(HomeUser user) {
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1A1F3A),
              ),
              child: ClipOval(
                child: user.avatarUrl != null
                    ? OptimizedImage(
                        imageUrl: user.avatarUrl!,
                        fit: BoxFit.cover,
                        width: 45,
                        height: 45,
                        errorWidget: const Icon(
                          Icons.person,
                          color: Color(0xFF6C5CE7),
                          size: 20,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF6C5CE7),
                        size: 20,
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
                Text(
                  'Level ${user.level}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF6C5CE7)],
                  ).createShader(bounds),
                  child: Text(
                    user.nickname ?? 'Player',
                    style: const TextStyle(
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
              Text(
                _formatNumber(user.coins),
                style: const TextStyle(
                  color: Color(0xFFFFB800),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Chat/Messages
        Stack(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConversationsPage()),
                ).then((_) {
                  // Qaytganda countni yangilash
                  _loadUnreadMessagesCount();
                });
              },
              icon: Icon(
                Icons.chat_bubble_outline,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            if (_unreadMessagesCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D9FF),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _unreadMessagesCount > 9 ? '9+' : '$_unreadMessagesCount',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Notifications
        Stack(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/notifications').then((_) {
                  // Qaytganda countni yangilash
                  _loadNotificationCount();
                });
              },
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            if (_notificationCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _notificationCount > 9 ? '9+' : '$_notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00D9FF), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUserStatsSection(HomeStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xFF00D9FF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Statistika',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Win Rate: ${stats.winRate.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Color(0xFF6C5CE7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('O\'yinlar', stats.totalMatches.toString(), const Color(0xFF00D9FF)),
              _buildStatItem('G\'alabalar', stats.wins.toString(), const Color(0xFF00FB94)),
              _buildStatItem('Mag\'lubiyat', stats.losses.toString(), const Color(0xFFFF6B6B)),
              _buildStatItem('Durrang', stats.draws.toString(), const Color(0xFFFFB800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentsList(List<HomeTournament> tournaments) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          final tournament = tournaments[index];
          return _buildTournamentCard(tournament);
        },
      ),
    );
  }

  Widget _buildTournamentCard(HomeTournament tournament) {
    final isFeatured = tournament.isFeatured;
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isFeatured
            ? const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isFeatured ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFeatured
              ? Colors.transparent
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: isFeatured ? Colors.white : const Color(0xFFFFB800),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tournament.name,
                  style: TextStyle(
                    color: isFeatured ? Colors.white : Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${tournament.participantCount}/${tournament.maxParticipants} ishtirokchi',
            style: TextStyle(
              color: isFeatured ? Colors.white70 : Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                color: isFeatured ? Colors.white : const Color(0xFFFFB800),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${tournament.prizePool}',
                style: TextStyle(
                  color: isFeatured ? Colors.white : const Color(0xFFFFB800),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isFeatured
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFF00FB94).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tournament.status,
                  style: TextStyle(
                    color: isFeatured ? Colors.white : const Color(0xFF00FB94),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMatchesList(List<HomeMatch> matches) {
    return Column(
      children: matches.map((match) => _buildMatchItem(match)).toList(),
    );
  }

  Widget _buildMatchItem(HomeMatch match) {
    final isWin = match.result == 'WIN';
    final isDraw = match.result == 'DRAW';
    final resultColor = isWin
        ? const Color(0xFF00FB94)
        : isDraw
            ? const Color(0xFFFFB800)
            : const Color(0xFFFF6B6B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: resultColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Result indicator
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: resultColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // Opponent info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'vs ${match.opponentNickname}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  match.mode,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                match.score,
                style: TextStyle(
                  color: resultColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${match.ratingChange > 0 ? '+' : ''}${match.ratingChange}',
                style: TextStyle(
                  color: match.ratingChange > 0
                      ? const Color(0xFF00FB94)
                      : const Color(0xFFFF6B6B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMatches() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sports_esports_outlined,
            color: Color(0xFF6C5CE7),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Hali o\'yin o\'ynalmagan',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Birinchi o\'yiningizni boshlang!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
