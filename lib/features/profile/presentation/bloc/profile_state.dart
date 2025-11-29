import 'package:equatable/equatable.dart';
import '../../../../core/models/profile_model.dart';

/// Profile BLoC holatlari
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Boshlang'ich holat - hech narsa yuklanmagan
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Profil yuklanmoqda
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profil muvaffaqiyatli yuklandi
class ProfileLoaded extends ProfileState {
  final UserMeModel user;

  const ProfileLoaded(this.user);

  /// Profilni olish (qisqa yo'l)
  ProfileModel? get profile => user.profile;

  @override
  List<Object?> get props => [user];
}

/// Profil yangilanmoqda (loading ko'rsatish uchun)
class ProfileUpdating extends ProfileState {
  final UserMeModel user;

  const ProfileUpdating(this.user);

  @override
  List<Object?> get props => [user];
}

/// Profil muvaffaqiyatli yangilandi
class ProfileUpdateSuccess extends ProfileState {
  final ProfileModel profile;

  const ProfileUpdateSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Xatolik yuz berdi
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
