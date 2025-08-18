import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Email OTP yuborish - avtomatik registration/login
  static Future<void> sendOTP({required String email}) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null, // Web uchun, mobile da null
        shouldCreateUser: true, // Yangi user yaratish
      );
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // OTP kod bilan login/registration qilish
  static Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      // Agar user muvaffaqiyatli login/register bo'lsa
      if (response.user != null) {
        // User profili mavjudligini ta'minlash
        await _ensureUserProfile(response.user!);
        // Last login ni yangilash
        await _updateLastLogin(response.user!.id);
      }

      return response;
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Google bilan login (Fixed)
  static Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: null,
      );
      
      // Profile yaratish auth state change da amalga oshiriladi
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Discord bilan login (Fixed)
  static Future<void> signInWithDiscord() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.discord,
        redirectTo: null,
      );
      
      // Profile yaratish auth state change da amalga oshiriladi
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Auth state stream
  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  // Logout
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Foydalanuvchi profili olish (Enhanced)
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        return response;
      }
      return null;
    } catch (error) {
      print('Get user profile error: $error');
      return null;
    }
  }

  // User profilini yangilash
  static Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // updated_at ni avtomatik qo'shish
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', user.id);

      return true;
    } catch (error) {
      print('Update user profile error: $error');
      return false;
    }
  }

  // Username mavjudligini tekshirish
  static Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (error) {
      print('Check username availability error: $error');
      return false;
    }
  }

  // Joriy foydalanuvchini olish
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // User ni ban qilish (admin uchun)
  static Future<bool> banUser(String userId, String reason) async {
    try {
      await _supabase
          .from('users')
          .update({
        'is_banned': true,
        'ban_reason': reason,
        'banned_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);

      return true;
    } catch (error) {
      print('Ban user error: $error');
      return false;
    }
  }

  // Last login ni yangilash
  static Future<void> _updateLastLogin(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({
        'last_login_at': DateTime.now().toIso8601String(),
        'last_active_at': DateTime.now().toIso8601String(),
      })
          .eq('id', userId);
    } catch (error) {
      print('Update last login error: $error');
    }
  }

  // Enhanced error handling
  static String _handleAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid login credentials') || 
        errorString.contains('invalid credentials')) {
      return 'Email yoki parol noto\'g\'ri';
    } else if (errorString.contains('email not confirmed')) {
      return 'Email tasdiqlanmagan';
    } else if (errorString.contains('user already registered')) {
      return 'Bu email bilan allaqachon ro\'yxatdan o\'tilgan';
    } else if (errorString.contains('email rate limit exceeded') ||
               errorString.contains('rate limit')) {
      return 'Juda ko\'p urinish. 5 daqiqa kutib, qayta urinib ko\'ring';
    } else if (errorString.contains('otp expired') ||
               errorString.contains('token expired')) {
      return 'Kod muddati tugagan. Yangi kod so\'rang';
    } else if (errorString.contains('invalid otp') ||
               errorString.contains('invalid token')) {
      return 'Noto\'g\'ri kod kiritildi';
    } else if (errorString.contains('network') ||
               errorString.contains('connection')) {
      return 'Internet aloqasi bilan muammo. Qayta urinib ko\'ring';
    } else if (errorString.contains('timeout')) {
      return 'Vaqt tugadi. Qayta urinib ko\'ring';
    } else {
      return 'Xatolik yuz berdi. Qayta urinib ko\'ring';
    }
  }

  // Enhanced user profile creation
  static Future<void> _ensureUserProfile(User user) async {
    try {
      // Profil mavjudligini tekshirish
      final profileResponse = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // Agar profil mavjud bo'lmasa, yangi profil yaratish
      if (profileResponse == null) {
        // Username ni unique qilish
        String baseUsername = user.email?.split('@')[0] ?? 'user';
        String username = await _generateUniqueUsername(baseUsername);

        await _supabase.from('users').insert({
          'id': user.id,
          'email': user.email,
          'username': username,
          'full_name': user.userMetadata?['full_name'] ?? '',
          'avatar_url': user.userMetadata?['avatar_url'],
          'bio': '',
          
          // Gaming ma'lumotlar
          'favorite_games': [],
          'primary_game': null,
          'skill_level': 'beginner',
          'rank': null,
          'total_playtime': 0,
          'gaming_style': null,
          'favorite_game_mode': null,
          'preferred_team_size': 5,
          
          // Profil ma'lumotlari
          'country': null,
          'city': null,
          'timezone': null,
          'language': 'en',
          'profile_completion_percentage': 0,
          'verification_status': 'pending',
          'reputation_score': 100,
          
          // Platform
          'platform': 'mobile',
          'device_info': {},
          
          // Social
          'discord_id': null,
          'steam_id': null,
          'twitch_username': null,
          'youtube_channel': null,
          'social_links': {},
          
          // Account status
          'is_verified': false,
          'is_premium': false,
          'is_coach': false,
          'is_organizer': false,
          'is_banned': false,
          
          // Team
          'current_team_id': null,
          'team_role': null,
          'team_join_date': null,
          
          // Coaching
          'coach_hourly_rate': 0.00,
          'coach_availability': {},
          'coach_specialization': [],
          'coach_rating': 0.00,
          'total_coaching_hours': 0,
          
          // Settings
          'preferences': {
            'theme': 'dark',
            'language': 'uz',
            'notifications_enabled': true,
          },
          'privacy_settings': {
            'profile_visible': true,
            'show_online_status': true,
            'allow_friend_requests': true,
          },
          'notification_settings': {
            'tournament_updates': true,
            'team_invitations': true,
            'match_reminders': true,
            'coaching_sessions': true,
          },
          
          // Statistics
          'total_matches': 0,
          'wins': 0,
          'losses': 0,
          'draws': 0,
          'win_rate': 0.00,
          'average_score': 0.00,
          'highest_score': 0,
          
          // Tournament stats
          'tournaments_participated': 0,
          'tournaments_organized': 0,
          'tournament_wins': 0,
          'best_tournament_position': null,
          'last_tournament_date': null,
          
          // Financial
          'total_earnings': 0.00,
          'current_balance': 0.00,
          
          // Timestamps
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'last_active_at': DateTime.now().toIso8601String(),
          'last_login_at': DateTime.now().toIso8601String(),
        });

        print('User profile created successfully for ${user.email}');
      } else {
        print('User profile already exists for ${user.email}');
        // Existing user uchun last_login ni yangilash
        await _updateLastLogin(user.id);
      }
    } catch (error) {
      print('Profile creation error: $error');
      rethrow;
    }
  }

  // Unique username yaratish
  static Future<String> _generateUniqueUsername(String baseUsername) async {
    // Faqat harflar va raqamlarni qoldirish
    baseUsername = baseUsername.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    
    if (baseUsername.isEmpty) {
      baseUsername = 'user';
    }
    
    String username = baseUsername;
    int counter = 1;
    
    while (!(await isUsernameAvailable(username))) {
      username = '${baseUsername}_$counter';
      counter++;
      
      // 50 dan ortiq urinishdan keyin random raqam qo'shish
      if (counter > 50) {
        final random = DateTime.now().millisecondsSinceEpoch % 10000;
        username = '${baseUsername}_$random';
        break;
      }
    }
    
    return username;
  }

  // Email format validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Password strength check (agar kerak bo'lsa)
  static Map<String, dynamic> checkPasswordStrength(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length >= 8;
    
    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialCharacters) strength++;
    if (hasMinLength) strength++;
    
    String strengthText = '';
    if (strength <= 2) {
      strengthText = 'Zaif';
    } else if (strength <= 3) {
      strengthText = 'O\'rtacha';
    } else if (strength <= 4) {
      strengthText = 'Kuchli';
    } else {
      strengthText = 'Juda kuchli';
    }
    
    return {
      'strength': strength,
      'strengthText': strengthText,
      'hasUppercase': hasUppercase,
      'hasLowercase': hasLowercase,
      'hasDigits': hasDigits,
      'hasSpecialCharacters': hasSpecialCharacters,
      'hasMinLength': hasMinLength,
    };
  }
}