import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Backend URL
  static const String baseUrl = 'https://nights.uz/api/v1';

  late Dio _dio;
  String? _accessToken;

  Future<void> initialize() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor for logging and token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          print(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
          );
          return handler.next(error);
        },
      ),
    );

    // Load saved token
    await _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    _accessToken = token;
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _accessToken = null;
  }

  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken != null;

  // Send OTP code to email
  Future<ApiResponse> sendOTP(String email) async {
    print('========== SEND OTP ==========');
    print('Email: $email');
    print('Full URL: $baseUrl/auth/send-code');

    try {
      final response = await _dio.post(
        '/auth/send-code',
        data: {'email': email},
      );

      print('Response Status: ${response.statusCode}');
      print('Response Data: ${response.data}');

      return ApiResponse(
        success: true,
        message: response.data['message'] ?? 'Code sent successfully',
      );
    } on DioException catch (e) {
      print('========== DIO ERROR ==========');
      print('Error Type: ${e.type}');
      print('Error Message: ${e.message}');
      print('Response: ${e.response}');
      print('Response Data: ${e.response?.data}');
      print('Response Status: ${e.response?.statusCode}');
      print('================================');
      return _handleError(e);
    } catch (e) {
      print('========== GENERAL ERROR ==========');
      print('Error: $e');
      print('====================================');
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // Verify OTP and login
  Future<AuthResponse> verifyOTP(String email, String code) async {
    try {
      final response = await _dio.post(
        '/auth/verify-code',
        data: {'email': email, 'code': code},
      );

      final data = response.data;
      final token = data['access_token'];
      final isNewUser = data['is_new_user'] ?? false;

      // Save token
      await _saveToken(token);

      return AuthResponse(
        success: true,
        accessToken: token,
        isNewUser: isNewUser,
      );
    } on DioException catch (e) {
      final error = _handleError(e);
      return AuthResponse(success: false, message: error.message);
    }
  }

  // Logout
  Future<void> logout() async {
    await _clearToken();
  }

  // Check if user is authenticated
  Future<bool> checkAuth() async {
    await _loadToken();
    return _accessToken != null;
  }

  // Error handler
  ApiResponse _handleError(DioException e) {
    String message = 'Unknown error occurred';

    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) {
        message = data['detail'];
      } else if (e.response?.statusCode == 400) {
        message = 'Invalid request';
      } else if (e.response?.statusCode == 401) {
        message = 'Unauthorized';
      } else if (e.response?.statusCode == 500) {
        message = 'Server error';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Network error';
    }

    return ApiResponse(success: false, message: message);
  }
}

class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;

  ApiResponse({required this.success, this.message, this.data});
}

class AuthResponse {
  final bool success;
  final String? accessToken;
  final bool isNewUser;
  final String? message;

  AuthResponse({
    required this.success,
    this.accessToken,
    this.isNewUser = false,
    this.message,
  });
}
