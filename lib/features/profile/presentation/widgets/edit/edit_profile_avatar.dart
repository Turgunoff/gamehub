import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Avatar tahrirlash widgeti
///
/// Avatar ko'rsatadi, yuklash va o'chirish imkoniyatlarini beradi.
class EditProfileAvatar extends StatelessWidget {
  final File? selectedImage;
  final String? currentAvatarUrl;
  final bool isUploading;
  final bool isVerified;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const EditProfileAvatar({
    super.key,
    this.selectedImage,
    this.currentAvatarUrl,
    this.isUploading = false,
    this.isVerified = false,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Avatar container
          _buildAvatarContainer(),

          // Camera button
          _buildCameraButton(),

          // Remove button
          if (_hasAvatar) _buildRemoveButton(),

          // Verified badge
          if (isVerified) _buildVerifiedBadge(),
        ],
      ),
    );
  }

  bool get _hasAvatar => selectedImage != null || currentAvatarUrl != null;

  Widget _buildAvatarContainer() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Color(0xFF00D9FF),
            Color(0xFF6C5CE7),
            Color(0xFFFFB800),
            Color(0xFF00D9FF),
          ],
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF1A1F3A),
        ),
        child: ClipOval(child: _buildAvatarContent()),
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (isUploading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C5CE7),
          strokeWidth: 2,
        ),
      );
    }

    if (selectedImage != null) {
      return Image.file(
        selectedImage!,
        fit: BoxFit.cover,
        width: 114,
        height: 114,
      );
    }

    if (currentAvatarUrl != null) {
      return CachedNetworkImage(
        imageUrl: currentAvatarUrl!,
        fit: BoxFit.cover,
        width: 114,
        height: 114,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6C5CE7),
            strokeWidth: 2,
          ),
        ),
        errorWidget: (_, __, ___) => _buildDefaultAvatar(),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return const Icon(
      Icons.person,
      size: 50,
      color: Color(0xFF6C5CE7),
    );
  }

  Widget _buildCameraButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: isUploading ? null : () {
          HapticFeedback.lightImpact();
          onPickImage();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
            ),
          ),
          child: const Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      child: GestureDetector(
        onTap: isUploading ? null : () {
          HapticFeedback.lightImpact();
          onRemoveImage();
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withValues(alpha: 0.9),
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF00FB94),
        ),
        child: const Icon(
          Icons.verified,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
