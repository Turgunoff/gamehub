import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      // TODO: Keyinchalik bu yerda API dan ma'lumot olamiz
      await Future.delayed(const Duration(seconds: 1)); // Imitatsiya

      // Hozircha soxta ma'lumot yuklaymiz
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          username: 'Gamer_UZ',
          phoneNumber: '+998901234567',
          pesId: '123456789',
          teamStrength: 3150,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      // TODO: Keyinchalik API ga yangi ma'lumotni yuboramiz
      await Future.delayed(const Duration(seconds: 1));

      // Muvaffaqiyatli yangilandi
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          username: event.username,
          pesId: event.pesId,
          teamStrength: event.teamStrength,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: "Yangilashda xatolik bo'ldi",
        ),
      );
    }
  }
}
