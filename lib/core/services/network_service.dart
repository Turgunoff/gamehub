import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _hasConnection = false;
  bool get hasConnection => _hasConnection;

  Future<void> initialize() async {
    // Initial check
    await checkConnection();

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      await checkConnection();
    });

    // Listen to internet connection changes
    _internetChecker.onStatusChange.listen((InternetStatus status) {
      final hasConnection = status == InternetStatus.connected;
      _hasConnection = hasConnection;
      _connectionController.add(hasConnection);
    });
  }

  Future<bool> checkConnection() async {
    bool previousConnection = _hasConnection;

    try {
      // Check actual internet connection
      _hasConnection = await _internetChecker.hasInternetAccess;
    } catch (e) {
      _hasConnection = false;
    }

    // Notify listeners if connection status changed
    if (previousConnection != _hasConnection) {
      _connectionController.add(_hasConnection);
    }

    return _hasConnection;
  }

  void dispose() {
    _connectionController.close();
    
  }
}
