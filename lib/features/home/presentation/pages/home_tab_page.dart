import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cyberpitch/core/widgets/optimized_image.dart';
import 'package:cyberpitch/core/widgets/cyberpitch_background.dart';
import 'package:cyberpitch/core/services/api_service.dart';
import 'package:cyberpitch/core/services/onesignal_service.dart';
import '../bloc/home_bloc.dart';
import '../widgets/quick_play_section.dart';
import '../../../chat/presentation/pages/conversations_page.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage>
    with TickerProviderStateMixin {
  int _notificationCount = 0;
  int _unreadMessagesCount = 0;
  int _currentBannerIndex = 0;
  bool _showDailyReward = true;
  late PageController _bannerController;
  Timer? _bannerTimer;
  StreamSubscription<NotificationEvent>? _notificationSubscription;
  late AnimationController _rewardAnimationController;
  late Animation<double> _rewardScaleAnimation;

  // Mock data - keyinroq API dan keladi
  final List<NewsItem> _newsItems = [
    NewsItem(
      id: '1',
      title: 'Haftalik Turnir Boshlandi!',
      subtitle: 'Ishtirok eting va 100,000 coin yuting',
      gradient: [const Color(0xFF6C5CE7), const Color(0xFF00D9FF)],
      icon: Icons.emoji_events,
    ),
    NewsItem(
      id: '2',
      title: '2X XP Weekend',
      subtitle: 'Shanba-Yakshanba barcha o\'yinlarda 2X XP',
      gradient: [const Color(0xFFFF6B6B), const Color(0xFFFFB800)],
      icon: Icons.star,
    ),
    NewsItem(
      id: '3',
      title: 'Yangi Season Boshlandi',
      subtitle: 'Season 2 - Yangi mukofotlar kutmoqda',
      gradient: [const Color(0xFF00FB94), const Color(0xFF00D9FF)],
      icon: Icons.rocket_launch,
    ),
  ];

  final List<DailyChallenge> _dailyChallenges = [
    DailyChallenge(
      id: '1',
      title: '1 ta o\'yin o\'yna',
      reward: 50,
      progress: 1,
      target: 1,
      isCompleted: true,
    ),
    DailyChallenge(
      id: '2',
      title: '3 ta g\'alaba qozon',
      reward: 150,
      progress: 1,
      target: 3,
      isCompleted: false,
    ),
    DailyChallenge(
      id: '3',
      title: 'Do\'stingni taklif qil',
      reward: 100,
      progress: 0,
      target: 1,
      isCompleted: false,
    ),
  ];

  final List<TopPlayer> _topPlayers = [
    TopPlayer(rank: 1, nickname: 'ProGamer', rating: 2847, avatarUrl: null),
    TopPlayer(rank: 2, nickname: 'Legend99', rating: 2756, avatarUrl: null),
    TopPlayer(rank: 3, nickname: 'Champion', rating: 2701, avatarUrl: null),
  ];

  // NEW: Online Friends Mock Data
  final List<OnlineFriend> _onlineFriends = [
    OnlineFriend(
      id: '1',
      nickname: 'Ali_Pro',
      avatarUrl: null,
      status: 'online',
      rating: 2156,
    ),
    OnlineFriend(
      id: '2',
      nickname: 'Sardor99',
      avatarUrl: null,
      status: 'in_game',
      rating: 1987,
    ),
    OnlineFriend(
      id: '3',
      nickname: 'Bobur_FC',
      avatarUrl: null,
      status: 'online',
      rating: 2234,
    ),
    OnlineFriend(
      id: '4',
      nickname: 'Jasur_PES',
      avatarUrl: null,
      status: 'online',
      rating: 1876,
    ),
    OnlineFriend(
      id: '5',
      nickname: 'Shox_Legend',
      avatarUrl: null,
      status: 'in_game',
      rating: 2456,
    ),
  ];

  // NEW: User Rank Data
  final UserRankData _userRank = UserRankData(
    currentRank: 45,
    totalPlayers: 1250,
    rating: 2156,
    ratingChange: 45,
    nextMilestone: 50,
    pointsToNext: 12,
    tier: 'Gold',
    tierIcon: '🥇',
  );

  // NEW: Daily Login Reward Data
  final DailyLoginReward _dailyReward = DailyLoginReward(
    day: 5,
    reward: 100,
    streakBonus: 50,
    isClaimed: false,
    streakDays: [
      StreakDay(day: 1, reward: 20, isClaimed: true, isToday: false),
      StreakDay(day: 2, reward: 30, isClaimed: true, isToday: false),
      StreakDay(day: 3, reward: 50, isClaimed: true, isToday: false),
      StreakDay(day: 4, reward: 75, isClaimed: true, isToday: false),
      StreakDay(day: 5, reward: 100, isClaimed: false, isToday: true),
      StreakDay(day: 6, reward: 150, isClaimed: false, isToday: false),
      StreakDay(day: 7, reward: 300, isClaimed: false, isToday: false),
    ],
  );

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _startBannerTimer();

    // Reward animation
    _rewardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rewardScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _rewardAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    context.read<HomeBloc>().add(const HomeLoadRequested());
    _loadNotificationCount();
    _loadUnreadMessagesCount();

    _notificationSubscription = OneSignalService().onNotificationReceived
        .listen((event) {
          _loadNotificationCount();
          if (event.type == 'chat_message') {
            _loadUnreadMessagesCount();
          }
        });
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final nextPage = (_currentBannerIndex + 1) % _newsItems.length;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _rewardAnimationController.dispose();
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

  void _claimDailyReward() {
    HapticFeedback.heavyImpact();
    setState(() {
      _showDailyReward = false;
    });
    // TODO: API call to claim reward
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.monetization_on, color: Color(0xFFFFB800)),
            const SizedBox(width: 8),
            Text(
              '+${_dailyReward.reward + _dailyReward.streakBonus} coin olindi!',
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1F3A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
                    child: CircularProgressIndicator(color: Color(0xFF00D9FF)),
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
          // Daily Reward Popup
          if (_showDailyReward && !_dailyReward.isClaimed)
            _buildDailyRewardPopup(),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // 1. Live Activity Section
                  _buildLiveActivitySection(data.onlineUsers),
                  const SizedBox(height: 16),

                  // 2. News Banner Slider
                  _buildNewsBanner(),
                  const SizedBox(height: 20),

                  // 3. Your Rank Card (NEW)
                  _buildYourRankCard(),
                  const SizedBox(height: 20),

                  // 4. Quick Play Section
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
                  const SizedBox(height: 20),

                  // 5. Online Friends (NEW)
                  _buildOnlineFriendsSection(),
                  const SizedBox(height: 20),

                  // 6. Daily Challenges
                  _buildDailyChallengesSection(),
                  const SizedBox(height: 20),

                  // 7. Daily Login Streak (NEW - compact version)
                  _buildDailyLoginStreakCompact(),
                  const SizedBox(height: 20),

                  // 8. Top Players
                  _buildTopPlayersSection(),
                  const SizedBox(height: 20),

                  // 9. User Stats Section
                  _buildUserStatsSection(data.stats),
                  const SizedBox(height: 20),

                  // 10. Active Tournaments
                  if (data.tournaments.isNotEmpty) ...[
                    _buildSectionTitle('Aktiv Turnirlar', Icons.emoji_events),
                    const SizedBox(height: 12),
                    _buildTournamentsList(data.tournaments),
                    const SizedBox(height: 20),
                  ],

                  // 11. Recent Matches
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

  // ==================== NEW SECTIONS ====================

  /// Daily Reward Popup (Full Screen Overlay)
  Widget _buildDailyRewardPopup() {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: ScaleTransition(
          scale: _rewardScaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1F3A), Color(0xFF0A0E1A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFFFB800).withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB800).withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showDailyReward = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Gift icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB800), Color(0xFFFF6B6B)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB800).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.card_giftcard,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Kunlik Mukofot!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kun ${_dailyReward.day} — Ketma-ket tashrifingiz uchun!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Streak days
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _dailyReward.streakDays.length,
                    itemBuilder: (context, index) {
                      final day = _dailyReward.streakDays[index];
                      return _buildStreakDayItem(day);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Reward amount
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB800).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFB800).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Color(0xFFFFB800),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '+${_dailyReward.reward}',
                            style: const TextStyle(
                              color: Color(0xFFFFB800),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_dailyReward.streakBonus > 0)
                            Text(
                              '+${_dailyReward.streakBonus} bonus',
                              style: const TextStyle(
                                color: Color(0xFF00FB94),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Claim button
                GestureDetector(
                  onTap: _claimDailyReward,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB800), Color(0xFFFF6B6B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB800).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'OLISH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
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

  Widget _buildStreakDayItem(StreakDay day) {
    final isToday = day.isToday;
    final isClaimed = day.isClaimed;

    return Container(
      width: 45,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isClaimed
                  ? const Color(0xFF00FB94)
                  : isToday
                  ? const Color(0xFFFFB800)
                  : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: isToday && !isClaimed
                  ? Border.all(color: const Color(0xFFFFB800), width: 2)
                  : null,
              boxShadow: isToday
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFB800).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isClaimed
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${day.reward}',
                      style: TextStyle(
                        color: isToday ? Colors.black : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'D${day.day}',
            style: TextStyle(
              color: isToday ? const Color(0xFFFFB800) : Colors.white54,
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Your Rank Card
  Widget _buildYourRankCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/leaderboard');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6C5CE7).withOpacity(0.3),
              const Color(0xFF00D9FF).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Rank badge
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFB800)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB800).withOpacity(0.4),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _userRank.tierIcon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Rank info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_userRank.tier} ',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _userRank.ratingChange >= 0
                                  ? const Color(0xFF00FB94).withOpacity(0.2)
                                  : const Color(0xFFFF6B6B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_userRank.ratingChange >= 0 ? '+' : ''}${_userRank.ratingChange}',
                              style: TextStyle(
                                color: _userRank.ratingChange >= 0
                                    ? const Color(0xFF00FB94)
                                    : const Color(0xFFFF6B6B),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${_userRank.currentRank} / ${_userRank.totalPlayers} o\'yinchi',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_userRank.rating}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'RATING',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress to next milestone
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOP ${_userRank.nextMilestone} ga',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${_userRank.pointsToNext} ball kerak',
                      style: const TextStyle(
                        color: Color(0xFF00D9FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1 - (_userRank.pointsToNext / 50),
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00D9FF),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Online Friends Section
  Widget _buildOnlineFriendsSection() {
    final onlineFriends = _onlineFriends
        .where((f) => f.status != 'offline')
        .toList();

    if (onlineFriends.isEmpty) {
      return const SizedBox.shrink();
    }

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FB94).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people,
                  color: Color(0xFF00FB94),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Online Do\'stlar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${onlineFriends.length} ta do\'st online',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/friends');
                },
                child: const Row(
                  children: [
                    Text(
                      'Barchasi',
                      style: TextStyle(
                        color: Color(0xFF00D9FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF00D9FF),
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Friends horizontal list
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: onlineFriends.length,
              itemBuilder: (context, index) {
                return _buildOnlineFriendItem(onlineFriends[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineFriendItem(OnlineFriend friend) {
    final isInGame = friend.status == 'in_game';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showFriendActionSheet(friend);
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            // Avatar with status
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isInGame
                          ? [const Color(0xFFFFB800), const Color(0xFFFF6B6B)]
                          : [const Color(0xFF00FB94), const Color(0xFF00D9FF)],
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1A1F3A),
                    ),
                    child: friend.avatarUrl != null
                        ? ClipOval(
                            child: OptimizedImage(
                              imageUrl: friend.avatarUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            color: Color(0xFF6C5CE7),
                            size: 24,
                          ),
                  ),
                ),
                // Status indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isInGame
                          ? const Color(0xFFFFB800)
                          : const Color(0xFF00FB94),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1A1F3A),
                        width: 2,
                      ),
                    ),
                    child: isInGame
                        ? const Icon(
                            Icons.sports_esports,
                            color: Colors.black,
                            size: 10,
                          )
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Nickname
            Text(
              friend.nickname,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            // Status text
            Text(
              isInGame ? 'O\'yinda' : 'Online',
              style: TextStyle(
                color: isInGame
                    ? const Color(0xFFFFB800)
                    : const Color(0xFF00FB94),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFriendActionSheet(OnlineFriend friend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1F3A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Friend info
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                    ),
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rating: ${friend.rating}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            _buildActionButton(
              icon: Icons.sports_esports,
              label: 'Challenge yuborish',
              color: const Color(0xFF6C5CE7),
              onTap: () {
                Navigator.pop(context);
                // TODO: Send challenge
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.chat_bubble_outline,
              label: 'Xabar yuborish',
              color: const Color(0xFF00D9FF),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open chat
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.person,
              label: 'Profilni ko\'rish',
              color: const Color(0xFF00FB94),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile/${friend.id}');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Daily Login Streak (Compact Version - in scroll)
  Widget _buildDailyLoginStreakCompact() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFB800).withOpacity(0.15),
            const Color(0xFFFF6B6B).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFFFB800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Kunlik Tashriflar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFFF6B6B),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_dailyReward.day} kun',
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Streak days row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _dailyReward.streakDays.map((day) {
              return _buildCompactStreakDay(day);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStreakDay(StreakDay day) {
    final isToday = day.isToday;
    final isClaimed = day.isClaimed;
    final isFuture = !isClaimed && !isToday;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isClaimed
                ? const Color(0xFF00FB94)
                : isToday
                ? const Color(0xFFFFB800)
                : Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: const Color(0xFFFFB800), width: 2)
                : null,
          ),
          child: Center(
            child: isClaimed
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Icon(
                    isFuture ? Icons.lock : Icons.card_giftcard,
                    color: isToday ? Colors.black : Colors.white38,
                    size: 16,
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'D${day.day}',
          style: TextStyle(
            color: isToday
                ? const Color(0xFFFFB800)
                : isClaimed
                ? const Color(0xFF00FB94)
                : Colors.white38,
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // ==================== EXISTING SECTIONS (kept same) ====================

  Widget _buildLiveActivitySection(int onlineUsers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.2),
            const Color(0xFF00D9FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Color(0xFFFF6B6B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 20, color: Colors.white.withOpacity(0.2)),
          const SizedBox(width: 16),
          const Icon(Icons.people_outline, color: Color(0xFF00FB94), size: 18),
          const SizedBox(width: 6),
          Text(
            '$onlineUsers online',
            style: const TextStyle(
              color: Color(0xFF00FB94),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Icon(Icons.sports_esports, color: Color(0xFF00D9FF), size: 18),
          const SizedBox(width: 6),
          Text(
            '${(onlineUsers * 0.3).toInt()} o\'yin',
            style: const TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsBanner() {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _newsItems.length,
            itemBuilder: (context, index) {
              return _buildBannerItem(_newsItems[index]);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _newsItems.length,
            (index) => Container(
              width: _currentBannerIndex == index ? 20 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? const Color(0xFF00D9FF)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(NewsItem item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: item.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: item.gradient[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: Colors.white, size: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengesSection() {
    final completedCount = _dailyChallenges.where((c) => c.isCompleted).length;
    final totalReward = _dailyChallenges.fold<int>(
      0,
      (sum, c) => sum + c.reward,
    );

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.task_alt,
                  color: Color(0xFFFFB800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Kunlik Vazifalar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FB94).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount/${_dailyChallenges.length}',
                  style: const TextStyle(
                    color: Color(0xFF00FB94),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Jami: $totalReward coin',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_dailyChallenges.length, (index) {
            final challenge = _dailyChallenges[index];
            return _buildChallengeItem(
              challenge,
              index == _dailyChallenges.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(DailyChallenge challenge, bool isLast) {
    final progress = challenge.progress / challenge.target;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: challenge.isCompleted
                  ? const Color(0xFF00FB94)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: challenge.isCompleted
                    ? const Color(0xFF00FB94)
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: challenge.isCompleted
                ? const Icon(Icons.check, color: Colors.black, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: TextStyle(
                    color: challenge.isCompleted
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: challenge.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      challenge.isCompleted
                          ? const Color(0xFF00FB94)
                          : const Color(0xFF6C5CE7),
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Color(0xFFFFB800),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${challenge.reward}',
                  style: const TextStyle(
                    color: Color(0xFFFFB800),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPlayersSection() {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.leaderboard,
                  color: Color(0xFF6C5CE7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Top O\'yinchilar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/leaderboard');
                },
                child: const Row(
                  children: [
                    Text(
                      'Barchasi',
                      style: TextStyle(
                        color: Color(0xFF00D9FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF00D9FF),
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_topPlayers.length, (index) {
            final player = _topPlayers[index];
            return _buildTopPlayerItem(player, index == _topPlayers.length - 1);
          }),
        ],
      ),
    );
  }

  Widget _buildTopPlayerItem(TopPlayer player, bool isLast) {
    final rankColors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };
    final rankIcons = {1: '🥇', 2: '🥈', 3: '🥉'};

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: player.rank == 1
            ? const Color(0xFFFFD700).withOpacity(0.1)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: player.rank == 1
            ? Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Text(
            rankIcons[player.rank] ?? '${player.rank}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  rankColors[player.rank] ?? const Color(0xFF6C5CE7),
                  const Color(0xFF00D9FF),
                ],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1A1F3A),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF6C5CE7),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.nickname,
              style: TextStyle(
                color: player.rank == 1
                    ? const Color(0xFFFFD700)
                    : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  rankColors[player.rank]?.withOpacity(0.15) ??
                  const Color(0xFF6C5CE7).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${player.rating}',
              style: TextStyle(
                color: rankColors[player.rank] ?? const Color(0xFF6C5CE7),
                fontSize: 13,
                fontWeight: FontWeight.bold,
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
            const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 64),
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
    return CyberPitchBackground(
      opacity: 0.3,
    );
  }

  Widget _buildSliverAppBar(HomeUser user) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
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
        Stack(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConversationsPage(),
                  ),
                ).then((_) => _loadUnreadMessagesCount());
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
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
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
        Stack(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context
                    .push('/notifications')
                    .then((_) => _loadNotificationCount());
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
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
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
              _buildStatItem(
                'O\'yinlar',
                stats.totalMatches.toString(),
                const Color(0xFF00D9FF),
              ),
              _buildStatItem(
                'G\'alabalar',
                stats.wins.toString(),
                const Color(0xFF00FB94),
              ),
              _buildStatItem(
                'Mag\'lubiyat',
                stats.losses.toString(),
                const Color(0xFFFF6B6B),
              ),
              _buildStatItem(
                'Durrang',
                stats.draws.toString(),
                const Color(0xFFFFB800),
              ),
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
          return _buildTournamentCard(tournaments[index]);
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
                    color: isFeatured
                        ? Colors.white
                        : Colors.white.withOpacity(0.9),
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
              color: isFeatured
                  ? Colors.white70
                  : Colors.white.withOpacity(0.6),
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
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: resultColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
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
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }
}

// ==================== DATA MODELS ====================

class NewsItem {
  final String id;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final IconData icon;

  NewsItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });
}

class DailyChallenge {
  final String id;
  final String title;
  final int reward;
  final int progress;
  final int target;
  final bool isCompleted;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.reward,
    required this.progress,
    required this.target,
    required this.isCompleted,
  });
}

class TopPlayer {
  final int rank;
  final String nickname;
  final int rating;
  final String? avatarUrl;

  TopPlayer({
    required this.rank,
    required this.nickname,
    required this.rating,
    this.avatarUrl,
  });
}

class OnlineFriend {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final String status; // 'online', 'in_game', 'offline'
  final int rating;

  OnlineFriend({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.status,
    required this.rating,
  });
}

class UserRankData {
  final int currentRank;
  final int totalPlayers;
  final int rating;
  final int ratingChange;
  final int nextMilestone;
  final int pointsToNext;
  final String tier;
  final String tierIcon;

  UserRankData({
    required this.currentRank,
    required this.totalPlayers,
    required this.rating,
    required this.ratingChange,
    required this.nextMilestone,
    required this.pointsToNext,
    required this.tier,
    required this.tierIcon,
  });
}

class DailyLoginReward {
  final int day;
  final int reward;
  final int streakBonus;
  final bool isClaimed;
  final List<StreakDay> streakDays;

  DailyLoginReward({
    required this.day,
    required this.reward,
    required this.streakBonus,
    required this.isClaimed,
    required this.streakDays,
  });
}

class StreakDay {
  final int day;
  final int reward;
  final bool isClaimed;
  final bool isToday;

  StreakDay({
    required this.day,
    required this.reward,
    required this.isClaimed,
    required this.isToday,
  });
}
