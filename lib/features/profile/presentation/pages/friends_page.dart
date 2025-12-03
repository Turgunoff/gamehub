import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/optimized_image.dart';
import '../../../chat/presentation/pages/chat_page.dart';

/// Do'stlar sahifasi - barcha do'stlarni ko'rsatadi
class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<FriendInfo> _friends = [];
  int _total = 0;
  int _onlineCount = 0;
  bool _isLoading = true;
  String? _error;
  String _filter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService().getFriends(filter: _filter);
      if (mounted) {
        setState(() {
          _friends = response.friends;
          _total = response.total;
          _onlineCount = response.onlineCount;
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

  List<FriendInfo> get _filteredFriends {
    if (_searchQuery.isEmpty) return _friends;
    return _friends
        .where((f) => f.nickname.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
                _buildSearchAndFilter(),
                Expanded(
                  child: _isLoading
                      ? _buildLoading()
                      : _error != null
                          ? _buildError()
                          : _filteredFriends.isEmpty
                              ? _buildEmpty()
                              : _buildFriendsList(),
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
            'DO\'STLAR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 12),
          // Stats badges
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_total',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00FB94).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                  '$_onlineCount',
                  style: const TextStyle(
                    color: Color(0xFF00FB94),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadFriends,
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Do\'st qidirish...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),

          // Filter tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _buildFilterTab('Hammasi', 'all')),
                Expanded(child: _buildFilterTab('Online', 'online')),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () {
        if (_filter != value) {
          HapticFeedback.lightImpact();
          setState(() => _filter = value);
          _loadFriends();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.withOpacity(0.7), size: 64),
          const SizedBox(height: 16),
          Text(
            'Xatolik yuz berdi',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadFriends,
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty
                ? Icons.search_off
                : _filter == 'online'
                    ? Icons.wifi_off
                    : Icons.people_outline,
            color: Colors.white.withOpacity(0.3),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Hech narsa topilmadi'
                : _filter == 'online'
                    ? 'Online do\'st yo\'q'
                    : 'Hali do\'stlar yo\'q',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          if (_searchQuery.isEmpty && _filter == 'all') ...[
            const SizedBox(height: 8),
            Text(
              'O\'yinchilar profilidan do\'st qo\'shing',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    return RefreshIndicator(
      onRefresh: _loadFriends,
      color: const Color(0xFF6C5CE7),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredFriends.length,
        itemBuilder: (context, index) {
          return _FriendListTile(
            friend: _filteredFriends[index],
            onTap: () => _openProfile(_filteredFriends[index]),
            onChatTap: () => _openChat(_filteredFriends[index]),
            onRemoveTap: () => _showRemoveFriendDialog(_filteredFriends[index]),
          );
        },
      ),
    );
  }

  void _openProfile(FriendInfo friend) {
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

  void _showRemoveFriendDialog(FriendInfo friend) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Do\'stni o\'chirish', style: TextStyle(color: Colors.white)),
        content: Text(
          '${friend.nickname}ni do\'stlar ro\'yxatidan o\'chirmoqchimisiz?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('BEKOR', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFriend(friend);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
            child: const Text('O\'CHIRISH'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFriend(FriendInfo friend) async {
    try {
      await ApiService().removeFriend(friend.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Do\'stlikdan chiqarildi'),
            backgroundColor: Color(0xFFFFB800),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadFriends();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Do'st list tile widget
class _FriendListTile extends StatelessWidget {
  final FriendInfo friend;
  final VoidCallback onTap;
  final VoidCallback onChatTap;
  final VoidCallback onRemoveTap;

  const _FriendListTile({
    required this.friend,
    required this.onTap,
    required this.onChatTap,
    required this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: friend.isOnline
              ? const Color(0xFF00FB94).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onRemoveTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
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
                                width: 56,
                                height: 56,
                                errorWidget: _buildDefaultAvatar(),
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                    if (friend.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00FB94),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0A0E1A), width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInfoChip('LVL ${friend.level}', const Color(0xFF6C5CE7)),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            '${friend.winRate.toStringAsFixed(0)}%',
                            friend.winRate >= 50
                                ? const Color(0xFF00FB94)
                                : const Color(0xFFFF6B6B),
                          ),
                          if (!friend.isOnline && friend.lastOnline != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatLastOnline(friend.lastOnline!),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Chat button
                    IconButton(
                      onPressed: onChatTap,
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Color(0xFF00D9FF),
                        size: 22,
                      ),
                    ),
                    // More button
                    IconButton(
                      onPressed: onRemoveTap,
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white.withOpacity(0.5),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
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

  String _formatLastOnline(String lastOnline) {
    try {
      final dateTime = DateTime.parse(lastOnline);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} daq oldin';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} soat oldin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} kun oldin';
      } else {
        return '${dateTime.day}.${dateTime.month}';
      }
    } catch (e) {
      return '';
    }
  }
}
