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
        // data: {'email': email},
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
        type: OtpType.email, // signup yoki signin uchun
      );

      // Agar user muvaffaqiyatli login/register bo'lsa
      if (response.user != null) {
        // User profili mavjudligini ta'minlash
        await _ensureUserProfile(response.user!);
      }

      return response;
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Email bilan login qilish
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Email bilan registration qilish
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      return response;
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Google bilan login
  static Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: null, // Mobile uchun null
      );
    } catch (error) {
      throw _handleAuthError(error);
    }
  }

  // Discord bilan login
  static Future<void> signInWithDiscord() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.discord,
        redirectTo: null, // Mobile uchun null
      );
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
    await _supabase.auth.signOut();
  }

  // Foydalanuvchi profili
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Profil ma'lumotlarini olish
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .single();

        return response;
      }
      return null;
    } catch (error) {
      if (error.toString().contains('Could not find the table') ||
          error.toString().contains('users')) {
        print('Users table mavjud emas. Uni yaratish kerak.');
        return null;
      }
      print('Get user profile error: $error');
      return null;
    }
  }

  // Foydalanuvchi mavjudligini tekshirish
  static Future<bool> isUserExists(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (error) {
      if (error.toString().contains('Could not find the table') ||
          error.toString().contains('users')) {
        print('Users table mavjud emas. Uni yaratish kerak.');
        return false;
      }
      print('Check user exists error: $error');
      return false;
    }
  }

  // Joriy foydalanuvchini olish
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Auth xatoliklarini boshqarish
  static String _handleAuthError(dynamic error) {
    if (error.toString().contains('Invalid login credentials')) {
      return 'Noto\'g\'ri email yoki parol';
    } else if (error.toString().contains('Email not confirmed')) {
      return 'Email tasdiqlanmagan';
    } else if (error.toString().contains('User already registered')) {
      return 'Foydalanuvchi allaqachon ro\'yxatdan o\'tgan';
    } else if (error.toString().contains('Email rate limit exceeded')) {
      return 'Email yuborish chegarasi oshdi. Keyinroq urinib ko\'ring';
    } else if (error.toString().contains('OTP expired')) {
      return 'OTP muddati tugagan. Yangi kod yuboring';
    } else if (error.toString().contains('Invalid OTP')) {
      return 'Noto\'g\'ri OTP kod';
    } else {
      return 'Xatolik yuz berdi: ${error.toString()}';
    }
  }

  // User profili mavjudligini ta'minlash
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
        await _supabase.from('users').insert({
          'id': user.id,
          'email': user.email,
          'username':
              user.email?.split('@')[0] ?? 'user_${user.id.substring(0, 8)}',
          'full_name': '',
          'avatar_url': null,
          'bio': '',
          'favorite_games': [],
          'primary_game': null,
          'skill_level': 'beginner',
          'rank': null,
          'country': null,
          'city': null,
          'is_verified': false,
          'is_coach': false,
          'is_organizer': false,
          'is_banned': false,
          'preferences': {},
          'privacy_settings': {},
          'notification_settings': {},
          'total_matches': 0,
          'wins': 0,
          'losses': 0,
          'win_rate': 0.00,
          'total_earnings': 0.00,
          'tournament_wins': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'last_active_at': DateTime.now().toIso8601String(),
          'last_login_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (error) {
      // Agar users table mavjud bo'lmasa, uni yaratish
      if (error.toString().contains('Could not find the table') ||
          error.toString().contains('users')) {
        print('Users table mavjud emas. Uni yaratish kerak.');
        print('Supabase Console da quyidagi SQL ni ishga tushiring:');
        print('''
-- Users table yaratish
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  bio TEXT,
  favorite_games TEXT[],
  primary_game TEXT,
  skill_level TEXT CHECK (skill_level IN ('beginner', 'intermediate', 'advanced', 'professional')),
  rank TEXT,
  total_playtime INTEGER DEFAULT 0,
  date_of_birth DATE,
  country TEXT,
  city TEXT,
  timezone TEXT,
  language TEXT DEFAULT 'en',
  platform TEXT CHECK (platform IN ('pc', 'mobile', 'console', 'all')),
  device_info JSONB,
  discord_id TEXT,
  steam_id TEXT,
  twitch_username TEXT,
  youtube_channel TEXT,
  social_links JSONB,
  is_verified BOOLEAN DEFAULT FALSE,
  is_premium BOOLEAN DEFAULT FALSE,
  is_coach BOOLEAN DEFAULT FALSE,
  is_organizer BOOLEAN DEFAULT FALSE,
  is_banned BOOLEAN DEFAULT FALSE,
  preferences JSONB DEFAULT '{}',
  privacy_settings JSONB DEFAULT '{}',
  notification_settings JSONB DEFAULT '{}',
  total_matches INTEGER DEFAULT 0,
  wins INTEGER DEFAULT 0,
  losses INTEGER DEFAULT 0,
  win_rate DECIMAL(5,2) DEFAULT 0.00,
  total_earnings DECIMAL(10,2) DEFAULT 0.00,
  tournament_wins INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes yaratish
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_username ON public.users(username);
CREATE INDEX idx_users_skill_level ON public.users(skill_level);
CREATE INDEX idx_users_primary_game ON public.users(primary_game);
CREATE INDEX idx_users_country ON public.users(country);
CREATE INDEX idx_users_is_coach ON public.users(is_coach);
CREATE INDEX idx_users_is_organizer ON public.users(is_organizer);
CREATE INDEX idx_users_last_active_at ON public.users(last_active_at);

-- RLS ni yoqish
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Security policies yaratish
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Public profiles ko'rish uchun
CREATE POLICY "Public profile access" ON public.users
  FOR SELECT USING (
    is_banned = FALSE AND 
    is_verified = TRUE
  );
        ''');
      } else {
        print('Profile creation error: $error');
      }
    }
  }
}
