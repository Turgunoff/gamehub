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

  const AuthAuthenticated({this.isNewUser = false});

  @override
  List<Object?> get props => [isNewUser];
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
  // REGISTER - Ro'yxatdan o'tish
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

    if (username.length < 3) {
      emit(const AuthError(
        message: 'Username kamida 3 ta belgi bo\'lishi kerak',
        errorCode: 'SHORT_USERNAME',
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

    emit(const AuthLoading(message: 'Ro\'yxatdan o\'tilmoqda...'));

    final response = await _apiService.register(
      username: username,
      email: email,
      password: password,
    );

    if (response.success) {
      await OneSignalService().registerPlayerIdAfterLogin();
      await WebSocketService().connect();
      emit(AuthAuthenticated(isNewUser: response.isNewUser));
    } else {
      emit(AuthError(
        message: response.message ?? 'Ro\'yxatdan o\'tishda xatolik',
        errorCode: 'REGISTER_FAILED',
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
      emit(const AuthAuthenticated());
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
