import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/optimized_image.dart';
import '../../../chat/presentation/pages/chat_page.dart';

class PlayerProfileScreen extends StatefulWidget {
  final String playerId;

  const PlayerProfileScreen({
    super.key,
    required this.playerId,
  });

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  PlayerProfile? _profile;
  bool _isLoading = true;
  String? _error;

  // Alohida loading state'lar
  bool _isFriendLoading = false;
  bool _isChallengeLoading = false;
  bool _isChallengeSent = false; // Challenge yuborilganmi

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await ApiService().getPlayerProfile(widget.playerId);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isChallengeSent = profile.hasPendingChallenge;
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
                Expanded(
                  child: _isLoading
                      ? _buildLoading()
                      : _error != null
                          ? _buildError()
                          : _buildContent(),
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
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'O\'YINCHI PROFILI',
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
          Icon(
            Icons.error_outline,
            color: Colors.red.withOpacity(0.7),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'Xatolik yuz berdi',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadProfile,
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

  Widget _buildContent() {
    final profile = _profile!;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: const Color(0xFF00D9FF),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(profile),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(profile),
            const SizedBox(height: 24),

            // Stats Card
            _buildStatsCard(profile),
            const SizedBox(height: 20),

            // Head-to-Head
            if (profile.headToHead.totalMatches > 0) ...[
              _buildHeadToHead(profile),
              const SizedBox(height: 20),
            ],

            // Game Info
            _buildGameInfo(profile),
            const SizedBox(height: 20),

            // Social Links
            if (_hasSocialLinks(profile)) ...[
              _buildSocialLinks(profile),
              const SizedBox(height: 20),
            ],

            // Recent Matches
            if (profile.recentMatches.isNotEmpty)
              _buildRecentMatches(profile),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(PlayerProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: profile.isOnline
              ? [
                  const Color(0xFF1A2A3A).withOpacity(0.9),
                  const Color(0xFF0F1A2A).withOpacity(0.95),
                ]
              : [
                  const Color(0xFF1A1F2E).withOpacity(0.8),
                  const Color(0xFF0F1422).withOpacity(0.9),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: profile.isOnline
              ? const Color(0xFF00FB94).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: profile.isOnline
            ? [
                BoxShadow(
                  color: const Color(0xFF00FB94).withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: profile.isOnline
                        ? [const Color(0xFF6C5CE7), const Color(0xFF00D9FF)]
                        : [const Color(0xFF3A3F5A), const Color(0xFF2A2F4A)],
                  ),
                  border: Border.all(
                    color: profile.isOnline
                        ? const Color(0xFF00FB94)
                        : Colors.white.withOpacity(0.2),
                    width: 3,
                  ),
                  boxShadow: profile.isOnline
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00FB94).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: ClipOval(
                  child: profile.avatarUrl != null
                      ? OptimizedImage(
                          imageUrl: profile.avatarUrl!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorWidget: const Icon(
                            Icons.person,
                            color: Colors.white70,
                            size: 60,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 60,
                        ),
                ),
              ),
              // Online indicator
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: profile.isOnline
                        ? const Color(0xFF00FB94)
                        : const Color(0xFF6B7280),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0A0E1A),
                      width: 3,
                    ),
                    boxShadow: profile.isOnline
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00FB94).withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                ),
              ),
              // Verified badge
              if (profile.isVerified)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00D9FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Nickname and badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  profile.nickname,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (profile.isPro) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (profile.fullName != null) ...[
            const SizedBox(height: 4),
            Text(
              profile.fullName!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Level and status badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF8B7CF7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'LEVEL ${profile.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: profile.isOnline
                      ? const Color(0xFF00FB94).withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: profile.isOnline
                        ? const Color(0xFF00FB94).withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  profile.isOnline ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    color: profile.isOnline
                        ? const Color(0xFF00FB94)
                        : Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              profile.bio!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Region and member since
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (profile.region != null) ...[
                Icon(Icons.location_on, color: Colors.white.withOpacity(0.5), size: 16),
                const SizedBox(width: 4),
                Text(
                  profile.region!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.5), size: 14),
              const SizedBox(width: 4),
              Text(
                'A\'zo: ${profile.memberSince}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PlayerProfile profile) {
    // O'zining profilimi tekshirish
    if (profile.friendshipStatus == 'self') {
      return const SizedBox.shrink();
    }

    final isFriend = profile.friendshipStatus == 'friends';

    return Column(
      children: [
        // 1-qator: Do'stlik va Xabar
        Row(
          children: [
            // Do'stlik button
            Expanded(
              child: _buildFriendButton(profile),
            ),
            // Xabar button - faqat do'stlar uchun
            if (isFriend) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'XABAR',
                  gradient: const [Color(0xFF00D9FF), Color(0xFF6C5CE7)],
                  onTap: () => _openChat(profile),
                ),
              ),
            ],
          ],
        ),

        // 2-qator: Challenge (katta button) - faqat yuborilmagan bo'lsa
        if (!_isChallengeSent) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildChallengeButton(
              onTap: () => _sendChallenge(profile),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChallengeButton({VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB800).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isChallengeLoading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isChallengeLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.black,
                    ),
                  )
                else
                  const Icon(
                    Icons.sports_esports,
                    color: Colors.black,
                    size: 24,
                  ),
                const SizedBox(width: 10),
                const Text(
                  'O\'YIN TAKLIF QILISH',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendButton(PlayerProfile profile) {
    switch (profile.friendshipStatus) {
      case 'friends':
        return _buildActionButton(
          icon: Icons.person_remove,
          label: 'DO\'ST',
          gradient: const [Color(0xFF00FB94), Color(0xFF00D9A5)],
          onTap: () => _showRemoveFriendDialog(profile),
          isLoading: _isFriendLoading,
        );
      case 'request_sent':
        return _buildActionButton(
          icon: Icons.hourglass_top,
          label: 'YUBORILDI',
          gradient: const [Color(0xFF6B7280), Color(0xFF4B5563)],
          onTap: null,
          isLoading: false,
        );
      case 'request_received':
        return _buildActionButton(
          icon: Icons.person_add,
          label: 'QABUL QILISH',
          gradient: const [Color(0xFF00D9FF), Color(0xFF6C5CE7)],
          onTap: () => _acceptFriendRequest(profile),
          isLoading: _isFriendLoading,
        );
      case 'blocked':
        return _buildActionButton(
          icon: Icons.block,
          label: 'BLOKLANGAN',
          gradient: const [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
          onTap: null,
          isLoading: false,
        );
      default: // 'none'
        return _buildActionButton(
          icon: Icons.person_add,
          label: 'DO\'ST QO\'SHISH',
          gradient: const [Color(0xFF6C5CE7), Color(0xFF8B7CF7)],
          onTap: () => _sendFriendRequest(profile),
          isLoading: _isFriendLoading,
        );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: onTap != null ? LinearGradient(colors: gradient) : null,
        color: onTap == null ? const Color(0xFF3A3F5A) : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: onTap != null
            ? [
                BoxShadow(
                  color: gradient.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLoading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: onTap != null ? Colors.white : Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: onTap != null ? Colors.white : Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(PlayerProfile profile) {
    final stats = profile.stats;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
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
                'STATISTIKA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main stats row
          Row(
            children: [
              _buildStatItem('O\'yinlar', '${stats.totalMatches}', Colors.white),
              _buildStatItem('G\'alabalar', '${stats.wins}', const Color(0xFF00FB94)),
              _buildStatItem('Mag\'lubiyat', '${stats.losses}', const Color(0xFFFF6B6B)),
              _buildStatItem('Durrang', '${stats.draws}', const Color(0xFFFFB800)),
            ],
          ),
          const SizedBox(height: 20),

          // Win rate progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Win Rate',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${stats.winRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: stats.winRate >= 50
                          ? const Color(0xFF00FB94)
                          : const Color(0xFFFF6B6B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: stats.winRate / 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(
                    stats.winRate >= 50
                        ? const Color(0xFF00FB94)
                        : const Color(0xFFFF6B6B),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tournaments
          Row(
            children: [
              Expanded(
                child: _buildTournamentStat(
                  'Turnirlar',
                  '${stats.tournamentsPlayed}',
                  Icons.emoji_events_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTournamentStat(
                  'G\'oliblik',
                  '${stats.tournamentsWon}',
                  Icons.emoji_events,
                ),
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
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFB800), size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeadToHead(PlayerProfile profile) {
    final h2h = profile.headToHead;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.2),
            const Color(0xFF00D9FF).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, color: Color(0xFF6C5CE7), size: 20),
              const SizedBox(width: 8),
              const Text(
                'SIZ VS ULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // H2H Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildH2HStat('G\'alabalar', '${h2h.wins}', const Color(0xFF00FB94)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${h2h.totalMatches} o\'yin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildH2HStat('Mag\'lubiyat', '${h2h.losses}', const Color(0xFFFF6B6B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildH2HStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGameInfo(PlayerProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_soccer, color: Color(0xFF00D9FF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'O\'YIN MA\'LUMOTLARI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid of info
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (profile.teamStrength != null)
                _buildInfoChip(Icons.fitness_center, 'Kuch: ${profile.teamStrength}'),
              if (profile.favoriteTeam != null)
                _buildInfoChip(Icons.favorite, profile.favoriteTeam!),
              if (profile.playStyle != null)
                _buildInfoChip(Icons.style, _formatPlayStyle(profile.playStyle!)),
              if (profile.preferredFormation != null)
                _buildInfoChip(Icons.grid_3x3, profile.preferredFormation!),
              if (profile.availableHours != null)
                _buildInfoChip(Icons.schedule, profile.availableHours!),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPlayStyle(String style) {
    switch (style.toLowerCase()) {
      case 'attacking':
        return 'Hujumchi';
      case 'defensive':
        return 'Himoyachi';
      case 'balanced':
        return 'Muvozanatli';
      default:
        return style;
    }
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF00D9FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00D9FF), size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasSocialLinks(PlayerProfile profile) {
    return profile.telegram != null ||
        profile.instagram != null ||
        profile.discord != null;
  }

  Widget _buildSocialLinks(PlayerProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, color: Color(0xFF00D9FF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'IJTIMOIY TARMOQLAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (profile.telegram != null)
                _buildSocialChip(
                  'Telegram',
                  profile.telegram!,
                  const Color(0xFF0088CC),
                ),
              if (profile.instagram != null)
                _buildSocialChip(
                  'Instagram',
                  profile.instagram!,
                  const Color(0xFFE4405F),
                ),
              if (profile.discord != null)
                _buildSocialChip(
                  'Discord',
                  profile.discord!,
                  const Color(0xFF5865F2),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialChip(String platform, String username, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            username,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMatches(PlayerProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFF00D9FF), size: 20),
              const SizedBox(width: 8),
              const Text(
                'SO\'NGI O\'YINLAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ...profile.recentMatches.take(5).map((match) => _buildMatchItem(match)),
        ],
      ),
    );
  }

  Widget _buildMatchItem(RecentMatch match) {
    Color resultColor;
    String resultText;

    switch (match.result.toLowerCase()) {
      case 'win':
        resultColor = const Color(0xFF00FB94);
        resultText = 'G\'ALABA';
        break;
      case 'loss':
        resultColor = const Color(0xFFFF6B6B);
        resultText = 'MAG\'LUBIYAT';
        break;
      default:
        resultColor = const Color(0xFFFFB800);
        resultText = 'DURRANG';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: resultColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: resultColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Result indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: resultColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),

          // Match info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'vs ${match.opponent.nickname}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  match.mode.toUpperCase(),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              match.score,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Result
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              resultText,
              style: TextStyle(
                color: resultColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ACTIONS
  // ════════════════════════════════════════════════════════════

  void _openChat(PlayerProfile profile) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          otherUserId: profile.id,
          otherUserNickname: profile.nickname,
          otherUserAvatar: profile.avatarUrl,
        ),
      ),
    );
  }

  Future<void> _sendChallenge(PlayerProfile profile) async {
    HapticFeedback.mediumImpact();
    try {
      setState(() => _isChallengeLoading = true);
      await ApiService().sendChallenge(opponentId: profile.id);
      if (mounted) {
        setState(() => _isChallengeSent = true);
        _showSnackBar('O\'yin taklifi yuborildi!', const Color(0xFF00FB94));
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Xatolik: $e', const Color(0xFFFF6B6B));
      }
    } finally {
      if (mounted) {
        setState(() => _isChallengeLoading = false);
      }
    }
  }

  Future<void> _sendFriendRequest(PlayerProfile profile) async {
    HapticFeedback.lightImpact();
    try {
      setState(() => _isFriendLoading = true);
      await ApiService().sendFriendRequest(profile.id);
      if (mounted) {
        _showSnackBar('Do\'stlik so\'rovi yuborildi!', const Color(0xFF00FB94));
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Xatolik: $e', const Color(0xFFFF6B6B));
      }
    } finally {
      if (mounted) {
        setState(() => _isFriendLoading = false);
      }
    }
  }

  Future<void> _acceptFriendRequest(PlayerProfile profile) async {
    HapticFeedback.lightImpact();
    try {
      setState(() => _isFriendLoading = true);
      await ApiService().acceptFriendRequest(profile.id);
      if (mounted) {
        _showSnackBar('Do\'stlik qabul qilindi!', const Color(0xFF00FB94));
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Xatolik: $e', const Color(0xFFFF6B6B));
      }
    } finally {
      if (mounted) {
        setState(() => _isFriendLoading = false);
      }
    }
  }

  void _showRemoveFriendDialog(PlayerProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Do\'stni o\'chirish',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '${profile.nickname}ni do\'stlar ro\'yxatidan o\'chirmoqchimisiz?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'BEKOR',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFriend(profile);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
            ),
            child: const Text('O\'CHIRISH'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFriend(PlayerProfile profile) async {
    try {
      setState(() => _isFriendLoading = true);
      await ApiService().removeFriend(profile.id);
      if (mounted) {
        _showSnackBar('Do\'stlikdan chiqarildi', const Color(0xFFFFB800));
        _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Xatolik: $e', const Color(0xFFFF6B6B));
      }
    } finally {
      if (mounted) {
        setState(() => _isFriendLoading = false);
      }
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
