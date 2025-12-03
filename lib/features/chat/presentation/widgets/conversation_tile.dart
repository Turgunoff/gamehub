// lib/features/chat/presentation/widgets/conversation_tile.dart
import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar with unread indicator
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    ),
                  ),
                  child: conversation.otherUserAvatar != null &&
                          conversation.otherUserAvatar!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            conversation.otherUserAvatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
                if (conversation.hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D26A),
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
            const SizedBox(width: 16),

            // Conversation info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserNickname,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: conversation.hasUnread
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: TextStyle(
                            color: conversation.hasUnread
                                ? const Color(0xFF00D26A)
                                : Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage ?? 'Xabar yoq',
                    style: TextStyle(
                      color: conversation.hasUnread
                          ? Colors.white.withOpacity(0.8)
                          : Colors.white.withOpacity(0.4),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        conversation.otherUserNickname.isNotEmpty
            ? conversation.otherUserNickname[0].toUpperCase()
            : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Kecha';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} kun';
    } else {
      return '${dateTime.day}.${dateTime.month}';
    }
  }
}
