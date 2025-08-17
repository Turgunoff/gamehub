import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

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

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
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

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
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
    emit(AuthLoading());

    try {
      final user = AuthService.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (error) {
      emit(AuthError('Authentication check failed: ${error.toString()}'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await AuthService.signOut();
      emit(AuthUnauthenticated());
    } catch (error) {
      emit(AuthError('Logout failed: ${error.toString()}'));
    }
  }

  Future<void> _onAuthOTPSent(
    AuthOTPSent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await AuthService.sendOTP(email: event.email);
      emit(AuthOTPSentState(event.email));
    } catch (error) {
      emit(AuthError('Failed to send OTP: ${error.toString()}'));
    }
  }

  Future<void> _onAuthOTPVerified(
    AuthOTPVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await AuthService.verifyOTP(
        email: event.email,
        token: event.otp,
      );

      if (response.user != null) {
        emit(AuthAuthenticated(response.user!));
      } else {
        emit(AuthError('OTP verification failed'));
      }
    } catch (error) {
      emit(AuthError('OTP verification failed: ${error.toString()}'));
    }
  }
}
