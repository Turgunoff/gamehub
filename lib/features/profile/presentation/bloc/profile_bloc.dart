import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdateGameStats>(_onUpdateGameStats);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      // TODO: Implement API call to fetch profile
      // For now, emit a placeholder state
      await Future.delayed(const Duration(milliseconds: 500));

      emit(
        ProfileLoaded(
          id: event.userId,
          email: 'user@example.com',
          username: 'Gamer',
          fullName: '',
          avatarUrl: null,
          bio: '',
          skillLevel: 'beginner',
          reputationScore: 100,
          isVerified: false,
          isPremium: false,
          totalMatches: 0,
          wins: 0,
          losses: 0,
          draws: 0,
          winRate: 0.0,
          tournamentsParticipated: 0,
          tournamentWins: 0,
          country: null,
          city: null,
          language: 'uz',
          timezone: 'UTC+5',
          profileCompletionPercentage: 0,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          collectiveStrength: 0,
          collectiveStrengthProof: null,
          collectiveStrengthVerified: false,
        ),
      );
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      try {
        // TODO: Implement API call to update profile
        emit(
          currentState.copyWith(
            fullName: event.name,
            username: event.username,
            bio: event.bio,
          ),
        );
      } catch (e) {
        emit(ProfileError('Failed to update profile: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateGameStats(
    UpdateGameStats event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(
        currentState.copyWith(
          winRate: event.winRate.toDouble(),
          totalMatches: event.matches,
        ),
      );
    }
  }
}
