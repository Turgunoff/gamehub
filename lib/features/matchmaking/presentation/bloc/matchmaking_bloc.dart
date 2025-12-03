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

/// Timer tick - har sekundda
class _SearchTimerTicked extends MatchmakingEvent {
  final int duration;
  const _SearchTimerTicked(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// O'yinchilarni yuklash
class PlayersRequested extends MatchmakingEvent {
  final String? filter; // online, all
  final String? search;

  const PlayersRequested({this.filter, this.search});

  @override
  List<Object?> get props => [filter, search];
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
  final int searchDuration;

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

/// O'yinchilar yuklandi
class PlayersLoaded extends MatchmakingState {
  final List<OnlinePlayer> players;
  final int totalOnline;
  final String currentFilter;

  const PlayersLoaded({
    required this.players,
    required this.totalOnline,
    this.currentFilter = 'all',
  });

  @override
  List<Object?> get props => [players, totalOnline, currentFilter];
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

/// Loading
class MatchmakingLoading extends MatchmakingState {
  const MatchmakingLoading();
}

// ══════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════

class MatchmakingBloc extends Bloc<MatchmakingEvent, MatchmakingState> {
  final ApiService _apiService;
  Timer? _searchTimer;
  Timer? _pollTimer;
  int _searchDuration = 0;
  int _currentPosition = 1;
  int _currentQueueSize = 1;

  MatchmakingBloc({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(const MatchmakingInitial()) {
    on<MatchmakingStarted>(_onStarted);
    on<MatchmakingCancelled>(_onCancelled);
    on<MatchmakingStatusChecked>(_onStatusChecked);
    on<_SearchTimerTicked>(_onTimerTicked);
    on<PlayersRequested>(_onPlayersRequested);
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
        _currentPosition = response.position ?? 1;
        _currentQueueSize = response.queueSize ?? 1;

        emit(MatchmakingSearching(
          position: _currentPosition,
          queueSize: _currentQueueSize,
          searchDuration: _searchDuration,
        ));

        _startTimers();
      }
    } catch (e) {
      _log('Xatolik: $e');
      emit(MatchmakingError(e.toString()));
    }
  }

  void _startTimers() {
    _stopTimers();

    // Search timer - har sekundda event yuboradi
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _searchDuration++;
      add(_SearchTimerTicked(_searchDuration));
    });

    // Poll timer - har 3 sekundda status tekshiradi
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

  void _onTimerTicked(
    _SearchTimerTicked event,
    Emitter<MatchmakingState> emit,
  ) {
    if (state is MatchmakingSearching) {
      emit(MatchmakingSearching(
        position: _currentPosition,
        queueSize: _currentQueueSize,
        searchDuration: event.duration,
      ));
    }
  }

  Future<void> _onStatusChecked(
    MatchmakingStatusChecked event,
    Emitter<MatchmakingState> emit,
  ) async {
    if (state is! MatchmakingSearching) return;

    try {
      final status = await _apiService.getQueueStatus();

      if (!status.inQueue) {
        _stopTimers();
        // TODO: Match topilganmi tekshirish
      } else {
        _currentPosition = status.position ?? _currentPosition;
        _currentQueueSize = status.queueSize ?? _currentQueueSize;
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
      // O'yinchilar ro'yxatini qayta yuklash
      add(const PlayersRequested(filter: 'all'));
    } catch (e) {
      _log('Bekor qilishda xato: $e');
      // Xatolik bo'lsa ham o'yinchilarni yuklash
      add(const PlayersRequested(filter: 'all'));
    }
  }

  Future<void> _onPlayersRequested(
    PlayersRequested event,
    Emitter<MatchmakingState> emit,
  ) async {
    try {
      _log('O\'yinchilar yuklanmoqda... filter: ${event.filter}');
      emit(const MatchmakingLoading());

      final response = await _apiService.getAllPlayers(
        filter: event.filter ?? 'all',
        search: event.search,
      );

      _log('${response.count} ta o\'yinchi topildi');
      emit(PlayersLoaded(
        players: response.players,
        totalOnline: response.totalOnline,
        currentFilter: event.filter ?? 'all',
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
      // O'yinchilar ro'yxatini qayta yuklash
      add(const PlayersRequested(filter: 'all'));
    } catch (e) {
      _log('Challenge xatosi: $e');
      emit(MatchmakingError(e.toString()));
      // Xatolik bo'lsa ham ro'yxatni yangilash
      add(const PlayersRequested(filter: 'all'));
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
