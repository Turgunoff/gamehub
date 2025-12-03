import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/optimized_image.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../pages/friends_page.dart';

/// Profile ekranidagi do'stlar section widget'i
/// Faqat 5 ta do'stni ko'rsatadi, qolganlari uchun "Barchasi" tugmasi
class ProfileFriendsSection extends StatefulWidget {
  const ProfileFriendsSection({super.key});

  @override
  State<ProfileFriendsSection> createState() => _ProfileFriendsSectionState();
}

class _ProfileFriendsSectionState extends State<ProfileFriendsSection> {
  static const int _maxDisplayCount = 5;

  List<FriendInfo> _friends = [];
  int _onlineCount = 0;
  int _totalCount = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService().getFriends();
      if (mounted) {
        setState(() {
          _totalCount = response.friends.length;
          _onlineCount = response.onlineCount;
          // Faqat birinchi 5 tasini olish
          _friends = response.friends.take(_maxDisplayCount).toList();
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
              if (_totalCount > 0)
                GestureDetector(
                  onTap: _openFriendsPage,
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
                          'Barchasi ($_totalCount)',
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
          _isLoading
              ? _buildLoading()
              : _error != null
                  ? _buildError()
                  : _friends.isEmpty
                      ? _buildEmpty()
                      : _buildFriendsList(),
        ],
      ),
    );
  }

  void _openFriendsPage() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FriendsPage()),
    );
  }

  Widget _buildLoading() {
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

  Widget _buildError() {
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

  Widget _buildEmpty() {
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
          return _FriendCard(
            friend: _friends[index],
            onTap: () => _openFriendProfile(_friends[index]),
            onChatTap: () => _openChat(_friends[index]),
          );
        },
      ),
    );
  }

  void _openFriendProfile(FriendInfo friend) {
    HapticFeedback.lightImpact();
    context.push('/player-profile/${friend.id}');
  }

  void _openChat(FriendInfo friend) {
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
  }
}

/// Do'st kartasi widget'i
class _FriendCard extends StatelessWidget {
  final FriendInfo friend;
  final VoidCallback onTap;
  final VoidCallback onChatTap;

  const _FriendCard({
    required this.friend,
    required this.onTap,
    required this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                            errorWidget: _buildDefaultAvatar(),
                          )
                        : _buildDefaultAvatar(),
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
              onTap: onChatTap,
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

  Widget _buildDefaultAvatar() {
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
}
