import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _hasConnection = true;
  bool get hasConnection => _hasConnection;

  Future<void> initialize() async {
    // Initial check
    await checkConnection();

    // Listen to connectivity changes
    try {
      _connectivity.onConnectivityChanged.listen((
        List<ConnectivityResult> results,
      ) async {
        await checkConnection();
      }, onError: (error) {
        // Silently handle errors
      });
    } catch (e) {
      // Platform exception - skip
    }
  }

  Future<bool> checkConnection() async {
    bool previousConnection = _hasConnection;

    try {
      final results = await _connectivity.checkConnectivity();
      _hasConnection = results.isNotEmpty &&
          !results.contains(ConnectivityResult.none);
    } catch (e) {
      _hasConnection = true; // Assume connected on error
    }

    if (previousConnection != _hasConnection) {
      _connectionController.add(_hasConnection);
    }

    return _hasConnection;
  }

  void dispose() {
    _connectionController.close();
  }
}
