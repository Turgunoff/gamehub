import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../widgets/tournaments_header.dart';
import '../widgets/tournaments_tab_bar.dart';
import '../widgets/tournament_card.dart';
import '../widgets/completed_tournament_card.dart';
import '../widgets/tournament_filter_dialog.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  // TODO: Backend'dan ma'lumot olish kerak
  // Hozircha bo'sh - user hali turnirlarda qatnashmagan
  final List<Map<String, dynamic>> _myActiveTournaments = [];
  final List<Map<String, dynamic>> _myCompletedTournaments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // User birorta turnirda qatnashganmi?
  bool get _hasParticipated =>
      _myActiveTournaments.isNotEmpty || _myCompletedTournaments.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1F3A),
                  Color(0xFF0A0E1A),
                ],
              ),
            ),
          ),

          SafeArea(
            child: _hasParticipated ? _buildWithData() : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  // Ma'lumotlar bor bo'lganda
  Widget _buildWithData() {
    return Column(
      children: [
        // Header
        TournamentsHeader(onFilterTap: _showFilterDialog),

        // Tab Bar
        TournamentsTabBar(controller: _tabController),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveTab(),
              _buildUpcomingTab(),
              _buildCompletedTab(),
            ],
          ),
        ),
      ],
    );
  }

  // Ma'lumotlar yo'q - Empty State
  Widget _buildEmptyState() {
    return Column(
      children: [
        // Header (soddalashtirilgan)
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TURNIRLAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chempionatlarda qatnashing',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Empty State
        Expanded(
          child: TournamentsEmptyState(
            onBrowseTournaments: () {
              // TODO: Barcha turnirlar sahifasiga o'tish
            },
          ),
        ),
      ],
    );
  }

  /// Faol turnirlar ro'yxati (user qatnashayotgan)
  Widget _buildActiveTab() {
    if (_myActiveTournaments.isEmpty) {
      return const Center(
        child: TournamentsEmptyState(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TournamentCard(
          title: 'CHAMPIONS LEAGUE',
          status: 'LIVE',
          stage: 'Semi Finals',
          prize: '100,000',
          participants: '128/128',
          entryFee: '1,000',
          endTime: '2h 30m left',
          isLive: true,
          myStatus: 'Quarter Finals',
        ),
        const SizedBox(height: 16),
        TournamentCard(
          title: 'DAILY KNOCKOUT',
          status: 'IN PROGRESS',
          stage: 'Round of 16',
          prize: '25,000',
          participants: '64/64',
          entryFee: '500',
          endTime: '5h left',
          isLive: true,
          myStatus: 'Active',
        ),
      ],
    );
  }

  /// Kelgusi turnirlar ro'yxati
  Widget _buildUpcomingTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TournamentCard(
          title: 'WEEKEND WARRIORS',
          status: 'REGISTRATION',
          stage: 'Starting in 2h',
          prize: '50,000',
          participants: '45/128',
          entryFee: '750',
          endTime: 'Sat, 20:00',
          isLive: false,
          myStatus: null,
        ),
        const SizedBox(height: 16),
        TournamentCard(
          title: 'BEGINNER CUP',
          status: 'REGISTRATION',
          stage: 'Starting Tomorrow',
          prize: '10,000',
          participants: '12/32',
          entryFee: 'FREE',
          endTime: 'Sun, 18:00',
          isLive: false,
          myStatus: null,
        ),
        const SizedBox(height: 16),
        TournamentCard(
          title: 'PRO LEAGUE',
          status: 'REGISTRATION',
          stage: 'Starting Monday',
          prize: '200,000',
          participants: '89/256',
          entryFee: '2,500',
          endTime: 'Mon, 21:00',
          isLive: false,
          myStatus: null,
        ),
      ],
    );
  }

  /// Tugallangan turnirlar ro'yxati (user qatnashgan)
  Widget _buildCompletedTab() {
    if (_myCompletedTournaments.isEmpty) {
      return const Center(
        child: TournamentsEmptyState(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CompletedTournamentCard(
          title: 'MASTERS CUP',
          position: '3rd',
          prize: '15,000',
          date: '2 days ago',
          participants: '256',
        ),
        const SizedBox(height: 16),
        CompletedTournamentCard(
          title: 'QUICK TOURNAMENT',
          position: '8th',
          prize: '2,000',
          date: '5 days ago',
          participants: '64',
        ),
        const SizedBox(height: 16),
        CompletedTournamentCard(
          title: 'ELITE CHAMPIONSHIP',
          position: '1st',
          prize: '50,000',
          date: '1 week ago',
          participants: '128',
        ),
      ],
    );
  }


  /// Filter dialog'ni ko'rsatish
  void _showFilterDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => TournamentFilterDialog(
        selectedFilter: _selectedFilter,
        onFilterSelected: (filter) {
          setState(() => _selectedFilter = filter);
        },
      ),
    );
  }
}