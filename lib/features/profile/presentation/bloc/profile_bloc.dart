import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final _supabase = Supabase.instance.client;

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
      // Fetch user profile from Supabase
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', event.userId)
          .single();

      // Parse win_rate from string to double
      final winRateStr = data['win_rate']?.toString() ?? '0.00';
      final winRate = double.tryParse(winRateStr) ?? 0.0;

      emit(
        ProfileLoaded(
          id: data['id'] ?? '',
          email: data['email'] ?? '',
          username: data['username'] ?? '',
          fullName: data['full_name'] ?? '',
          avatarUrl: data['avatar_url'],
          bio: data['bio'] ?? '',
          skillLevel: data['skill_level'] ?? 'beginner',
          reputationScore: data['reputation_score'] ?? 100,
          isVerified: data['is_verified'] ?? false,
          isPremium: data['is_premium'] ?? false,
          totalMatches: data['total_matches'] ?? 0,
          wins: data['wins'] ?? 0,
          losses: data['losses'] ?? 0,
          draws: data['draws'] ?? 0,
          winRate: winRate,
          tournamentsParticipated: data['tournaments_participated'] ?? 0,
          tournamentWins: data['tournament_wins'] ?? 0,
          country: data['country'],
          city: data['city'],
          language: data['language'] ?? 'en',
          timezone: data['timezone'] ?? 'UTC+5',
          profileCompletionPercentage: data['profile_completion_percentage'] ?? 0,
          createdAt: DateTime.parse(data['created_at']),
          lastActiveAt: data['last_active_at'] != null
              ? DateTime.parse(data['last_active_at'])
              : null,
          collectiveStrength: data['collective_strength'] ?? 0,
          collectiveStrengthProof: data['collective_strength_proof'],
          collectiveStrengthVerified: data['collective_strength_verified'] ?? false,
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
        // Update profile in Supabase
        await _supabase
            .from('users')
            .update({
              'full_name': event.name,
              'username': event.username,
              'bio': event.bio,
            })
            .eq('id', currentState.id);

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
