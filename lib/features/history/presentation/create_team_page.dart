// lib/features/teams/presentation/pages/create_team_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/auth_text_field.dart';
import '../../../../shared/widgets/auth_button.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();

  String _selectedSkillLevel = 'Intermediate';
  String _selectedRegion = 'Asia';
  int _maxMembers = 11;
  bool _isOpen = true;

  final List<String> _skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Pro',
  ];
  final List<String> _regions = ['Asia', 'Europe', 'Americas', 'Global'];

  @override
  void dispose() {
    _teamNameController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: const Text(
          'Create Team',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team Logo Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.sports_soccer,
                        color: AppColors.primary,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // TODO: Add logo upload functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logo upload coming soon!'),
                          ),
                        );
                      },
                      child: Text(
                        'Add Team Logo',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Team Name
              AuthTextField(
                controller: _teamNameController,
                label: 'Team Name',
                hint: 'Enter team name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Team name is required';
                  }
                  if (value.length < 3) {
                    return 'Team name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              AuthTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Tell others about your team...',
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Skill Level
              Text(
                'Skill Level',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.bgCardLight.withOpacity(0.3),
                  ),
                ),
                child: DropdownButton<String>(
                  value: _selectedSkillLevel,
                  onChanged: (value) =>
                      setState(() => _selectedSkillLevel = value!),
                  underline: const SizedBox(),
                  dropdownColor: AppColors.bgCard,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  isExpanded: true,
                  items: _skillLevels
                      .map(
                        (level) =>
                            DropdownMenuItem(value: level, child: Text(level)),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Region
              Text(
                'Region',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.bgCardLight.withOpacity(0.3),
                  ),
                ),
                child: DropdownButton<String>(
                  value: _selectedRegion,
                  onChanged: (value) =>
                      setState(() => _selectedRegion = value!),
                  underline: const SizedBox(),
                  dropdownColor: AppColors.bgCard,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  isExpanded: true,
                  items: _regions
                      .map(
                        (region) => DropdownMenuItem(
                          value: region,
                          child: Text(region),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Max Members
              Text(
                'Maximum Members',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.bgCardLight.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Players: $_maxMembers',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _maxMembers > 5
                          ? () => setState(() => _maxMembers--)
                          : null,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: _maxMembers > 5
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _maxMembers < 20
                          ? () => setState(() => _maxMembers++)
                          : null,
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: _maxMembers < 20
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Requirements (Optional)
              AuthTextField(
                controller: _requirementsController,
                label: 'Requirements (Optional)',
                hint: 'e.g., Minimum rating 800, must have mic...',
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),

              // Open for Recruitment
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.bgCardLight.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Open for Recruitment',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Allow other players to request to join',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isOpen,
                      onChanged: (value) => setState(() => _isOpen = value),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              AuthButton(text: 'Create Team', onPressed: _createTeam),
              const SizedBox(height: 16),

              // Info Text
              Text(
                'By creating a team, you become the captain and can manage team settings, accept/decline members, and organize matches.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createTeam() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Implement team creation logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          'Team Created!',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text(
              'Congratulations! "${_teamNameController.text}" has been created successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to teams page
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }
}
