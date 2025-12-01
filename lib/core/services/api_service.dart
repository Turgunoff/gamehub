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
  // HOME METHODS
  // ══════════════════════════════════════════════════════════

  /// Home dashboard ma'lumotlari
  Future<HomeDashboardResponse> getHomeDashboard() async {
    try {
      final response = await _dio.get('/home/dashboard');
      return HomeDashboardResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Leaderboard
  Future<List<LeaderboardItem>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await _dio.get('/home/leaderboard', queryParameters: {'limit': limit});
      final list = response.data['leaderboard'] as List;
      return list.map((e) => LeaderboardItem.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ══════════════════════════════════════════════════════════
  // MATCHMAKING METHODS
  // ══════════════════════════════════════════════════════════

  /// Matchmaking queuega qo'shilish
  Future<MatchmakingResponse> joinMatchmakingQueue({String mode = 'ranked'}) async {
    try {
      final response = await _dio.post('/matches/queue/join', queryParameters: {'mode': mode});
      return MatchmakingResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Queuedan chiqish
  Future<void> leaveMatchmakingQueue() async {
    try {
      await _dio.delete('/matches/queue/leave');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Queue holatini tekshirish
  Future<QueueStatusResponse> getQueueStatus() async {
    try {
      final response = await _dio.get('/matches/queue/status');
      return QueueStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Online o'yinchilar
  Future<OnlinePlayersResponse> getOnlinePlayers({int limit = 20}) async {
    try {
      final response = await _dio.get('/matches/online-players', queryParameters: {'limit': limit});
      return OnlinePlayersResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Challenge yuborish
  Future<ChallengeResponse> sendChallenge({
    required String opponentId,
    String mode = 'friendly',
    int betAmount = 0,
  }) async {
    try {
      final response = await _dio.post('/matches/challenge', data: {
        'opponent_id': opponentId,
        'mode': mode,
        'bet_amount': betAmount,
      });
      return ChallengeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Online statusni yangilash
  Future<void> updateOnlineStatus() async {
    try {
      await _dio.post('/matches/update-online');
    } catch (e) {
      // Ignore errors
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

// ══════════════════════════════════════════════════════════
// HOME RESPONSE MODELS
// ══════════════════════════════════════════════════════════

class HomeDashboardResponse {
  final HomeUser user;
  final HomeStats stats;
  final int onlineUsers;
  final int pendingChallenges;
  final List<HomeTournament> tournaments;
  final List<HomeMatch> recentMatches;

  HomeDashboardResponse({
    required this.user,
    required this.stats,
    required this.onlineUsers,
    required this.pendingChallenges,
    required this.tournaments,
    required this.recentMatches,
  });

  factory HomeDashboardResponse.fromJson(Map<String, dynamic> json) {
    return HomeDashboardResponse(
      user: HomeUser.fromJson(json['user']),
      stats: HomeStats.fromJson(json['stats']),
      onlineUsers: json['online_users'] ?? 0,
      pendingChallenges: json['pending_challenges'] ?? 0,
      tournaments: (json['tournaments'] as List?)
              ?.map((e) => HomeTournament.fromJson(e))
              .toList() ??
          [],
      recentMatches: (json['recent_matches'] as List?)
              ?.map((e) => HomeMatch.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class HomeUser {
  final String id;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final int level;
  final int coins;
  final int gems;

  HomeUser({
    required this.id,
    required this.email,
    this.nickname,
    this.avatarUrl,
    required this.level,
    required this.coins,
    required this.gems,
  });

  factory HomeUser.fromJson(Map<String, dynamic> json) {
    return HomeUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'],
      avatarUrl: json['avatar_url'],
      level: json['level'] ?? 1,
      coins: json['coins'] ?? 0,
      gems: json['gems'] ?? 0,
    );
  }
}

class HomeStats {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final int tournamentsPlayed;
  final int tournamentsWon;
  final int coins;
  final int gems;
  final int level;
  final int experience;

  HomeStats({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.tournamentsPlayed,
    required this.tournamentsWon,
    required this.coins,
    required this.gems,
    required this.level,
    required this.experience,
  });

  factory HomeStats.fromJson(Map<String, dynamic> json) {
    return HomeStats(
      totalMatches: json['total_matches'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      tournamentsPlayed: json['tournaments_played'] ?? 0,
      tournamentsWon: json['tournaments_won'] ?? 0,
      coins: json['coins'] ?? 0,
      gems: json['gems'] ?? 0,
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
    );
  }
}

class HomeTournament {
  final String id;
  final String name;
  final String status;
  final String format;
  final int prizePool;
  final int entryFee;
  final int maxParticipants;
  final int participantCount;
  final String? startTime;
  final bool isFeatured;
  final bool isJoined;

  HomeTournament({
    required this.id,
    required this.name,
    required this.status,
    required this.format,
    required this.prizePool,
    required this.entryFee,
    required this.maxParticipants,
    required this.participantCount,
    this.startTime,
    required this.isFeatured,
    required this.isJoined,
  });

  factory HomeTournament.fromJson(Map<String, dynamic> json) {
    return HomeTournament(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      format: json['format'] ?? '',
      prizePool: json['prize_pool'] ?? 0,
      entryFee: json['entry_fee'] ?? 0,
      maxParticipants: json['max_participants'] ?? 0,
      participantCount: json['participant_count'] ?? 0,
      startTime: json['start_time'],
      isFeatured: json['is_featured'] ?? false,
      isJoined: json['is_joined'] ?? false,
    );
  }
}

class HomeMatch {
  final String id;
  final String opponentNickname;
  final String? opponentAvatar;
  final String result;
  final String score;
  final int ratingChange;
  final String mode;
  final String? playedAt;

  HomeMatch({
    required this.id,
    required this.opponentNickname,
    this.opponentAvatar,
    required this.result,
    required this.score,
    required this.ratingChange,
    required this.mode,
    this.playedAt,
  });

  factory HomeMatch.fromJson(Map<String, dynamic> json) {
    return HomeMatch(
      id: json['id'] ?? '',
      opponentNickname: json['opponent_nickname'] ?? 'Unknown',
      opponentAvatar: json['opponent_avatar'],
      result: json['result'] ?? '',
      score: json['score'] ?? '-',
      ratingChange: json['rating_change'] ?? 0,
      mode: json['mode'] ?? '',
      playedAt: json['played_at'],
    );
  }
}

class LeaderboardItem {
  final int rank;
  final String odoserId;
  final String nickname;
  final String? avatarUrl;
  final int level;
  final int totalMatches;
  final int wins;
  final double winRate;
  final int tournamentsWon;

  LeaderboardItem({
    required this.rank,
    required this.odoserId,
    required this.nickname,
    this.avatarUrl,
    required this.level,
    required this.totalMatches,
    required this.wins,
    required this.winRate,
    required this.tournamentsWon,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      rank: json['rank'] ?? 0,
      odoserId: json['user_id'] ?? '',
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatar_url'],
      level: json['level'] ?? 1,
      totalMatches: json['total_matches'] ?? 0,
      wins: json['wins'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      tournamentsWon: json['tournaments_won'] ?? 0,
    );
  }
}

// ══════════════════════════════════════════════════════════
// MATCHMAKING RESPONSE MODELS
// ══════════════════════════════════════════════════════════

class MatchmakingResponse {
  final String status; // searching, match_found, already_in_queue
  final String message;
  final int? position;
  final int? queueSize;
  final String? matchId;
  final OnlinePlayer? opponent;

  MatchmakingResponse({
    required this.status,
    required this.message,
    this.position,
    this.queueSize,
    this.matchId,
    this.opponent,
  });

  factory MatchmakingResponse.fromJson(Map<String, dynamic> json) {
    return MatchmakingResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      position: json['position'],
      queueSize: json['queue_size'],
      matchId: json['match_id'],
      opponent: json['opponent'] != null
          ? OnlinePlayer.fromJson(json['opponent'])
          : null,
    );
  }

  bool get isMatchFound => status == 'match_found';
  bool get isSearching => status == 'searching';
}

class QueueStatusResponse {
  final String status;
  final bool inQueue;
  final int? position;
  final int? queueSize;
  final String? mode;
  final String? joinedAt;

  QueueStatusResponse({
    required this.status,
    required this.inQueue,
    this.position,
    this.queueSize,
    this.mode,
    this.joinedAt,
  });

  factory QueueStatusResponse.fromJson(Map<String, dynamic> json) {
    return QueueStatusResponse(
      status: json['status'] ?? '',
      inQueue: json['in_queue'] ?? false,
      position: json['position'],
      queueSize: json['queue_size'],
      mode: json['mode'],
      joinedAt: json['joined_at'],
    );
  }
}

class OnlinePlayersResponse {
  final List<OnlinePlayer> players;
  final int count;
  final int totalOnline;

  OnlinePlayersResponse({
    required this.players,
    required this.count,
    required this.totalOnline,
  });

  factory OnlinePlayersResponse.fromJson(Map<String, dynamic> json) {
    return OnlinePlayersResponse(
      players: (json['players'] as List?)
              ?.map((e) => OnlinePlayer.fromJson(e))
              .toList() ??
          [],
      count: json['count'] ?? 0,
      totalOnline: json['total_online'] ?? 0,
    );
  }
}

class OnlinePlayer {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final int level;
  final int wins;
  final int totalMatches;
  final double winRate;
  final bool hasActiveMatch;
  final String? lastOnline;

  OnlinePlayer({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.level,
    required this.wins,
    required this.totalMatches,
    required this.winRate,
    required this.hasActiveMatch,
    this.lastOnline,
  });

  factory OnlinePlayer.fromJson(Map<String, dynamic> json) {
    return OnlinePlayer(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      level: json['level'] ?? 1,
      wins: json['wins'] ?? 0,
      totalMatches: json['total_matches'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      hasActiveMatch: json['has_active_match'] ?? false,
      lastOnline: json['last_online'],
    );
  }
}

class ChallengeResponse {
  final String message;
  final String matchId;
  final OnlinePlayer? opponent;

  ChallengeResponse({
    required this.message,
    required this.matchId,
    this.opponent,
  });

  factory ChallengeResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeResponse(
      message: json['message'] ?? '',
      matchId: json['match_id'] ?? '',
      opponent: json['opponent'] != null
          ? OnlinePlayer.fromJson(json['opponent'])
          : null,
    );
  }
}
