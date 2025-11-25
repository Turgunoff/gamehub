import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Turnirlarni filtrlash dialog'i
/// Turli filter variantlarini ko'rsatadi
class TournamentFilterDialog extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onFilterSelected;

  const TournamentFilterDialog({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  State<TournamentFilterDialog> createState() =>
      _TournamentFilterDialogState();
}

class _TournamentFilterDialogState extends State<TournamentFilterDialog> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1F3A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FILTER TOURNAMENTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('All Tournaments', 'all'),
            _buildFilterOption('Free Entry', 'free'),
            _buildFilterOption('My Strength Range', 'strength'),
            _buildFilterOption('High Prize', 'prize'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onFilterSelected(_selectedFilter);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                  ),
                  child: const Text(
                    'APPLY',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Filter variantini ko'rsatuvchi widget
  Widget _buildFilterOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      value: value,
      groupValue: _selectedFilter,
      onChanged: (newValue) {
        setState(() => _selectedFilter = newValue!);
      },
      activeColor: const Color(0xFF00D9FF),
    );
  }
}

