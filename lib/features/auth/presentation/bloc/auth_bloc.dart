import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthOTPSent extends AuthEvent {
  final String email;

  const AuthOTPSent(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthOTPVerified extends AuthEvent {
  final String email;
  final String otp;

  const AuthOTPVerified({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String? loadingMessage;

  const AuthLoading({this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

class AuthAuthenticated extends AuthState {
  final bool isNewUser;

  const AuthAuthenticated({this.isNewUser = false});

  @override
  List<Object?> get props => [isNewUser];
}

class AuthUnauthenticated extends AuthState {}

class AuthOTPSentState extends AuthState {
  final String email;

  const AuthOTPSentState(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthError extends AuthState {
  final String message;
  final String? errorCode;

  const AuthError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService = ApiService();

  bool get isAuthenticated => _apiService.isLoggedIn;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthOTPSent>(_onAuthOTPSent);
    on<AuthOTPVerified>(_onAuthOTPVerified);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(loadingMessage: 'Checking authentication...'));

    try {
      final isAuth = await _apiService.checkAuth();
      if (isAuth) {
        emit(const AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (error) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(loadingMessage: 'Signing out...'));

    try {
      await _apiService.logout();
      emit(AuthUnauthenticated());
    } catch (error) {
      emit(const AuthError('Logout failed', errorCode: 'LOGOUT_FAILED'));
    }
  }

  Future<void> _onAuthOTPSent(
    AuthOTPSent event,
    Emitter<AuthState> emit,
  ) async {
    // Email validation
    if (!_isValidEmail(event.email)) {
      emit(const AuthError('Invalid email format', errorCode: 'INVALID_EMAIL'));
      return;
    }

    emit(const AuthLoading(loadingMessage: 'Sending verification code...'));

    try {
      final response = await _apiService.sendOTP(event.email);
      if (response.success) {
        emit(AuthOTPSentState(event.email));
      } else {
        emit(AuthError(response.message ?? 'Failed to send code', errorCode: 'OTP_SEND_FAILED'));
      }
    } catch (error) {
      emit(AuthError(error.toString(), errorCode: 'OTP_SEND_FAILED'));
    }
  }

  Future<void> _onAuthOTPVerified(
    AuthOTPVerified event,
    Emitter<AuthState> emit,
  ) async {
    // OTP validation
    if (event.otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(event.otp)) {
      emit(const AuthError('Invalid OTP format', errorCode: 'INVALID_OTP_FORMAT'));
      return;
    }

    emit(const AuthLoading(loadingMessage: 'Verifying code...'));

    try {
      final response = await _apiService.verifyOTP(event.email, event.otp);

      if (response.success) {
        emit(AuthAuthenticated(isNewUser: response.isNewUser));
      } else {
        emit(AuthError(
          response.message ?? 'OTP verification failed',
          errorCode: 'OTP_VERIFICATION_FAILED',
        ));
      }
    } catch (error) {
      emit(AuthError(error.toString(), errorCode: 'OTP_VERIFICATION_ERROR'));
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
