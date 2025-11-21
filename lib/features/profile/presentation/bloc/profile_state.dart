import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String username;
  final String phoneNumber;
  final String avatarUrl;

  // PES 2026 maxsus maydonlari
  final String pesId; // 9 xonali ID
  final int teamStrength; // Jamoa kuchi (masalan: 3150)

  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.username = '',
    this.phoneNumber = '',
    this.avatarUrl = '',
    this.pesId = '',
    this.teamStrength = 0,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? username,
    String? phoneNumber,
    String? avatarUrl,
    String? pesId,
    int? teamStrength,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      pesId: pesId ?? this.pesId,
      teamStrength: teamStrength ?? this.teamStrength,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    username,
    phoneNumber,
    avatarUrl,
    pesId,
    teamStrength,
    errorMessage,
  ];
}
