import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String userId;

  const LoadProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends ProfileEvent {
  final String name;
  final String username;
  final String bio;

  const UpdateProfile({
    required this.name,
    required this.username,
    required this.bio,
  });

  @override
  List<Object?> get props => [name, username, bio];
}

class UpdateGameStats extends ProfileEvent {
  final int winRate;
  final double kdRatio;
  final int matches;

  const UpdateGameStats({
    required this.winRate,
    required this.kdRatio,
    required this.matches,
  });

  @override
  List<Object?> get props => [winRate, kdRatio, matches];
}
