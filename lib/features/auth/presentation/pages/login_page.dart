import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/auth_button.dart';
import '../../../../shared/widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement login logic with Supabase
      // For now, just simulate login
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // TODO: Navigate to home page
        context.go('/home');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo/Title Section
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.games_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'GameHub Pro',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                          ),
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Gaming jamiyatiga qo\'shiling',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Email Field
                AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email kiriting';
                        }
                        if (!value.contains('@')) {
                          return 'To\'g\'ri email kiriting';
                        }
                        return null;
                      },
                    )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                    )
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                    ),

                const SizedBox(height: 32),

                // Login Button
                AuthButton(
                      text: 'Kirish',
                      onPressed: _isLoading ? null : _login,
                      isLoading: _isLoading,
                    )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 800),
                    )
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 800),
                    ),

                const SizedBox(height: 32),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.textTertiary.withOpacity(0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'yoki',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.textTertiary.withOpacity(0.3),
                      ),
                    ),
                  ],
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 1000),
                ),

                const SizedBox(height: 24),

                // Social Login Buttons
                Row(
                      children: [
                        Expanded(
                          child: AuthButton(
                            text: 'Google',
                            onPressed: () async {
                              // TODO: Implement Google login
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Google login - Coming Soon!'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            backgroundColor: Colors.white,
                            textColor: Colors.black87,
                            icon: Icons.g_mobiledata_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AuthButton(
                            text: 'Discord',
                            onPressed: () async {
                              // TODO: Implement Discord login
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Discord login - Coming Soon!'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            backgroundColor: const Color(0xFF5865F2),
                            textColor: Colors.white,
                            icon: Icons.discord_rounded,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 1200),
                    )
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 1200),
                    ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
