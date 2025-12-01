import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';

// ══════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════

abstract class MatchmakingEvent extends Equatable {
  const MatchmakingEvent();

  @override
  List<Object?> get props => [];
}

/// Queuega qo'shilish
class MatchmakingStarted extends MatchmakingEvent {
  final String mode;

  const MatchmakingStarted({this.mode = 'ranked'});

  @override
  List<Object?> get props => [mode];
}

/// Queuedan chiqish
class MatchmakingCancelled extends MatchmakingEvent {
  const MatchmakingCancelled();
}

/// Queue holatini tekshirish
class MatchmakingStatusChecked extends MatchmakingEvent {
  const MatchmakingStatusChecked();
}

/// Online o'yinchilarni yuklash
class OnlinePlayersRequested extends MatchmakingEvent {
  const OnlinePlayersRequested();
}

/// Challenge yuborish
class ChallengeSent extends MatchmakingEvent {
  final String opponentId;
  final String mode;

  const ChallengeSent({
    required this.opponentId,
    this.mode = 'friendly',
  });

  @override
  List<Object?> get props => [opponentId, mode];
}

/// Reset state
class MatchmakingReset extends MatchmakingEvent {
  const MatchmakingReset();
}

// ══════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════

abstract class MatchmakingState extends Equatable {
  const MatchmakingState();

  @override
  List<Object?> get props => [];
}

/// Boshlang'ich holat
class MatchmakingInitial extends MatchmakingState {
  const MatchmakingInitial();
}

/// Qidirilmoqda
class MatchmakingSearching extends MatchmakingState {
  final int position;
  final int queueSize;
  final int searchDuration; // seconds

  const MatchmakingSearching({
    required this.position,
    required this.queueSize,
    required this.searchDuration,
  });

  @override
  List<Object?> get props => [position, queueSize, searchDuration];
}

/// Raqib topildi
class MatchmakingMatchFound extends MatchmakingState {
  final String matchId;
  final OnlinePlayer opponent;

  const MatchmakingMatchFound({
    required this.matchId,
    required this.opponent,
  });

  @override
  List<Object?> get props => [matchId, opponent];
}

/// Online o'yinchilar yuklandi
class OnlinePlayersLoaded extends MatchmakingState {
  final List<OnlinePlayer> players;
  final int totalOnline;

  const OnlinePlayersLoaded({
    required this.players,
    required this.totalOnline,
  });

  @override
  List<Object?> get props => [players, totalOnline];
}

/// Challenge yuborildi
class ChallengeSentSuccess extends MatchmakingState {
  final String matchId;
  final String opponentNickname;

  const ChallengeSentSuccess({
    required this.matchId,
    required this.opponentNickname,
  });

  @override
  List<Object?> get props => [matchId, opponentNickname];
}

/// Xatolik
class MatchmakingError extends MatchmakingState {
  final String message;

  const MatchmakingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Bekor qilindi
class MatchmakingCancelledState extends MatchmakingState {
  const MatchmakingCancelledState();
}

// ══════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════

class MatchmakingBloc extends Bloc<MatchmakingEvent, MatchmakingState> {
  final ApiService _apiService;
  Timer? _searchTimer;
  Timer? _pollTimer;
  int _searchDuration = 0;

