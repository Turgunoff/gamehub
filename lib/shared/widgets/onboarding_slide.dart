import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? image;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon/Image Section
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
            ),
            child: Icon(icon, size: 100, color: AppColors.primary),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
          ),

          const SizedBox(height: 48),

          // Title
          Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
              )
              .slideY(
                begin: 0.3,
                end: 0,
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
              ),

          const SizedBox(height: 16),

          // Description
          Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
              )
              .slideY(
                begin: 0.3,
                end: 0,
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
              ),
        ],
      ),
    );
  }
}
