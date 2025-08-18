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
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      emit(
        const ProfileLoaded(
          name: 'Alex Thompson',
          username: '@alexthompson',
          bio: 'Playing PUBG Mobile',
          level: 25,
          isOnline: true,
          winRate: 65,
          kdRatio: 3.2,
          matches: 342,
          totalPlaytime: 124,
          tournamentsWon: 12,
          friendsCount: 463,
          onlineFriends: 23,
        ),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(
        currentState.copyWith(
          name: event.name,
          username: event.username,
          bio: event.bio,
        ),
      );
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
          winRate: event.winRate,
          kdRatio: event.kdRatio,
          matches: event.matches,
        ),
      );
    }
  }
}
