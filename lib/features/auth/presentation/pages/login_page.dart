import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/auth_button.dart';
import '../../../../shared/widgets/auth_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    // AuthBloc orqali OTP yuborish
    context.read<AuthBloc>().add(AuthOTPSent(_emailController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOTPSentState) {
            // OTP yuborilganda OTP verification page ga o'tish
            context.push('/otp-verification', extra: state.email);
          } else if (state is AuthError) {
            // Xatolik bo'lsa SnackBar ko'rsatish
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Xatolik: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: SafeArea(
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

                  const SizedBox(height: 16),

                  // Email Field
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'example@email.com',
                    keyboardType: TextInputType.emailAddress,
                    enabled: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email kiriting';
                      }
                      if (!value.contains('@')) {
                        return 'To\'g\'ri email kiriting';
                      }
                      return null;
                    },
                  ).animate().fadeIn(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 800),
                  ),

                  const SizedBox(height: 24),

                  // Send OTP Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AuthButton(
                        text: 'Kod yuborish',
                        onPressed: state is AuthLoading ? null : _sendOTP,
                        isLoading: state is AuthLoading,
                      ).animate().fadeIn(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 1000),
                      );
                    },
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
                    delay: const Duration(milliseconds: 1200),
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
                  ).animate().fadeIn(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 1400),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
