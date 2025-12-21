import 'package:flutter/material.dart';
import 'package:cyberpitch/core/widgets/section_header.dart';

class LiveTournamentsSection extends StatelessWidget {
  final VoidCallback? onViewAllTap;

  const LiveTournamentsSection({
    super.key,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'LIVE TOURNAMENTS',
          actionText: 'View All',
          onActionTap: onViewAllTap,
          icon: Icons.emoji_events,
        ),
        const SizedBox(height: 16),
        TournamentCard(
          title: 'PES CHAMPIONS CUP',
          status: 'LIVE NOW',
          prize: '50,000',
          participants: '128/128',
          entryFee: '500',
          timeLeft: 'Finals Stage',
          isLive: true,
        ),
        const SizedBox(height: 12),
        TournamentCard(
          title: 'WEEKEND LEAGUE',
          status: 'Starting in 2h 15m',
          prize: '25,000',
          participants: '89/256',
          entryFee: '250',
          timeLeft: 'Registration Open',
          isLive: false,
        ),
        const SizedBox(height: 12),
        TournamentCard(
          title: 'BEGINNER FRIENDLY',
          status: 'Tomorrow 20:00',
          prize: '10,000',
          participants: '12/64',
          entryFee: 'FREE',
          timeLeft: 'Team Strength < 3000',
          isLive: false,
        ),
      ],
    );
  }
}

class TournamentCard extends StatelessWidget {
  final String title;
  final String status;
  final String prize;
  final String participants;
  final String entryFee;
  final String timeLeft;
  final bool isLive;

  const TournamentCard({
    super.key,
    required this.title,
    required this.status,
    required this.prize,
    required this.participants,
    required this.entryFee,
    required this.timeLeft,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLive
              ? Colors.redAccent.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Tournament Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLive
                        ? [Colors.redAccent, Colors.orange]
                        : [const Color(0xFF6C5CE7), const Color(0xFF00D9FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Tournament Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (isLive) ...[
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.access_time,
                            color: Colors.white.withOpacity(0.5),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              status,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Icon(
                          Icons.people,
                          color: Colors.white.withOpacity(0.5),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            participants,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Prize Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Color(0xFFFFB800),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        prize,
                        style: const TextStyle(
                          color: Color(0xFFFFB800),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Entry: $entryFee',
                    style: TextStyle(
                      color: entryFee == 'FREE'
                          ? const Color(0xFF00FB94)
                          : Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (timeLeft.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                timeLeft,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

