import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/optimized_image.dart';
import '../bloc/matchmaking_bloc.dart';

class QuickMatchPage extends StatefulWidget {
  final String mode; // ranked, friendly

  const QuickMatchPage({
    super.key,
    this.mode = 'ranked',
  });

  @override
  State<QuickMatchPage> createState() => _QuickMatchPageState();
}

class _QuickMatchPageState extends State<QuickMatchPage>
    with TickerProviderStateMixin {
  late MatchmakingBloc _matchmakingBloc;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  Timer? _onlineStatusTimer;
  String _currentFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _matchmakingBloc = MatchmakingBloc();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Barcha o'yinchilarni yuklash
    _matchmakingBloc.add(const PlayersRequested(filter: 'all'));

    // Har 30 sekundda online status yangilash
    _onlineStatusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ApiService().updateOnlineStatus();
    });

    // Pending challenges tekshirish
    _checkPendingChallenges();
  }

  Future<void> _checkPendingChallenges() async {
    try {
      final response = await ApiService().getPendingChallenges();
      if (response.count > 0 && mounted) {
        _showPendingChallengesDialog(response.challenges);
      }
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _onlineStatusTimer?.cancel();
    _searchController.dispose();
    _matchmakingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _matchmakingBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        body: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: BlocConsumer<MatchmakingBloc, MatchmakingState>(
                      listener: (context, state) {
                        if (state is MatchmakingMatchFound) {
                          HapticFeedback.heavyImpact();
                          _showMatchFoundDialog(state);
                        } else if (state is ChallengeSentSuccess) {
                          _showSnackBar('Challenge yuborildi!', Colors.green);
                        } else if (state is MatchmakingError) {
                          _showSnackBar(state.message, Colors.red);
                        }
                      },
                      builder: (context, state) {
                        if (state is MatchmakingSearching) {
                          return _buildSearchingView(state);
                        }
                        return _buildMainView();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _matchmakingBloc.add(const MatchmakingCancelled());
              context.pop();
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'QUICK MATCH',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Find Match Button
          _buildFindMatchButton(),
          const SizedBox(height: 32),

          // OR Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'YOKI',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
            ],
          ),
          const SizedBox(height: 24),

          // Online Players Section
          _buildOnlinePlayersSection(),
        ],
      ),
    );
  }

  Widget _buildFindMatchButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.03),
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _matchmakingBloc.add(MatchmakingStarted(mode: widget.mode));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sports_esports,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'RAQIB TOPISH',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.mode == 'ranked' ? '1v1 RANKED' : 'FRIENDLY',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchingView(MatchmakingSearching state) {
    final minutes = state.searchDuration ~/ 60;
    final seconds = state.searchDuration % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated search indicator
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * 3.14159,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D9FF),
                      width: 3,
                    ),
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFF6C5CE7).withOpacity(0.5),
                        const Color(0xFF00D9FF).withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_search,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          const Text(
            'RAQIB QIDIRILMOQDA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),

          // Timer
          Text(
            timeStr,
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Queueda: ${state.queueSize} kishi',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 48),

          // Cancel button
          OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _matchmakingBloc.add(const MatchmakingCancelled());
            },
            icon: const Icon(Icons.close),
            label: const Text('BEKOR QILISH'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B6B),
              side: const BorderSide(color: Color(0xFFFF6B6B)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlinePlayersSection() {
    return BlocBuilder<MatchmakingBloc, MatchmakingState>(
      buildWhen: (prev, curr) =>
          curr is PlayersLoaded || curr is MatchmakingInitial || curr is MatchmakingLoading,
      builder: (context, state) {
        if (state is MatchmakingLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Color(0xFF00D9FF)),
            ),
          );
        }

        if (state is PlayersLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with filter
              Row(
                children: [
                  const Icon(Icons.people, color: Color(0xFF00D9FF), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'O\'YINCHILAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FB94).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00FB94),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${state.totalOnline} online',
                          style: const TextStyle(
                            color: Color(0xFF00FB94),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search and Filter Row
              Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Qidirish...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.4),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (value) {
                          _matchmakingBloc.add(PlayersRequested(
                            filter: _currentFilter,
                            search: value.isNotEmpty ? value : null,
                          ));
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Filter buttons
                  _buildFilterButton('all', 'Hammasi', state.currentFilter),
                  const SizedBox(width: 6),
                  _buildFilterButton('online', 'Online', state.currentFilter),
                ],
              ),
              const SizedBox(height: 16),

              // Players count
              Text(
                '${state.players.length} ta o\'yinchi',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),

              if (state.players.isEmpty)
                _buildNoPlayersFound()
              else
                ...state.players.map((p) => _buildPlayerCard(p)),
            ],
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D9FF)),
        );
      },
    );
  }

  Widget _buildFilterButton(String filter, String label, String currentFilter) {
    final isActive = filter == currentFilter;
    return GestureDetector(
      onTap: () {
        setState(() => _currentFilter = filter);
        _matchmakingBloc.add(PlayersRequested(
          filter: filter,
          search: _searchController.text.isNotEmpty ? _searchController.text : null,
        ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6C5CE7).withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6C5CE7)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF00D9FF) : Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNoPlayersFound() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_off,
            color: Colors.white.withOpacity(0.5),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Hozircha online o\'yinchi yo\'q',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Avtomatik qidiruv orqali raqib toping',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(OnlinePlayer player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: player.isOnline
              ? [
                  const Color(0xFF1A2A3A).withOpacity(0.8),
                  const Color(0xFF0F1A2A).withOpacity(0.9),
                ]
              : [
                  const Color(0xFF1A1F2E).withOpacity(0.6),
                  const Color(0xFF0A0E1A).withOpacity(0.7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: player.isOnline
              ? const Color(0xFF00FB94).withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          width: 1.5,
        ),
        boxShadow: player.isOnline
            ? [
                BoxShadow(
                  color: const Color(0xFF00FB94).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/player-profile/${player.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar with glow effect for online
                Container(
                  decoration: player.isOnline
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FB94).withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        )
                      : null,
                  child: Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: player.isOnline
                                ? [const Color(0xFF6C5CE7), const Color(0xFF00D9FF)]
                                : [const Color(0xFF3A3F5A), const Color(0xFF2A2F4A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: player.isOnline
                                ? const Color(0xFF00FB94)
                                : Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: player.avatarUrl != null
                              ? OptimizedImage(
                                  imageUrl: player.avatarUrl!,
                                  fit: BoxFit.cover,
                                  width: 56,
                                  height: 56,
                                  errorWidget: const Icon(
                                    Icons.person,
                                    color: Colors.white70,
                                    size: 28,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 28,
                                ),
                        ),
                      ),
                      // Online indicator with pulse
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: player.isOnline
                                ? const Color(0xFF00FB94)
                                : const Color(0xFF6B7280),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0A0E1A),
                              width: 2.5,
                            ),
                            boxShadow: player.isOnline
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00FB94).withOpacity(0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nickname with status badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              player.nickname,
                              style: TextStyle(
                                color: player.isOnline
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: player.isOnline
                                  ? const Color(0xFF00FB94).withOpacity(0.15)
                                  : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: player.isOnline
                                    ? const Color(0xFF00FB94).withOpacity(0.3)
                                    : Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Text(
                              player.isOnline ? 'ONLINE' : 'OFFLINE',
                              style: TextStyle(
                                color: player.isOnline
                                    ? const Color(0xFF00FB94)
                                    : Colors.white.withOpacity(0.4),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Stats row
                      Row(
                        children: [
                          // Level badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C5CE7), Color(0xFF8B7CF7)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'LVL ${player.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Win rate
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (player.winRate >= 50
                                      ? const Color(0xFF00FB94)
                                      : const Color(0xFFFF6B6B))
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  player.winRate >= 50
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  size: 12,
                                  color: player.winRate >= 50
                                      ? const Color(0xFF00FB94)
                                      : const Color(0xFFFF6B6B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${player.winRate.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: player.winRate >= 50
                                        ? const Color(0xFF00FB94)
                                        : const Color(0xFFFF6B6B),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Total matches
                          Text(
                            '${player.totalMatches} o\'yin',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Challenge button
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: player.hasActiveMatch
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: player.hasActiveMatch ? const Color(0xFF3A3F5A) : null,
                    boxShadow: player.hasActiveMatch
                        ? []
                        : [
                            BoxShadow(
                              color: const Color(0xFFFFB800).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: player.hasActiveMatch
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              _matchmakingBloc
                                  .add(ChallengeSent(opponentId: player.id));
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              player.hasActiveMatch
                                  ? Icons.hourglass_top
                                  : Icons.sports_esports,
                              size: 16,
                              color: player.hasActiveMatch
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              player.hasActiveMatch ? 'BAND' : 'CHALLENGE',
                              style: TextStyle(
                                color: player.hasActiveMatch
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.black87,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMatchFoundDialog(MatchmakingMatchFound state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF00FB94),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'RAQIB TOPILDI!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                    ),
                    child: state.opponent.avatarUrl != null
                        ? ClipOval(
                            child: OptimizedImage(
                              imageUrl: state.opponent.avatarUrl!,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Color(0xFF6C5CE7),
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.opponent.nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Level ${state.opponent.level}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to match room
                  _showSnackBar('O\'yin boshlanmoqda...', Colors.green);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FB94),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'O\'YINNI BOSHLASH',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPendingChallengesDialog(List<PendingChallenge> challenges) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB800).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sports_esports,
                color: Color(0xFFFFB800),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'CHALLENGE KELDI!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return _buildChallengeCard(challenge, dialogContext);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'YOPISH',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(PendingChallenge challenge, BuildContext dialogContext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A2F4A).withOpacity(0.8),
            const Color(0xFF1A1F3A).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFB800).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFB800),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: challenge.challenger.avatarUrl != null
                      ? OptimizedImage(
                          imageUrl: challenge.challenger.avatarUrl!,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          errorWidget: const Icon(
                            Icons.person,
                            color: Colors.white70,
                            size: 24,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Challenger info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.challenger.nickname ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C5CE7).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            challenge.mode.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF00D9FF),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (challenge.betAmount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB800).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  size: 12,
                                  color: Color(0xFFFFB800),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${challenge.betAmount}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFB800),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await ApiService().declineChallenge(challenge.id);
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        _showSnackBar('Challenge rad etildi', Colors.orange);
                      }
                    } catch (e) {
                      _showSnackBar('Xatolik: $e', Colors.red);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B6B),
                    side: const BorderSide(color: Color(0xFFFF6B6B)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'RAD ETISH',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await ApiService().acceptChallenge(challenge.id);
                      if (mounted) {
                        Navigator.pop(dialogContext);
                        _showSnackBar('Challenge qabul qilindi!', Colors.green);
                        // TODO: Navigate to match room
                      }
                    } catch (e) {
                      _showSnackBar('Xatolik: $e', Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FB94),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'QABUL QILISH',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
