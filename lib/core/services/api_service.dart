import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Production server
  static const String baseUrl = 'http://45.93.201.167:8080/api/v1';

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
            '${error.response?.statusCode} ${error.requestOptions.path} - ${error.type.name}: ${error.message}',
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
  // TOURNAMENT METHODS
  // ══════════════════════════════════════════════════════════

  /// Turnirlar ro'yxati
  Future<TournamentsResponse> getTournaments({String? status, int limit = 20}) async {
    try {
      final params = <String, dynamic>{'limit': limit};
      if (status != null) params['status'] = status;
      final response = await _dio.get('/tournaments', queryParameters: params);
      return TournamentsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Turnir tafsilotlari
  Future<TournamentDetail> getTournamentDetail(String tournamentId) async {
    try {
      final response = await _dio.get('/tournaments/$tournamentId');
      return TournamentDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Turnir bracket
  Future<TournamentBracket> getTournamentBracket(String tournamentId) async {
    try {
      final response = await _dio.get('/tournaments/$tournamentId/bracket');
      return TournamentBracket.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Turnirga qo'shilish
  Future<Map<String, dynamic>> joinTournament(String tournamentId) async {
    try {
      final response = await _dio.post('/tournaments/$tournamentId/join');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Turnirdan chiqish
  Future<Map<String, dynamic>> leaveTournament(String tournamentId) async {
    try {
      final response = await _dio.post('/tournaments/$tournamentId/leave');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
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
  // CHAT METHODS
  // ══════════════════════════════════════════════════════════

  /// Suhbatlar ro'yxatini olish
  Future<ConversationsResponse> getConversations({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get('/chat/conversations', queryParameters: {
        'limit': limit,
        'offset': offset,
      });
      return ConversationsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Foydalanuvchi bilan xabarlarni olish
  Future<MessagesResponse> getMessages(String userId, {int limit = 50, DateTime? before}) async {
    try {
      final params = <String, dynamic>{'limit': limit};
      if (before != null) {
        params['before'] = before.toIso8601String();
      }
      final response = await _dio.get('/chat/messages/$userId', queryParameters: params);
      return MessagesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Xabar yuborish
  Future<ChatMessage> sendChatMessage(String receiverId, String content) async {
    try {
      final response = await _dio.post('/chat/messages', data: {
        'receiver_id': receiverId,
        'content': content,
      });
      return ChatMessage.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// O'qilmagan xabarlar sonini olish
  Future<int> getUnreadMessagesCount() async {
    try {
      final response = await _dio.get('/chat/unread-count');
      return response.data['unread_count'] ?? 0;
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

  /// Barcha o'yinchilar (filter va search bilan)
  Future<AllPlayersResponse> getAllPlayers({
    String filter = 'all', // 'all' yoki 'online'
    String? search,
    int limit = 50,
  }) async {
    try {
      final params = <String, dynamic>{
        'filter': filter,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      final response = await _dio.get('/matches/players', queryParameters: params);
      return AllPlayersResponse.fromJson(response.data);
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

  /// Kutilayotgan challenge'larni olish
  Future<PendingChallengesResponse> getPendingChallenges() async {
    try {
      final response = await _dio.get('/matches/pending');
      return PendingChallengesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Challenge qabul qilish
  Future<Map<String, dynamic>> acceptChallenge(String matchId) async {
    try {
      final response = await _dio.post('/matches/$matchId/accept');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Challenge rad etish
  Future<Map<String, dynamic>> declineChallenge(String matchId) async {
    try {
      final response = await _dio.post('/matches/$matchId/decline');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Challenge bekor qilish (o'zim yuborgan)
  Future<Map<String, dynamic>> cancelChallenge(String matchId) async {
    try {
      final response = await _dio.post('/matches/$matchId/cancel');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// O'yin natijasini yuborish
  Future<MatchResultResponse> submitMatchResult({
    required String matchId,
    required int myScore,
    required int opponentScore,
    String? screenshotUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/matches/$matchId/result',
        data: {
          'my_score': myScore,
          'opponent_score': opponentScore,
          if (screenshotUrl != null) 'screenshot_url': screenshotUrl,
        },
      );
      return MatchResultResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Faol o'yinlarni olish (natija yuborilmagan)
  Future<List<ActiveMatch>> getActiveMatches() async {
    try {
      final response = await _dio.get('/matches/active');
      final List<dynamic> data = response.data['matches'] ?? [];
      return data.map((json) => ActiveMatch.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ══════════════════════════════════════════════════════════
  // PLAYER PROFILE
  // ══════════════════════════════════════════════════════════

  /// O'yinchi profilini olish (batafsil)
  Future<PlayerProfile> getPlayerProfile(String userId) async {
    try {
      final response = await _dio.get('/users/player/$userId');
      return PlayerProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ══════════════════════════════════════════════════════════
  // FRIENDSHIP
  // ══════════════════════════════════════════════════════════

  /// Do'stlik so'rovi yuborish
  Future<Map<String, dynamic>> sendFriendRequest(String userId) async {
    try {
      final response = await _dio.post('/users/friends/request/$userId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Do'stlik so'rovini qabul qilish
  Future<Map<String, dynamic>> acceptFriendRequest(String userId) async {
    try {
      final response = await _dio.post('/users/friends/accept/$userId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Do'stlik so'rovini rad etish
  Future<Map<String, dynamic>> declineFriendRequest(String userId) async {
    try {
      final response = await _dio.post('/users/friends/decline/$userId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Do'stlikdan chiqarish
  Future<Map<String, dynamic>> removeFriend(String userId) async {
    try {
      final response = await _dio.delete('/users/friends/$userId');
      return response.data;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Do'stlar ro'yxati
  Future<FriendsListResponse> getFriends({String filter = 'all'}) async {
    try {
      final response = await _dio.get(
        '/users/friends',
        queryParameters: {'status_filter': filter},
      );
      return FriendsListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  /// Kutilayotgan do'stlik so'rovlari
  Future<FriendRequestsResponse> getFriendRequests() async {
    try {
      final response = await _dio.get('/users/friends/requests');
      return FriendRequestsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  // ══════════════════════════════════════════════════════════
  // ONESIGNAL (PUSH NOTIFICATIONS)
  // ══════════════════════════════════════════════════════════

  /// OneSignal Player ID ni backendga yuborish
  Future<void> updateOneSignalPlayerId(String playerId) async {
    try {
      await _dio.patch('/users/me', data: {
        'onesignal_player_id': playerId,
      });
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

  /// Ro'yxatdan o'tish
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        // Token saqlash
        final token = data['data']['token'];
        await _saveTokens(token, token);

        return AuthResponse(
          success: true,
          isNewUser: true,
          message: data['message'],
        );
      }

      return AuthResponse(
        success: false,
        message: data['message'] ?? 'Ro\'yxatdan o\'tishda xatolik',
      );
    } on DioException catch (e) {
      return AuthResponse(success: false, message: _getErrorMessage(e));
    }
  }

  /// Tizimga kirish
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        // Token saqlash
        final token = data['data']['token'];
        await _saveTokens(token, token);

        return AuthResponse(
          success: true,
          isNewUser: false,
          message: data['message'],
        );
      }

      return AuthResponse(
        success: false,
        message: data['message'] ?? 'Kirish xatosi',
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
      final response = await _dio.get('/auth/me');
      return response.data['success'] == true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token eskirgan
        await _clearTokens();
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
  final bool hasPendingChallenge;  // Men yuborgan taklif
  final bool isBusy;  // O'yinchi boshqa o'yinda band
  final bool isOnline;
  final String? lastOnline;

  OnlinePlayer({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.level,
    required this.wins,
    required this.totalMatches,
    required this.winRate,
    this.hasPendingChallenge = false,
    this.isBusy = false,
    this.isOnline = false,
    this.lastOnline,
  });

  // Eski API uchun backward compatibility
  bool get hasActiveMatch => hasPendingChallenge || isBusy;

  factory OnlinePlayer.fromJson(Map<String, dynamic> json) {
    return OnlinePlayer(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      level: json['level'] ?? 1,
      wins: json['wins'] ?? 0,
      totalMatches: json['total_matches'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      hasPendingChallenge: json['has_pending_challenge'] ?? false,
      isBusy: json['is_busy'] ?? false,
      isOnline: json['is_online'] ?? false,
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

class AllPlayersResponse {
  final List<OnlinePlayer> players;
  final int count;
  final int totalOnline;
  final String filter;

  AllPlayersResponse({
    required this.players,
    required this.count,
    required this.totalOnline,
    required this.filter,
  });

  factory AllPlayersResponse.fromJson(Map<String, dynamic> json) {
    return AllPlayersResponse(
      players: (json['players'] as List?)
              ?.map((e) => OnlinePlayer.fromJson(e))
              .toList() ??
          [],
      count: json['count'] ?? 0,
      totalOnline: json['total_online'] ?? 0,
      filter: json['filter'] ?? 'all',
    );
  }
}

class PendingChallengesResponse {
  final List<PendingChallenge> challenges;
  final int count;

  PendingChallengesResponse({
    required this.challenges,
    required this.count,
  });

  factory PendingChallengesResponse.fromJson(Map<String, dynamic> json) {
    return PendingChallengesResponse(
      challenges: (json['challenges'] as List?)
              ?.map((e) => PendingChallenge.fromJson(e))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }
}

class PendingChallenge {
  final String id;
  final String mode;
  final int betAmount;
  final ChallengerInfo challenger;
  final DateTime createdAt;

  PendingChallenge({
    required this.id,
    required this.mode,
    required this.betAmount,
    required this.challenger,
    required this.createdAt,
  });

  factory PendingChallenge.fromJson(Map<String, dynamic> json) {
    return PendingChallenge(
      id: json['id'] ?? '',
      mode: json['mode'] ?? 'friendly',
      betAmount: json['bet_amount'] ?? 0,
      challenger: ChallengerInfo.fromJson(json['challenger'] ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class ChallengerInfo {
  final String id;
  final String? nickname;
  final String? avatarUrl;
  final int? teamStrength;

  ChallengerInfo({
    required this.id,
    this.nickname,
    this.avatarUrl,
    this.teamStrength,
  });

  factory ChallengerInfo.fromJson(Map<String, dynamic> json) {
    return ChallengerInfo(
      id: json['id'] ?? '',
      nickname: json['nickname'],
      avatarUrl: json['avatar_url'],
      teamStrength: json['team_strength'],
    );
  }
}

// ══════════════════════════════════════════════════════════
// PLAYER PROFILE MODELS
// ══════════════════════════════════════════════════════════

class PlayerProfile {
  final String id;
  final String nickname;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final String? region;

  // O'yin ma'lumotlari
  final int level;
  final int experience;
  final int? teamStrength;
  final String? favoriteTeam;
  final String? playStyle;
  final String? preferredFormation;
  final String? availableHours;

  // Ijtimoiy
  final String? telegram;
  final String? instagram;
  final String? discord;

  // Statistika
  final PlayerStats stats;

  // Status
  final bool isOnline;
  final String? lastOnline;
  final bool isVerified;
  final bool isPro;
  final bool isPublic;

  // Do'stlik
  final String friendshipStatus;

  // Challenge holati
  final bool hasPendingChallenge;
  final String? pendingChallengeId;  // Bekor qilish uchun
  final bool isBusy;  // O'yinchi boshqa o'yinda band

  // Head-to-head
  final HeadToHead headToHead;

  // Oxirgi o'yinlar
  final List<RecentMatch> recentMatches;

  final String memberSince;

  PlayerProfile({
    required this.id,
    required this.nickname,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.region,
    required this.level,
    this.experience = 0,
    this.teamStrength,
    this.favoriteTeam,
    this.playStyle,
    this.preferredFormation,
    this.availableHours,
    this.telegram,
    this.instagram,
    this.discord,
    required this.stats,
    this.isOnline = false,
    this.lastOnline,
    this.isVerified = false,
    this.isPro = false,
    this.isPublic = true,
    required this.friendshipStatus,
    this.hasPendingChallenge = false,
    this.pendingChallengeId,
    this.isBusy = false,
    required this.headToHead,
    required this.recentMatches,
    required this.memberSince,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? 'Unknown',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      region: json['region'],
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      teamStrength: json['team_strength'],
      favoriteTeam: json['favorite_team'],
      playStyle: json['play_style'],
      preferredFormation: json['preferred_formation'],
      availableHours: json['available_hours'],
      telegram: json['telegram'],
      instagram: json['instagram'],
      discord: json['discord'],
      stats: PlayerStats.fromJson(json['stats'] ?? {}),
      isOnline: json['is_online'] ?? false,
      lastOnline: json['last_online'],
      isVerified: json['is_verified'] ?? false,
      isPro: json['is_pro'] ?? false,
      isPublic: json['is_public'] ?? true,
      friendshipStatus: json['friendship_status'] ?? 'none',
      hasPendingChallenge: json['has_pending_challenge'] ?? false,
      pendingChallengeId: json['pending_challenge_id'],
      isBusy: json['is_busy'] ?? false,
      headToHead: HeadToHead.fromJson(json['head_to_head'] ?? {}),
      recentMatches: (json['recent_matches'] as List?)
              ?.map((e) => RecentMatch.fromJson(e))
              .toList() ??
          [],
      memberSince: json['member_since'] ?? '',
    );
  }
}

class PlayerStats {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final int tournamentsWon;
  final int tournamentsPlayed;

  PlayerStats({
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.winRate = 0,
    this.tournamentsWon = 0,
    this.tournamentsPlayed = 0,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      totalMatches: json['total_matches'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      tournamentsWon: json['tournaments_won'] ?? 0,
      tournamentsPlayed: json['tournaments_played'] ?? 0,
    );
  }
}

class HeadToHead {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;

  HeadToHead({
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.winRate = 0,
  });

  factory HeadToHead.fromJson(Map<String, dynamic> json) {
    return HeadToHead(
      totalMatches: json['total_matches'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
    );
  }
}

class RecentMatch {
  final String id;
  final MatchOpponent opponent;
  final String result;
  final String score;
  final String mode;
  final String? playedAt;

  RecentMatch({
    required this.id,
    required this.opponent,
    required this.result,
    required this.score,
    required this.mode,
    this.playedAt,
  });

  factory RecentMatch.fromJson(Map<String, dynamic> json) {
    return RecentMatch(
      id: json['id'] ?? '',
      opponent: MatchOpponent.fromJson(json['opponent'] ?? {}),
      result: json['result'] ?? '',
      score: json['score'] ?? '',
      mode: json['mode'] ?? '',
      playedAt: json['played_at'],
    );
  }
}

class MatchOpponent {
  final String id;
  final String nickname;
  final String? avatarUrl;

  MatchOpponent({
    required this.id,
    required this.nickname,
    this.avatarUrl,
  });

  factory MatchOpponent.fromJson(Map<String, dynamic> json) {
    return MatchOpponent(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
    );
  }
}

class FriendsListResponse {
  final List<FriendInfo> friends;
  final int total;
  final int onlineCount;

  FriendsListResponse({
    required this.friends,
    required this.total,
    required this.onlineCount,
  });

  factory FriendsListResponse.fromJson(Map<String, dynamic> json) {
    return FriendsListResponse(
      friends: (json['friends'] as List?)
              ?.map((e) => FriendInfo.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      onlineCount: json['online_count'] ?? 0,
    );
  }
}

class FriendInfo {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final int level;
  final bool isOnline;
  final String? lastOnline;
  final double winRate;

  FriendInfo({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.level,
    this.isOnline = false,
    this.lastOnline,
    this.winRate = 0,
  });

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      level: json['level'] ?? 1,
      isOnline: json['is_online'] ?? false,
      lastOnline: json['last_online'],
      winRate: (json['win_rate'] ?? 0).toDouble(),
    );
  }
}

class FriendRequestsResponse {
  final List<FriendRequest> requests;
  final int count;

  FriendRequestsResponse({
    required this.requests,
    required this.count,
  });

  factory FriendRequestsResponse.fromJson(Map<String, dynamic> json) {
    return FriendRequestsResponse(
      requests: (json['requests'] as List?)
              ?.map((e) => FriendRequest.fromJson(e))
              .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }
}

class FriendRequest {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final int level;
  final double winRate;
  final String requestedAt;

  FriendRequest({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    required this.level,
    this.winRate = 0,
    required this.requestedAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      level: json['level'] ?? 1,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      requestedAt: json['requested_at'] ?? '',
    );
  }
}

// ══════════════════════════════════════════════════════════
// MATCH RESULT MODELS
// ══════════════════════════════════════════════════════════

class MatchResultResponse {
  final bool success;
  final String message;
  final String status; // waiting_opponent, completed, disputed
  final int? ratingChange;
  final int? coinsWon;

  MatchResultResponse({
    required this.success,
    required this.message,
    required this.status,
    this.ratingChange,
    this.coinsWon,
  });

  factory MatchResultResponse.fromJson(Map<String, dynamic> json) {
    return MatchResultResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      status: json['status'] ?? 'waiting_opponent',
      ratingChange: json['rating_change'],
      coinsWon: json['coins_won'],
    );
  }
}

class ActiveMatch {
  final String id;
  final String mode;
  final MatchOpponentInfo opponent;
  final int? betAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  ActiveMatch({
    required this.id,
    required this.mode,
    required this.opponent,
    this.betAmount,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  factory ActiveMatch.fromJson(Map<String, dynamic> json) {
    return ActiveMatch(
      id: json['id'] ?? '',
      mode: json['mode'] ?? 'friendly',
      opponent: MatchOpponentInfo.fromJson(json['opponent'] ?? {}),
      betAmount: json['bet_amount'],
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.tryParse(json['accepted_at'])
          : null,
    );
  }
}

class MatchOpponentInfo {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final int? level;
  final int? teamStrength;

  MatchOpponentInfo({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.level,
    this.teamStrength,
  });

  factory MatchOpponentInfo.fromJson(Map<String, dynamic> json) {
    return MatchOpponentInfo(
      id: json['id'] ?? '',
      nickname: json['nickname'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      level: json['level'],
      teamStrength: json['team_strength'],
    );
  }
}

// ══════════════════════════════════════════════════════════
// CHAT MODELS
// ══════════════════════════════════════════════════════════

class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserNickname;
  final String? otherUserAvatar;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool hasUnread;

  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserNickname,
    this.otherUserAvatar,
    this.lastMessage,
    this.lastMessageAt,
    required this.hasUnread,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      otherUserId: json['other_user_id'] ?? '',
      otherUserNickname: json['other_user_nickname'] ?? 'Unknown',
      otherUserAvatar: json['other_user_avatar'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : null,
      hasUnread: json['has_unread'] ?? false,
    );
  }
}

class ConversationsResponse {
  final List<Conversation> conversations;
  final int total;

  ConversationsResponse({
    required this.conversations,
    required this.total,
  });

  factory ConversationsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['conversations'] as List? ?? [];
    return ConversationsResponse(
      conversations: list.map((e) => Conversation.fromJson(e)).toList(),
      total: json['total'] ?? 0,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final String? senderNickname;
  final String? senderAvatar;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.senderNickname,
    this.senderAvatar,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      content: json['content'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      senderNickname: json['sender_nickname'],
      senderAvatar: json['sender_avatar'],
    );
  }
}

class MessagesResponse {
  final List<ChatMessage> messages;
  final int total;
  final bool hasMore;

  MessagesResponse({
    required this.messages,
    required this.total,
    required this.hasMore,
  });

  factory MessagesResponse.fromJson(Map<String, dynamic> json) {
    final list = json['messages'] as List? ?? [];
    return MessagesResponse(
      messages: list.map((e) => ChatMessage.fromJson(e)).toList(),
      total: json['total'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }
}

// ══════════════════════════════════════════════════════════
// TOURNAMENT MODELS
// ══════════════════════════════════════════════════════════

class TournamentItem {
  final String id;
  final String name;
  final String? description;
  final String status;
  final String format;
  final int prizePool;
  final int entryFee;
  final int maxParticipants;
  final int participantCount;
  final DateTime? startTime;
  final bool isFeatured;
  final bool isJoined;

  TournamentItem({
    required this.id,
    required this.name,
    this.description,
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

  factory TournamentItem.fromJson(Map<String, dynamic> json) {
    return TournamentItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      format: json['format'] ?? '',
      prizePool: json['prize_pool'] ?? 0,
      entryFee: json['entry_fee'] ?? 0,
      maxParticipants: json['max_participants'] ?? 0,
      participantCount: json['participant_count'] ?? 0,
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'])
          : null,
      isFeatured: json['is_featured'] ?? false,
      isJoined: json['is_joined'] ?? false,
    );
  }
}

class TournamentsResponse {
  final List<TournamentItem> tournaments;
  final int total;

  TournamentsResponse({
    required this.tournaments,
    required this.total,
  });

  factory TournamentsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['tournaments'] as List? ?? [];
    return TournamentsResponse(
      tournaments: list.map((e) => TournamentItem.fromJson(e)).toList(),
      total: json['total'] ?? 0,
    );
  }
}

class TournamentDetail {
  final String id;
  final String name;
  final String? description;
  final String status;
  final String format;
  final int prizePool;
  final int entryFee;
  final int maxParticipants;
  final int participantCount;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isFeatured;
  final bool isJoined;
  final String? rules;
  final List<TournamentParticipant> participants;

  TournamentDetail({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.format,
    required this.prizePool,
    required this.entryFee,
    required this.maxParticipants,
    required this.participantCount,
    this.startTime,
    this.endTime,
    required this.isFeatured,
    required this.isJoined,
    this.rules,
    required this.participants,
  });

  factory TournamentDetail.fromJson(Map<String, dynamic> json) {
    final participantsList = json['participants'] as List? ?? [];
    return TournamentDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      format: json['format'] ?? '',
      prizePool: json['prize_pool'] ?? 0,
      entryFee: json['entry_fee'] ?? 0,
      maxParticipants: json['max_participants'] ?? 0,
      participantCount: json['participant_count'] ?? 0,
      startTime: json['start_time'] != null
          ? DateTime.tryParse(json['start_time'])
          : null,
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'])
          : null,
      isFeatured: json['is_featured'] ?? false,
      isJoined: json['is_joined'] ?? false,
      rules: json['rules'],
      participants: participantsList
          .map((e) => TournamentParticipant.fromJson(e))
          .toList(),
    );
  }
}

class TournamentParticipant {
  final String odoserId;
  final String nickname;
  final String? avatarUrl;
  final int? seed;

  TournamentParticipant({
    required this.odoserId,
    required this.nickname,
    this.avatarUrl,
    this.seed,
  });

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) {
    return TournamentParticipant(
      odoserId: json['user_id'] ?? '',
      nickname: json['nickname'] ?? 'Unknown',
      avatarUrl: json['avatar_url'],
      seed: json['seed'],
    );
  }
}

class TournamentBracket {
  final String tournamentId;
  final String format;
  final int totalRounds;
  final List<BracketMatch> matches;

  TournamentBracket({
    required this.tournamentId,
    required this.format,
    required this.totalRounds,
    required this.matches,
  });

  factory TournamentBracket.fromJson(Map<String, dynamic> json) {
    final matchesList = json['matches'] as List? ?? [];
    return TournamentBracket(
      tournamentId: json['tournament_id'] ?? '',
      format: json['format'] ?? '',
      totalRounds: json['total_rounds'] ?? 0,
      matches: matchesList.map((e) => BracketMatch.fromJson(e)).toList(),
    );
  }

  /// Raund bo'yicha matchlar
  List<BracketMatch> getMatchesByRound(int round) {
    return matches.where((m) => m.roundNumber == round).toList();
  }
}

class BracketMatch {
  final String id;
  final String tournamentId;
  final String? player1Id;
  final String? player2Id;
  final String? player1Nickname;
  final String? player2Nickname;
  final String? winnerId;
  final int? player1Score;
  final int? player2Score;
  final int roundNumber;
  final int matchNumber;
  final String status;
  final DateTime? scheduledTime;
  final DateTime? startedAt;
  final DateTime? completedAt;

  BracketMatch({
    required this.id,
    required this.tournamentId,
    this.player1Id,
    this.player2Id,
    this.player1Nickname,
    this.player2Nickname,
    this.winnerId,
    this.player1Score,
    this.player2Score,
    required this.roundNumber,
    required this.matchNumber,
    required this.status,
    this.scheduledTime,
    this.startedAt,
    this.completedAt,
  });

  factory BracketMatch.fromJson(Map<String, dynamic> json) {
    return BracketMatch(
      id: json['id'] ?? '',
      tournamentId: json['tournament_id'] ?? '',
      player1Id: json['player1_id'],
      player2Id: json['player2_id'],
      player1Nickname: json['player1_nickname'],
      player2Nickname: json['player2_nickname'],
      winnerId: json['winner_id'],
      player1Score: json['player1_score'],
      player2Score: json['player2_score'],
      roundNumber: json['round_number'] ?? 1,
      matchNumber: json['match_number'] ?? 1,
      status: json['status'] ?? '',
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.tryParse(json['scheduled_time'])
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
    );
  }

  bool get isCompleted => status == 'completed';
  bool get hasBothPlayers => player1Id != null && player2Id != null;
}
