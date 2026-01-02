import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/onesignal_service.dart';
import '../../../../core/services/websocket_service.dart';

// ══════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// App ishga tushganda token tekshirish
class AuthCheckRequested extends AuthEvent {}

/// Tizimdan chiqish
class AuthLogoutRequested extends AuthEvent {}

/// Ro'yxatdan o'tish
class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;

  const AuthRegisterRequested({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [username, email, password];
}

/// Tizimga kirish
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Xatolikni tozalash
class AuthErrorCleared extends AuthEvent {}

/// OTP tasdiqlash (ro'yxatdan o'tish uchun)
class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String code;

  const AuthVerifyOtpRequested({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}

/// OTP qayta yuborish
class AuthResendOtpRequested extends AuthEvent {
  final String email;

  const AuthResendOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

// ══════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Boshlang'ich holat
class AuthInitial extends AuthState {}

/// Yuklanmoqda
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Tizimga kirgan
class AuthAuthenticated extends AuthState {
  final bool isNewUser;
  final DailyBonusInfo? dailyBonus;

  const AuthAuthenticated({this.isNewUser = false, this.dailyBonus});

  @override
  List<Object?> get props => [isNewUser, dailyBonus];
}

/// Tizimga kirmagan
class AuthUnauthenticated extends AuthState {}

/// Xatolik
class AuthError extends AuthState {
  final String message;
  final String? errorCode;

  const AuthError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

/// OTP talab qilinmoqda (ro'yxatdan o'tish uchun)
class AuthOtpRequired extends AuthState {
  final String email;

  const AuthOtpRequired({required this.email});

  @override
  List<Object?> get props => [email];
}

/// OTP qayta yuborildi
class AuthOtpResent extends AuthState {}

// ══════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService = ApiService();

  bool get isAuthenticated => _apiService.isLoggedIn;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthVerifyOtpRequested>(_onAuthVerifyOtpRequested);
    on<AuthResendOtpRequested>(_onAuthResendOtpRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthErrorCleared>(_onAuthErrorCleared);
  }

  // ══════════════════════════════════════════════════════════
  // AUTH CHECK - Token tekshirish
  // ══════════════════════════════════════════════════════════

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Tekshirilmoqda...'));

    try {
      final isAuth = await _apiService.checkAuth();

      if (isAuth) {
        // OneSignal Player ID ni backend ga yuborish
        await OneSignalService().registerPlayerIdAfterLogin();

        // WebSocket ga ulanish
        await WebSocketService().connect();

        emit(const AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // ══════════════════════════════════════════════════════════
  // LOGOUT - Tizimdan chiqish
  // ══════════════════════════════════════════════════════════

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Chiqilmoqda...'));

    try {
      WebSocketService().disconnect();
      await _apiService.logout();
    } catch (e) {
      // Xato bo'lsa ham chiqarish
    }

    emit(AuthUnauthenticated());
  }

  // ══════════════════════════════════════════════════════════
  // REGISTER - Ro'yxatdan o'tish (1-qadam: OTP yuborish)
  // ══════════════════════════════════════════════════════════

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    final username = event.username.trim();
    final email = event.email.trim().toLowerCase();
    final password = event.password;

    // Validation
    if (username.isEmpty) {
      emit(const AuthError(
        message: 'Username kiriting',
        errorCode: 'EMPTY_USERNAME',
      ));
      return;
    }

    if (username.length < 4) {
      emit(const AuthError(
        message: 'Username kamida 4 ta belgi bo\'lishi kerak',
        errorCode: 'SHORT_USERNAME',
      ));
      return;
    }

    // Format validation: only letters, numbers, and dashes, but not starting/ending with dash
    final usernameRegex = RegExp(r'^[a-zA-Z0-9]+([-][a-zA-Z0-9]+)*$');
    if (!usernameRegex.hasMatch(username)) {
      emit(const AuthError(
        message: 'Username faqat harflar, raqamlar va chiziqchadan iborat bo\'lishi kerak. Boshi va oxiri chiziqcha bilan bo\'lmasligi kerak',
        errorCode: 'INVALID_USERNAME_FORMAT',
      ));
      return;
    }

    if (email.isEmpty) {
      emit(const AuthError(
        message: 'Email kiriting',
        errorCode: 'EMPTY_EMAIL',
      ));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(const AuthError(
        message: 'Email formati noto\'g\'ri',
        errorCode: 'INVALID_EMAIL',
      ));
      return;
    }

    if (password.isEmpty) {
      emit(const AuthError(
        message: 'Parol kiriting',
        errorCode: 'EMPTY_PASSWORD',
      ));
      return;
    }

    if (password.length < 6) {
      emit(const AuthError(
        message: 'Parol kamida 6 ta belgi bo\'lishi kerak',
        errorCode: 'SHORT_PASSWORD',
      ));
      return;
    }

    emit(const AuthLoading(message: 'Tekshirilmoqda...'));

    final response = await _apiService.register(
      username: username,
      email: email,
      password: password,
    );

    if (response.success) {
      // OTP yuborildi, tasdiqlash sahifasiga o'tish kerak
      emit(AuthOtpRequired(email: email));
    } else {
      emit(AuthError(
        message: response.message ?? 'Ro\'yxatdan o\'tishda xatolik',
        errorCode: 'REGISTER_FAILED',
      ));
    }
  }

  // ══════════════════════════════════════════════════════════
  // VERIFY OTP - OTP tasdiqlash (2-qadam: account yaratish)
  // ══════════════════════════════════════════════════════════

  Future<void> _onAuthVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.code.isEmpty || event.code.length != 6) {
      emit(const AuthError(
        message: '6 raqamli kodni kiriting',
        errorCode: 'INVALID_CODE',
      ));
      return;
    }

    emit(const AuthLoading(message: 'Tasdiqlanmoqda...'));

    final response = await _apiService.verifyRegistration(
      email: event.email,
      code: event.code,
    );

    if (response.success) {
      await OneSignalService().registerPlayerIdAfterLogin();
      await WebSocketService().connect();
      emit(const AuthAuthenticated(isNewUser: true));
    } else {
      emit(AuthError(
        message: response.message ?? 'Tasdiqlashda xatolik',
        errorCode: 'VERIFY_FAILED',
      ));
    }
  }

  // ══════════════════════════════════════════════════════════
  // RESEND OTP - OTP qayta yuborish
  // ══════════════════════════════════════════════════════════

  Future<void> _onAuthResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Yuborilmoqda...'));

    final response = await _apiService.resendRegistrationCode(email: event.email);

    if (response.success) {
      emit(AuthOtpResent());
      // Keyin yana OTP required holatiga qaytish
      await Future.delayed(const Duration(milliseconds: 100));
      emit(AuthOtpRequired(email: event.email));
    } else {
      emit(AuthError(
        message: response.message ?? 'Kod yuborishda xatolik',
        errorCode: 'RESEND_FAILED',
      ));
    }
  }

  // ══════════════════════════════════════════════════════════
  // LOGIN - Tizimga kirish
  // ══════════════════════════════════════════════════════════

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.email.trim().toLowerCase();
    final password = event.password;

    // Validation
    if (email.isEmpty) {
      emit(const AuthError(
        message: 'Email kiriting',
        errorCode: 'EMPTY_EMAIL',
      ));
      return;
    }

    if (!_isValidEmail(email)) {
      emit(const AuthError(
        message: 'Email formati noto\'g\'ri',
        errorCode: 'INVALID_EMAIL',
      ));
      return;
    }

    if (password.isEmpty) {
      emit(const AuthError(
        message: 'Parol kiriting',
        errorCode: 'EMPTY_PASSWORD',
      ));
      return;
    }

    emit(const AuthLoading(message: 'Kirilmoqda...'));

    final response = await _apiService.login(
      email: email,
      password: password,
    );

    if (response.success) {
      await OneSignalService().registerPlayerIdAfterLogin();
      await WebSocketService().connect();
      emit(AuthAuthenticated(dailyBonus: response.dailyBonus));
    } else {
      emit(AuthError(
        message: response.message ?? 'Kirish xatosi',
        errorCode: 'LOGIN_FAILED',
      ));
    }
  }

  // ══════════════════════════════════════════════════════════
  // ERROR CLEAR - Xatolikni tozalash
  // ══════════════════════════════════════════════════════════

  Future<void> _onAuthErrorCleared(
    AuthErrorCleared event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUnauthenticated());
  }

  // ══════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }
}
