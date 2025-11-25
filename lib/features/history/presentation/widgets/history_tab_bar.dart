import 'package:flutter/material.dart';

/// History ekranining tab bar qismi
/// Matches va Statistics tab'larini ko'rsatadi
class HistoryTabBar extends StatelessWidget {
  final TabController controller;

  const HistoryTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
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
          Tab(text: 'MATCHES'),
          Tab(text: 'STATISTICS'),
        ],
      ),
    );
  }
}

