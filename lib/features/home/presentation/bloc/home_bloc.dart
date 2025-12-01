import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';

// ══════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Dashboard ma'lumotlarini yuklash
class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

/// Refresh qilish
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

// ══════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Boshlang'ich holat
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Yuklanmoqda
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Muvaffaqiyatli yuklandi
class HomeLoaded extends HomeState {
  final HomeDashboardResponse data;

  const HomeLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Xatolik
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// ══════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiService _apiService;

  HomeBloc({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
    on<HomeRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      _log('Dashboard yuklanmoqda...');
      final data = await _apiService.getHomeDashboard();
      _log('Dashboard yuklandi: ${data.user.nickname}');
      emit(HomeLoaded(data));
    } catch (e) {
      _log('Dashboard xatosi: $e');
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    // Eski ma'lumotlarni saqlab qolish
    final currentState = state;

    try {
      _log('Dashboard yangilanmoqda...');
      final data = await _apiService.getHomeDashboard();
      _log('Dashboard yangilandi');
      emit(HomeLoaded(data));
    } catch (e) {
      _log('Yangilash xatosi: $e');
      // Xato bo'lsa eski holatni qaytarish
      if (currentState is HomeLoaded) {
        emit(currentState);
      } else {
        emit(HomeError(e.toString()));
      }
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      print('🏠 [HomeBloc] $message');
    }
  }
}
