import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Page
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),

      // Onboarding Page
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Auth Pages
      GoRoute(path: '/auth', builder: (context, state) => const LoginPage()),

      // Settings Page (for testing)
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // Home Page (placeholder)
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home Page - Coming Soon!')),
        ),
      ),
    ],
  );
}
