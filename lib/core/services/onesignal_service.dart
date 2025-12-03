import 'dart:async';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import 'api_service.dart';

/// Notification event model for real-time UI updates
class NotificationEvent {
  final String type;
  final String? userId;
  final String? matchId;
  final String? title;
  final String? message;
  final Map<String, dynamic>? data;

  NotificationEvent({
    required this.type,
    this.userId,
    this.matchId,
    this.title,
    this.message,
    this.data,
  });
}

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  final _logger = Logger();

  // OneSignal App ID
  static const String _appId = '5affee5f-1d19-460f-af51-af806e9b1c64';

  String? _playerId;
  String? get playerId => _playerId;

  // Stream controller for notification events (real-time UI updates)
  final _notificationController = StreamController<NotificationEvent>.broadcast();
  Stream<NotificationEvent> get onNotificationReceived => _notificationController.stream;

  /// OneSignal ni ishga tushirish
  Future<void> initialize() async {
    try {
      // Debug mode
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      // Initialize
      OneSignal.initialize(_appId);

      // Notification ruxsatini so'rash
      await OneSignal.Notifications.requestPermission(true);

      // Player ID ni olish
      _playerId = OneSignal.User.pushSubscription.id;
      _logger.i('OneSignal Player ID: $_playerId');

      // Notification listener
      OneSignal.Notifications.addClickListener(_onNotificationClicked);
      OneSignal.Notifications.addForegroundWillDisplayListener(_onNotificationReceived);

      // Player ID o'zgarganda
      OneSignal.User.pushSubscription.addObserver((state) {
        _playerId = state.current.id;
        _logger.i('OneSignal Player ID yangilandi: $_playerId');

        // Backend ga yuborish
        if (_playerId != null) {
          _sendPlayerIdToBackend();
        }
      });

    } catch (e) {
      _logger.e('OneSignal initialization error: $e');
    }
  }

  /// Notification bosilganda
  void _onNotificationClicked(OSNotificationClickEvent event) {
    _logger.i('Notification clicked: ${event.notification.title}');

    final data = event.notification.additionalData;
    if (data != null) {
      final type = data['type'] as String?;
      final userId = data['user_id'] as String?;
      final matchId = data['match_id'] as String?;

      _logger.i('Notification type: $type, userId: $userId, matchId: $matchId');

      // Notification turiga qarab navigatsiya
      // Har doim notifications ekraniga o'tish
      switch (type) {
        case 'challenge':
          // Challenge - notifications sahifasiga (tab 0 - challenges)
          _logger.i('Challenge notification - navigating to notifications');
          AppRouter.router.go('/notifications?tab=0');
          break;
        case 'friend_request':
          // Do'stlik so'rovi - notifications sahifasiga (tab 1 - friends)
          _logger.i('Friend request - navigating to notifications friends tab');
          AppRouter.router.go('/notifications?tab=1');
          break;
        case 'friend_accepted':
          // Do'stlik qabul qilindi - notifications sahifasiga
          _logger.i('Friend accepted - navigating to notifications friends tab');
          AppRouter.router.go('/notifications?tab=1');
          break;
        case 'match_start':
        case 'match_reminder':
          // Match sahifasiga o'tish
          _logger.i('Match notification - navigating to quick-match');
          AppRouter.router.go('/quick-match');
          break;
        default:
          // Default - notifications sahifasiga
          AppRouter.router.go('/notifications');
      }
    }
  }

  /// Notification kelganda (app ochiq bo'lganda)
  void _onNotificationReceived(OSNotificationWillDisplayEvent event) {
    _logger.i('Notification received: ${event.notification.title}');

    // Notification ni ko'rsatish
    event.notification.display();

    // Real-time UI yangilash uchun event yuborish
    final data = event.notification.additionalData;
    if (data != null) {
      final notificationEvent = NotificationEvent(
        type: data['type'] as String? ?? 'unknown',
        userId: data['user_id'] as String?,
        matchId: data['match_id'] as String?,
        title: event.notification.title,
        message: event.notification.body,
        data: data,
      );
      _notificationController.add(notificationEvent);
      _logger.i('NotificationEvent emitted: ${notificationEvent.type}');
    }
  }

  /// Player ID ni backend ga yuborish
  Future<void> _sendPlayerIdToBackend() async {
    if (_playerId == null) return;

    try {
      await ApiService().updateOneSignalPlayerId(_playerId!);
      _logger.i('Player ID backend ga yuborildi');
    } catch (e) {
      _logger.e('Player ID yuborishda xato: $e');
    }
  }

  /// Login bo'lgandan keyin player ID ni yuborish
  Future<void> registerPlayerIdAfterLogin() async {
    // Player ID ni yangilash
    _playerId = OneSignal.User.pushSubscription.id;
    _logger.i('🔔 registerPlayerIdAfterLogin called, playerId: $_playerId');

    if (_playerId != null && _playerId!.isNotEmpty) {
      await _sendPlayerIdToBackend();
      _logger.i('🔔 Player ID backend ga yuborildi: $_playerId');
    } else {
      _logger.w('🔔 Player ID topilmadi! OneSignal permission tekshiring.');
    }
  }

  /// External User ID ni sozlash (user login bo'lganda)
  Future<void> setExternalUserId(String oderId) async {
    try {
      OneSignal.login(oderId);
      _logger.i('External User ID set: $oderId');
    } catch (e) {
      _logger.e('External User ID error: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      OneSignal.logout();
      _logger.i('OneSignal logout');
    } catch (e) {
      _logger.e('OneSignal logout error: $e');
    }
  }
}
