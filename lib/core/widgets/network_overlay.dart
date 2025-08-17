import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app_settings/app_settings.dart';
import '../theme/app_colors.dart';
import '../services/network_service.dart';

class NetworkOverlay extends StatefulWidget {
  final Widget child;

  const NetworkOverlay({super.key, required this.child});

  @override
  State<NetworkOverlay> createState() => _NetworkOverlayState();
}

class _NetworkOverlayState extends State<NetworkOverlay>
    with SingleTickerProviderStateMixin {
  final NetworkService _networkService = NetworkService();
  bool _hasConnection = true;
  bool _isCheckingConnection = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _initializeNetwork();
  }

  Future<void> _initializeNetwork() async {
    // Initial check
    await _checkInitialConnection();

    // Listen to connection changes
    _networkService.connectionStream.listen((hasConnection) {
      if (mounted) {
        setState(() {
          _hasConnection = hasConnection;
          if (!hasConnection) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    final hasConnection = await _networkService.checkConnection();
    if (mounted) {
      setState(() {
        _hasConnection = hasConnection;
        if (!hasConnection) {
          _animationController.value = 1.0;
        }
      });
    }
  }

  Future<void> _retryConnection() async {
    setState(() {
      _isCheckingConnection = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    await _networkService.checkConnection();

    if (mounted) {
      setState(() {
        _isCheckingConnection = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          // Main content
          widget.child,

          // No Internet Overlay
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_animationController.value == 0) {
                return const SizedBox.shrink();
              }

              return Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(
                    0.85 * _animationController.value,
                  ),
                  child: SafeArea(
                    child: Center(
                      child: FadeTransition(
                        opacity: _animationController,
                        child: ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOutBack,
                          ),
                          child: _buildConnectionErrorCard(context),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionErrorCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgCard, AppColors.bgCard.withOpacity(0.95)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withOpacity(0.05),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon
                  _buildAnimatedIcon(),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Internet aloqasi uzildi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'Iltimos, internet ulanishingizni tekshiring va qayta urinib ko\'ring',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  _buildActionButtons(context),

                  // Settings Links section removed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer circle animation
        Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withOpacity(0.1),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
              duration: 2.seconds,
              curve: Curves.easeInOut,
            ),

        // Inner circle
        Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.error.withOpacity(0.15),
                    AppColors.error.withOpacity(0.25),
                  ],
                ),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: AppColors.error,
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              duration: 3.seconds,
              color: AppColors.error.withOpacity(0.3),
            ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Retry Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isCheckingConnection ? null : _retryConnection,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isCheckingConnection
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tekshirilmoqda...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh_rounded, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Qayta urinish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
