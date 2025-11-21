// lib/features/teams/presentation/pages/teams_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../domain/entities/team.dart';
import 'team_details_page.dart';
import 'create_team_page.dart';
import 'widgets/team_card.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedSkillFilter = 'All';
  String _selectedRegionFilter = 'All';

  final List<String> _skillLevels = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Pro',
  ];
  final List<String> _regions = ['All', 'Asia', 'Europe', 'Americas', 'Global'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Team> get _filteredTeams {
    List<Team> teams = _getMockTeams();

    // Search filter
    if (_searchController.text.isNotEmpty) {
      teams = teams.where((team) {
        return team.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            team.captainName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
      }).toList();
    }

    // Skill level filter
    if (_selectedSkillFilter != 'All') {
      teams = teams
          .where((team) => team.skillLevel == _selectedSkillFilter)
          .toList();
    }

    // Region filter
    if (_selectedRegionFilter != 'All') {
      teams = teams
          .where((team) => team.region == _selectedRegionFilter)
          .toList();
    }

    // Tab filter
    switch (_tabController.index) {
      case 0: // All Teams
        return teams;
      case 1: // Recruiting
        return teams
            .where((team) => team.isOpen && team.memberCount < team.maxMembers)
            .toList();
      case 2: // My Teams
        // TODO: Filter user's teams
        return teams.take(1).toList();
      default:
        return teams;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchAndFilters(),
            _buildTabBar(),
            Expanded(child: _buildTabBarView()),
          ],
        ),
      ),
      floatingActionButton: _buildCreateTeamFAB(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PES 25 Teams',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              Text(
                'Find your squad',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.sports_soccer,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.bgCardLight.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search teams or captains...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filters Row
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Skill',
                  _selectedSkillFilter,
                  _skillLevels,
                  (value) {
                    setState(() => _selectedSkillFilter = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  'Region',
                  _selectedRegionFilter,
                  _regions,
                  (value) {
                    setState(() => _selectedRegionFilter = value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildFilterDropdown(
    String label,
    String selected,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.bgCardLight.withOpacity(0.3)),
      ),
      child: DropdownButton<String>(
        value: selected,
        onChanged: (value) => onChanged(value!),
        underline: const SizedBox(),
        dropdownColor: AppColors.bgCard,
        style: const TextStyle(color: AppColors.textPrimary),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.textTertiary,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgCardLight.withOpacity(0.3)),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'All Teams'),
          Tab(text: 'Recruiting'),
          Tab(text: 'My Teams'),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [_buildTeamsList(), _buildTeamsList(), _buildMyTeams()],
    );
  }

  Widget _buildTeamsList() {
    final teams = _filteredTeams;

    if (teams.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        return TeamCard(
          team: teams[index],
          onJoinPressed: () => _onJoinTeam(teams[index]),
          onViewPressed: () => _onViewTeamDetails(teams[index]),
        ).animate().fadeIn(delay: (100 * index).ms);
      },
    );
  }

  Widget _buildMyTeams() {
    return Column(
      children: [
        Expanded(child: _buildTeamsList()),
        Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You can join up to 3 teams',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.groups_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No teams found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _onCreateTeam(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Create Team'),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTeamFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _onCreateTeam,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Team',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _onJoinTeam(Team team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildJoinTeamModal(team),
    );
  }

  void _onViewTeamDetails(Team team) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeamDetailsPage(team: team)),
    );
  }

  void _onCreateTeam() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTeamPage()),
    );
  }

  Widget _buildJoinTeamModal(Team team) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Join ${team.name}?',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              team.requirements ?? 'No specific requirements',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Request sent to join ${team.name}'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Join'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Team> _getMockTeams() {
    return [
      Team(
        id: '1',
        name: 'FC Barcelona Legends',
        logoUrl: '',
        description: 'Professional PES 25 team looking for skilled midfielders',
        memberCount: 8,
        maxMembers: 11,
        skillLevel: 'Pro',
        region: 'Europe',
        isOpen: true,
        isVerified: true,
        captainId: '1',
        captainName: 'Messi_10',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        achievements: ['Champion League Winner', 'Division 1 Champions'],
        wins: 45,
        losses: 12,
        draws: 8,
        winRate: 69.2,
        members: [],
        requirements: 'Minimum 850 rating, active daily',
      ),
      Team(
        id: '2',
        name: 'Real Madrid CF',
        logoUrl: '',
        description: 'Competitive team seeking defenders and forwards',
        memberCount: 9,
        maxMembers: 11,
        skillLevel: 'Advanced',
        region: 'Europe',
        isOpen: true,
        isVerified: true,
        captainId: '2',
        captainName: 'CR7_Forever',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        achievements: ['Cup Winners'],
        wins: 38,
        losses: 15,
        draws: 12,
        winRate: 58.5,
        members: [],
        requirements: 'Good communication, team player',
      ),
      Team(
        id: '3',
        name: 'Manchester United',
        logoUrl: '',
        description: 'Friendly team for casual and competitive play',
        memberCount: 6,
        maxMembers: 11,
        skillLevel: 'Intermediate',
        region: 'Europe',
        isOpen: true,
        isVerified: false,
        captainId: '3',
        captainName: 'RedDevil_99',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        achievements: [],
        wins: 22,
        losses: 18,
        draws: 5,
        winRate: 48.9,
        members: [],
        requirements: 'Be respectful and have fun',
      ),
      Team(
        id: '4',
        name: 'Arsenal FC',
        logoUrl: '',
        description: 'Full squad - looking for substitutes only',
        memberCount: 11,
        maxMembers: 11,
        skillLevel: 'Advanced',
        region: 'Europe',
        isOpen: false,
        isVerified: true,
        captainId: '4',
        captainName: 'Gunner_14',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        achievements: ['Division 2 Champions'],
        wins: 41,
        losses: 9,
        draws: 15,
        winRate: 63.1,
        members: [],
      ),
    ];
  }
}
