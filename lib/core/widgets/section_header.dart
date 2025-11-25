import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Umumiy section header widget'i
/// Barcha section'larda ishlatiladi
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        if (actionText != null && onActionTap != null)
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onActionTap?.call();
            },
            child: Text(
              actionText!,
              style: const TextStyle(
                color: Color(0xFF6C5CE7),
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}

