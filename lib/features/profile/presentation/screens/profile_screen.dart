import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/profile_model.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_stats_section.dart';
import '../widgets/profile_pes_info_card.dart';
import '../widgets/profile_performance_chart.dart';
import '../widgets/profile_achievements_section.dart';
import '../widgets/profile_friends_section.dart';
import '../widgets/profile_recent_activity.dart';
import '../widgets/profile_floating_edit_button.dart';
import '../widgets/profile_background.dart';
import '../widgets/profile_app_bar.dart';

/// Profil ekrani
///
/// Foydalanuvchi profili, statistikasi va yutuqlari ko'rsatiladi.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _loadProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll listener - parallax effekt uchun
  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (mounted) {
        setState(() => _scrollOffset = _scrollController.offset);
      }
    });
  }

  /// Profilni yuklash
  void _loadProfile() {
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = _getUser(state);
        final isLoading = state is ProfileLoading;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Background
              const ProfileBackground(),

              // Main Content
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  ProfileAppBar(
                    user: user,
                    scrollOffset: _scrollOffset,
                    onSettingsTap: () => _navigateToSettings(context),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: isLoading
                        ? _buildLoadingIndicator()
                        : _buildContent(user),
                  ),
                ],
              ),

              // Floating Edit Button
              const ProfileFloatingEditButton(),
            ],
          ),
        );
      },
    );
  }

  /// Userni state dan olish
  UserMeModel? _getUser(ProfileState state) {
    if (state is ProfileLoaded) return state.user;
    if (state is ProfileUpdating) return state.user;
    return null;
  }

  /// Loading indicator
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(50),
        child: CircularProgressIndicator(
          color: Color(0xFF6C5CE7),
        ),
      ),
    );
  }

  /// Asosiy kontent
  Widget _buildContent(UserMeModel? user) {
    return Column(
      children: [
        // Statistika
        ProfileStatsSection(user: user),

        // PES ma'lumotlari
        ProfilePESInfoCard(user: user),

        // Do'stlar
        const SizedBox(height: 24),
        const ProfileFriendsSection(),

        // Grafik
        const ProfilePerformanceChart(),

        // Yutuqlar
        const ProfileAchievementsSection(),

        // So'nggi faoliyat
        const ProfileRecentActivity(),

        // Pastki joy
        const SizedBox(height: 100),
      ],
    );
  }

  /// Sozlamalarga o'tish
  void _navigateToSettings(BuildContext context) {
    HapticFeedback.lightImpact();
    context.push('/settings');
  }
}
