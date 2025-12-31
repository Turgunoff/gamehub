// lib/features/chat/presentation/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/cyberpitch_background.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserNickname;
  final String? otherUserAvatar;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserNickname,
    this.otherUserAvatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatBloc()..add(MessagesLoadRequested(widget.otherUserId)),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        appBar: _buildAppBar(),
        body: CyberPitchBackground(
          opacity: 0.3,
          child: Column(
            children: [
              Expanded(child: _buildMessagesList()),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A1F3A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
            ),
            child: widget.otherUserAvatar != null &&
                    widget.otherUserAvatar!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      widget.otherUserAvatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    ),
                  )
                : _buildDefaultAvatar(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.otherUserNickname,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        widget.otherUserNickname.isNotEmpty
            ? widget.otherUserNickname[0].toUpperCase()
            : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is MessagesLoaded) {
          // Scroll to bottom after new message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      },
      builder: (context, state) {
        if (state is MessagesLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6C5CE7),
            ),
          );
        }

        if (state is MessagesLoaded) {
          if (state.messages.isEmpty) {
            return Center(
              child: Text(
                'Xabar yozing',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[index];
              final isMe = message.senderId != widget.otherUserId;
              return MessageBubble(message: message, isMe: isMe);
            },
          );
        }

        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF6C5CE7).withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF6C5CE7).withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Xabar yozing...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 12),
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () => _sendMessage(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    context.read<ChatBloc>().add(MessageSent(
          receiverId: widget.otherUserId,
          content: text,
        ));
    _messageController.clear();
    _focusNode.requestFocus();
  }
}
