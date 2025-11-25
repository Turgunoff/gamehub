import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/tournament.dart';
import '../widgets/tournament_card.dart';
import 'tournament_details_page.dart';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Live', 'Upcoming', 'Completed'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Tournament> get _filteredTournaments {
    List<Tournament> tournaments = _getMockTournaments();

    if (_selectedFilter != 'All') {
      tournaments = tournaments.where((tournament) {
        switch (_selectedFilter) {
          case 'Live':
            return tournament.isLive;
          case 'Upcoming':
            return !tournament.isLive && tournament.status == 'UPCOMING';
          case 'Completed':
            return tournament.status == 'COMPLETED';
          default:
            return true;
        }
      }).toList();
    }

    if (_searchController.text.isNotEmpty) {
      tournaments = tournaments.where((tournament) {
        return tournament.title.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            tournament.game.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
      }).toList();
    }

    return tournaments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Tournaments',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilters(),
            _buildFilterTabs(),
            Expanded(child: _buildTournamentsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() {}),
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search tournaments...',
            hintStyle: TextStyle(color: AppColors.textTertiary),
            prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _filters.map((filter) {
          final isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: isSelected
                  ? BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6B46C1), // Boshida - bright purple
                          Color(0xFF06B6D4), // Oxirida - bright blue
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Text(
                filter,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTournamentsList() {
    final tournaments = _filteredTournaments;

    if (tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No tournaments found',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return TournamentCard(
          title: tournament.title,
          status: tournament.status,
          stage: tournament.status == 'LIVE' ? 'In Progress' : tournament.time,
          prize: tournament.prizePool.toStringAsFixed(0),
          participants:
              '${tournament.currentParticipants}/${tournament.maxParticipants}',
          entryFee: tournament.entryFee == 0
              ? 'FREE'
              : tournament.entryFee.toStringAsFixed(0),
          endTime: tournament.time,
          isLive: tournament.isLive,
          onTap: () => _onViewTournamentDetails(tournament),
        );
      },
    );
  }

  void _onJoinTournament(Tournament tournament) {
    // TODO: Implement join tournament logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining ${tournament.title}...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onViewTournamentDetails(Tournament tournament) {
    if (!mounted) return;
    // Navigate to details with the selected tournament as extra
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TournamentDetailsPage(tournament: tournament),
      ),
    );
  }

  List<Tournament> _getMockTournaments() {
    return [
      Tournament(
        id: '1',
        title: 'Pro League Season 5',
        game: 'CS:GO',
        status: 'LIVE',
        time: '2:00 PM',
        currentParticipants: 45,
        maxParticipants: 64,
        entryFee: 10,
        prizePool: 5000,
        imageUrl: 'csgo_icon',
        isLive: true,
        isPremium: true,
      ),
      Tournament(
        id: '2',
        title: 'Valorant Championship',
        game: 'Valorant',
        status: 'UPCOMING',
        time: '5:30 PM',
        currentParticipants: 32,
        maxParticipants: 64,
        entryFee: 15,
        prizePool: 3000,
        imageUrl: 'valorant_icon',
        isLive: false,
        isPremium: false,
      ),
      Tournament(
        id: '3',
        title: 'Battle Royale Masters',
        game: 'PUBG',
        status: 'LIVE',
        time: '7:00 PM',
        currentParticipants: 64,
        maxParticipants: 64,
        entryFee: 20,
        prizePool: 10000,
        imageUrl: 'pubg_icon',
        isLive: true,
        isPremium: true,
      ),
      Tournament(
        id: '4',
        title: 'Rising Stars Tournament',
        game: 'League of Legends',
        status: 'UPCOMING',
        time: 'Tomorrow',
        currentParticipants: 16,
        maxParticipants: 32,
        entryFee: 5,
        prizePool: 1000,
        imageUrl: 'lol_icon',
        isLive: false,
        isPremium: false,
      ),
    ];
  }
}
