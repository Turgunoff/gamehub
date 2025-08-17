import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/auth_button.dart';
import '../bloc/auth_bloc.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;

  const OTPVerificationPage({super.key, required this.email});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage>
    with TickerProviderStateMixin {
  final TextEditingController _otpController =
      TextEditingController(); // Bitta controller

  bool _isVerifying = false;
  String? _errorMessage;
  int _countdown = 60;
  bool _canResend = false;
  late AnimationController _countdownController;
  Timer? _countdownTimer; // Timer ni saqlash uchun

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    // Timer ni to'xtatish
    _countdownTimer?.cancel();

    _otpController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });

    // Timer ni saqlash va mounted tekshirish
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      if (mounted) {
        setState(() {
          _errorMessage = '6 xonali kod kiriting';
        });
      }
      return;
    }

    // AuthBloc orqali OTP tasdiqlash
    context.read<AuthBloc>().add(
      AuthOTPVerified(email: widget.email, otp: otp),
    );
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    // AuthBloc orqali OTP qayta yuborish
    context.read<AuthBloc>().add(AuthOTPSent(widget.email));
  }

  void _editEmail() {
    context.pop();
  }

  String _formatCountdown() {
    final minutes = _countdown ~/ 60;
    final seconds = _countdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // OTP tasdiqlanganda dashboard ga o'tish
          context.go('/dashboard');
        } else if (state is AuthOTPSentState) {
          // OTP qayta yuborilganda
          if (mounted) {
            // OTP input ni tozalash
            _otpController.clear();

            // Eski timer ni to'xtatish
            _countdownTimer?.cancel();

            // Countdown ni qayta boshlash
            setState(() {
              _countdown = 60;
              _canResend = false;
              _isVerifying = false;
            });
            _startCountdown();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Yangi kod yuborildi!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else if (state is AuthError) {
          // Xatolik bo'lsa
          if (mounted) {
            setState(() {
              _errorMessage = state.message;
              _isVerifying = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Xatolik: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Header Section
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 40,
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
                      'Kodni tasdiqlang',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                          ),
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '${widget.email} ga yuborilgan 6 xonali kodni kiriting',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                    ),

                    const SizedBox(height: 16),

                    // Email Edit Button
                    TextButton.icon(
                      onPressed: _editEmail,
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'Email ni o\'zgartirish',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // OTP Input Field
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _otpController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.bgPrimary,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      hintText: '123456',
                      hintStyle: TextStyle(
                        color: AppColors.textTertiary.withOpacity(0.5),
                        fontSize: 24,
                        letterSpacing: 8,
                      ),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 3,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.textTertiary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                    ),
                  ),
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 800),
                ),

                const SizedBox(height: 32),

                // Verify Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AuthButton(
                      text: 'Tasdiqlash',
                      onPressed: state is AuthLoading ? null : _verifyOTP,
                      isLoading: state is AuthLoading,
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 1000),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Resend Section
                Column(
                  children: [
                    if (!_canResend) ...[
                      Text(
                        'Kodni qayta yuborish',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatCountdown(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      TextButton(
                        onPressed: _resendOTP,
                        child: Text(
                          'Kodni qayta yuborish',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 1200),
                ),

                // Error Message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().shake(),
                ],

                const SizedBox(height: 32),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kod 60 soniyadan keyin yuboriladi. Spam papkasini ham tekshiring.',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 1400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
