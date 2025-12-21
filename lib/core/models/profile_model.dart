class ProfileModel {
  final String? fullName;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String? region;
  final String? bio;
  final String? language;

  // Ijtimoiy
  final String? telegram;
  final String? instagram;
  final String? youtube;
  final String? discord;

  // O'yin
  final String? pesId;
  final int? teamStrength;
  final String? favoriteTeam;
  final String? playStyle;
  final String? preferredFormation;
  final String? availableHours;

  ProfileModel({
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

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      fullName: json['full_name'],
      phone: json['phone'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      region: json['region'],
      bio: json['bio'],
      language: json['language'],
      telegram: json['telegram'],
      instagram: json['instagram'],
      youtube: json['youtube'],
      discord: json['discord'],
      pesId: json['pes_id'],
      teamStrength: json['team_strength'],
      favoriteTeam: json['favorite_team'],
      playStyle: json['play_style'],
      preferredFormation: json['preferred_formation'],
      availableHours: json['available_hours'],
    );
  }
}

class StatsModel {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final int tournamentsPlayed;
  final int tournamentsWon;

  StatsModel({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.tournamentsPlayed,
    required this.tournamentsWon,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      totalMatches: json['total_matches'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      tournamentsPlayed: json['tournaments_played'] ?? 0,
      tournamentsWon: json['tournaments_won'] ?? 0,
    );
  }
}

class UserMeModel {
  final int id;
  final String email;
  final String? nickname;
  final String? avatarUrl;
  final int level;
  final int experience;
  final int coins;
  final int gems;
  final ProfileModel? profile;
  final StatsModel? stats;
  final bool isVerified;
  final bool isPro;
  final bool isPublic;
  final bool isOnline;
  final String? memberSince;

  UserMeModel({
    required this.id,
    required this.email,
    this.nickname,
    this.avatarUrl,
    required this.level,
    required this.experience,
    required this.coins,
    required this.gems,
    this.profile,
    this.stats,
    required this.isVerified,
    required this.isPro,
    required this.isPublic,
    required this.isOnline,
    this.memberSince,
  });

  factory UserMeModel.fromJson(Map<String, dynamic> json) {
    return UserMeModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      email: json['email'] ?? '',
      nickname: json['nickname'],
      avatarUrl: json['avatar_url'],
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      coins: json['coins'] ?? 0,
      gems: json['gems'] ?? 0,
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : null,
      stats: json['stats'] != null
          ? StatsModel.fromJson(json['stats'])
          : null,
      isVerified: json['is_verified'] ?? false,
      isPro: json['is_pro'] ?? false,
      isPublic: json['is_public'] ?? true,
      isOnline: json['is_online'] ?? false,
      memberSince: json['member_since'],
    );
  }

  // Backward compatibility
  String get idStr => id.toString();
}
