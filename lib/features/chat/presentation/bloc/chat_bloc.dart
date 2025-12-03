// lib/features/chat/presentation/bloc/chat_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/websocket_service.dart';

// ══════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Suhbatlar ro'yxatini yuklash
class ConversationsLoadRequested extends ChatEvent {
  const ConversationsLoadRequested();
}

/// Xabarlarni yuklash
class MessagesLoadRequested extends ChatEvent {
  final String userId;

  const MessagesLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Xabar yuborish
class MessageSent extends ChatEvent {
  final String receiverId;
  final String content;

  const MessageSent({required this.receiverId, required this.content});

  @override
  List<Object?> get props => [receiverId, content];
}

/// Yangi xabar keldi (WebSocket)
class NewMessageReceived extends ChatEvent {
  final ChatMessage message;

  const NewMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

// ══════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ConversationsLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<Conversation> conversations;

  const ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class MessagesLoading extends ChatState {}

class MessagesLoaded extends ChatState {
  final String otherUserId;
  final List<ChatMessage> messages;
  final bool hasMore;

  const MessagesLoaded({
    required this.otherUserId,
    required this.messages,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [otherUserId, messages, hasMore];
}

class MessageSending extends ChatState {}

class MessageSentSuccess extends ChatState {
  final ChatMessage message;

  const MessageSentSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

// ══════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ApiService _apiService = ApiService();
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription? _wsSubscription;

  ChatBloc() : super(ChatInitial()) {
    on<ConversationsLoadRequested>(_onConversationsLoad);
    on<MessagesLoadRequested>(_onMessagesLoad);
    on<MessageSent>(_onMessageSent);
    on<NewMessageReceived>(_onNewMessageReceived);

    // WebSocket dan xabar tinglash
    _wsSubscription = _wsService.on('new_message').listen((event) {
      final messageData = event.data['message'] as Map<String, dynamic>?;
      if (messageData != null) {
        add(NewMessageReceived(ChatMessage.fromJson(messageData)));
      }
    });
  }

  Future<void> _onConversationsLoad(
    ConversationsLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(ConversationsLoading());

    try {
      final response = await _apiService.getConversations();
      emit(ConversationsLoaded(response.conversations));
    } catch (e) {
      emit(ChatError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onMessagesLoad(
    MessagesLoadRequested event,
    Emitter<ChatState> emit,
  ) async {
    emit(MessagesLoading());

    try {
      final response = await _apiService.getMessages(event.userId);
      emit(MessagesLoaded(
        otherUserId: event.userId,
        messages: response.messages,
        hasMore: response.hasMore,
      ));
    } catch (e) {
      emit(ChatError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    // Store current state to restore messages after sending
    final currentState = state;

    try {
      final message = await _apiService.sendChatMessage(
        event.receiverId,
        event.content,
      );

      // If we were in MessagesLoaded state, add the new message
      if (currentState is MessagesLoaded) {
        final updatedMessages = [...currentState.messages, message];
        emit(MessagesLoaded(
          otherUserId: currentState.otherUserId,
          messages: updatedMessages,
          hasMore: currentState.hasMore,
        ));
      } else {
        emit(MessageSentSuccess(message));
      }
    } catch (e) {
      emit(ChatError(e.toString().replaceFirst('Exception: ', '')));
      // Restore previous state
      if (currentState is MessagesLoaded) {
        emit(currentState);
      }
    }
  }

  void _onNewMessageReceived(
    NewMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      // Check if message is from current conversation
      if (event.message.senderId == currentState.otherUserId ||
          event.message.receiverId == currentState.otherUserId) {
        final updatedMessages = [...currentState.messages, event.message];
        emit(MessagesLoaded(
          otherUserId: currentState.otherUserId,
          messages: updatedMessages,
          hasMore: currentState.hasMore,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }
}
