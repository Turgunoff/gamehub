import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamehub/core/theme/app_colors.dart';
import 'package:gamehub/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:gamehub/features/profile/presentation/bloc/profile_event.dart';
import 'package:gamehub/features/profile/presentation/bloc/profile_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:country_picker/country_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _collectiveStrengthController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;

  // Dropdowns
  String? _selectedLanguage;
  String? _selectedTimezone;

  bool _isLoading = false;
  bool _isUploading = false;
  bool _isCheckingUsername = false;
  String? _newAvatarUrl;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _fullNameController = TextEditingController(text: state.fullName);
      _usernameController = TextEditingController(text: state.username);
      _bioController = TextEditingController(text: state.bio);
      _collectiveStrengthController = TextEditingController(
        text: state.collectiveStrength > 0 ? state.collectiveStrength.toString() : '',
      );
      _countryController = TextEditingController(text: state.country ?? '');
      _cityController = TextEditingController(text: state.city ?? '');

      _selectedLanguage = state.language;
      _selectedTimezone = state.timezone;
    } else {
      _fullNameController = TextEditingController();
      _usernameController = TextEditingController();
      _bioController = TextEditingController();
      _collectiveStrengthController = TextEditingController();
      _countryController = TextEditingController();
      _cityController = TextEditingController();
    }

    // Add username validation listener
    _usernameController.addListener(_validateUsername);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _collectiveStrengthController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // Validate username uniqueness
  Future<void> _validateUsername() async {
    final username = _usernameController.text.trim();
    final state = context.read<ProfileBloc>().state;

    if (state is! ProfileLoaded) return;

    // Skip if username hasn't changed
    if (username == state.username) {
      setState(() {
        _usernameError = null;
        _isCheckingUsername = false;
      });
      return;
    }

    // Skip if username is empty
    if (username.isEmpty) {
      setState(() {
        _usernameError = null;
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() => _isCheckingUsername = true);

    try {
      final result = await _supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _usernameError = result != null ? 'Username already taken' : null;
          _isCheckingUsername = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _usernameError = 'Error checking username';
          _isCheckingUsername = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() => _isUploading = true);

      try {
        final bytes = await image.readAsBytes();
        final userId = _supabase.auth.currentUser?.id;
        final fileExt = image.path.split('.').last;
        final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'avatars/$fileName';

        // Upload to Supabase Storage
        await _supabase.storage.from('profiles').uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$fileExt',
                upsert: true,
              ),
            );

        // Get public URL
        final url = _supabase.storage.from('profiles').getPublicUrl(filePath);

        setState(() {
          _newAvatarUrl = url;
          _isUploading = false;
        });
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload image: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickCollectiveStrengthProof() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _isUploading = true);

      try {
        final bytes = await image.readAsBytes();
        final userId = _supabase.auth.currentUser?.id;
        final fileExt = image.path.split('.').last;
        final fileName = 'strength-$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'collective_strength_proofs/$fileName';

        // Upload to Supabase Storage
        await _supabase.storage.from('profiles').uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$fileExt',
                upsert: true,
              ),
            );

        // Get public URL
        final url = _supabase.storage.from('profiles').getPublicUrl(filePath);

        setState(() => _isUploading = false);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Screenshot uploaded! Admin will verify soon.'),
              backgroundColor: AppColors.success,
            ),
          );
        }

        // Save to database (will be verified by admin)
        if (mounted) {
          final state = context.read<ProfileBloc>().state;
          if (state is ProfileLoaded) {
            final strengthValue = int.tryParse(_collectiveStrengthController.text) ?? 0;
            await _supabase.from('users').update({
              'collective_strength': strengthValue,
              'collective_strength_proof': url,
              'collective_strength_verified': false, // Reset verification
            }).eq('id', state.id);
          }
        }
      } catch (e) {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload screenshot: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Check username error
    if (_usernameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix username error'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final state = context.read<ProfileBloc>().state;
      if (state is ProfileLoaded) {
        // Update profile in Supabase
        await _supabase.from('users').update({
          'full_name': _fullNameController.text,
          'username': _usernameController.text,
          'bio': _bioController.text,
          'country': _countryController.text.isEmpty ? null : _countryController.text,
          'city': _cityController.text.isEmpty ? null : _cityController.text,
          'language': _selectedLanguage ?? 'en',
          'timezone': _selectedTimezone ?? 'UTC+5',
          'avatar_url': _newAvatarUrl ?? state.avatarUrl,
        }).eq('id', state.id);

        if (mounted) {
          // Update BLoC state
          context.read<ProfileBloc>().add(
                UpdateProfile(
                  name: _fullNameController.text,
                  username: _usernameController.text,
                  bio: _bioController.text,
                ),
              );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );

          // Reload profile to get updated data
          final userId = _supabase.auth.currentUser?.id;
          if (userId != null) {
            context.read<ProfileBloc>().add(LoadProfile(userId));
          }

          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            backgroundColor: AppColors.bgCard,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    'SAVE',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  _buildAvatarSection(state),
                  const SizedBox(height: 24),

                  // Basic Info Section
                  _buildSectionHeader('Basic Info'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.person_outline,
                    isRequired: true,
                    errorText: _usernameError,
                    suffix: _isCheckingUsername
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : _usernameError == null && _usernameController.text.isNotEmpty && _usernameController.text != state.username
                            ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                            : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.badge_outlined,
                    isRequired: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _bioController,
                    label: 'Bio',
                    icon: Icons.info_outline,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Location Section
                  _buildSectionHeader('Location'),
                  const SizedBox(height: 12),
                  _buildCountryPickerField(),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 24),

                  // PES Mobile Settings
                  _buildSectionHeader('PES Mobile Settings'),
                  const SizedBox(height: 12),

                  // Skill Level (Read-only)
                  _buildReadOnlyField(
                    label: 'Skill Level',
                    value: _getSkillLevelText(state.skillLevel),
                    icon: Icons.military_tech_outlined,
                    color: _getSkillLevelColor(state.skillLevel),
                    subtitle: 'Auto-calculated based on your match results',
                  ),
                  const SizedBox(height: 12),

                  // Collective Strength
                  _buildCollectiveStrengthSection(state),
                  const SizedBox(height: 24),

                  // Preferences Section
                  _buildSectionHeader('Preferences'),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: 'Language',
                    value: _selectedLanguage,
                    items: ['en', 'uz', 'ru'],
                    icon: Icons.language_outlined,
                    onChanged: (value) => setState(() => _selectedLanguage = value),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    label: 'Timezone',
                    value: _selectedTimezone,
                    items: ['UTC', 'UTC+5', 'UTC+3', 'UTC-5', 'UTC-8'],
                    icon: Icons.schedule_outlined,
                    onChanged: (value) => setState(() => _selectedTimezone = value),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(ProfileLoaded profile) {
    final avatarUrl = _newAvatarUrl ?? profile.avatarUrl;

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgCard,
                image: avatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: avatarUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : null,
            ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgDark.withValues(alpha: 0.7),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectiveStrengthSection(ProfileLoaded profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: profile.collectiveStrengthVerified
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: profile.collectiveStrengthVerified
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sports_soccer_outlined,
                color: profile.collectiveStrengthVerified ? AppColors.success : AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Collective Strength',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (profile.collectiveStrengthVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _collectiveStrengthController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Your Team Strength',
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              hintText: 'e.g., 3492',
              hintStyle: TextStyle(color: AppColors.textTertiary.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.fitness_center, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.bgCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _pickCollectiveStrengthProof,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Screenshot for Verification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.collectiveStrengthVerified
                ? '✓ Your collective strength has been verified by admin'
                : 'Upload a screenshot of your team to verify your collective strength. Admin will approve it.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = false,
    String? errorText,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffix,
        errorText: errorText,
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.lock_outline, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      style: const TextStyle(color: AppColors.textPrimary),
      dropdownColor: AppColors.bgCard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(_formatDropdownLabel(label, item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  String _formatDropdownLabel(String fieldLabel, String value) {
    if (fieldLabel == 'Language') {
      switch (value) {
        case 'en':
          return 'English';
        case 'uz':
          return 'O\'zbek';
        case 'ru':
          return 'Русский';
        default:
          return value;
      }
    }
    return value;
  }

  Color _getSkillLevelColor(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'beginner':
        return AppColors.textTertiary; // Bronze
      case 'intermediate':
        return AppColors.accent; // Silver
      case 'advanced':
        return AppColors.warning; // Gold
      case 'expert':
        return AppColors.primary; // Diamond
      case 'master':
        return AppColors.success; // Legend
      default:
        return AppColors.textSecondary;
    }
  }

  String _getSkillLevelText(String skillLevel) {
    switch (skillLevel.toLowerCase()) {
      case 'beginner':
        return '🥉 BRONZE';
      case 'intermediate':
        return '🥈 SILVER';
      case 'advanced':
        return '🥇 GOLD';
      case 'expert':
        return '💎 DIAMOND';
      case 'master':
        return '👑 LEGEND';
      default:
        return skillLevel.toUpperCase();
    }
  }

  Widget _buildCountryPickerField() {
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          countryListTheme: CountryListThemeData(
            backgroundColor: AppColors.bgCard,
            textStyle: const TextStyle(color: AppColors.textPrimary),
            searchTextStyle: const TextStyle(color: AppColors.textPrimary),
            inputDecoration: InputDecoration(
              labelText: 'Search',
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              hintText: 'Start typing to search',
              hintStyle: TextStyle(color: AppColors.textTertiary.withValues(alpha: 0.5)),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.bgDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          onSelect: (Country country) {
            setState(() {
              _countryController.text = country.name;
            });
          },
        );
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: _countryController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Country',
            labelStyle: const TextStyle(color: AppColors.textSecondary),
            hintText: 'Select your country',
            hintStyle: TextStyle(color: AppColors.textTertiary.withValues(alpha: 0.5)),
            prefixIcon: const Icon(Icons.public_outlined, color: AppColors.textSecondary),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.bgCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textTertiary.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
