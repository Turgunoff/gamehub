class ProfileModel {
  final String id;
  final String userId;

  // Shaxsiy
  final String? nickname;
  final String? fullName;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final String? avatarUrl;
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

  // Resurslar
  final int coins;
  final int gems;
  final int level;
  final int experience;

  // Statistika
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final int tournamentsWon;
  final int tournamentsPlayed;
  final double winRate;

  // Status
  final bool isVerified;
  final bool isPro;
  final bool isPublic;
  final bool showStats;
  final String? lastOnline;

  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.userId,
    this.nickname,
    this.fullName,
    this.phone,
    this.birthDate,
    this.gender,
    this.avatarUrl,
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
    required this.coins,
    required this.gems,
    required this.level,
    required this.experience,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.tournamentsWon,
    required this.tournamentsPlayed,
    required this.winRate,
    required this.isVerified,
    required this.isPro,
    required this.isPublic,
    required this.showStats,
    this.lastOnline,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      userId: json['user_id'],

      // Shaxsiy
      nickname: json['nickname'],
      fullName: json['full_name'],
      phone: json['phone'],
      birthDate: json['birth_date'],
      gender: json['gender'],
      avatarUrl: json['avatar_url'],
      region: json['region'],
      bio: json['bio'],
      language: json['language'],

      // Ijtimoiy
      telegram: json['telegram'],
      instagram: json['instagram'],
      youtube: json['youtube'],
      discord: json['discord'],

      // O'yin
      pesId: json['pes_id'],
      teamStrength: json['team_strength'],
      favoriteTeam: json['favorite_team'],
      playStyle: json['play_style'],
      preferredFormation: json['preferred_formation'],
      availableHours: json['available_hours'],

      // Resurslar
      coins: json['coins'] ?? 0,
      gems: json['gems'] ?? 0,
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,

      // Statistika
      totalMatches: json['total_matches'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      tournamentsWon: json['tournaments_won'] ?? 0,
      tournamentsPlayed: json['tournaments_played'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),

      // Status
      isVerified: json['is_verified'] ?? false,
      isPro: json['is_pro'] ?? false,
      isPublic: json['is_public'] ?? true,
      showStats: json['show_stats'] ?? true,
      lastOnline: json['last_online'],

      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class UserMeModel {
  final String id;
  final String email;
  final bool isActive;
  final DateTime createdAt;
  final ProfileModel? profile;

  UserMeModel({
    required this.id,
    required this.email,
    required this.isActive,
    required this.createdAt,
    this.profile,
  });

  factory UserMeModel.fromJson(Map<String, dynamic> json) {
    return UserMeModel(
      id: json['id'],
      email: json['email'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'])
          : null,
    );
  }
}
