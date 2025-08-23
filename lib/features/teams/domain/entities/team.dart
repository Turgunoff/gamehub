// lib/features/teams/domain/entities/team.dart
class Team {
  final String id;
  final String name;
  final String logoUrl;
  final String description;
  final int memberCount;
  final int maxMembers;
  final String skillLevel; // 'Beginner', 'Intermediate', 'Advanced', 'Pro'
  final String region;
  final bool isOpen;
  final bool isVerified;
  final String captainId;
  final String captainName;
  final DateTime createdAt;
  final List<String> achievements;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final List<TeamMember> members;
  final String? requirements;

  const Team({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.memberCount,
    required this.maxMembers,
    required this.skillLevel,
    required this.region,
    required this.isOpen,
    required this.isVerified,
    required this.captainId,
    required this.captainName,
    required this.createdAt,
    required this.achievements,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
    required this.members,
    this.requirements,
  });
}

class TeamMember {
  final String id;
  final String name;
  final String username;
  final String role; // 'Captain', 'Co-Captain', 'Player', 'Sub'
  final String position; // 'GK', 'DEF', 'MID', 'FWD'
  final int rating;
  final String avatarUrl;
  final bool isOnline;
  final DateTime joinedAt;

  const TeamMember({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.position,
    required this.rating,
    required this.avatarUrl,
    required this.isOnline,
    required this.joinedAt,
  });
}
