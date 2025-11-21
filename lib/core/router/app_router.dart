import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/home/presentation/pages/dashboard_page.dart';
import '../../features/history/presentation/teams_page.dart';
import '../../features/tournaments/presentation/pages/tournaments_page.dart';
import '../../features/tournaments/presentation/pages/tournament_details_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Auth Flow
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return OTPVerificationPage(email: email);
        },
      ),

      // Main App
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // Tournaments
      GoRoute(
        path: '/tournaments',
        builder: (context, state) => const TournamentsPage(),
      ),
      GoRoute(
        path: '/tournament-details',
        builder: (context, state) {
          final tournament = state.extra as dynamic;
          return TournamentDetailsPage(tournament: tournament);
        },
      ),

      // Teams
      GoRoute(path: '/teams', builder: (context, state) => const TeamsPage()),

      // Profile
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
