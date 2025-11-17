import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load profile only if not already loaded
    final profileBloc = context.read<ProfileBloc>();
    final currentState = profileBloc.state;

    // Only load if profile is not loaded yet
    if (currentState is! ProfileLoaded) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        profileBloc.add(LoadProfile(userId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final userId =
                          Supabase.instance.client.auth.currentUser?.id;
                      if (userId != null) {
                        context.read<ProfileBloc>().add(LoadProfile(userId));
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.bgCard,
              onRefresh: () async {
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId != null) {
                  context.read<ProfileBloc>().add(LoadProfile(userId));
                  // Wait for the bloc to finish loading
                  await context.read<ProfileBloc>().stream.firstWhere(
                        (state) => state is! ProfileLoading,
                      );
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Custom App Bar with gradient
                  _buildSliverAppBar(context, state),

                  // Profile Content
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // User Stats Cards
                        _buildStatsSection(state),

                        const SizedBox(height: 24),

                        // Profile completion indicator
                        if (state.profileCompletionPercentage < 100)
                          _buildProfileCompletion(state),

                        if (state.profileCompletionPercentage < 100)
                          const SizedBox(height: 24),

                        // Collective Strength Card
                        if (state.collectiveStrength > 0)
                          _buildCollectiveStrengthCard(state),

                        if (state.collectiveStrength > 0)
                          const SizedBox(height: 24),

                        // Profile Options
                        _buildProfileOptions(context),

                        const SizedBox(height: 24),

                        // Settings Section
                        _buildSettingsSection(context, state),

                        const SizedBox(height: 24),

                        // Logout Button
                        _buildLogoutSection(context),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  /// Custom SliverAppBar with profile header
  Widget _buildSliverAppBar(BuildContext context, ProfileLoaded profile) {
    return SliverAppBar(
      expandedHeight: 330,
      pinned: true,
      backgroundColor: AppColors.bgCard,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.bgCard,
                AppColors.bgDark,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Profile Avatar with glow effect
                _buildProfileAvatar(),

                const SizedBox(height: 16),

                // User Name with verified badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile.fullName.isEmpty
                          ? profile.username
                          : profile.fullName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.verified_rounded,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                // Skill level badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSkillLevelColor(
                      profile.skillLevel,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getSkillLevelColor(
                        profile.skillLevel,
                      ).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getSkillLevelText(profile.skillLevel),
                    style: TextStyle(
                      color: _getSkillLevelColor(profile.skillLevel),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // User Email with chip style
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        profile.email,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Badges row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Member since badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Since ${profile.createdAt.year}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Premium badge
                    if (profile.isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.warning,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.workspace_premium_rounded,
                              size: 12,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'PRO',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Reputation score
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.reputationScore}',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Edit Profile Button
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Profile Avatar with animated glow
  Widget _buildProfileAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
        ),

        // Gradient border
        Container(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgCard,
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.bgCardLight,
              child: Icon(
                Icons.person_rounded,
                size: 50,
                color: AppColors.primary,
              ),
              // For user image:
              // backgroundImage: NetworkImage(userImageUrl),
            ),
          ),
        ),

        // Online status indicator
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.bgCard, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  /// Profile Completion Widget
  Widget _buildProfileCompletion(ProfileLoaded profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.warning.withValues(alpha: 0.2),
              AppColors.warning.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: profile.profileCompletionPercentage / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.bgCardLight,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.warning,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${profile.profileCompletionPercentage}%',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your profile to unlock tournaments & challenges!',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// User Stats Section - PES Mobile focused
  Widget _buildStatsSection(ProfileLoaded profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Main stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.sports_soccer_rounded,
                  label: 'Matches',
                  value: '${profile.totalMatches}',
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.emoji_events_rounded,
                  label: 'Wins',
                  value: '${profile.wins}',
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.2),
                      AppColors.success.withValues(alpha: 0.05),
                    ],
                  ),
                  iconColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Win Rate',
                  value: '${profile.winRate.toStringAsFixed(0)}%',
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.2),
                      AppColors.accent.withValues(alpha: 0.05),
                    ],
                  ),
                  iconColor: AppColors.accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Additional PES stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.military_tech_rounded,
                  label: 'Tournaments',
                  value: '${profile.tournamentWins}',
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning.withValues(alpha: 0.2),
                      AppColors.warning.withValues(alpha: 0.05),
                    ],
                  ),
                  iconColor: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.close_rounded,
                  label: 'Losses',
                  value: '${profile.losses}',
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error.withValues(alpha: 0.2),
                      AppColors.error.withValues(alpha: 0.05),
                    ],
                  ),
                  iconColor: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.horizontal_rule_rounded,
                  label: 'Draws',
                  value: '${profile.draws}',
                  gradient: LinearGradient(
                    colors: [
                      AppColors.textTertiary.withValues(alpha: 0.2),
                      AppColors.textTertiary.withValues(alpha: 0.05),
                    ],
                  ),
                  iconColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Single stat card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Gradient gradient,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Profile Options Section - PES Mobile focused
  Widget _buildProfileOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bgCardLight, width: 1),
        ),
        child: Column(
          children: [
            _buildOptionTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              subtitle: 'Update your profile & preferences',
              iconBgColor: AppColors.primary.withValues(alpha: 0.2),
              iconColor: AppColors.primary,
              onTap: () {
                // Navigate to edit profile
              },
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.sports_soccer_rounded,
              title: 'Match History',
              subtitle: 'View all your PES battles',
              iconBgColor: AppColors.accent.withValues(alpha: 0.2),
              iconColor: AppColors.accent,
              onTap: () {
                // Navigate to match history
              },
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.emoji_events_outlined,
              title: 'My Tournaments',
              subtitle: 'Active & past tournaments',
              iconBgColor: AppColors.warning.withValues(alpha: 0.2),
              iconColor: AppColors.warning,
              onTap: () {
                // Navigate to tournaments
              },
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.military_tech_rounded,
              title: 'Achievements',
              subtitle: 'Trophies, badges & rewards',
              iconBgColor: AppColors.success.withValues(alpha: 0.2),
              iconColor: AppColors.success,
              onTap: () {
                // Navigate to achievements
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Settings Section
  Widget _buildSettingsSection(BuildContext context, ProfileLoaded profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bgCardLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage your alerts',
              iconBgColor: AppColors.success.withValues(alpha: 0.2),
              iconColor: AppColors.success,
              onTap: () {
                // Navigate to notifications settings
              },
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.security_rounded,
              title: 'Privacy & Security',
              subtitle: 'Control your privacy',
              iconBgColor: AppColors.primary.withValues(alpha: 0.2),
              iconColor: AppColors.primary,
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: profile.language.toUpperCase(),
              iconBgColor: AppColors.accent.withValues(alpha: 0.2),
              iconColor: AppColors.accent,
              onTap: () {
                // Navigate to language settings
              },
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              subtitle: 'Get help when you need it',
              iconBgColor: AppColors.warning.withValues(alpha: 0.2),
              iconColor: AppColors.warning,
              onTap: () {
                // Navigate to help
              },
            ),
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.info_outline_rounded,
              title: 'About GameHub',
              subtitle: 'PES Mobile v1.0.0',
              iconBgColor: AppColors.textTertiary.withValues(alpha: 0.2),
              iconColor: AppColors.textSecondary,
              onTap: () {
                // Navigate to about
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Logout Section
  Widget _buildLogoutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Option tile widget
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.textTertiary,
        size: 16,
      ),
    );
  }

  /// Divider widget
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.bgCardLight,
      indent: 16,
      endIndent: 16,
    );
  }

  /// Logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.bgCardLight, width: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Get skill level color - PES focused
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

  /// Get skill level text - PES focused
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

  /// Collective Strength Card (PES Mobile)
  Widget _buildCollectiveStrengthCard(ProfileLoaded profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: profile.collectiveStrengthVerified
                ? [
                    AppColors.success.withValues(alpha: 0.2),
                    AppColors.success.withValues(alpha: 0.05),
                  ]
                : [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: profile.collectiveStrengthVerified
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: profile.collectiveStrengthVerified
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sports_soccer_rounded,
                    color: profile.collectiveStrengthVerified
                        ? AppColors.success
                        : AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Team Strength',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${profile.collectiveStrength}',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: profile.collectiveStrengthVerified
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (profile.collectiveStrengthVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.success,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 12,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'VERIFIED',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.warning,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.pending,
                                    size: 12,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PENDING',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.warning,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              profile.collectiveStrengthVerified
                  ? '✓ Your team strength has been verified by admin'
                  : 'Waiting for admin verification...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
