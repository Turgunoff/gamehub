import 'package:flutter/material.dart';

/// Tournaments ekranining tab bar qismi
/// Active, Upcoming, Completed tab'larini ko'rsatadi
class TournamentsTabBar extends StatelessWidget {
  final TabController controller;

  const TournamentsTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: controller,
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
}

