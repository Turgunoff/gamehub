import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamehub/core/services/api_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService _apiService = ApiService();

  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileResetRequested>(_onResetRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    print('📥 [ProfileBloc] Profil ma\'lumotlarini yuklash so\'rovi');
    emit(ProfileLoading());

    try {
      print('🔄 [ProfileBloc] API so\'rovi: GET /users/me');
      final user = await _apiService.getMyProfile();
      print('✅ [ProfileBloc] Profil ma\'lumotlari muvaffaqiyatli yuklandi');
      print('📊 [ProfileBloc] User ID: ${user.id}');
      print('📊 [ProfileBloc] Email: ${user.email}');
      if (user.profile != null) {
        print('📊 [ProfileBloc] Profile ma\'lumotlari:');
        print('   - Nickname: ${user.profile!.nickname}');
        print('   - PES ID: ${user.profile!.pesId}');
        print('   - Team Strength: ${user.profile!.teamStrength}');
        print('   - Region: ${user.profile!.region}');
        print('   - Bio: ${user.profile!.bio}');
        print('   - Avatar URL: ${user.profile!.avatarUrl}');
      } else {
        print('⚠️ [ProfileBloc] Profile ma\'lumotlari mavjud emas');
      }
      emit(ProfileLoaded(user));
    } catch (e) {
      print('❌ [ProfileBloc] Xatolik yuz berdi: $e');
      emit(ProfileError(_getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    print('📝 [ProfileBloc] Profilni yangilash so\'rovi');
    print('📤 [ProfileBloc] Yuborilayotgan ma\'lumotlar:');
    print('   - Nickname: ${event.nickname}');
    print('   - PES ID: ${event.pesId}');
    print('   - Team Strength: ${event.teamStrength}');
    print('   - Region: ${event.region}');
    print('   - Bio: ${event.bio}');

    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentState.user));
    }

    try {
      print('🔄 [ProfileBloc] API so\'rovi: PATCH /users/me');
      final profile = await _apiService.updateProfile(
        nickname: event.nickname,
        pesId: event.pesId,
        teamStrength: event.teamStrength,
        region: event.region,
        bio: event.bio,
      );
      print('✅ [ProfileBloc] Profil muvaffaqiyatli yangilandi');
      print('📊 [ProfileBloc] Yangilangan profil ma\'lumotlari:');
      print('   - Nickname: ${profile.nickname}');
      print('   - PES ID: ${profile.pesId}');
      print('   - Team Strength: ${profile.teamStrength}');
      print('   - Region: ${profile.region}');
      print('   - Bio: ${profile.bio}');
      print('   - Avatar URL: ${profile.avatarUrl}');
      emit(ProfileUpdateSuccess(profile));

      // Profilni qayta yuklash
      print('🔄 [ProfileBloc] Profilni qayta yuklash...');
      add(ProfileLoadRequested());
    } catch (e) {
      print('❌ [ProfileBloc] Profilni yangilashda xatolik: $e');
      if (e is DioException) {
        print('❌ [ProfileBloc] Status Code: ${e.response?.statusCode}');
        print('❌ [ProfileBloc] Response Data: ${e.response?.data}');
      }
      emit(ProfileError(_getErrorMessage(e)));

      // Xato bo'lsa eski holatga qaytish
      if (currentState is ProfileLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onResetRequested(
    ProfileResetRequested event,
    Emitter<ProfileState> emit,
  ) async {
    print('🔄 [ProfileBloc] Profil holati tozalanmoqda...');
    emit(ProfileInitial());
    print('✅ [ProfileBloc] Profil holati tozalandi');
  }

  String _getErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
    }
    return 'Xatolik yuz berdi';
  }
}
