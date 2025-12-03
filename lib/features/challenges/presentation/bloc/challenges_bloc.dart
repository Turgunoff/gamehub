// lib/features/challenges/presentation/bloc/challenges_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/websocket_service.dart';

// ══════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════

abstract class ChallengesEvent extends Equatable {
  const ChallengesEvent();

  @override
  List<Object?> get props => [];
}

class ChallengesLoadRequested extends ChallengesEvent {
  const ChallengesLoadRequested();
}

class ChallengeAccepted extends ChallengesEvent {
  final String matchId;
  const ChallengeAccepted(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class ChallengeDeclined extends ChallengesEvent {
  final String matchId;
  const ChallengeDeclined(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class ChallengeSent extends ChallengesEvent {
  final String opponentId;
  final String mode;
  final int? betAmount;

  const ChallengeSent({
    required this.opponentId,
    required this.mode,
    this.betAmount,
  });

  @override
  List<Object?> get props => [opponentId, mode, betAmount];
}

class ChallengeReceived extends ChallengesEvent {
  final Map<String, dynamic> data;
  const ChallengeReceived(this.data);

  @override
  List<Object?> get props => [data];
}

// ══════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════

abstract class ChallengesState extends Equatable {
  const ChallengesState();

  @override
  List<Object?> get props => [];
}

class ChallengesInitial extends ChallengesState {
  const ChallengesInitial();
}

class ChallengesLoading extends ChallengesState {
  const ChallengesLoading();
}

class ChallengesLoaded extends ChallengesState {
  final List<PendingChallenge> challenges;

  const ChallengesLoaded(this.challenges);

  @override
  List<Object?> get props => [challenges];
}

class ChallengesError extends ChallengesState {
  final String message;

  const ChallengesError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChallengeActionLoading extends ChallengesState {
  final String matchId;
  const ChallengeActionLoading(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class ChallengeAcceptedState extends ChallengesState {
  final String matchId;
  const ChallengeAcceptedState(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class ChallengeDeclinedState extends ChallengesState {
  final String matchId;
  const ChallengeDeclinedState(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

class ChallengeSentState extends ChallengesState {
  final String matchId;
  const ChallengeSentState(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

// ══════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════

class ChallengesBloc extends Bloc<ChallengesEvent, ChallengesState> {
  final ApiService _apiService = ApiService();
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription? _wsSubscription;

  ChallengesBloc() : super(const ChallengesInitial()) {
    on<ChallengesLoadRequested>(_onLoadRequested);
    on<ChallengeAccepted>(_onAccepted);
    on<ChallengeDeclined>(_onDeclined);
    on<ChallengeSent>(_onSent);
    on<ChallengeReceived>(_onReceived);

    // WebSocket events listen
    _wsSubscription = _wsService.onEvent.listen((event) {
      if (event.type == 'new_challenge') {
        add(ChallengeReceived(event.data));
      }
    });
  }

  Future<void> _onLoadRequested(
    ChallengesLoadRequested event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(const ChallengesLoading());

    try {
      final response = await _apiService.getPendingChallenges();
      emit(ChallengesLoaded(response.challenges));
    } catch (e) {
      emit(ChallengesError(e.toString()));
    }
  }

  Future<void> _onAccepted(
    ChallengeAccepted event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(ChallengeActionLoading(event.matchId));

    try {
      await _apiService.acceptChallenge(event.matchId);
      emit(ChallengeAcceptedState(event.matchId));
      // Refresh list
      add(const ChallengesLoadRequested());
    } catch (e) {
      emit(ChallengesError(e.toString()));
    }
  }

  Future<void> _onDeclined(
    ChallengeDeclined event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(ChallengeActionLoading(event.matchId));

    try {
      await _apiService.declineChallenge(event.matchId);
      emit(ChallengeDeclinedState(event.matchId));
      // Refresh list
      add(const ChallengesLoadRequested());
    } catch (e) {
      emit(ChallengesError(e.toString()));
    }
  }

  Future<void> _onSent(
    ChallengeSent event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(const ChallengesLoading());

    try {
      final response = await _apiService.sendChallenge(
        opponentId: event.opponentId,
        mode: event.mode,
        betAmount: event.betAmount ?? 0,
      );
      emit(ChallengeSentState(response.matchId));
    } catch (e) {
      emit(ChallengesError(e.toString()));
    }
  }

  Future<void> _onReceived(
    ChallengeReceived event,
    Emitter<ChallengesState> emit,
  ) async {
    // Reload challenges when new one received
    add(const ChallengesLoadRequested());
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    return super.close();
  }
}
