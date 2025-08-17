import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 3 sekund kutish va auth state ni tekshirish
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Auth state ni tekshirish
    context.read<AuthBloc>().add(AuthCheckRequested());

    // 3 sekund kutish
    await Future.delayed(const Duration(seconds: 3));

    // Agar widget hali mounted bo'lsa, navigation qilish
    if (mounted) {
      _handleNavigation();
    }
  }

  void _handleNavigation() {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      // User auth bo'lsa dashboard ga o'tish
      context.go('/dashboard');
    } else if (authState is AuthUnauthenticated) {
      // User auth bo'lmasa onboarding yoki auth ga o'tish
      _checkOnboardingAndNavigate();
    } else if (authState is AuthError) {
      // Xatolik bo'lsa auth ga o'tish
      context.go('/auth');
    } else {
      // AuthLoading yoki AuthInitial holatida onboarding/auth ga o'tish
      _checkOnboardingAndNavigate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_esports,
                size: 60,
                color: Colors.white,
              ),
            ).animate().fadeIn(duration: 600.ms).scale(delay: 300.ms),

            const SizedBox(height: 24),

            // App Name
            Text(
                  'GAMEHUB',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    letterSpacing: 3,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'COMPETE • WIN • DOMINATE',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

            const SizedBox(height: 60),

            // Loading Indicator
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }

  void _checkOnboardingAndNavigate() async {
    // Onboarding status ni tekshirish
    final isOnboardingCompleted =
        await OnboardingService.isOnboardingCompleted();
    final isFirstLaunch = await OnboardingService.isFirstLaunch();

    if (mounted) {
      if (isFirstLaunch) {
        // App birinchi marta ochilgan - onboarding ga o'tish
        context.go('/onboarding');
      } else if (isOnboardingCompleted) {
        // Onboarding tugagan - auth ga o'tish
        context.go('/auth');
      } else {
        // Onboarding tugamagan - onboarding ga o'tish
        context.go('/onboarding');
      }
    }
  }
}
