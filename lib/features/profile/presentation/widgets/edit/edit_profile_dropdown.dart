import 'package:flutter/material.dart';

/// Profil tahrirlash uchun Dropdown
///
/// Izchil ko'rinish bilan dropdown yaratadi.
class EditProfileDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final IconData icon;
  final String? hint;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const EditProfileDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    this.hint,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1F3A),
                hint: Row(
                  children: [
                    Icon(
                      icon,
                      color: const Color(0xFF6C5CE7),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      hint ?? 'Tanlang',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                items: items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: const Color(0xFF6C5CE7),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          itemLabel(item),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
