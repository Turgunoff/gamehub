import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/api_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Profile BLoC - Profil boshqaruvi
///
/// Foydalanuvchi profili bilan bog'liq barcha operatsiyalar
/// (yuklash, yangilash, tozalash) shu yerda boshqariladi.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService _apiService;

  ProfileBloc({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileResetRequested>(_onResetRequested);
  }

  // ═══════════════════════════════════════════════════════════════
  // PROFILNI YUKLASH
  // ═══════════════════════════════════════════════════════════════

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    _log('Profil yuklanmoqda...');
    emit(const ProfileLoading());

    try {
      final user = await _apiService.getMyProfile();
      _log('Profil yuklandi: ${user.email}');
      _logProfile(user.profile);
      emit(ProfileLoaded(user));
    } catch (e) {
      _logError('Profil yuklashda xatolik', e);
      emit(ProfileError(_getErrorMessage(e)));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PROFILNI YANGILASH
  // ═══════════════════════════════════════════════════════════════

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    _log('Profil yangilanmoqda...');

    // Hozirgi holatni saqlash (xato bo'lsa qaytish uchun)
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentState.user));
    }

    try {
      final profile = await _apiService.updateProfile(
        nickname: event.nickname,
        fullName: event.fullName,
        phone: event.phone,
        birthDate: event.birthDate,
        gender: event.gender,
        region: event.region,
        bio: event.bio,
        language: event.language,
        telegram: event.telegram,
        instagram: event.instagram,
        youtube: event.youtube,
        discord: event.discord,
        pesId: event.pesId,
        teamStrength: event.teamStrength,
        favoriteTeam: event.favoriteTeam,
        playStyle: event.playStyle,
        preferredFormation: event.preferredFormation,
        availableHours: event.availableHours,
      );

      _log('Profil yangilandi');
      emit(ProfileUpdateSuccess(profile));

      // Yangilangan profilni qayta yuklash
      add(const ProfileLoadRequested());
    } catch (e) {
      _logError('Profil yangilashda xatolik', e);
      emit(ProfileError(_getErrorMessage(e)));

      // Xato bo'lsa eski holatga qaytish
      if (currentState is ProfileLoaded) {
        emit(currentState);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PROFILNI TOZALASH (LOGOUT)
  // ═══════════════════════════════════════════════════════════════

  Future<void> _onResetRequested(
    ProfileResetRequested event,
    Emitter<ProfileState> emit,
  ) async {
    _log('Profil tozalanmoqda...');
    emit(const ProfileInitial());
  }

  // ═══════════════════════════════════════════════════════════════
  // YORDAMCHI METODLAR
  // ═══════════════════════════════════════════════════════════════

  /// Xatolik xabarini olish
  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
    }
    return 'Xatolik yuz berdi';
  }

  /// Debug log
  void _log(String message) {
    if (kDebugMode) {
      print('📱 [ProfileBloc] $message');
    }
  }

  /// Xatolik log
  void _logError(String message, dynamic error) {
    if (kDebugMode) {
      print('❌ [ProfileBloc] $message: $error');
      if (error is DioException) {
        print('   Status: ${error.response?.statusCode}');
        print('   Data: ${error.response?.data}');
      }
    }
  }

  /// Profil ma'lumotlarini log qilish
  void _logProfile(dynamic profile) {
    if (kDebugMode && profile != null) {
      print('   - Nickname: ${profile.nickname}');
      print('   - Avatar: ${profile.avatarUrl}');
    }
  }
}
