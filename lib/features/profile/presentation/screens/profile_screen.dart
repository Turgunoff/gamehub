import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/profile_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/optimized_image.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../pages/friends_page.dart';

/// Profil ekrani
///
/// Foydalanuvchi profili, statistikasi va yutuqlari ko'rsatiladi.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  // Friends section state
  List<FriendInfo> _friends = [];
  int _onlineCount = 0;
  int _totalFriendsCount = 0;
  bool _isFriendsLoading = true;
  String? _friendsError;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _loadProfile();
    _loadFriends();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll listener - parallax effekt uchun
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (mounted) {
        setState(() => _scrollOffset = _scrollController.offset);
      }
    });
  }

  /// Profilni yuklash
  void _loadProfile() {
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  /// Do'stlarni yuklash
  Future<void> _loadFriends() async {
    setState(() {
      _isFriendsLoading = true;
      _friendsError = null;
    });

    try {
      final response = await ApiService().getFriends();
      if (mounted) {
        setState(() {
          _totalFriendsCount = response.friends.length;
          _onlineCount = response.onlineCount;
          _friends = response.friends.take(5).toList();
          _isFriendsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _friendsError = e.toString();
          _isFriendsLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = _getUser(state);
        final isLoading = state is ProfileLoading;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Background
              _buildBackground(),

              // Main Content
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  _buildAppBar(user),

                  // Content
                  SliverToBoxAdapter(
                    child: isLoading
                        ? _buildLoadingIndicator()
                        : _buildContent(user),
                  ),
                ],
              ),

              // Floating Edit Button
              _buildFloatingEditButton(),
            ],
          ),
        );
      },
    );
  }

  /// Userni state dan olish
  UserMeModel? _getUser(ProfileState state) {
    if (state is ProfileLoaded) return state.user;
    if (state is ProfileUpdating) return state.user;
    return null;
  }

  /// Loading indicator
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(50),
        child: CircularProgressIndicator(
          color: Color(0xFF6C5CE7),
        ),
      ),
    );
  }

  /// Asosiy kontent
  Widget _buildContent(UserMeModel? user) {
    return Column(
      children: [
        // Statistika
        _buildStatsSection(user),

        // PES ma'lumotlari
        _buildPESInfoCard(user),

        // Do'stlar
        const SizedBox(height: 24),
        _buildFriendsSection(),

        // Grafik
        _buildPerformanceChart(),

        // Yutuqlar
        _buildAchievementsSection(),

        // So'nggi faoliyat
        _buildRecentActivity(),

        // Pastki joy
        const SizedBox(height: 100),
      ],
    );
  }

  /// Sozlamalarga o'tish
  void _navigateToSettings(BuildContext context) {
    HapticFeedback.lightImpact();
    context.push('/settings');
  }

  // ══════════════════════════════════════════════════════════
  // BACKGROUND
  // ══════════════════════════════════════════════════════════

  Widget _buildBackground() {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0E1A),
                Color(0xFF1A1F3A),
                Color(0xFF0A0E1A),
              ],
            ),
          ),
        ),

        // Mesh Pattern
        CustomPaint(
          painter: _MeshPatternPainter(),
          child: Container(),
        ),

        // Gradient Overlays
        _buildGradientOverlay(
          top: 100,
          left: 50,
          size: 200,
          color: const Color(0xFF00D9FF),
        ),
        _buildGradientOverlay(
          top: 300,
          right: 50,
          size: 150,
          color: const Color(0xFF6C5CE7),
        ),
      ],
    );
  }

  Widget _buildGradientOverlay({
    double? top,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.15),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // APP BAR
  // ══════════════════════════════════════════════════════════

  Widget _buildAppBar(UserMeModel? user) {
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
                child: CustomPaint(painter: _HexagonPatternPainter()),
              ),
            ),

            // Profile Header
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: _buildProfileHeader(user),
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
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: const Icon(Icons.settings, size: 20),
          ),
          onPressed: () => _navigateToSettings(context),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // PROFILE HEADER
  // ══════════════════════════════════════════════════════════

  Widget _buildProfileHeader(UserMeModel? user) {
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

  // ══════════════════════════════════════════════════════════
  // FLOATING EDIT BUTTON
  // ══════════════════════════════════════════════════════════

  Widget _buildFloatingEditButton() {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.push('/edit-profile');
          },
          backgroundColor: const Color(0xFF6C5CE7),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STATS SECTION
  // ══════════════════════════════════════════════════════════

  Widget _buildStatsSection(UserMeModel? user) {
    final wins = user?.stats?.wins ?? 0;
    final totalMatches = user?.stats?.totalMatches ?? 0;
    final winRate = user?.stats?.winRate ?? 0.0;
    final level = user?.level ?? 1;

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
                  value: wins.toString(),
                  color: const Color(0xFFFFB800),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.sports_esports,
                  title: 'MATCHES',
                  value: totalMatches.toString(),
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
                  value: '${winRate.toStringAsFixed(0)}%',
                  color: const Color(0xFF00FB94),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.star,
                  title: 'LEVEL',
                  value: level.toString(),
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

  // ══════════════════════════════════════════════════════════
  // PES INFO CARD
  // ══════════════════════════════════════════════════════════

  Widget _buildPESInfoCard(UserMeModel? user) {
    final pesId = user?.profile?.pesId ?? '-';
    final teamStrength = user?.profile?.teamStrength;

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
                    // PES ID Row
                    _buildPESIDRow(pesId),
                    const SizedBox(height: 20),
                    Container(height: 1, color: Colors.white.withOpacity(0.1)),
                    const SizedBox(height: 20),
                    // Team Strength Row
                    _buildTeamStrengthRow(teamStrength),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPESIDRow(String pesId) {
    return Row(
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
              Text(
                pesId,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        if (pesId != '-')
          IconButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Clipboard.setData(ClipboardData(text: pesId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('PES ID nusxalandi'),
                  backgroundColor: const Color(0xFF1A1F3A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.copy,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildTeamStrengthRow(int? teamStrength) {
    final strengthValue = teamStrength != null
        ? _formatNumber(teamStrength)
        : '-';

    return Row(
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
              Text(
                strengthValue,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K'.replaceAll('.', ',');
    }
    return number.toString();
  }

  // ══════════════════════════════════════════════════════════
  // FRIENDS SECTION
  // ══════════════════════════════════════════════════════════

  Widget _buildFriendsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'DO\'STLAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FB94).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$_onlineCount online',
                      style: const TextStyle(
                        color: Color(0xFF00FB94),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // "Barchasi" tugmasi
              if (_totalFriendsCount > 0)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FriendsPage()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Barchasi ($_totalFriendsCount)',
                          style: const TextStyle(
                            color: Color(0xFF6C5CE7),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Color(0xFF6C5CE7),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          _isFriendsLoading
              ? _buildFriendsLoading()
              : _friendsError != null
                  ? _buildFriendsError()
                  : _friends.isEmpty
                      ? _buildFriendsEmpty()
                      : _buildFriendsList(),
        ],
      ),
    );
  }

  Widget _buildFriendsLoading() {
    return const SizedBox(
      height: 100,
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C5CE7),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildFriendsError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Xatolik yuz berdi',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: _loadFriends,
            child: const Text('Qayta', style: TextStyle(color: Color(0xFF6C5CE7))),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsEmpty() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            color: Colors.white.withOpacity(0.3),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Hali do\'stlar yo\'q',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'O\'yinchilar profilidan do\'st qo\'shing',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          return _buildFriendCard(_friends[index]);
        },
      ),
    );
  }

  Widget _buildFriendCard(FriendInfo friend) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/player-profile/${friend.id}');
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              friend.isOnline
                  ? const Color(0xFF00FB94).withOpacity(0.15)
                  : const Color(0xFF6C5CE7).withOpacity(0.15),
              const Color(0xFF00D9FF).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: friend.isOnline
                ? const Color(0xFF00FB94).withOpacity(0.3)
                : const Color(0xFF6C5CE7).withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                    ),
                    border: Border.all(
                      color: friend.isOnline
                          ? const Color(0xFF00FB94)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: friend.avatarUrl != null
                        ? OptimizedImage(
                            imageUrl: friend.avatarUrl!,
                            fit: BoxFit.cover,
                            width: 44,
                            height: 44,
                            errorWidget: _buildDefaultFriendAvatar(friend),
                          )
                        : _buildDefaultFriendAvatar(friend),
                  ),
                ),
                // Online indicator
                if (friend.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FB94),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0A0E1A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Nickname
            Text(
              friend.nickname,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Level
            Text(
              'LVL ${friend.level}',
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 4),

            // Chat button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      otherUserId: friend.id,
                      otherUserNickname: friend.nickname,
                      otherUserAvatar: friend.avatarUrl,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 10, color: Color(0xFF00D9FF)),
                    SizedBox(width: 3),
                    Text(
                      'Chat',
                      style: TextStyle(
                        color: Color(0xFF00D9FF),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultFriendAvatar(FriendInfo friend) {
    return Center(
      child: Text(
        friend.nickname.isNotEmpty ? friend.nickname[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // PERFORMANCE CHART
  // ══════════════════════════════════════════════════════════

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
                painter: _PerformanceChartPainter(),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ACHIEVEMENTS SECTION
  // ══════════════════════════════════════════════════════════

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
                return _buildAchievementCard(
                  icon: achievement['icon']!,
                  name: achievement['name']!,
                  description: achievement['desc']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard({
    required String icon,
    required String name,
    required String description,
  }) {
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
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 6),
          Text(
            name,
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
            description,
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
  }

  // ══════════════════════════════════════════════════════════
  // RECENT ACTIVITY
  // ══════════════════════════════════════════════════════════

  Widget _buildRecentActivity() {
    final activities = [
      {'title': 'Victory vs ProPlayer', 'time': '1 hours ago', 'points': '+25', 'color': Colors.green, 'icon': Icons.emoji_events},
      {'title': 'Tournament Started', 'time': '2 hours ago', 'points': '0', 'color': Colors.orange, 'icon': Icons.sports_esports},
      {'title': 'Defeat vs Champion', 'time': '3 hours ago', 'points': '-15', 'color': Colors.red, 'icon': Icons.close},
    ];

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
          ...activities.map((activity) => _buildActivityItem(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
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
                colors: [
                  activity['color'] as Color,
                  (activity['color'] as Color).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['points'] as String,
            style: TextStyle(
              color: activity['color'] as Color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ══════════════════════════════════════════════════════════

/// Mesh pattern painter
class _MeshPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    // Gradient circles
    final circles = [
      _CircleConfig(
        offset: Offset(size.width * 0.3, size.height * 0.2),
        radius: 150,
        color: const Color(0xFF6C5CE7),
      ),
      _CircleConfig(
        offset: Offset(size.width * 0.7, size.height * 0.4),
        radius: 120,
        color: const Color(0xFF00D9FF),
      ),
      _CircleConfig(
        offset: Offset(size.width * 0.5, size.height * 0.6),
        radius: 100,
        color: const Color(0xFFFFB800),
      ),
    ];

    for (final circle in circles) {
      paint.shader = RadialGradient(
        colors: [circle.color.withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromCircle(center: circle.offset, radius: circle.radius));
      canvas.drawCircle(circle.offset, circle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircleConfig {
  final Offset offset;
  final double radius;
  final Color color;

  _CircleConfig({
    required this.offset,
    required this.radius,
    required this.color,
  });
}

/// Hexagon pattern painter
class _HexagonPatternPainter extends CustomPainter {
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
        final centerY = row * hexSize * math.sqrt(3) +
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

/// Performance chart painter
class _PerformanceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF00D9FF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Mock data points
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width, size.height * 0.35),
    ];

    // Draw filled area
    final path = Path();
    path.moveTo(points[0].dx, size.height);
    for (var point in points) {
      path.lineTo(point.dx, point.dy);
    }
    path.lineTo(points.last.dx, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF00D9FF)
      ..style = PaintingStyle.fill;

    for (var point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
