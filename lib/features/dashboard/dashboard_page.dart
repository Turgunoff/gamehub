import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamehub/features/play/presentation/pages/play_page.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../home/presentation/pages/home_tab_page.dart';
import '../tournaments/presentation/pages/tournaments_tab_page.dart';
import '../create/presentation/pages/create_tab_page.dart';
import '../history/presentation/pages/history_tab_page.dart';
import '../profile/presentation/pages/profile_page.dart';
import '../profile/presentation/bloc/profile_bloc.dart';
import '../profile/presentation/bloc/profile_event.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeTabPage(),
    TournamentsPage(),
    PlayPage(),
    HistoryTabPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/');
        } else if (state is AuthAuthenticated) {
          // Yangi user kirganda yoki dashboard ochilganda profilni yuklash
          print('✅ [DashboardPage] User authenticated, profil yuklanmoqda...');
          context.read<ProfileBloc>().add(ProfileLoadRequested());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: _pages[_currentIndex],
        bottomNavigationBar: GameHubBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
