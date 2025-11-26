import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Import your models and blocs
// import 'package:gamehub/core/models/profile_model.dart';
// import 'package:gamehub/features/profile/presentation/bloc/profile_bloc.dart';
// import 'package:gamehub/features/profile/presentation/bloc/profile_event.dart';
// import 'package:gamehub/features/profile/presentation/bloc/profile_state.dart';
// import 'package:gamehub/core/services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Controllers - Shaxsiy
  final _nicknameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  // Controllers - Ijtimoiy
  final _telegramController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _discordController = TextEditingController();

  // Controllers - O'yin
  final _pesIdController = TextEditingController();
  final _strengthController = TextEditingController();
  final _availableHoursController = TextEditingController();

  // Phone verification
  final _phoneCodeController = TextEditingController();
  bool _isPhoneVerified = false;
  bool _showPhoneCodeField = false;
  bool _isVerifyingPhone = false;

  // Selections
  String _selectedRegion = 'Tashkent';
  String _selectedGender = 'male';
  String _selectedLanguage = 'uz';
  String _selectedPlayStyle = 'balanced';
  String _selectedFormation = '4-3-3';
  String? _selectedFavoriteTeam;
  DateTime? _selectedBirthDate;

  // Avatar
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isInitialized = false;
  bool _isLoading = false;

  // Dropdown options
  final List<String> _regions = [
    'Tashkent',
    'Samarkand',
    'Bukhara',
    'Andijan',
    'Fergana',
    'Namangan',
    'Kashkadarya',
    'Surkhandarya',
    'Khorezm',
    'Navoi',
    'Jizzakh',
    'Syrdarya',
    'Karakalpakstan',
  ];

  final List<String> _genders = ['male', 'female', 'other'];
  final List<String> _languages = ['uz', 'ru', 'en'];
  final List<String> _playStyles = ['attacking', 'defensive', 'balanced'];
  final List<String> _formations = [
    '4-3-3',
    '4-4-2',
    '4-2-4',
    '3-5-2',
    '5-3-2',
    '4-1-4-1',
  ];
  final List<String> _teams = [
    'Barcelona',
    'Real Madrid',
    'Manchester United',
    'Manchester City',
    'Liverpool',
    'Chelsea',
    'Arsenal',
    'Bayern Munich',
    'PSG',
    'Juventus',
    'AC Milan',
    'Inter Milan',
    'Borussia Dortmund',
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _telegramController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _discordController.dispose();
    _pesIdController.dispose();
    _strengthController.dispose();
    _availableHoursController.dispose();
    _phoneCodeController.dispose();
    super.dispose();
  }

  void _initializeWithProfile(dynamic profile) {
    if (_isInitialized || profile == null) return;
    _isInitialized = true;

    // Shaxsiy
    _nicknameController.text = profile.nickname ?? '';
    _fullNameController.text = profile.fullName ?? '';
    _phoneController.text = profile.phone ?? '';
    _bioController.text = profile.bio ?? '';
    _selectedRegion = profile.region ?? 'Tashkent';
    _selectedGender = profile.gender ?? 'male';
    _selectedLanguage = profile.language ?? 'uz';
    _isPhoneVerified = profile.isVerified ?? false;

    if (profile.birthDate != null) {
      _selectedBirthDate = DateTime.tryParse(profile.birthDate);
    }

    // Ijtimoiy
    _telegramController.text = profile.telegram ?? '';
    _instagramController.text = profile.instagram ?? '';
    _youtubeController.text = profile.youtube ?? '';
    _discordController.text = profile.discord ?? '';

    // O'yin
    _pesIdController.text = profile.pesId ?? '';
    _strengthController.text = profile.teamStrength?.toString() ?? '';
    _selectedFavoriteTeam = profile.favoriteTeam;
    _selectedPlayStyle = profile.playStyle ?? 'balanced';
    _selectedFormation = profile.preferredFormation ?? '4-3-3';
    _availableHoursController.text = profile.availableHours ?? '';

    setState(() {});
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 10),
      ), // 10 yosh min
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C5CE7),
              surface: Color(0xFF1A1F3A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _sendPhoneCode() {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Telefon raqamni kiriting', isError: true);
      return;
    }

    setState(() {
      _showPhoneCodeField = true;
    });

    _showSnackBar('Kod yuborildi: 123456');
  }

  Future<void> _verifyPhone() async {
    if (_phoneCodeController.text != '123456') {
      _showSnackBar('Kod noto\'g\'ri', isError: true);
      return;
    }

    setState(() {
      _isVerifyingPhone = true;
    });

    try {
      // API call
      // await ApiService().verifyPhone(_phoneController.text, _phoneCodeController.text);

      // Hozircha mock
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isPhoneVerified = true;
        _showPhoneCodeField = false;
        _isVerifyingPhone = false;
      });

      _showSnackBar('Telefon tasdiqlandi!');
    } catch (e) {
      setState(() {
        _isVerifyingPhone = false;
      });
      _showSnackBar('Xatolik: $e', isError: true);
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Formani to\'g\'ri to\'ldiring', isError: true);
      return;
    }

    HapticFeedback.mediumImpact();

    final data = {
      'nickname': _nicknameController.text.trim().isEmpty
          ? null
          : _nicknameController.text.trim(),
      'full_name': _fullNameController.text.trim().isEmpty
          ? null
          : _fullNameController.text.trim(),
      'phone': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      'birth_date': _selectedBirthDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedBirthDate!)
          : null,
      'gender': _selectedGender,
      'region': _selectedRegion,
      'bio': _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      'language': _selectedLanguage,
      'telegram': _telegramController.text.trim().isEmpty
          ? null
          : _telegramController.text.trim(),
      'instagram': _instagramController.text.trim().isEmpty
          ? null
          : _instagramController.text.trim(),
      'youtube': _youtubeController.text.trim().isEmpty
          ? null
          : _youtubeController.text.trim(),
      'discord': _discordController.text.trim().isEmpty
          ? null
          : _discordController.text.trim(),
      'pes_id': _pesIdController.text.trim().isEmpty
          ? null
          : _pesIdController.text.trim(),
      'team_strength': _strengthController.text.trim().isEmpty
          ? null
          : int.tryParse(_strengthController.text.trim()),
      'favorite_team': _selectedFavoriteTeam,
      'play_style': _selectedPlayStyle,
      'preferred_formation': _selectedFormation,
      'available_hours': _availableHoursController.text.trim().isEmpty
          ? null
          : _availableHoursController.text.trim(),
    };

    print('💾 Saving profile: $data');

    // TODO: Call ProfileBloc
    // context.read<ProfileBloc>().add(ProfileUpdateRequested(...));

    _showSnackBar('Profil saqlandi!');
    Navigator.pop(context);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: isError ? Colors.red : const Color(0xFF00FB94),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF1A1F3A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1F3A), Color(0xFF0A0E1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        _buildAvatarSection(),
                        const SizedBox(height: 32),

                        // Shaxsiy ma'lumotlar
                        _buildSectionTitle('👤 SHAXSIY MA\'LUMOTLAR'),
                        const SizedBox(height: 16),
                        _buildPersonalSection(),
                        const SizedBox(height: 32),

                        // Telefon tasdiqlash
                        _buildSectionTitle('📱 TELEFON TASDIQLASH'),
                        const SizedBox(height: 16),
                        _buildPhoneVerificationSection(),
                        const SizedBox(height: 32),

                        // Ijtimoiy tarmoqlar
                        _buildSectionTitle('🌐 IJTIMOIY TARMOQLAR'),
                        const SizedBox(height: 16),
                        _buildSocialSection(),
                        const SizedBox(height: 32),

                        // O'yin ma'lumotlari
                        _buildSectionTitle('🎮 O\'YIN MA\'LUMOTLARI'),
                        const SizedBox(height: 16),
                        _buildGameSection(),
                        const SizedBox(height: 32),

                        // Bio
                        _buildSectionTitle('📝 BIO'),
                        const SizedBox(height: 16),
                        _buildBioField(),
                        const SizedBox(height: 40),

                        // Save button
                        _buildSaveButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
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
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'PROFILNI TAHRIRLASH',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF6C5CE7),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
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
              child: ClipOval(
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: 114,
                        height: 114,
                      )
                    : const Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF6C5CE7),
                      ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) {
                  setState(() => _selectedImage = File(picked.path));
                }
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
          ),
          // Verified badge
          if (_isPhoneVerified)
            Positioned(
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
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _nicknameController,
          label: 'Nickname',
          icon: Icons.person,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Nickname kiriting';
            if (v.length < 3) return 'Kamida 3 ta belgi';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _fullNameController,
          label: 'To\'liq ism',
          icon: Icons.badge,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Viloyat',
          icon: Icons.location_on,
          value: _selectedRegion,
          items: _regions,
          onChanged: (v) => setState(() => _selectedRegion = v!),
        ),
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'Jins',
                icon: Icons.wc,
                value: _selectedGender,
                items: _genders,
                displayItems: ['Erkak', 'Ayol', 'Boshqa'],
                onChanged: (v) => setState(() => _selectedGender = v!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                label: 'Til',
                icon: Icons.language,
                value: _selectedLanguage,
                items: _languages,
                displayItems: ['O\'zbek', 'Русский', 'English'],
                onChanged: (v) => setState(() => _selectedLanguage = v!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneVerificationSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _phoneController,
                label: 'Telefon raqam',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                enabled: !_isPhoneVerified,
                suffix: _isPhoneVerified
                    ? const Icon(
                        Icons.verified,
                        color: Color(0xFF00FB94),
                        size: 20,
                      )
                    : null,
              ),
            ),
            if (!_isPhoneVerified) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _sendPhoneCode,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'KOD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_showPhoneCodeField && !_isPhoneVerified) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _phoneCodeController,
                  label: 'Tasdiqlash kodi',
                  icon: Icons.lock,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _isVerifyingPhone ? null : _verifyPhone,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _isVerifyingPhone
                        ? Colors.grey
                        : const Color(0xFF00FB94),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isVerifyingPhone
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Test kod: 123456',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
        if (_isPhoneVerified)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00FB94).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00FB94).withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user, color: Color(0xFF00FB94), size: 20),
                SizedBox(width: 12),
                Text(
                  'Telefon tasdiqlangan ✓',
                  style: TextStyle(
                    color: Color(0xFF00FB94),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _telegramController,
          label: 'Telegram',
          icon: Icons.telegram,
          prefix: '@',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _instagramController,
          label: 'Instagram',
          icon: Icons.camera_alt,
          prefix: '@',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _youtubeController,
          label: 'YouTube',
          icon: Icons.play_circle,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _discordController,
          label: 'Discord',
          icon: Icons.discord,
        ),
      ],
    );
  }

  Widget _buildGameSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _pesIdController,
          label: 'PES ID',
          icon: Icons.fingerprint,
          keyboardType: TextInputType.number,
          maxLength: 15,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _strengthController,
          label: 'Jamoa kuchi (1000-5000)',
          icon: Icons.flash_on,
          keyboardType: TextInputType.number,
          maxLength: 4,
          validator: (v) {
            if (v != null && v.isNotEmpty) {
              final n = int.tryParse(v);
              if (n == null || n < 1000 || n > 5000) {
                return '1000-5000 orasida bo\'lishi kerak';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Sevimli jamoa',
          icon: Icons.sports_soccer,
          value: _selectedFavoriteTeam,
          items: _teams,
          onChanged: (v) => setState(() => _selectedFavoriteTeam = v),
          isNullable: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                label: 'O\'yin uslubi',
                icon: Icons.sports,
                value: _selectedPlayStyle,
                items: _playStyles,
                displayItems: ['Hujumkor', 'Himoyachi', 'Muvozanat'],
                onChanged: (v) => setState(() => _selectedPlayStyle = v!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                label: 'Taktika',
                icon: Icons.grid_on,
                value: _selectedFormation,
                items: _formations,
                onChanged: (v) => setState(() => _selectedFormation = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _availableHoursController,
          label: 'O\'ynash vaqti (masalan: 18:00-23:00)',
          icon: Icons.access_time,
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _bioController,
        maxLines: 4,
        maxLength: 500,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'O\'zingiz haqingizda qisqacha...',
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: Icon(Icons.edit_note, color: Color(0xFF6C5CE7)),
          ),
          counterStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectBirthDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF6C5CE7)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _selectedBirthDate != null
                    ? DateFormat('dd.MM.yyyy').format(_selectedBirthDate!)
                    : 'Tug\'ilgan sana',
                style: TextStyle(
                  color: _selectedBirthDate != null
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    String? prefix,
    Widget? suffix,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        enabled: enabled,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7)),
          prefixText: prefix,
          prefixStyle: const TextStyle(color: Colors.white70),
          suffixIcon: suffix,
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    List<String>? displayItems,
    required Function(String?) onChanged,
    bool isNullable = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7)),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF1A1F3A),
        style: const TextStyle(color: Colors.white),
        hint: Text(
          'Tanlang',
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        items: [
          if (isNullable)
            const DropdownMenuItem(value: null, child: Text('Tanlanmagan')),
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return DropdownMenuItem(
              value: item,
              child: Text(displayItems != null ? displayItems[idx] : item),
            );
          }),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5CE7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'SAQLASH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
