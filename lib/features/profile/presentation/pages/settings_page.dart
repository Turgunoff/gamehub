import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings values
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = true;
  String _selectedLanguage = 'O\'zbek';
  double _graphicsQuality = 2; // 0-Low, 1-Medium, 2-High

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Simple gradient background (no animation)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1F3A), Color(0xFF0A0E1A)],
              ),
            ),
          ),

          // Subtle pattern overlay
          CustomPaint(painter: GridPatternPainter(), child: Container()),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        _buildProfileSection(),
                        _buildGameSettingsSection(),
                        _buildNotificationSection(),
                        _buildAppearanceSection(),
                        _buildAccountSection(),
                        _buildAboutSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Title
          const Text(
            'SETTINGS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),

          const Spacer(),

          // Profile indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C5CE7).withOpacity(0.2),
            const Color(0xFF00D9FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),

          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CYBER_STRIKER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PES ID: 123-456-789',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // Navigate to edit profile
            },
            icon: Icon(Icons.edit, color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSettingsSection() {
    return _buildSection(
      title: 'GAME SETTINGS',
      icon: Icons.sports_esports,
      color: const Color(0xFFFFB800),
      children: [
        _buildSettingTile(
          icon: Icons.speed,
          title: 'Graphics Quality',
          subtitle: _getGraphicsQualityText(),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getGraphicsQualityColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getGraphicsQualityColor().withOpacity(0.5),
              ),
            ),
            child: Text(
              _getGraphicsQualityText(),
              style: TextStyle(
                color: _getGraphicsQualityColor(),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () => _showGraphicsQualityDialog(),
        ),

        _buildDivider(),

        _buildSwitchTile(
          icon: Icons.volume_up,
          title: 'Sound Effects',
          subtitle: 'Game sounds and music',
          value: _soundEnabled,
          onChanged: (value) {
            setState(() => _soundEnabled = value);
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSwitchTile(
          icon: Icons.vibration,
          title: 'Vibration',
          subtitle: 'Haptic feedback',
          value: _vibrationEnabled,
          onChanged: (value) {
            setState(() => _vibrationEnabled = value);
            if (value) HapticFeedback.mediumImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.gamepad,
          title: 'Controls',
          subtitle: 'Customize game controls',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to controls settings
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: 'NOTIFICATIONS',
      icon: Icons.notifications,
      color: const Color(0xFF00FB94),
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_active,
          title: 'Push Notifications',
          subtitle: 'Receive match and tournament alerts',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.message,
          title: 'Message Alerts',
          subtitle: 'Team and private messages',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ON',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.emoji_events,
          title: 'Tournament Reminders',
          subtitle: 'Get notified before tournaments',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      title: 'APPEARANCE',
      icon: Icons.palette,
      color: const Color(0xFF6C5CE7),
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode,
          title: 'Dark Mode',
          subtitle: 'Reduce eye strain',
          value: _darkMode,
          onChanged: (value) {
            setState(() => _darkMode = value);
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.language,
          title: 'Language',
          subtitle: _selectedLanguage,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00D9FF).withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 14, color: Color(0xFF00D9FF)),
                const SizedBox(width: 6),
                Text(
                  _selectedLanguage.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF00D9FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          onTap: () => _showLanguageDialog(),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'ACCOUNT',
      icon: Icons.person,
      color: const Color(0xFFFF6B6B),
      children: [
        _buildSettingTile(
          icon: Icons.security,
          title: 'Privacy & Security',
          subtitle: 'Manage your account security',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.link,
          title: 'Connected Accounts',
          subtitle: 'Manage linked social accounts',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '2 LINKED',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.backup,
          title: 'Backup & Restore',
          subtitle: 'Save your game progress',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.logout,
          title: 'Sign Out',
          subtitle: 'Sign out from your account',
          trailing: Icon(
            Icons.logout,
            color: Colors.red.withOpacity(0.8),
            size: 20,
          ),
          onTap: () => _showSignOutDialog(),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'ABOUT',
      icon: Icons.info,
      color: Colors.white54,
      children: [
        _buildSettingTile(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help with the app',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.description,
          title: 'Terms & Conditions',
          subtitle: 'Read our terms of service',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          subtitle: 'Learn how we protect your data',
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.star,
          title: 'Rate Us',
          subtitle: 'Help us improve with your feedback',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                size: 16,
                color: index < 4 ? const Color(0xFFFFB800) : Colors.white24,
              );
            }),
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),

        _buildDivider(),

        _buildSettingTile(
          icon: Icons.code,
          title: 'Version',
          subtitle: 'CyberPitch v1.0.0',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'LATEST',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            HapticFeedback.lightImpact();
            // Show version details
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Section content
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(children: children),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.red : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDestructive
                          ? Colors.red.withOpacity(0.7)
                          : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00D9FF),
            activeTrackColor: const Color(0xFF00D9FF).withOpacity(0.3),
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white.withOpacity(0.05),
    );
  }

  String _getGraphicsQualityText() {
    switch (_graphicsQuality.toInt()) {
      case 0:
        return 'LOW';
      case 1:
        return 'MEDIUM';
      case 2:
        return 'HIGH';
      default:
        return 'MEDIUM';
    }
  }

  Color _getGraphicsQualityColor() {
    switch (_graphicsQuality.toInt()) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.green;
      default:
        return Colors.yellow;
    }
  }

  void _showGraphicsQualityDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Graphics Quality',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption('Low', 0),
            _buildQualityOption('Medium', 1),
            _buildQualityOption('High', 2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'APPLY',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityOption(String label, int value) {
    return RadioListTile<int>(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: _graphicsQuality.toInt(),
      onChanged: (newValue) {
        setState(() => _graphicsQuality = newValue!.toDouble());
        HapticFeedback.lightImpact();
      },
      activeColor: const Color(0xFF00D9FF),
    );
  }

  void _showLanguageDialog() {
    HapticFeedback.mediumImpact();
    final languages = ['O\'zbek', 'Русский', 'English'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Select Language',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return ListTile(
              leading: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _selectedLanguage == lang
                      ? const Color(0xFF00D9FF)
                      : Colors.white12,
                  shape: BoxShape.circle,
                ),
                child: _selectedLanguage == lang
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              title: Text(
                lang,
                style: TextStyle(
                  color: _selectedLanguage == lang
                      ? const Color(0xFF00D9FF)
                      : Colors.white,
                  fontWeight: _selectedLanguage == lang
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out? You will need to sign in again to access your account.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              // Perform sign out
            },
            child: const Text(
              'SIGN OUT',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple grid pattern painter (no animation)
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 50.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
