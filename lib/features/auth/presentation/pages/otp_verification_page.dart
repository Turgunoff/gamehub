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
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  String? _errorMessage;
  int _countdown = 60;
  bool _canResend = false;
  late AnimationController _countdownController;
  late AnimationController _shakeController;
  Timer? _countdownTimer;

  // Animation for shake effect on error
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startCountdown();
    
    // Auto focus on OTP field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
  }

  void _initializeAnimations() {
    _countdownController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    _countdownController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    
    _countdownController.reset();
    _countdownController.forward();

    _countdownTimer?.cancel();
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

    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validation
    if (otp.isEmpty) {
      _showError('Kodni kiriting');
      return;
    }

    if (otp.length != 6) {
      _showError('6 xonali kod kiriting');
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      _showError('Faqat raqamlar kiriting');
      return;
    }

    // AuthBloc orqali OTP tasdiqlash
    context.read<AuthBloc>().add(
      AuthOTPVerified(email: widget.email, otp: otp),
    );
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    // Clear OTP field and error
    _otpController.clear();
    setState(() {
      _errorMessage = null;
    });

    // AuthBloc orqali OTP qayta yuborish
    context.read<AuthBloc>().add(AuthOTPSent(widget.email));
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    
    // Shake animation for error
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
    
    // Clear OTP field on error and refocus
    _otpController.clear();
    _otpFocusNode.requestFocus();
  }

  void _editEmail() {
    context.pop();
  }

  String _formatEmail(String email) {
    if (email.isEmpty) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) {
      return '${username}***@${domain}';
    } else {
      final visibleChars = username.substring(0, 3);
      final hiddenChars = '*' * (username.length - 3);
      return '${visibleChars}${hiddenChars}@${domain}';
    }
  }

  String _formatCountdown() {
    final minutes = _countdown ~/ 60;
    final seconds = _countdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleAuthStateChanges,
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeaderSection(),
                const SizedBox(height: 16),
                _buildOTPInputSection(),
                const SizedBox(height: 32),
                _buildVerifyButton(),
                const SizedBox(height: 24),
                _buildResendSection(),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  _buildErrorMessage(),
                ],
                const SizedBox(height: 32),
                _buildInfoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAuthStateChanges(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      // OTP tasdiqlanganda dashboard ga o'tish
      context.go('/dashboard');
    } else if (state is AuthOTPSentState) {
      // OTP qayta yuborilganda
      _startCountdown();
      
      _showSuccessSnackBar('Yangi kod yuborildi!');
    } else if (state is AuthError) {
      // Xatolik bo'lsa
      _showError(state.message);
      _showErrorSnackBar('Xatolik: ${state.message}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
          '${_formatEmail(widget.email)} ga kod yuborildi',
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
    );
  }

  Widget _buildOTPInputSection() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.bgPrimary,
                letterSpacing: 8,
              ),
              onChanged: (value) {
                // Clear error when user starts typing
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
                
                // Auto-verify when 6 digits are entered
                if (value.length == 6) {
                  _verifyOTP();
                }
              },
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
                    color: _errorMessage != null 
                        ? AppColors.error 
                        : AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _errorMessage != null 
                        ? AppColors.error 
                        : AppColors.primary,
                    width: 3,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: _errorMessage != null 
                        ? AppColors.error.withOpacity(0.5)
                        : AppColors.textTertiary.withOpacity(0.3),
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
          ),
        );
      },
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 800),
    );
  }

  Widget _buildVerifyButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        
        return AuthButton(
          text: 'Tasdiqlash',
          onPressed: isLoading ? null : _verifyOTP,
          isLoading: isLoading,
        ).animate().fadeIn(
          duration: const Duration(milliseconds: 800),
          delay: const Duration(milliseconds: 1000),
        );
      },
    );
  }

  Widget _buildResendSection() {
    return Column(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatCountdown(),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resendOTP,
              icon: Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              label: Text(
                'Kodni qayta yuborish',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 1200),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
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
    ).animate().fadeIn().shake();
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kod 1 daqiqa davomida amal qiladi.',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Agar kod kelmasa, spam papkasini tekshiring yoki qayta yuborishni bosing.',
            style: TextStyle(
              color: AppColors.primary.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 1400),
    );
  }
}