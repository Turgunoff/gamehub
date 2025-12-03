import 'package:equatable/equatable.dart';

/// Base event class
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Profilni yuklash so'rovi
///
/// Ilova ochilganda yoki profile page ga kirilganda chaqiriladi.
class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

/// Profilni tozalash (logout)
///
/// Foydalanuvchi tizimdan chiqganda chaqiriladi.
class ProfileResetRequested extends ProfileEvent {
  const ProfileResetRequested();
}

/// Profilni yangilash so'rovi
///
/// Edit profile page dan ma'lumotlar saqlanayotganda chaqiriladi.
class ProfileUpdateRequested extends ProfileEvent {
  // ═══════════════════════════════════════════
  // SHAXSIY MA'LUMOTLAR
  // ═══════════════════════════════════════════
  final String? nickname;
  final String? fullName;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String? region;
  final String? bio;
  final String? language;

  // ═══════════════════════════════════════════
  // IJTIMOIY TARMOQLAR
  // ═══════════════════════════════════════════
  final String? telegram;
  final String? instagram;
  final String? youtube;
  final String? discord;

  // ═══════════════════════════════════════════
  // O'YIN MA'LUMOTLARI
  // ═══════════════════════════════════════════
  final String? pesId;
  final int? teamStrength;
  final String? favoriteTeam;
  final String? playStyle;
  final String? preferredFormation;
  final String? availableHours;

  const ProfileUpdateRequested({
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
    this.favoriteTeam,
    this.playStyle,
    this.preferredFormation,
    this.availableHours,
  });

  @override
  List<Object?> get props => [
    nickname, fullName, phone, birthDate, gender, region, bio, language,
    telegram, instagram, youtube, discord,
    pesId, teamStrength, favoriteTeam, playStyle, preferredFormation, availableHours,
  ];
}
