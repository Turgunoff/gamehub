import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../shared/widgets/onboarding_slide.dart';
import '../../../../shared/constants/onboarding_data.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < onboardingSlides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToAuth();
    }
  }

  Future<void> _goToAuth() async {
    // Onboarding tugatilgan deb belgilash
    await OnboardingService.markOnboardingCompleted();
    await OnboardingService.markAppLaunched();

    // Navigate to auth page using GoRouter
    if (mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingSlides.length,
                itemBuilder: (context, index) {
                  return OnboardingSlide(
                    title: onboardingSlides[index].title,
                    description: onboardingSlides[index].description,
                    icon: onboardingSlides[index].icon,
                    image: onboardingSlides[index].image,
                  );
                },
              ),
            ),

            // Bottom Section
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(onboardingSlides.length, (index) {
                      final isActive = _currentPage == index;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textTertiary.withOpacity(0.3),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == onboardingSlides.length - 1
                            ? 'Boshlash'
                            : 'Keyingi',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skip Button
                  if (_currentPage < onboardingSlides.length - 1)
                    TextButton(
                      onPressed: _goToAuth,
                      child: Text(
                        'O\'tkazib yuborish',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
