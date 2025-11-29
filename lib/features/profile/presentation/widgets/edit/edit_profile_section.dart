import 'package:flutter/material.dart';

/// Profil tahrirlash uchun section
///
/// Icon va sarlavha bilan bo'lim yaratadi.
class EditProfileSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final EdgeInsets? padding;

  const EditProfileSection({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF6C5CE7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
