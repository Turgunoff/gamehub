import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamehub/core/theme/app_colors.dart'; // O'zingizdagi path
import 'package:gamehub/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:gamehub/features/profile/presentation/bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary, // Dark color
      appBar: AppBar(
        title: const Text("Mening Profilim"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 1. Avatar va Ism
                _buildHeader(state),
                const SizedBox(height: 24),

                // 2. PES Statistikasi
                _buildPesStats(state),
                const SizedBox(height: 24),

                // 3. Tahrirlash tugmasi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/edit-profile'),
                    icon: const Icon(Icons.edit),
                    label: const Text("Profilni Tahrirlash"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ProfileState state) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[800],
          backgroundImage: state.avatarUrl.isNotEmpty
              ? NetworkImage(state.avatarUrl)
              : null,
          child: state.avatarUrl.isEmpty
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          state.username.isEmpty ? "Geymer" : state.username,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          state.phoneNumber.isEmpty ? "+998 -- --- -- --" : state.phoneNumber,
          style: TextStyle(color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildPesStats(ProfileState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("PES ID", state.pesId.isEmpty ? "Yo'q" : state.pesId),
          Container(width: 1, height: 40, color: Colors.grey[700]),
          _statItem("Jamoa Kuchi", "${state.teamStrength}"),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
      ],
    );
  }
}
