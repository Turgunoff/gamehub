import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';

// Enhanced Events
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

// Social login events
class AuthGoogleSignInRequested extends AuthEvent {}

class AuthDiscordSignInRequested extends AuthEvent {}

// Profile events
class AuthProfileUpdateRequested extends AuthEvent {
  final Map<String, dynamic> updates;

  const AuthProfileUpdateRequested(this.updates);

  @override
  List<Object?> get props => [updates];
}

class AuthUsernameCheckRequested extends AuthEvent {
  final String username;

  const AuthUsernameCheckRequested(this.username);

  @override
  List<Object?> get props => [username];
}

// Enhanced States
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
  final User user;
  final Map<String, dynamic>? userProfile;

  const AuthAuthenticated(this.user, {this.userProfile});

  @override
  List<Object?> get props => [user, userProfile];
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

// New states
class AuthProfileUpdated extends AuthState {
  final Map<String, dynamic> updatedProfile;

  const AuthProfileUpdated(this.updatedProfile);

  @override
  List<Object?> get props => [updatedProfile];
}

class AuthUsernameChecked extends AuthState {
  final String username;
  final bool isAvailable;

  const AuthUsernameChecked(this.username, this.isAvailable);

  @override
  List<Object?> get props => [username, isAvailable];
}

// Enhanced Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  StreamSubscription? _authSubscription;

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isCoach => _userProfile?['is_coach'] == true;
  bool get isOrganizer => _userProfile?['is_organizer'] == true;
  bool get isPremium => _userProfile?['is_premium'] == true;
  bool get isVerified => _userProfile?['is_verified'] == true;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthOTPSent>(_onAuthOTPSent);
    on<AuthOTPVerified>(_onAuthOTPVerified);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthDiscordSignInRequested>(_onDiscordSignInRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthUsernameCheckRequested>(_onUsernameCheckRequested);

    // Auth state changes ni tinglab turish (Fixed)
    _authSubscription = AuthService.authStateChanges.listen((
      supabaseAuthState,
    ) {
      if (supabaseAuthState.event == AuthChangeEvent.signedIn) {
        _currentUser = supabaseAuthState.session?.user;
        if (_currentUser != null) {
          _loadUserProfile();
        }
      } else if (supabaseAuthState.event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        _userProfile = null;
      }
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(loadingMessage: 'Checking authentication...'));

    try {
      final user = AuthService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        await _loadUserProfile();
        emit(AuthAuthenticated(user, userProfile: _userProfile));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (error) {
      emit(
        AuthError(
          'Authentication check failed',
          errorCode: 'AUTH_CHECK_FAILED',
        ),
      );
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(loadingMessage: 'Signing out...'));

    try {
      await AuthService.signOut();
      _currentUser = null;
      _userProfile = null;
      emit(AuthUnauthenticated());
    } catch (error) {
      emit(AuthError('Logout failed', errorCode: 'LOGOUT_FAILED'));
    }
  }

  Future<void> _onAuthOTPSent(
    AuthOTPSent event,
    Emitter<AuthState> emit,
  ) async {
    // Email validation
    if (!AuthService.isValidEmail(event.email)) {
      emit(const AuthError('Invalid email format', errorCode: 'INVALID_EMAIL'));
      return;
    }

    emit(const AuthLoading(loadingMessage: 'Sending verification code...'));

    try {
      await AuthService.sendOTP(email: event.email);
      emit(AuthOTPSentState(event.email));
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
      emit(
        const AuthError('Invalid OTP format', errorCode: 'INVALID_OTP_FORMAT'),
      );
      return;
    }

    emit(const AuthLoading(loadingMessage: 'Verifying code...'));

    try {
      final response = await AuthService.verifyOTP(
        email: event.email,
        token: event.otp,
      );

      if (response.user != null) {
        _currentUser = response.user!;
        await _loadUserProfile();
        emit(AuthAuthenticated(response.user!, userProfile: _userProfile));
      } else {
        emit(
          const AuthError(
            'OTP verification failed',
            errorCode: 'OTP_VERIFICATION_FAILED',
          ),
        );
      }
    } catch (error) {
      emit(AuthError(error.toString(), errorCode: 'OTP_VERIFICATION_ERROR'));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(loadingMessage: 'Signing in with Google...'));

    try {
      await AuthService.signInWithGoogle();
      // User ma'lumotlari auth state change da handle bo'ladi
    } catch (error) {
      emit(AuthError(error.toString(), errorCode: 'GOOGLE_SIGNIN_ERROR'));
    }
  }

  Future<void> _onDiscordSignInRequested(
    AuthDiscordSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(loadingMessage: 'Signing in with Discord...'));

    try {
      await AuthService.signInWithDiscord();
      // User ma'lumotlari auth state change da handle bo'ladi
    } catch (error) {
      emit(AuthError(error.toString(), errorCode: 'DISCORD_SIGNIN_ERROR'));
    }
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_currentUser == null) {
      emit(
        const AuthError(
          'User not authenticated',
          errorCode: 'NOT_AUTHENTICATED',
        ),
      );
      return;
    }

    emit(const AuthLoading(loadingMessage: 'Updating profile...'));

    try {
      final success = await AuthService.updateUserProfile(event.updates);

      if (success) {
        await _loadUserProfile();
        emit(AuthProfileUpdated(_userProfile ?? {}));
        // Return to authenticated state with updated profile
        emit(AuthAuthenticated(_currentUser!, userProfile: _userProfile));
      } else {
        emit(
          const AuthError(
            'Failed to update profile',
            errorCode: 'PROFILE_UPDATE_FAILED',
          ),
        );
      }
    } catch (error) {
      emit(AuthError(error.toString(), errorCode: 'PROFILE_UPDATE_ERROR'));
    }
  }

  Future<void> _onUsernameCheckRequested(
    AuthUsernameCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isAvailable = await AuthService.isUsernameAvailable(event.username);
      emit(AuthUsernameChecked(event.username, isAvailable));
    } catch (error) {
      emit(
        AuthError(
          'Failed to check username availability',
          errorCode: 'USERNAME_CHECK_FAILED',
        ),
      );
    }
  }

  // Helper method to load user profile
  Future<void> _loadUserProfile() async {
    try {
      _userProfile = await AuthService.getUserProfile();
    } catch (error) {
      print('Failed to load user profile: $error');
      _userProfile = null;
    }
  }

  // Helper methods for UI
  String get displayName {
    if (_userProfile?['full_name']?.isNotEmpty == true) {
      return _userProfile!['full_name'];
    }
    return _userProfile?['username'] ??
        _currentUser?.email?.split('@')[0] ??
        'User';
  }

  String get avatarUrl {
    return _userProfile?['avatar_url'] ?? '';
  }

  int get profileCompletionPercentage {
    return _userProfile?['profile_completion_percentage'] ?? 0;
  }

  // Cleanup method
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _currentUser = null;
    _userProfile = null;
    return super.close();
  }
}
