import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/onesignal_service.dart';
import '../../../../core/widgets/optimized_image.dart';
import '../../../chat/presentation/pages/chat_page.dart';

class NotificationsScreen extends StatefulWidget {
  final int initialTab;

  const NotificationsScreen({super.key, this.initialTab = 0});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription<NotificationEvent>? _notificationSubscription;

  // Data
  List<PendingChallenge> _challenges = [];
  List<FriendRequest> _friendRequests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _loadData();

    // Real-time notification listener
    _notificationSubscription = OneSignalService().onNotificationReceived.listen((event) {
      // Notification kelganda data ni yangilash
      if (event.type == 'challenge' || event.type == 'friend_request') {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        ApiService().getPendingChallenges(),
        ApiService().getFriendRequests(),
      ]);

      if (mounted) {
        setState(() {
          _challenges = (results[0] as PendingChallengesResponse).challenges;
          _friendRequests = (results[1] as FriendRequestsResponse).requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
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
            child: Column(
              children: [
                _buildAppBar(),
                _buildTabBar(),
                Expanded(
                  child: _isLoading
                      ? _buildLoading()
                      : _error != null
                          ? _buildError()
                          : _buildTabContent(),
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
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Agar pop mumkin bo'lsa pop, aks holda dashboard ga o'tish
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'BILDIRISHNOMALAR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          // Refresh button
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final challengeCount = _challenges.length;
    final friendCount = _friendRequests.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports_esports, size: 18),
                const SizedBox(width: 8),
                const Text('Challenge'),
                if (challengeCount > 0) ...[
                  const SizedBox(width: 6),
                  _buildBadge(challengeCount, const Color(0xFFFFB800)),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 18),
                const SizedBox(width: 8),
                const Text('Do\'stlik'),
                if (friendCount > 0) ...[
                  const SizedBox(width: 6),
                  _buildBadge(friendCount, const Color(0xFF00D9FF)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF00D9FF)),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.withOpacity(0.7), size: 48),
          const SizedBox(height: 16),
          Text(
            'Xatolik yuz berdi',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Qayta urinish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildChallengesTab(),
        _buildFriendRequestsTab(),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // CHALLENGES TAB
  // ════════════════════════════════════════════════════════════

  Widget _buildChallengesTab() {
    if (_challenges.isEmpty) {
      return _buildEmptyState(
        icon: Icons.sports_esports_outlined,
        title: 'Challenge yo\'q',
        subtitle: 'Hozircha sizga challenge kelmagan',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF00D9FF),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _challenges.length,
        itemBuilder: (context, index) => _buildChallengeCard(_challenges[index]),
      ),
    );
  }

  Widget _buildChallengeCard(PendingChallenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A2A3A).withOpacity(0.9),
            const Color(0xFF0F1A2A).withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFB800).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB800).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sports_esports, color: Color(0xFFFFB800), size: 18),
                const SizedBox(width: 8),
                const Text(
                  'CHALLENGE',
                  style: TextStyle(
                    color: Color(0xFFFFB800),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimeAgo(challenge.createdAt),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User row - tappable
                InkWell(
                  onTap: () => context.push('/player-profile/${challenge.challenger.id}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                            ),
                            border: Border.all(
                              color: const Color(0xFFFFB800),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB800).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: challenge.challenger.avatarUrl != null
                                ? OptimizedImage(
                                    imageUrl: challenge.challenger.avatarUrl!,
                                    fit: BoxFit.cover,
                                    width: 60,
                                    height: 60,
                                    errorWidget: const Icon(Icons.person, color: Colors.white70, size: 30),
                                  )
                                : const Icon(Icons.person, color: Colors.white70, size: 30),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      challenge.challenger.nickname ?? 'Unknown',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildInfoChip(
                                    challenge.mode.toUpperCase(),
                                    const Color(0xFF6C5CE7),
                                  ),
                                  if (challenge.betAmount > 0) ...[
                                    const SizedBox(width: 8),
                                    _buildCoinChip(challenge.betAmount),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    // Profil ko'rish
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/player-profile/${challenge.challenger.id}'),
                        icon: const Icon(Icons.person_outline, size: 16),
                        label: const Text('PROFIL'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00D9FF),
                          side: const BorderSide(color: Color(0xFF00D9FF)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Rad etish
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _declineChallenge(challenge),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6B6B),
                          side: const BorderSide(color: Color(0xFFFF6B6B)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'RAD',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Qabul qilish
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptChallenge(challenge),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('QABUL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FB94),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // FRIEND REQUESTS TAB
  // ════════════════════════════════════════════════════════════

  Widget _buildFriendRequestsTab() {
    if (_friendRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_add_outlined,
        title: 'So\'rov yo\'q',
        subtitle: 'Hozircha sizga do\'stlik so\'rovi kelmagan',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF00D9FF),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _friendRequests.length,
        itemBuilder: (context, index) => _buildFriendRequestCard(_friendRequests[index]),
      ),
    );
  }

  Widget _buildFriendRequestCard(FriendRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A2A3A).withOpacity(0.9),
            const Color(0xFF0F1A2A).withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D9FF).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_add, color: Color(0xFF00D9FF), size: 18),
                const SizedBox(width: 8),
                const Text(
                  'DO\'STLIK SO\'ROVI',
                  style: TextStyle(
                    color: Color(0xFF00D9FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimeAgo(DateTime.parse(request.requestedAt)),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // User row - tappable
                InkWell(
                  onTap: () => context.push('/player-profile/${request.id}'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                            ),
                            border: Border.all(
                              color: const Color(0xFF00D9FF),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: request.avatarUrl != null
                                ? OptimizedImage(
                                    imageUrl: request.avatarUrl!,
                                    fit: BoxFit.cover,
                                    width: 60,
                                    height: 60,
                                    errorWidget: const Icon(Icons.person, color: Colors.white70, size: 30),
                                  )
                                : const Icon(Icons.person, color: Colors.white70, size: 30),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      request.nickname,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildInfoChip('LVL ${request.level}', const Color(0xFF6C5CE7)),
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    '${request.winRate.toStringAsFixed(0)}% win',
                                    request.winRate >= 50
                                        ? const Color(0xFF00FB94)
                                        : const Color(0xFFFF6B6B),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    // Profil ko'rish
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/player-profile/${request.id}'),
                        icon: const Icon(Icons.person_outline, size: 16),
                        label: const Text('PROFIL'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00D9FF),
                          side: const BorderSide(color: Color(0xFF00D9FF)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Rad etish
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _declineFriendRequest(request),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF6B6B),
                          side: const BorderSide(color: Color(0xFFFF6B6B)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'RAD',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Qabul qilish
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptFriendRequest(request),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('QABUL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FB94),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.3), size: 50),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCoinChip(int amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB800).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, size: 14, color: Color(0xFFFFB800)),
          const SizedBox(width: 4),
          Text(
            '$amount',
            style: const TextStyle(
              color: Color(0xFFFFB800),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hozirgina';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} daqiqa oldin';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} soat oldin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} kun oldin';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  // ════════════════════════════════════════════════════════════
  // ACTIONS
  // ════════════════════════════════════════════════════════════

  Future<void> _acceptChallenge(PendingChallenge challenge) async {
    HapticFeedback.mediumImpact();
    try {
      await ApiService().acceptChallenge(challenge.id);
      _showSnackBar('Challenge qabul qilindi!', const Color(0xFF00FB94));
      _loadData();
      // TODO: Navigate to match room
    } catch (e) {
      _showSnackBar('Xatolik: $e', const Color(0xFFFF6B6B));
    }
  }

  Future<void> _declineChallenge(PendingChallenge challenge) async {
    HapticFeedback.lightImpact();
    try {
      await ApiService().declineChallenge(challenge.id);
      _showSnackBar('Challenge rad etildi', const Color(0xFFFFB800));
      setState(() {
        _challenges.remove(challenge);
      });
    } catch (e) {
      _showSnackBar('Xatolik: $e', const Color(0xFFFF6B6B));
    }
  }

  Future<void> _acceptFriendRequest(FriendRequest request) async {
    HapticFeedback.mediumImpact();
    try {
      await ApiService().acceptFriendRequest(request.id);
      _showSnackBar('Do\'stlik qabul qilindi!', const Color(0xFF00FB94));
      setState(() {
        _friendRequests.remove(request);
      });

      // Do'stlik qabul qilingandan keyin chat sahifasiga o'tish
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              otherUserId: request.id,
              otherUserNickname: request.nickname,
              otherUserAvatar: request.avatarUrl,
            ),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Xatolik: $e', const Color(0xFFFF6B6B));
    }
  }

  Future<void> _declineFriendRequest(FriendRequest request) async {
    HapticFeedback.lightImpact();
    try {
      await ApiService().declineFriendRequest(request.id);
      _showSnackBar('So\'rov rad etildi', const Color(0xFFFFB800));
      setState(() {
        _friendRequests.remove(request);
      });
    } catch (e) {
      _showSnackBar('Xatolik: $e', const Color(0xFFFF6B6B));
    }
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
}
