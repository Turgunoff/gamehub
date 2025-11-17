import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String bio;
  final String skillLevel;
  final int reputationScore;
  final bool isVerified;
  final bool isPremium;

  // Stats
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final int tournamentsParticipated;
  final int tournamentWins;

  // Additional info
  final String? country;
  final String? city;
  final String language;
  final String? timezone;
  final int profileCompletionPercentage;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  // Collective Strength (PES Mobile)
  final int collectiveStrength;
  final String? collectiveStrengthProof;
  final bool collectiveStrengthVerified;

  const ProfileLoaded({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    required this.bio,
    required this.skillLevel,
    required this.reputationScore,
    required this.isVerified,
    required this.isPremium,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.tournamentsParticipated,
    required this.tournamentWins,
    this.country,
    this.city,
    required this.language,
    this.timezone,
    required this.profileCompletionPercentage,
    required this.createdAt,
    this.lastActiveAt,
    required this.collectiveStrength,
    this.collectiveStrengthProof,
    required this.collectiveStrengthVerified,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    fullName,
    avatarUrl,
    bio,
    skillLevel,
    reputationScore,
    isVerified,
    isPremium,
    totalMatches,
    wins,
    losses,
    draws,
    winRate,
    tournamentsParticipated,
    tournamentWins,
    country,
    city,
    language,
    timezone,
    profileCompletionPercentage,
    createdAt,
    lastActiveAt,
    collectiveStrength,
    collectiveStrengthProof,
    collectiveStrengthVerified,
  ];

  ProfileLoaded copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? bio,
    String? skillLevel,
    int? reputationScore,
    bool? isVerified,
    bool? isPremium,
    int? totalMatches,
    int? wins,
    int? losses,
    int? draws,
    double? winRate,
    int? tournamentsParticipated,
    int? tournamentWins,
    String? country,
    String? city,
    String? language,
    String? timezone,
    int? profileCompletionPercentage,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    int? collectiveStrength,
    String? collectiveStrengthProof,
    bool? collectiveStrengthVerified,
  }) {
    return ProfileLoaded(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      skillLevel: skillLevel ?? this.skillLevel,
      reputationScore: reputationScore ?? this.reputationScore,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      totalMatches: totalMatches ?? this.totalMatches,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      winRate: winRate ?? this.winRate,
      tournamentsParticipated: tournamentsParticipated ?? this.tournamentsParticipated,
      tournamentWins: tournamentWins ?? this.tournamentWins,
      country: country ?? this.country,
      city: city ?? this.city,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      profileCompletionPercentage: profileCompletionPercentage ?? this.profileCompletionPercentage,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      collectiveStrength: collectiveStrength ?? this.collectiveStrength,
      collectiveStrengthProof: collectiveStrengthProof ?? this.collectiveStrengthProof,
      collectiveStrengthVerified: collectiveStrengthVerified ?? this.collectiveStrengthVerified,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
