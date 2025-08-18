class Tournament {
  final String id;
  final String title;
  final String game;
  final String status; // "LIVE", "UPCOMING", "COMPLETED"
  final String time;
  final int currentParticipants;
  final int maxParticipants;
  final double entryFee;
  final double prizePool;
  final String imageUrl;
  final bool isLive;
  final bool isPremium;

  Tournament({
    required this.id,
    required this.title,
    required this.game,
    required this.status,
    required this.time,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.entryFee,
    required this.prizePool,
    required this.imageUrl,
    this.isLive = false,
    this.isPremium = false,
  });
}
