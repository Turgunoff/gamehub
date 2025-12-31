import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasNavigated = false;
  bool _minSplashTimePassed = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check auth state
    context.read<AuthBloc>().add(AuthCheckRequested());

    // Minimum splash time (3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _minSplashTimePassed = true;
      });
      _handleNavigation();
    }
  }

  void _handleNavigation() {
    if (_hasNavigated) return;
    
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      _hasNavigated = true;
      context.go('/dashboard');
    } else if (authState is AuthUnauthenticated && _minSplashTimePassed) {
      _hasNavigated = true;
      _checkOnboardingAndNavigate();
    } else if (authState is AuthError && _minSplashTimePassed) {
      _hasNavigated = true;
      context.go('/auth');
    }
  }

  Future<void> _checkOnboardingAndNavigate() async {
    final isOnboardingCompleted = await OnboardingService.isOnboardingCompleted();
    final isFirstLaunch = await OnboardingService.isFirstLaunch();

    if (mounted) {
      if (isFirstLaunch) {
        context.go('/onboarding');
      } else if (isOnboardingCompleted) {
        context.go('/auth');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Auth state o'zgarganda navigation qilish
        if (_minSplashTimePassed) {
          _handleNavigation();
        }
      },
      child: Scaffold(
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
                    color: AppColors.primary.withValues(alpha: 0.5),
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
              'app_name'.tr().toUpperCase(),
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
              'tagline'.tr(),
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
      ),
    );
  }
}
