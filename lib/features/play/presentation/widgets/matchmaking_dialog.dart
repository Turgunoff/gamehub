import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Matchmaking dialog widget'i
/// Raqib topish jarayonini ko'rsatadi
class MatchmakingDialog extends StatelessWidget {
  final VoidCallback? onCancel;

  const MatchmakingDialog({
    super.key,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6C5CE7).withOpacity(0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
            ),
            const SizedBox(height: 24),
            const Text(
              'FINDING OPPONENT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please wait...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onCancel?.call();
                Navigator.pop(context);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

