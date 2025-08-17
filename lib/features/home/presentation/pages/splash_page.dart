import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/services/onboarding_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final NetworkService _networkService = NetworkService();
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize network service
    await _networkService.initialize();

    // Check connection
    final hasConnection = await _networkService.checkConnection();

    if (hasConnection) {
      // Wait for splash animation
      await Future.delayed(const Duration(seconds: 3));

      // Check onboarding status
      final isOnboardingCompleted = await OnboardingService.isOnboardingCompleted();
      final isFirstLaunch = await OnboardingService.isFirstLaunch();

      if (mounted) {
        if (isFirstLaunch) {
          // App birinchi marta ochilgan - onboarding ga o'tish
          context.go('/onboarding');
        } else if (isOnboardingCompleted) {
          // Onboarding tugagan - auth yoki home ga o'tish
          context.go('/auth');
        } else {
          // Onboarding tugamagan - onboarding ga o'tish
          context.go('/onboarding');
        }
      }
    }

    setState(() {
      _isChecking = false;
    });
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
            ).animate()
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

            // Loading or Network Status
            if (_isChecking)
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ).animate().fadeIn(delay: 800.ms)
            else if (!_networkService.hasConnection)
              Column(
                children: [
                  Icon(Icons.wifi_off, color: AppColors.error, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Internet aloqasi yo\'q',
                    style: TextStyle(color: AppColors.error, fontSize: 14),
                  ),
                ],
              ).animate().fadeIn(),
          ],
        ),
      ),
    );
  }
}
