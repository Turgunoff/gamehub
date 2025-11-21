import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamehub/core/theme/app_colors.dart'; // Theme path
import 'package:gamehub/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:gamehub/features/profile/presentation/bloc/profile_event.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _pesIdController;
  late TextEditingController _strengthController;

  @override
  void initState() {
    super.initState();
    // Hozirgi ma'lumotlarni olib formaga qo'yamiz
    final state = context.read<ProfileBloc>().state;
    _usernameController = TextEditingController(text: state.username);
    _pesIdController = TextEditingController(text: state.pesId);
    _strengthController = TextEditingController(
      text: state.teamStrength == 0 ? '' : state.teamStrength.toString(),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _pesIdController.dispose();
    _strengthController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final pesId = _pesIdController.text.trim();
    final username = _usernameController.text.trim();
    final strength = _strengthController.text.trim();

    // 1. Oddiy Validatsiya
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nickname bo'sh bo'lmasligi kerak")),
      );
      return;
    }

    if (pesId.length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PES ID 9 xonali bo'lishi shart!")),
      );
      return;
    }

    // 2. Bloc ga yuborish
    context.read<ProfileBloc>().add(
      UpdateProfile(
        username: username,
        pesId: pesId,
        teamStrength: int.tryParse(strength) ?? 0,
      ),
    );

    // 3. Ortga qaytish
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text("Profilni Tahrirlash"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Nickname
              _buildTextField(
                controller: _usernameController,
                label: "Nickname",
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // PES ID
              _buildTextField(
                controller: _pesIdController,
                label: "PES ID (9 xonali)",
                icon: Icons.gamepad,
                isNumber: true,
                maxLength: 9,
              ),
              const SizedBox(height: 16),

              // Team Strength
              _buildTextField(
                controller: _strengthController,
                label: "Jamoa Kuchi (Team Strength)",
                icon: Icons.flash_on,
                isNumber: true,
                maxLength: 4,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    "Saqlash",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: AppColors.primary),
        counterText: "", // MaxLength counter ni yashirish
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[800]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: AppColors.bgCard,
      ),
    );
  }
}
