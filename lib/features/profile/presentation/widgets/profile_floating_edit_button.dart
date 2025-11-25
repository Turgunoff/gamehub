import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Profile ekranidagi floating edit button widget'i
/// Profilni tahrirlash uchun tugma
class ProfileFloatingEditButton extends StatelessWidget {
  const ProfileFloatingEditButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.push('/edit-profile');
          },
          backgroundColor: const Color(0xFF6C5CE7),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    );
  }
}

