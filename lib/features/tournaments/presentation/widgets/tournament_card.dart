import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Turnir kartasi widget'i
/// Faol va kelgusi turnirlarni ko'rsatadi
class TournamentCard extends StatelessWidget {
  final String title;
  final String status;
  final String stage;
  final String prize;
  final String participants;
  final String entryFee;
  final String endTime;
  final bool isLive;
  final String? myStatus;
  final VoidCallback? onTap;

  const TournamentCard({
    super.key,
    required this.title,
    required this.status,
    required this.stage,
    required this.prize,
    required this.participants,
    required this.entryFee,
    required this.endTime,
    required this.isLive,
    this.myStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
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
          // Header section
          _buildHeader(),
          // Body section
          _buildBody(),
        ],
      ),
    );
  }

  /// Turnir kartasining header qismi
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLive
              ? [
                  Colors.redAccent.withOpacity(0.3),
                  Colors.orange.withOpacity(0.2)
                ]
              : [
                  const Color(0xFF6C5CE7).withOpacity(0.3),
                  const Color(0xFF00D9FF).withOpacity(0.2)
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Tournament icon
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
          // Tournament info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isLive
                            ? Colors.redAccent
                            : const Color(0xFF00D9FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stage,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Prize info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFFFB800),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    prize,
                    style: const TextStyle(
                      color: Color(0xFFFFB800),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
    );
  }

  /// Turnir kartasining body qismi
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Participants and time info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    participants,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.white.withOpacity(0.5),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    endTime,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // My status (if exists)
          if (myStatus != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF00FB94).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person,
                    color: Color(0xFF00FB94),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'You: $myStatus',
                    style: const TextStyle(
                      color: Color(0xFF00FB94),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onTap?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLive ? Colors.orange : const Color(0xFF6C5CE7),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLive ? 'VIEW BRACKET' : 'JOIN TOURNAMENT',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
