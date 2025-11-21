import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

// Profilni yuklash
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

// Profilni yangilash (Ism, PES ID, Jamoa kuchi)
class UpdateProfile extends ProfileEvent {
  final String username;
  final String pesId;
  final int teamStrength;

  const UpdateProfile({
    required this.username,
    required this.pesId,
    required this.teamStrength,
  });

  @override
  List<Object?> get props => [username, pesId, teamStrength];
}
