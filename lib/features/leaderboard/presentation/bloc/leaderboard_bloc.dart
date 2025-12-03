// lib/features/leaderboard/presentation/bloc/leaderboard_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

// ══════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LeaderboardLoadRequested extends LeaderboardEvent {
  final int limit;

  const LeaderboardLoadRequested({this.limit = 50});

  @override
  List<Object?> get props => [limit];
}

// ══════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardItem> players;

  const LeaderboardLoaded(this.players);

  @override
  List<Object?> get props => [players];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// ══════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final ApiService _apiService = ApiService();

  LeaderboardBloc() : super(LeaderboardInitial()) {
    on<LeaderboardLoadRequested>(_onLeaderboardLoad);
  }

  Future<void> _onLeaderboardLoad(
    LeaderboardLoadRequested event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());

    try {
      final players = await _apiService.getLeaderboard(limit: event.limit);
      emit(LeaderboardLoaded(players));
    } catch (e) {
      emit(LeaderboardError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
