// lib/core/services/websocket_service.dart
import 'dart:async' show Stream, StreamController, Timer, TimeoutException;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';
import 'api_service.dart';

/// WebSocket event model
class WebSocketEvent {
  final String type;
  final Map<String, dynamic> data;

  WebSocketEvent({required this.type, required this.data});

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    return WebSocketEvent(
      type: json['type'] as String? ?? 'unknown',
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'data': data};
}

/// WebSocket connection states
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  final _logger = Logger();

  // WebSocket configuration
  static const String _wsBaseUrl = 'ws://45.93.201.167:8080/api/v1/ws';
  static const Duration _pingInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const int _maxReconnectAttempts = 5;

  WebSocketChannel? _channel;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  WebSocketState _state = WebSocketState.disconnected;
  WebSocketState get state => _state;

  // Event streams
  final _eventController = StreamController<WebSocketEvent>.broadcast();
  Stream<WebSocketEvent> get onEvent => _eventController.stream;

  // State stream
  final _stateController = StreamController<WebSocketState>.broadcast();
  Stream<WebSocketState> get onStateChange => _stateController.stream;

  // Online count stream
  final _onlineCountController = StreamController<int>.broadcast();
  Stream<int> get onOnlineCountChange => _onlineCountController.stream;

  // ══════════════════════════════════════════════════════════
  // CONNECTION MANAGEMENT
  // ══════════════════════════════════════════════════════════

  /// WebSocket ga ulanish
  Future<bool> connect() async {
    if (_state == WebSocketState.connected) {
      _logger.w('WebSocket already connected');
      return true;
    }

    if (_state == WebSocketState.connecting) {
      _logger.w('WebSocket connection in progress');
      return false;
    }

    final token = ApiService().accessToken;
    if (token == null) {
      _logger.e('No access token available for WebSocket');
      return false;
    }

    _setState(WebSocketState.connecting);

    try {
      final wsUrl = Uri.parse('$_wsBaseUrl?token=$token');
      _logger.d('Connecting to WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(wsUrl);

      // Ready holati kutish
      await _channel!.ready.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('WebSocket connection timeout');
        },
      );

      // Listen to messages
      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _setState(WebSocketState.connected);
      _reconnectAttempts = 0;

      // Start ping timer
      _startPingTimer();

      _logger.i('🔌 WebSocket connected successfully');
      return true;
    } catch (e) {
      _logger.e('WebSocket connection error: $e');
      _channel?.sink.close();
      _channel = null;
      _setState(WebSocketState.disconnected);
      _scheduleReconnect();
      return false;
    }
  }

  /// WebSocket ni yopish
  void disconnect() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _setState(WebSocketState.disconnected);
    _logger.i('🔌 WebSocket disconnected');
  }

  /// Qayta ulanish
  void _scheduleReconnect() {
    // Agar allaqachon reconnect qilinayotgan bo'lsa, qaytadan schedule qilmaslik
    if (_state == WebSocketState.reconnecting) {
      return;
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.e('Max reconnect attempts reached. Stopping reconnection.');
      _setState(WebSocketState.disconnected);
      return;
    }

    _reconnectAttempts++;
    _setState(WebSocketState.reconnecting);

    final delay = _reconnectDelay * _reconnectAttempts;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      _logger.i(
          'Reconnecting... (attempt $_reconnectAttempts/$_maxReconnectAttempts)');
      await connect();
    });
  }

  void _setState(WebSocketState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  // ══════════════════════════════════════════════════════════
  // MESSAGE HANDLING
  // ══════════════════════════════════════════════════════════

  void _onMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;
      final event = WebSocketEvent.fromJson(json);

      _logger.d('📥 WS Event: ${event.type}');

      // Handle specific events
      switch (event.type) {
        case 'pong':
          // Heartbeat response - ignore
          break;
        case 'online_count':
          final count = event.data['count'] as int? ?? 0;
          _onlineCountController.add(count);
          break;
        default:
          // Forward to listeners
          _eventController.add(event);
      }
    } catch (e) {
      _logger.e('Error parsing WebSocket message: $e');
    }
  }

  void _onError(dynamic error) {
    _logger.e('WebSocket error: $error');
    _scheduleReconnect();
  }

  void _onDone() {
    _logger.w('WebSocket connection closed');
    _setState(WebSocketState.disconnected);
    _scheduleReconnect();
  }

  // ══════════════════════════════════════════════════════════
  // PING/PONG (Heartbeat)
  // ══════════════════════════════════════════════════════════

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      send('ping', {});
    });
  }

  // ══════════════════════════════════════════════════════════
  // SEND MESSAGES
  // ══════════════════════════════════════════════════════════

  /// Event yuborish
  void send(String type, Map<String, dynamic> data) {
    if (_state != WebSocketState.connected || _channel == null) {
      _logger.w('Cannot send message: WebSocket not connected');
      return;
    }

    try {
      final message = jsonEncode({'type': type, 'data': data});
      _channel!.sink.add(message);
      _logger.d('📤 WS Send: $type');
    } catch (e) {
      _logger.e('Error sending WebSocket message: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // CONVENIENCE METHODS
  // ══════════════════════════════════════════════════════════

  /// Room ga qo'shilish (Match, Tournament)
  void joinRoom(String roomId) {
    send('join_room', {'room_id': roomId});
  }

  /// Room dan chiqish
  void leaveRoom(String roomId) {
    send('leave_room', {'room_id': roomId});
  }

  /// Challenge qabul qilindi xabari
  void sendChallengeAccepted(String matchId, String challengerId) {
    send('challenge_accepted', {
      'match_id': matchId,
      'challenger_id': challengerId,
    });
  }

  /// Challenge rad etildi xabari
  void sendChallengeDeclined(String matchId, String challengerId) {
    send('challenge_declined', {
      'match_id': matchId,
      'challenger_id': challengerId,
    });
  }

  /// Score yangilash
  void sendScoreUpdate(String matchId, int myScore, int opponentScore) {
    send('score_update', {
      'match_id': matchId,
      'my_score': myScore,
      'opponent_score': opponentScore,
    });
  }

  /// Userlar online statusini so'rash
  void getOnlineStatus(List<String> userIds) {
    send('get_online_status', {'user_ids': userIds});
  }

  /// Typing indicator
  void sendTyping(String toUserId, bool isTyping) {
    send('typing', {
      'to_user_id': toUserId,
      'is_typing': isTyping,
    });
  }

  // ══════════════════════════════════════════════════════════
  // EVENT LISTENERS (Convenience)
  // ══════════════════════════════════════════════════════════

  /// Specific event type ni tinglash
  Stream<WebSocketEvent> on(String eventType) {
    return onEvent.where((event) => event.type == eventType);
  }

  /// Challenge accepted event
  Stream<WebSocketEvent> get onChallengeAccepted => on('challenge_accepted');

  /// Challenge declined event
  Stream<WebSocketEvent> get onChallengeDeclined => on('challenge_declined');

  /// New challenge event
  Stream<WebSocketEvent> get onNewChallenge => on('new_challenge');

  /// Score updated event
  Stream<WebSocketEvent> get onScoreUpdated => on('score_updated');

  /// Match found event (matchmaking)
  Stream<WebSocketEvent> get onMatchFound => on('match_found');

  /// Online status response
  Stream<WebSocketEvent> get onOnlineStatus => on('online_status');

  // ══════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════

  void dispose() {
    disconnect();
    _eventController.close();
    _stateController.close();
    _onlineCountController.close();
  }
}
