import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:logger/logger.dart';
import 'api_service.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  final _logger = Logger();

  // OneSignal App ID
  static const String _appId = '5affee5f-1d19-460f-af51-af806e9b1c64';

  String? _playerId;
  String? get playerId => _playerId;

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
      final id = data['id'] as String?;

      // Notification turiga qarab navigatsiya
      switch (type) {
        case 'challenge':
          // Challenge sahifasiga o'tish
          _logger.i('Challenge notification: $id');
          break;
        case 'friend_request':
          // Do'stlik so'rovi sahifasiga o'tish
          _logger.i('Friend request notification: $id');
          break;
        case 'match_start':
          // Match sahifasiga o'tish
          _logger.i('Match start notification: $id');
          break;
      }
    }
  }

  /// Notification kelganda (app ochiq bo'lganda)
  void _onNotificationReceived(OSNotificationWillDisplayEvent event) {
    _logger.i('Notification received: ${event.notification.title}');

    // Notification ni ko'rsatish
    event.notification.display();
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

    if (_playerId != null) {
      await _sendPlayerIdToBackend();
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
