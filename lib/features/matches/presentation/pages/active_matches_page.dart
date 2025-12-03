// lib/features/matches/presentation/pages/active_matches_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/match_result_bloc.dart';
import '../widgets/active_match_card.dart';
import '../widgets/empty_active_matches.dart';
import 'submit_result_page.dart';

class ActiveMatchesPage extends StatelessWidget {
  const ActiveMatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MatchResultBloc()..add(const ActiveMatchesLoadRequested()),
      child: const _ActiveMatchesView(),
    );
  }
}

class _ActiveMatchesView extends StatelessWidget {
  const _ActiveMatchesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'FAOL O\'YINLAR',
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
      body: BlocConsumer<MatchResultBloc, MatchResultState>(
        listener: (context, state) {
          if (state is MatchResultError) {
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
          if (state is MatchResultLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6C5CE7),
              ),
            );
          }

          if (state is ActiveMatchesLoaded) {
            if (state.matches.isEmpty) {
              return const EmptyActiveMatches();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<MatchResultBloc>()
                    .add(const ActiveMatchesLoadRequested());
              },
              color: const Color(0xFF6C5CE7),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.matches.length,
                itemBuilder: (context, index) {
                  final match = state.matches[index];
                  return ActiveMatchCard(
                    match: match,
                    onSubmitResult: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmitResultPage(match: match),
                        ),
                      ).then((_) {
                        // Qaytganda refresh qilish
                        context
                            .read<MatchResultBloc>()
                            .add(const ActiveMatchesLoadRequested());
                      });
                    },
                  );
                },
              ),
            );
          }

          if (state is MatchResultError) {
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
                      context
                          .read<MatchResultBloc>()
                          .add(const ActiveMatchesLoadRequested());
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
}
