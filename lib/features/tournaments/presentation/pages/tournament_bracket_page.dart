// lib/features/tournaments/presentation/pages/tournament_bracket_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../bloc/tournament_bloc.dart';
import '../widgets/bracket_match_card.dart';

class TournamentBracketPage extends StatelessWidget {
  final String tournamentId;
  final String tournamentName;

  const TournamentBracketPage({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TournamentBloc()..add(TournamentBracketLoadRequested(tournamentId)),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            tournamentName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<TournamentBloc, TournamentState>(
          builder: (context, state) {
            if (state is TournamentBracketLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C5CE7),
                ),
              );
            }

            if (state is TournamentBracketLoaded) {
              return _buildBracket(context, state.bracket);
            }

            if (state is TournamentError) {
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
                      state.message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<TournamentBloc>()
                            .add(TournamentBracketLoadRequested(tournamentId));
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
      ),
    );
  }

  Widget _buildBracket(BuildContext context, TournamentBracket bracket) {
    if (bracket.matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Bracket hali tayyor emas',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Turnir boshlanishi kutilmoqda',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(bracket.totalRounds, (roundIndex) {
            final round = roundIndex + 1;
            final roundMatches = bracket.getMatchesByRound(round);
            final roundName = _getRoundName(round, bracket.totalRounds);

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  // Round header
                  Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF6C5CE7).withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      roundName,
                      style: const TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Matches
                  ...roundMatches.map((match) => Padding(
                        padding: EdgeInsets.only(
                          bottom: 16,
                          top: roundIndex > 0
                              ? _calculateTopPadding(roundIndex, roundMatches.indexOf(match))
                              : 0,
                        ),
                        child: BracketMatchCard(match: match),
                      )),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  String _getRoundName(int round, int totalRounds) {
    if (round == totalRounds) return 'FINAL';
    if (round == totalRounds - 1) return 'YARIM FINAL';
    if (round == totalRounds - 2) return 'CHORAK FINAL';
    return 'ROUND $round';
  }

  double _calculateTopPadding(int roundIndex, int matchIndex) {
    // Har keyingi raund uchun matchlar orasidagi masofa ikki baravar oshadi
    final baseSpacing = 60.0;
    final multiplier = (1 << roundIndex).toDouble(); // 2^roundIndex
    return matchIndex > 0 ? baseSpacing * multiplier : baseSpacing * (multiplier / 2);
  }
}