  MatchmakingBloc({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(const MatchmakingInitial()) {
    on<MatchmakingStarted>(_onStarted);
    on<MatchmakingCancelled>(_onCancelled);
    on<MatchmakingStatusChecked>(_onStatusChecked);
    on<OnlinePlayersRequested>(_onOnlinePlayersRequested);
    on<ChallengeSent>(_onChallengeSent);
    on<MatchmakingReset>(_onReset);
  }

  Future<void> _onStarted(
    MatchmakingStarted event,
    Emitter<MatchmakingState> emit,
  ) async {
    try {
      _log('Matchmaking boshlandi: ${event.mode}');
      _searchDuration = 0;

      // Queuega qo'shilish
      final response = await _apiService.joinMatchmakingQueue(mode: event.mode);

      if (response.isMatchFound) {
        _log('Raqib topildi: ${response.opponent?.nickname}');
        _stopTimers();
        emit(MatchmakingMatchFound(
          matchId: response.matchId!,
          opponent: response.opponent!,
        ));
      } else {
        _log('Qidirilmoqda... Position: ${response.position}');
        emit(MatchmakingSearching(
          position: response.position ?? 1,
          queueSize: response.queueSize ?? 1,
          searchDuration: _searchDuration,
        ));

        // Timer boshlash
        _startSearchTimer(emit);
        _startPolling();
      }
    } catch (e) {
      _log('Xatolik: $e');
      emit(MatchmakingError(e.toString()));
    }
  }

  void _startSearchTimer(Emitter<MatchmakingState> emit) {
    _searchTimer?.cancel();
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _searchDuration++;
      if (state is MatchmakingSearching) {
        final current = state as MatchmakingSearching;
        emit(MatchmakingSearching(
          position: current.position,
          queueSize: current.queueSize,
          searchDuration: _searchDuration,
        ));
      }
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      add(const MatchmakingStatusChecked());
    });
  }

  void _stopTimers() {
    _searchTimer?.cancel();
    _pollTimer?.cancel();
    _searchTimer = null;
    _pollTimer = null;
  }

  Future<void> _onStatusChecked(
    MatchmakingStatusChecked event,
    Emitter<MatchmakingState> emit,
  ) async {
    if (state is! MatchmakingSearching) return;

    try {
      final status = await _apiService.getQueueStatus();

      if (!status.inQueue) {
        // Queueda emas - match topilgan bo'lishi mumkin
        // Yoki bekor qilingan
        _stopTimers();
      }
    } catch (e) {
      _log('Status tekshirishda xato: $e');
    }
  }

  Future<void> _onCancelled(
    MatchmakingCancelled event,
    Emitter<MatchmakingState> emit,
  ) async {
    try {
      _log('Matchmaking bekor qilindi');
      _stopTimers();
      await _apiService.leaveMatchmakingQueue();
      emit(const MatchmakingCancelledState());
    } catch (e) {
      _log('Bekor qilishda xato: $e');
      emit(const MatchmakingCancelledState());
    }
  }

  Future<void> _onOnlinePlayersRequested(
    OnlinePlayersRequested event,
    Emitter<MatchmakingState> emit,
  ) async {
    try {
      _log('Online o\'yinchilar yuklanmoqda...');
      final response = await _apiService.getOnlinePlayers();
      _log('${response.count} ta o\'yinchi topildi');
      emit(OnlinePlayersLoaded(
        players: response.players,
        totalOnline: response.totalOnline,
      ));
    } catch (e) {
      _log('Xatolik: $e');
      emit(MatchmakingError(e.toString()));
    }
  }

  Future<void> _onChallengeSent(
    ChallengeSent event,
    Emitter<MatchmakingState> emit,
  ) async {
    try {
      _log('Challenge yuborilmoqda: ${event.opponentId}');
      final response = await _apiService.sendChallenge(
        opponentId: event.opponentId,
        mode: event.mode,
      );
      _log('Challenge yuborildi: ${response.matchId}');
      emit(ChallengeSentSuccess(
        matchId: response.matchId,
        opponentNickname: response.opponent?.nickname ?? 'Unknown',
      ));
    } catch (e) {
      _log('Challenge xatosi: $e');
      emit(MatchmakingError(e.toString()));
    }
  }

  Future<void> _onReset(
    MatchmakingReset event,
    Emitter<MatchmakingState> emit,
  ) async {
    _stopTimers();
    _searchDuration = 0;
    emit(const MatchmakingInitial());
  }

  void _log(String message) {
    if (kDebugMode) {
      print('🎮 [MatchmakingBloc] $message');
    }
  }

  @override
  Future<void> close() {
    _stopTimers();
    return super.close();
  }
}
