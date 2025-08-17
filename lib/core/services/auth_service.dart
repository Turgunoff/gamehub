import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

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

  // Joriy foydalanuvchi
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Auth state stream
  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  // Logout
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Xatolikni handle qilish
  static String _handleAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Noto\'g\'ri email yoki parol';
        case 'Email not confirmed':
          return 'Email tasdiqlanmagan';
        case 'Too many requests':
          return 'Juda ko\'p so\'rov yuborildi. Iltimos, kutib turing';
        case 'User not found':
          return 'Foydalanuvchi topilmadi';
        case 'User already registered':
          return 'Bu email allaqachon ro\'yxatdan o\'tgan';
        default:
          return error.message;
      }
    }
    return 'Xatolik yuz berdi. Iltimos, qayta urinib ko\'ring';
  }

  // Foydalanuvchi profili
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Profil ma'lumotlarini olish
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        return response;
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  // User mavjudligini tekshirish
  static Future<bool> isUserExists(String email) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (error) {
      return false;
    }
  }
}
