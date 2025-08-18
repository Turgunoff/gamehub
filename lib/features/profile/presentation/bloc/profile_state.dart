import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String username;
  final String bio;
  final int level;
  final bool isOnline;
  final int winRate;
  final double kdRatio;
  final int matches;
  final int totalPlaytime;
  final int tournamentsWon;
  final int friendsCount;
  final int onlineFriends;

  const ProfileLoaded({
    required this.name,
    required this.username,
    required this.bio,
    required this.level,
    required this.isOnline,
    required this.winRate,
    required this.kdRatio,
    required this.matches,
    required this.totalPlaytime,
    required this.tournamentsWon,
    required this.friendsCount,
    required this.onlineFriends,
  });

  @override
  List<Object?> get props => [
    name,
    username,
    bio,
    level,
    isOnline,
    winRate,
    kdRatio,
    matches,
    totalPlaytime,
    tournamentsWon,
    friendsCount,
    onlineFriends,
  ];

  ProfileLoaded copyWith({
    String? name,
    String? username,
    String? bio,
    int? level,
    bool? isOnline,
    int? winRate,
    double? kdRatio,
    int? matches,
    int? totalPlaytime,
    int? tournamentsWon,
    int? friendsCount,
    int? onlineFriends,
  }) {
    return ProfileLoaded(
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      level: level ?? this.level,
      isOnline: isOnline ?? this.isOnline,
      winRate: winRate ?? this.winRate,
      kdRatio: kdRatio ?? this.kdRatio,
      matches: matches ?? this.matches,
      totalPlaytime: totalPlaytime ?? this.totalPlaytime,
      tournamentsWon: tournamentsWon ?? this.tournamentsWon,
      friendsCount: friendsCount ?? this.friendsCount,
      onlineFriends: onlineFriends ?? this.onlineFriends,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
