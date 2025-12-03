import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/services/onesignal_service.dart';

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

/// OTP kod yuborish
class AuthOTPSent extends AuthEvent {
  final String email;

  const AuthOTPSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// OTP kodni tekshirish
class AuthOTPVerified extends AuthEvent {
  final String email;
  final String otp;

  const AuthOTPVerified({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
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

/// OTP yuborildi
class AuthOTPSentSuccess extends AuthState {
  final String email;
  final int expiresIn;

  const AuthOTPSentSuccess({required this.email, this.expiresIn = 120});

  @override
  List<Object?> get props => [email, expiresIn];
}

/// Xatolik
class AuthError extends AuthState {
  final String message;
  final String? errorCode;
  final String? email; // OTP qayta yuborish uchun

  const AuthError({required this.message, this.errorCode, this.email});

  @override
  List<Object?> get props => [message, errorCode, email];
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
    on<AuthOTPSent>(_onAuthOTPSent);
    on<AuthOTPVerified>(_onAuthOTPVerified);
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

        emit(const AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // Xato bo'lsa ham unauthenticated
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
      await _apiService.logout();
    } catch (e) {
      // Xato bo'lsa ham chiqarish
    }

    emit(AuthUnauthenticated());
  }

  // ══════════════════════════════════════════════════════════
  // SEND OTP - Kod yuborish
  // ══════════════════════════════════════════════════════════

  Future<void> _onAuthOTPSent(
    AuthOTPSent event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.email.trim().toLowerCase();

    // Validation
    if (email.isEmpty) {
      emit(
        const AuthError(message: 'Email kiriting', errorCode: 'EMPTY_EMAIL'),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      emit(
        const AuthError(
          message: 'Email formati noto\'g\'ri',
          errorCode: 'INVALID_EMAIL',
        ),
      );
      return;
    }

    emit(const AuthLoading(message: 'Kod yuborilmoqda...'));

    final response = await _apiService.sendOTP(email);

    if (response.success) {
      emit(AuthOTPSentSuccess(email: email, expiresIn: response.expiresIn));
    } else {
      emit(
        AuthError(
          message: response.message ?? 'Kod yuborishda xatolik',
          errorCode: 'OTP_SEND_FAILED',
        ),
      );
    }
  }

  // ══════════════════════════════════════════════════════════
  // VERIFY OTP - Kodni tekshirish
  // ══════════════════════════════════════════════════════════

  Future<void> _onAuthOTPVerified(
    AuthOTPVerified event,
    Emitter<AuthState> emit,
  ) async {
    final email = event.email.trim().toLowerCase();
    final otp = event.otp.trim();

    // Validation
    if (otp.isEmpty) {
      emit(
        AuthError(
          message: 'Kodni kiriting',
          errorCode: 'EMPTY_OTP',
          email: email,
        ),
      );
      return;
    }

    if (otp.length != 6) {
      emit(
        AuthError(
          message: 'Kod 6 ta raqamdan iborat bo\'lishi kerak',
          errorCode: 'INVALID_OTP_LENGTH',
          email: email,
        ),
      );
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      emit(
        AuthError(
          message: 'Kod faqat raqamlardan iborat bo\'lishi kerak',
          errorCode: 'INVALID_OTP_FORMAT',
          email: email,
        ),
      );
      return;
    }

    emit(const AuthLoading(message: 'Tekshirilmoqda...'));

    final response = await _apiService.verifyOTP(
      email,
      otp,
      deviceInfo: DeviceService.instance.toJson(),
    );

    if (response.success) {
      // OneSignal Player ID ni backend ga yuborish
      await OneSignalService().registerPlayerIdAfterLogin();

      emit(AuthAuthenticated(isNewUser: response.isNewUser));
    } else {
      emit(
        AuthError(
          message: response.message ?? 'Kod noto\'g\'ri',
          errorCode: 'OTP_VERIFY_FAILED',
          email: email,
        ),
      );
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
