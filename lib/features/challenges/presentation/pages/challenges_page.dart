// lib/features/challenges/presentation/pages/challenges_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../bloc/challenges_bloc.dart';
import '../widgets/challenge_card.dart';
import '../widgets/empty_challenges.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChallengesBloc()..add(const ChallengesLoadRequested()),
      child: const _ChallengesView(),
    );
  }
}

class _ChallengesView extends StatelessWidget {
  const _ChallengesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'CHALLENGES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<ChallengesBloc, ChallengesState>(
        listener: (context, state) {
          if (state is ChallengeAcceptedState) {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Challenge qabul qilindi! O\'yin boshlang.'),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // TODO: Navigate to match page
          } else if (state is ChallengeDeclinedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Challenge rad etildi'),
                backgroundColor: Colors.orange.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ChallengesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ChallengesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C5CE7),
              ),
            );
          }

          if (state is ChallengesLoaded) {
            if (state.challenges.isEmpty) {
              return const EmptyChallenges();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChallengesBloc>().add(const ChallengesLoadRequested());
              },
              color: const Color(0xFF6C5CE7),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.challenges.length,
                itemBuilder: (context, index) {
                  final challenge = state.challenges[index];
                  return ChallengeCard(
                    challenge: challenge,
                    onAccept: () {
                      HapticFeedback.lightImpact();
                      _showAcceptDialog(context, challenge);
                    },
                    onDecline: () {
                      HapticFeedback.lightImpact();
                      _showDeclineDialog(context, challenge);
                    },
                  );
                },
              ),
            );
          }

          if (state is ChallengesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Xatolik yuz berdi',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChallengesBloc>().add(const ChallengesLoadRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                    ),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, PendingChallenge challenge) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.green.withOpacity(0.5)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Challenge qabul qilish',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${challenge.challenger.nickname ?? 'Unknown'} sizni o\'yinga chaqirmoqda.',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            if (challenge.betAmount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFB800).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Color(0xFFFFB800)),
                    const SizedBox(width: 8),
                    Text(
                      'Stavka: ${challenge.betAmount} coin',
                      style: const TextStyle(
                        color: Color(0xFFFFB800),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Bekor qilish',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ChallengesBloc>().add(ChallengeAccepted(challenge.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Qabul qilish'),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context, PendingChallenge challenge) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.red.withOpacity(0.5)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Challenge rad etish',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          '${challenge.challenger.nickname ?? 'Unknown'} ning challenge\'ini rad etmoqchimisiz?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Bekor qilish',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ChallengesBloc>().add(ChallengeDeclined(challenge.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Rad etish'),
          ),
        ],
      ),
    );
  }
}
