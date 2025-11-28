import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    hide Options;
import 'package:flutter/foundation.dart';
import 'device_service.dart';
import '../models/profile_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'https://nights.uz/api/v1';

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;

  // ══════════════════════════════════════════════════════════
  // INITIALIZATION
  // ══════════════════════════════════════════════════════════

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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          _log('REQUEST', '${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _log(
            'RESPONSE',
            '${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          _log(
            'ERROR',
            '${error.response?.statusCode} ${error.requestOptions.path}',
          );

          // 401 bo'lsa token refresh qilish
          if (error.response?.statusCode == 401 && _refreshToken != null) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              // Qayta so'rov yuborish
              final retryResponse = await _retry(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }

          return handler.next(error);
        },
      ),
    );

    await _loadTokens();
  }

  // ══════════════════════════════════════════════════════════
  // PROFILE METHODS
  // ══════════════════════════════════════════════════════════

  /// Mening profilim
  Future<UserMeModel> getMyProfile() async {
    final response = await _dio.get('/users/me');
    return UserMeModel.fromJson(response.data);
  }

  /// Profilni yangilash
  Future<ProfileModel> updateProfile({
    String? nickname,
    String? fullName,
    String? phone,
    String? birthDate,
    String? gender,
    String? region,
    String? bio,
    String? language,
    String? telegram,
    String? instagram,
    String? youtube,
    String? discord,
    String? pesId,
    int? teamStrength,
    String? favoriteTeam,
    String? playStyle,
    String? preferredFormation,
    String? availableHours,
  }) async {
    final data = <String, dynamic>{};

    if (nickname != null) data['nickname'] = nickname;
    if (fullName != null) data['full_name'] = fullName;
    if (phone != null) data['phone'] = phone;
    if (birthDate != null) data['birth_date'] = birthDate;
    if (gender != null) data['gender'] = gender;
    if (region != null) data['region'] = region;
    if (bio != null) data['bio'] = bio;
    if (language != null) data['language'] = language;
    if (telegram != null) data['telegram'] = telegram;
    if (instagram != null) data['instagram'] = instagram;
    if (youtube != null) data['youtube'] = youtube;
    if (discord != null) data['discord'] = discord;
    if (pesId != null) data['pes_id'] = pesId;
    if (teamStrength != null) data['team_strength'] = teamStrength;
    if (favoriteTeam != null) data['favorite_team'] = favoriteTeam;
    if (playStyle != null) data['play_style'] = playStyle;
    if (preferredFormation != null)
      data['preferred_formation'] = preferredFormation;
    if (availableHours != null) data['available_hours'] = availableHours;

    final response = await _dio.patch('/users/me', data: data);
    return ProfileModel.fromJson(response.data['profile']);
  }

  /// Telefon tasdiqlash
  Future<Map<String, dynamic>> verifyPhone(String phone, String code) async {
    final response = await _dio.post(
      '/users/me/verify-phone',
      data: {'phone': phone, 'code': code},
    );
    return response.data;
  }

  /// Avatar yuklash
  Future<AvatarUploadResponse> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: 'avatar.jpg',
        ),
      });

      final response = await _dio.post(
        '/upload/avatar',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return AvatarUploadResponse(
        success: true,
        avatarUrl: response.data['avatar_url'],
        message: response.data['message'],
      );
    } on DioException catch (e) {
      return AvatarUploadResponse(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  /// Avatar o'chirish
  Future<bool> deleteAvatar() async {
    try {
      await _dio.delete('/upload/avatar');
      return true;
    } catch (e) {
      return false;
    }
  }
  // ══════════════════════════════════════════════════════════
  // TOKEN MANAGEMENT
  // ══════════════════════════════════════════════════════════

  Future<void> _loadTokens() async {
    _accessToken = await _storage.read(key: 'access_token');
    _refreshToken = await _storage.read(key: 'refresh_token');

    // DEBUG: Tekshirish
    print('TOKEN LOADED: ${_accessToken?.substring(0, 20) ?? "NULL"}');
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    // DEBUG: Tekshirish
    print('TOKEN SAVED: ${accessToken.substring(0, 20)}...');
  }

  Future<void> _clearTokens() async {
    await _storage.deleteAll();
    _accessToken = null;
    _refreshToken = null;
  }

  Future<bool> _tryRefreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': _refreshToken},
        options: Options(headers: {}), // Token qo'shmaslik
      );

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];
      await _saveTokens(accessToken, refreshToken);

      return true;
    } catch (e) {
      await _clearTokens();
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $_accessToken',
      },
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // ══════════════════════════════════════════════════════════
  // PUBLIC GETTERS
  // ══════════════════════════════════════════════════════════

  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken != null;

  // ══════════════════════════════════════════════════════════
  // AUTH METHODS
  // ══════════════════════════════════════════════════════════

  /// OTP kod yuborish
  Future<OTPResponse> sendOTP(String email) async {
    try {
      final response = await _dio.post(
        '/auth/send-code',
        data: {'email': email},
      );

      return OTPResponse(
        success: true,
        message: response.data['message'],
        expiresIn: response.data['expires_in'] ?? 120,
      );
    } on DioException catch (e) {
      return OTPResponse(success: false, message: _getErrorMessage(e));
    }
  }

  /// OTP tekshirish va login
  Future<AuthResponse> verifyOTP(
    String email,
    String code, {
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-code',
        data: {
          'email': email,
          'code': code,
          if (deviceInfo != null) 'device_info': deviceInfo,
        },
      );

      final data = response.data;

      // Tokenlarni saqlash
      await _saveTokens(data['access_token'], data['refresh_token']);

      return AuthResponse(
        success: true,
        isNewUser: data['is_new_user'] ?? false,
      );
    } on DioException catch (e) {
      return AuthResponse(success: false, message: _getErrorMessage(e));
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Xato bo'lsa ham tokenlarni o'chirish
    }
    await _clearTokens();
  }

  /// Auth tekshirish
  Future<bool> checkAuth() async {
    await _loadTokens();

    if (_accessToken == null) return false;

    try {
      // Token ishlashini tekshirish
      await _dio.get('/users/me');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token eskirgan, refresh qilib ko'rish
        return await _tryRefreshToken();
      }
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // GENERIC API METHODS
  // ══════════════════════════════════════════════════════════

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }

  // ══════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════

  String _getErrorMessage(DioException e) {
    // Server xatosi
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
    }

    // Status code bo'yicha
    switch (e.response?.statusCode) {
      case 400:
        return 'Noto\'g\'ri so\'rov';
      case 401:
        return 'Avtorizatsiya xatosi';
      case 403:
        return 'Ruxsat yo\'q';
      case 404:
        return 'Topilmadi';
      case 429:
        return 'Juda ko\'p so\'rov. Keyinroq urinib ko\'ring';
      case 500:
        return 'Server xatosi';
    }

    // Connection xatolari
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Internet aloqasi sekin';
      case DioExceptionType.connectionError:
        return 'Internet aloqasi yo\'q';
      default:
        return 'Xatolik yuz berdi';
    }
  }

  void _log(String type, String message) {
    if (kDebugMode) {
      print('[$type] $message');
    }
  }
}

// ══════════════════════════════════════════════════════════
// RESPONSE MODELS
// ══════════════════════════════════════════════════════════

class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;

  ApiResponse({required this.success, this.message, this.data});
}

class OTPResponse {
  final bool success;
  final String? message;
  final int expiresIn;

  OTPResponse({required this.success, this.message, this.expiresIn = 120});
}

class AuthResponse {
  final bool success;
  final String? message;
  final bool isNewUser;

  AuthResponse({required this.success, this.message, this.isNewUser = false});
}

class AvatarUploadResponse {
  final bool success;
  final String? avatarUrl;
  final String? message;

  AvatarUploadResponse({required this.success, this.avatarUrl, this.message});
}
