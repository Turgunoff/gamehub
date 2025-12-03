// lib/features/tournaments/presentation/bloc/tournament_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

// ══════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════

abstract class TournamentEvent extends Equatable {
  const TournamentEvent();

  @override
  List<Object?> get props => [];
}

class TournamentsLoadRequested extends TournamentEvent {
  final String? status;

  const TournamentsLoadRequested({this.status});

  @override
  List<Object?> get props => [status];
}

class TournamentDetailLoadRequested extends TournamentEvent {
  final String tournamentId;

  const TournamentDetailLoadRequested(this.tournamentId);

  @override
  List<Object?> get props => [tournamentId];
}

class TournamentBracketLoadRequested extends TournamentEvent {
  final String tournamentId;

  const TournamentBracketLoadRequested(this.tournamentId);

  @override
  List<Object?> get props => [tournamentId];
}

class TournamentJoinRequested extends TournamentEvent {
  final String tournamentId;

  const TournamentJoinRequested(this.tournamentId);

  @override
  List<Object?> get props => [tournamentId];
}

class TournamentLeaveRequested extends TournamentEvent {
  final String tournamentId;

  const TournamentLeaveRequested(this.tournamentId);

  @override
  List<Object?> get props => [tournamentId];
}

// ══════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════

abstract class TournamentState extends Equatable {
  const TournamentState();

  @override
  List<Object?> get props => [];
}

class TournamentInitial extends TournamentState {}

class TournamentsLoading extends TournamentState {}

class TournamentsLoaded extends TournamentState {
  final List<TournamentItem> tournaments;

  const TournamentsLoaded(this.tournaments);

  @override
  List<Object?> get props => [tournaments];
}

class TournamentDetailLoading extends TournamentState {}

class TournamentDetailLoaded extends TournamentState {
  final TournamentDetail tournament;

  const TournamentDetailLoaded(this.tournament);

  @override
  List<Object?> get props => [tournament];
}

class TournamentBracketLoading extends TournamentState {}

class TournamentBracketLoaded extends TournamentState {
  final TournamentBracket bracket;

  const TournamentBracketLoaded(this.bracket);

  @override
  List<Object?> get props => [bracket];
}

class TournamentJoining extends TournamentState {}

class TournamentJoined extends TournamentState {
  final String message;

  const TournamentJoined(this.message);

  @override
  List<Object?> get props => [message];
}

class TournamentLeft extends TournamentState {
  final String message;

  const TournamentLeft(this.message);

  @override
  List<Object?> get props => [message];
}

class TournamentError extends TournamentState {
  final String message;

  const TournamentError(this.message);

  @override
  List<Object?> get props => [message];
}

// ══════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final ApiService _apiService = ApiService();

  TournamentBloc() : super(TournamentInitial()) {
    on<TournamentsLoadRequested>(_onTournamentsLoad);
    on<TournamentDetailLoadRequested>(_onTournamentDetailLoad);
    on<TournamentBracketLoadRequested>(_onTournamentBracketLoad);
    on<TournamentJoinRequested>(_onTournamentJoin);
    on<TournamentLeaveRequested>(_onTournamentLeave);
  }

  Future<void> _onTournamentsLoad(
    TournamentsLoadRequested event,
    Emitter<TournamentState> emit,
  ) async {
    emit(TournamentsLoading());

    try {
      final response = await _apiService.getTournaments(status: event.status);
      emit(TournamentsLoaded(response.tournaments));
    } catch (e) {
      emit(TournamentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onTournamentDetailLoad(
    TournamentDetailLoadRequested event,
    Emitter<TournamentState> emit,
  ) async {
    emit(TournamentDetailLoading());

    try {
      final tournament = await _apiService.getTournamentDetail(event.tournamentId);
      emit(TournamentDetailLoaded(tournament));
    } catch (e) {
      emit(TournamentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onTournamentBracketLoad(
    TournamentBracketLoadRequested event,
    Emitter<TournamentState> emit,
  ) async {
    emit(TournamentBracketLoading());

    try {
      final bracket = await _apiService.getTournamentBracket(event.tournamentId);
      emit(TournamentBracketLoaded(bracket));
    } catch (e) {
      emit(TournamentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onTournamentJoin(
    TournamentJoinRequested event,
    Emitter<TournamentState> emit,
  ) async {
    emit(TournamentJoining());

    try {
      final result = await _apiService.joinTournament(event.tournamentId);
      emit(TournamentJoined(result['message'] ?? 'Turnirga qo\'shildingiz!'));
    } catch (e) {
      emit(TournamentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onTournamentLeave(
    TournamentLeaveRequested event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      final result = await _apiService.leaveTournament(event.tournamentId);
      emit(TournamentLeft(result['message'] ?? 'Turnirdan chiqdingiz'));
    } catch (e) {
      emit(TournamentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
