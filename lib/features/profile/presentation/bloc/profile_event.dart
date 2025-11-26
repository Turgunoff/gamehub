import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileResetRequested extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String? nickname;
  final String? pesId;
  final int? teamStrength;
  final String? region;
  final String? bio;

  ProfileUpdateRequested({
    this.nickname,
    this.pesId,
    this.teamStrength,
    this.region,
    this.bio,
  });

  @override
  List<Object?> get props => [nickname, pesId, teamStrength, region, bio];
}
