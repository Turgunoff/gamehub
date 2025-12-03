// lib/features/matches/presentation/bloc/match_result_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';

// ══════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════

abstract class MatchResultEvent extends Equatable {
  const MatchResultEvent();

  @override
  List<Object?> get props => [];
}

/// Faol o'yinlarni yuklash
class ActiveMatchesLoadRequested extends MatchResultEvent {
  const ActiveMatchesLoadRequested();
}

/// Natija yuborish
class MatchResultSubmitted extends MatchResultEvent {
  final String matchId;
  final int myScore;
  final int opponentScore;
  final String? screenshotUrl;

  const MatchResultSubmitted({
    required this.matchId,
    required this.myScore,
    required this.opponentScore,
    this.screenshotUrl,
  });

  @override
  List<Object?> get props => [matchId, myScore, opponentScore, screenshotUrl];
}

// ══════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════

abstract class MatchResultState extends Equatable {
  const MatchResultState();

  @override
  List<Object?> get props => [];
}

class MatchResultInitial extends MatchResultState {}

class MatchResultLoading extends MatchResultState {}

class ActiveMatchesLoaded extends MatchResultState {
  final List<ActiveMatch> matches;

  const ActiveMatchesLoaded(this.matches);

  @override
  List<Object?> get props => [matches];
}

class MatchResultSubmitting extends MatchResultState {}

class MatchResultSuccess extends MatchResultState {
  final MatchResultResponse response;

  const MatchResultSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class MatchResultError extends MatchResultState {
  final String message;

  const MatchResultError(this.message);

  @override
  List<Object?> get props => [message];
}

// ══════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════

class MatchResultBloc extends Bloc<MatchResultEvent, MatchResultState> {
  final ApiService _apiService = ApiService();

  MatchResultBloc() : super(MatchResultInitial()) {
    on<ActiveMatchesLoadRequested>(_onActiveMatchesLoad);
    on<MatchResultSubmitted>(_onMatchResultSubmit);
  }

  Future<void> _onActiveMatchesLoad(
    ActiveMatchesLoadRequested event,
    Emitter<MatchResultState> emit,
  ) async {
    emit(MatchResultLoading());

    try {
      final matches = await _apiService.getActiveMatches();
      emit(ActiveMatchesLoaded(matches));
    } catch (e) {
      emit(MatchResultError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onMatchResultSubmit(
    MatchResultSubmitted event,
    Emitter<MatchResultState> emit,
  ) async {
    emit(MatchResultSubmitting());

    try {
      final response = await _apiService.submitMatchResult(
        matchId: event.matchId,
        myScore: event.myScore,
        opponentScore: event.opponentScore,
        screenshotUrl: event.screenshotUrl,
      );
      emit(MatchResultSuccess(response));
    } catch (e) {
      emit(MatchResultError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
