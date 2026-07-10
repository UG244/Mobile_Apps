import 'package:flutter/material.dart';

class NotificationCategoryChip extends StatelessWidget {
  const NotificationCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFEAF3FE),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF1565C0) : Colors.black54,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? const Color(0xFF1565C0) : const Color(0xFFE0E7F1),
      ),
    );
  }
}
