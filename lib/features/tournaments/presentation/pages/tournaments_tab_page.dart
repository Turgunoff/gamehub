import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

class TournamentsPage extends StatefulWidget {
  const TournamentsPage({super.key});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

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
            child: Column(
              children: [
                // Header
                _buildHeader(),
                
                // Tab Bar
                _buildTabBar(),
                
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOURNAMENTS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Compete and win prizes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Filter Button
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6C5CE7).withOpacity(0.5),
              ),
            ),
            child: IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(
                Icons.filter_list,
                color: Color(0xFF6C5CE7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(text: 'ACTIVE'),
          Tab(text: 'UPCOMING'),
          Tab(text: 'COMPLETED'),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTournamentCard(
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
        _buildTournamentCard(
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

  Widget _buildUpcomingTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildTournamentCard(
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
        _buildTournamentCard(
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
        _buildTournamentCard(
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

  Widget _buildCompletedTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildCompletedTournamentCard(
          title: 'MASTERS CUP',
          position: '3rd',
          prize: '15,000',
          date: '2 days ago',
          participants: '256',
        ),
        const SizedBox(height: 16),
        _buildCompletedTournamentCard(
          title: 'QUICK TOURNAMENT',
          position: '8th',
          prize: '2,000',
          date: '5 days ago',
          participants: '64',
        ),
        const SizedBox(height: 16),
        _buildCompletedTournamentCard(
          title: 'ELITE CHAMPIONSHIP',
          position: '1st',
          prize: '50,000',
          date: '1 week ago',
          participants: '128',
        ),
      ],
    );
  }

  Widget _buildTournamentCard({
    required String title,
    required String status,
    required String stage,
    required String prize,
    required String participants,
    required String entryFee,
    required String endTime,
    required bool isLive,
    String? myStatus,
  }) {
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isLive
                  ? [Colors.redAccent.withOpacity(0.3), Colors.orange.withOpacity(0.2)]
                  : [const Color(0xFF6C5CE7).withOpacity(0.3), const Color(0xFF00D9FF).withOpacity(0.2)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
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
                              color: isLive ? Colors.redAccent : const Color(0xFF00D9FF),
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
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLive 
                        ? Colors.orange
                        : const Color(0xFF6C5CE7),
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
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTournamentCard({
    required String title,
    required String position,
    required String prize,
    required String date,
    required String participants,
  }) {
    Color positionColor = position == '1st' 
      ? const Color(0xFFFFD700)
      : position == '2nd'
        ? const Color(0xFFC0C0C0)
        : position == '3rd'
          ? const Color(0xFFCD7F32)
          : Colors.white54;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: positionColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: positionColor,
                  size: 24,
                ),
                Text(
                  position,
                  style: TextStyle(
                    color: positionColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
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
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$participants players',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              Text(
                'Won',
                style: TextStyle(
                  color: const Color(0xFF00FB94),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FILTER TOURNAMENTS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption('All Tournaments', 'all'),
              _buildFilterOption('Free Entry', 'free'),
              _buildFilterOption('My Strength Range', 'strength'),
              _buildFilterOption('High Prize', 'prize'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                    ),
                    child: const Text(
                      'APPLY',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      value: value,
      groupValue: _selectedFilter,
      onChanged: (newValue) {
        setState(() => _selectedFilter = newValue!);
      },
      activeColor: const Color(0xFF00D9FF),
    );
  }
}