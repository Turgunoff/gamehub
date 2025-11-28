import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/models/profile_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/image_picker_service.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

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
  String? _selectedRegion;
  String? _selectedGender;
  String _selectedLanguage = 'uz';
  DateTime? _selectedBirthDate;

  // Ijtimoiy tarmoqlar - qaysi biri tanlangan
  String? _selectedSocialNetwork;

  // O'ynash vaqti
  TimeOfDay _startTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 23, minute: 0);
  bool _hasSetPlayTime = false;

  // Avatar
  File? _selectedImage;
  String? _currentAvatarUrl;
  bool _isUploadingAvatar = false;
  final ImagePickerService _imagePickerService = ImagePickerService();
  final ApiService _apiService = ApiService();

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

  final List<String> _genders = ['male', 'female'];
  final List<String> _languages = ['uz', 'ru', 'en'];

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

  void _initializeWithProfile(ProfileModel? profile) {
    if (_isInitialized) return;
    _isInitialized = true;

    if (profile == null) {
      // Profil yo'q - default qiymatlar bilan qoldirish
      setState(() {});
      return;
    }

    // Shaxsiy - mavjud ma'lumotlarni to'ldirish, null bo'lsa bo'sh qoldirish
    _nicknameController.text = profile.nickname ?? '';
    _fullNameController.text = profile.fullName ?? '';
    _phoneController.text = profile.phone ?? '';
    _bioController.text = profile.bio ?? '';

    // Dropdown uchun - faqat qiymat mavjud bo'lsa o'zgartirish
    if (profile.region != null && _regions.contains(profile.region)) {
      _selectedRegion = profile.region!;
    }
    if (profile.gender != null && _genders.contains(profile.gender)) {
      _selectedGender = profile.gender!;
    }
    if (profile.language != null && _languages.contains(profile.language)) {
      _selectedLanguage = profile.language!;
    }

    _isPhoneVerified = profile.isVerified;

    if (profile.birthDate != null) {
      _selectedBirthDate = DateTime.tryParse(profile.birthDate!);
    }

    // Ijtimoiy
    _telegramController.text = profile.telegram ?? '';
    _instagramController.text = profile.instagram ?? '';
    _youtubeController.text = profile.youtube ?? '';
    _discordController.text = profile.discord ?? '';

    // O'yin
    _pesIdController.text = profile.pesId ?? '';
    _strengthController.text = profile.teamStrength?.toString() ?? '';
    _availableHoursController.text = profile.availableHours ?? '';

    // Avatar
    _currentAvatarUrl = profile.avatarUrl;

    // O'ynash vaqtini parse qilish
    if (profile.availableHours != null && profile.availableHours!.contains('-')) {
      final parts = profile.availableHours!.split('-');
      if (parts.length == 2) {
        final startParts = parts[0].split(':');
        final endParts = parts[1].split(':');
        if (startParts.length == 2 && endParts.length == 2) {
          _startTime = TimeOfDay(
            hour: int.tryParse(startParts[0]) ?? 18,
            minute: int.tryParse(startParts[1]) ?? 0,
          );
          _endTime = TimeOfDay(
            hour: int.tryParse(endParts[0]) ?? 23,
            minute: int.tryParse(endParts[1]) ?? 0,
          );
          _hasSetPlayTime = true;
        }
      }
    }

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

    setState(() => _isLoading = true);

    // ProfileBloc orqali saqlash
    context.read<ProfileBloc>().add(
      ProfileUpdateRequested(
        nickname: _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
        fullName: _fullNameController.text.trim().isEmpty
            ? null
            : _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        birthDate: _selectedBirthDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedBirthDate!)
            : null,
        gender: _selectedGender,
        region: _selectedRegion,
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        language: _selectedLanguage,
        telegram: _telegramController.text.trim().isEmpty
            ? null
            : _telegramController.text.trim(),
        instagram: _instagramController.text.trim().isEmpty
            ? null
            : _instagramController.text.trim(),
        youtube: _youtubeController.text.trim().isEmpty
            ? null
            : _youtubeController.text.trim(),
        discord: _discordController.text.trim().isEmpty
            ? null
            : _discordController.text.trim(),
        pesId: _pesIdController.text.trim().isEmpty
            ? null
            : _pesIdController.text.trim(),
        teamStrength: _strengthController.text.trim().isEmpty
            ? null
            : int.tryParse(_strengthController.text.trim()),
        availableHours: _availableHoursController.text.trim().isEmpty
            ? null
            : _availableHoursController.text.trim(),
      ),
    );
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
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _initializeWithProfile(state.user.profile);
        } else if (state is ProfileUpdateSuccess) {
          setState(() => _isLoading = false);
          _showSnackBar('Profil muvaffaqiyatli saqlandi!');
          Navigator.pop(context);
        } else if (state is ProfileError) {
          setState(() => _isLoading = false);
          _showSnackBar(state.message, isError: true);
        } else if (state is ProfileUpdating) {
          setState(() => _isLoading = true);
        }
      },
      builder: (context, state) {
        // Profil yuklanganda ma'lumotlarni to'ldirish
        if (state is ProfileLoaded && !_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeWithProfile(state.user.profile);
          });
        }

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
                            const SizedBox(height: 100), // Save button uchun joy
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Fixed bottom save button
          bottomNavigationBar: _buildFixedSaveButton(),
        );
      },
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
              child: ClipOval(
                child: _isUploadingAvatar
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C5CE7),
                          strokeWidth: 2,
                        ),
                      )
                    : _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: 114,
                            height: 114,
                          )
                        : _currentAvatarUrl != null
                            ? CachedNetworkImage(
                                imageUrl: _currentAvatarUrl!,
                                fit: BoxFit.cover,
                                width: 114,
                                height: 114,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6C5CE7),
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF6C5CE7),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Color(0xFF6C5CE7),
                              ),
              ),
            ),
          ),
          // Rasm tanlash tugmasi
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
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
          // Rasmni o'chirish tugmasi
          if (_selectedImage != null || _currentAvatarUrl != null)
            Positioned(
              bottom: 0,
              left: 0,
              child: GestureDetector(
                onTap: _isUploadingAvatar ? null : _removeAvatar,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.9),
                  ),
                  child: const Icon(
                    Icons.close,
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

  /// Rasm tanlash va yuklash
  Future<void> _pickAndUploadAvatar() async {
    HapticFeedback.lightImpact();

    final file = await _imagePickerService.pickAndCropAvatar(context);
    if (file == null) return;

    setState(() {
      _selectedImage = file;
      _isUploadingAvatar = true;
    });

    try {
      final response = await _apiService.uploadAvatar(file.path);

      if (response.success && response.avatarUrl != null) {
        setState(() {
          _currentAvatarUrl = response.avatarUrl;
          _isUploadingAvatar = false;
        });
        _showSnackBar('Avatar muvaffaqiyatli yuklandi!');
      } else {
        setState(() {
          _selectedImage = null;
          _isUploadingAvatar = false;
        });
        _showSnackBar(response.message ?? 'Avatar yuklashda xatolik', isError: true);
      }
    } catch (e) {
      setState(() {
        _selectedImage = null;
        _isUploadingAvatar = false;
      });
      _showSnackBar('Avatar yuklashda xatolik: $e', isError: true);
    }
  }

  /// Avatarni o'chirish
  Future<void> _removeAvatar() async {
    HapticFeedback.lightImpact();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Avatarni o\'chirish',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Haqiqatan ham avatarni o\'chirmoqchimisiz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'O\'chirish',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUploadingAvatar = true);

    try {
      final success = await _apiService.deleteAvatar();

      if (success) {
        setState(() {
          _selectedImage = null;
          _currentAvatarUrl = null;
          _isUploadingAvatar = false;
        });
        _showSnackBar('Avatar o\'chirildi');
      } else {
        setState(() => _isUploadingAvatar = false);
        _showSnackBar('Avatar o\'chirishda xatolik', isError: true);
      }
    } catch (e) {
      setState(() => _isUploadingAvatar = false);
      _showSnackBar('Avatar o\'chirishda xatolik: $e', isError: true);
    }
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
        // Viloyat - Chip style
        _buildChipSelector(
          label: 'Viloyat',
          icon: Icons.location_on,
          selectedValue: _selectedRegion,
          items: _regions,
          onSelected: (v) => setState(() => _selectedRegion = v),
        ),
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 16),
        // Jins - Toggle buttons
        _buildGenderSelector(),
        const SizedBox(height: 16),
        // Til - Segment style
        _buildLanguageSelector(),
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
        // Iconlar bir qatorda
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialIcon(
              icon: Icons.telegram,
              label: 'Telegram',
              color: const Color(0xFF0088CC),
              isSelected: _selectedSocialNetwork == 'telegram',
              hasValue: _telegramController.text.isNotEmpty,
              onTap: () => setState(() {
                _selectedSocialNetwork = _selectedSocialNetwork == 'telegram' ? null : 'telegram';
              }),
            ),
            _buildSocialIcon(
              icon: Icons.camera_alt,
              label: 'Instagram',
              color: const Color(0xFFE4405F),
              isSelected: _selectedSocialNetwork == 'instagram',
              hasValue: _instagramController.text.isNotEmpty,
              onTap: () => setState(() {
                _selectedSocialNetwork = _selectedSocialNetwork == 'instagram' ? null : 'instagram';
              }),
            ),
            _buildSocialIcon(
              icon: Icons.play_circle,
              label: 'YouTube',
              color: const Color(0xFFFF0000),
              isSelected: _selectedSocialNetwork == 'youtube',
              hasValue: _youtubeController.text.isNotEmpty,
              onTap: () => setState(() {
                _selectedSocialNetwork = _selectedSocialNetwork == 'youtube' ? null : 'youtube';
              }),
            ),
            _buildSocialIcon(
              icon: Icons.discord,
              label: 'Discord',
              color: const Color(0xFF5865F2),
              isSelected: _selectedSocialNetwork == 'discord',
              hasValue: _discordController.text.isNotEmpty,
              onTap: () => setState(() {
                _selectedSocialNetwork = _selectedSocialNetwork == 'discord' ? null : 'discord';
              }),
            ),
          ],
        ),
        // Tanlangan tarmoq uchun textfield
        if (_selectedSocialNetwork != null) ...[
          const SizedBox(height: 16),
          _buildSocialTextField(),
        ],
      ],
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color
                    : hasValue
                        ? color.withOpacity(0.5)
                        : Colors.transparent,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    color: isSelected || hasValue ? color : Colors.white54,
                    size: 28,
                  ),
                ),
                if (hasValue)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FB94),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected || hasValue ? Colors.white : Colors.white54,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialTextField() {
    TextEditingController controller;
    String label;
    String? prefix;

    switch (_selectedSocialNetwork) {
      case 'telegram':
        controller = _telegramController;
        label = 'Telegram username';
        prefix = '@';
        break;
      case 'instagram':
        controller = _instagramController;
        label = 'Instagram username';
        prefix = '@';
        break;
      case 'youtube':
        controller = _youtubeController;
        label = 'YouTube kanal';
        prefix = null;
        break;
      case 'discord':
        controller = _discordController;
        label = 'Discord username';
        prefix = null;
        break;
      default:
        return const SizedBox.shrink();
    }

    return _buildTextField(
      controller: controller,
      label: label,
      icon: Icons.link,
      prefix: prefix,
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
        _buildPlayTimeSelector(),
      ],
    );
  }

  // O'ynash vaqti uchun zamonaviy selector
  Widget _buildPlayTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, color: Color(0xFF6C5CE7), size: 20),
            const SizedBox(width: 8),
            Text(
              'O\'ynash vaqti',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (_hasSetPlayTime)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _hasSetPlayTime = false;
                    _availableHoursController.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Tozalash',
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (!_hasSetPlayTime)
          // Vaqt tanlanmagan holat
          GestureDetector(
            onTap: () => _showPlayTimeBottomSheet(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vaqtni belgilash',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Vaqt tanlangan holat
          GestureDetector(
            onTap: () => _showPlayTimeBottomSheet(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C5CE7).withOpacity(0.15),
                    const Color(0xFF00D9FF).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF6C5CE7).withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Boshlanish vaqti
                  Expanded(
                    child: _buildTimeCard(
                      label: 'Boshlanish',
                      time: _startTime,
                      icon: Icons.play_arrow_rounded,
                      color: const Color(0xFF00FB94),
                    ),
                  ),
                  // Chiziq
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 24,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _calculateDuration(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tugash vaqti
                  Expanded(
                    child: _buildTimeCard(
                      label: 'Tugash',
                      time: _endTime,
                      icon: Icons.stop_rounded,
                      color: const Color(0xFFFF6B6B),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeCard({
    required String label,
    required TimeOfDay time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateDuration() {
    int startMinutes = _startTime.hour * 60 + _startTime.minute;
    int endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes < startMinutes) {
      endMinutes += 24 * 60; // Keyingi kunga o'tish
    }

    int duration = endMinutes - startMinutes;
    int hours = duration ~/ 60;
    int minutes = duration % 60;

    if (minutes == 0) {
      return '$hours soat';
    }
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  void _showPlayTimeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1F3A), Color(0xFF0A0E1A)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Row(
                children: [
                  Icon(Icons.schedule, color: Color(0xFF6C5CE7)),
                  SizedBox(width: 12),
                  Text(
                    'O\'ynash vaqtini tanlang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Vaqt tanlovchilar
              Row(
                children: [
                  Expanded(
                    child: _buildTimePickerCard(
                      label: 'Boshlanish',
                      time: _startTime,
                      color: const Color(0xFF00FB94),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
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
                          setModalState(() => _startTime = picked);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePickerCard(
                      label: 'Tugash',
                      time: _endTime,
                      color: const Color(0xFFFF6B6B),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _endTime,
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
                          setModalState(() => _endTime = picked);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tez tanlash opsiyalari
              Text(
                'Tez tanlash',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickTimeOption('Ertalab', const TimeOfDay(hour: 6, minute: 0), const TimeOfDay(hour: 12, minute: 0), setModalState),
                  _buildQuickTimeOption('Kunduzi', const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 18, minute: 0), setModalState),
                  _buildQuickTimeOption('Kechqurun', const TimeOfDay(hour: 18, minute: 0), const TimeOfDay(hour: 23, minute: 0), setModalState),
                  _buildQuickTimeOption('Tungi', const TimeOfDay(hour: 22, minute: 0), const TimeOfDay(hour: 3, minute: 0), setModalState),
                  _buildQuickTimeOption('Kun bo\'yi', const TimeOfDay(hour: 0, minute: 0), const TimeOfDay(hour: 23, minute: 59), setModalState),
                ],
              ),

              const SizedBox(height: 24),

              // Tasdiqlash tugmasi
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _hasSetPlayTime = true;
                      _availableHoursController.text =
                        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}-'
                        '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}';
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tasdiqlash',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerCard({
    required String label,
    required TimeOfDay time,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bosing',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTimeOption(String label, TimeOfDay start, TimeOfDay end, StateSetter setModalState) {
    final isSelected = _startTime.hour == start.hour &&
                       _startTime.minute == start.minute &&
                       _endTime.hour == end.hour &&
                       _endTime.minute == end.minute;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setModalState(() {
          _startTime = start;
          _endTime = end;
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
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

  // Viloyat uchun - Chip style dropdown
  Widget _buildChipSelector({
    required String label,
    required IconData icon,
    required String? selectedValue,
    required List<String> items,
    required Function(String?) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showRegionBottomSheet(items, selectedValue, onSelected),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: selectedValue != null
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF6C5CE7).withOpacity(0.15),
                        const Color(0xFF00D9FF).withOpacity(0.1),
                      ],
                    )
                  : null,
              color: selectedValue == null ? Colors.white.withOpacity(0.05) : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedValue != null
                    ? const Color(0xFF6C5CE7).withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedValue ?? 'Viloyatni tanlang',
                    style: TextStyle(
                      color: selectedValue != null
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      fontSize: 15,
                      fontWeight: selectedValue != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: selectedValue != null
                      ? const Color(0xFF6C5CE7)
                      : Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRegionBottomSheet(
    List<String> items,
    String? selectedValue,
    Function(String?) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1F3A), Color(0xFF0A0E1A)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF6C5CE7)),
                  const SizedBox(width: 12),
                  const Text(
                    'Viloyatni tanlang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (selectedValue != null)
                    GestureDetector(
                      onTap: () {
                        onSelected(null);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tozalash',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item == selectedValue;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onSelected(item);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                              )
                            : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            item,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Jins uchun - Toggle style
  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, color: Color(0xFF6C5CE7), size: 20),
            const SizedBox(width: 8),
            Text(
              'Jins',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                icon: Icons.male,
                label: 'Erkak',
                value: 'male',
                gradient: const [Color(0xFF00D9FF), Color(0xFF6C5CE7)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption(
                icon: Icons.female,
                label: 'Ayol',
                value: 'female',
                gradient: const [Color(0xFFFF6B9D), Color(0xFFC44569)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedGender = _selectedGender == value ? null : value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: gradient)
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Til uchun - Segment style
  Widget _buildLanguageSelector() {
    final languages = [
      {'code': 'uz', 'label': "O'zbek", 'flag': '🇺🇿'},
      {'code': 'ru', 'label': 'Русский', 'flag': '🇷🇺'},
      {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.language, color: Color(0xFF6C5CE7), size: 20),
            const SizedBox(width: 8),
            Text(
              'Til',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: languages.map((lang) {
              final isSelected = _selectedLanguage == lang['code'];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedLanguage = lang['code']!);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6C5CE7).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang['flag']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          lang['label']!,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedSaveButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0E1A).withOpacity(0),
            const Color(0xFF0A0E1A),
          ],
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF00D9FF)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
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
      ),
    );
  }
}
