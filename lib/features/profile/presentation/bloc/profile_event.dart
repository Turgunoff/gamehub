import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileResetRequested extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  // Shaxsiy
  final String? nickname;
  final String? fullName;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String? region;
  final String? bio;
  final String? language;

  // Ijtimoiy tarmoqlar
  final String? telegram;
  final String? instagram;
  final String? youtube;
  final String? discord;

  // O'yin
  final String? pesId;
  final int? teamStrength;
  final String? availableHours;

  ProfileUpdateRequested({
    this.nickname,
    this.fullName,
    this.phone,
    this.birthDate,
    this.gender,
    this.region,
    this.bio,
    this.language,
    this.telegram,
    this.instagram,
    this.youtube,
    this.discord,
    this.pesId,
    this.teamStrength,
    this.availableHours,
  });

  @override
  List<Object?> get props => [
        nickname,
        fullName,
        phone,
        birthDate,
        gender,
        region,
        bio,
        language,
        telegram,
        instagram,
        youtube,
        discord,
        pesId,
        teamStrength,
        availableHours,
      ];
}
