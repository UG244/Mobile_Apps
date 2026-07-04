import 'package:flutter/material.dart';

import '../models/category_model.dart';

/// Bar kategori horizontal dengan chip yang dapat dipilih.
/// Chip pertama adalah "Semua" (nilai null).
class CategoryChipBar extends StatelessWidget {
  const CategoryChipBar({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Chip "Semua"
          _CategoryChip(
            label: 'Semua',
            icon: Icons.grid_view_rounded,
            color: const Color(0xFF1565C0),
            isSelected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          // Chip per-kategori
          ...categories.asMap().entries.map((entry) {
            final cat = entry.value;
            final isSelected = selectedId == cat.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _CategoryChip(
                label: cat.name,
                icon: _iconFromName(cat.iconName),
                color: Color(cat.color),
                isSelected: isSelected,
                onTap: () => onSelected(cat.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  static IconData _iconFromName(String name) {
    const iconMap = <String, IconData>{
      'laptop_mac': Icons.laptop_mac_rounded,
      'smartphone': Icons.smartphone_rounded,
      'headphones': Icons.headphones_rounded,
      'sports_esports': Icons.sports_esports_rounded,
      'cable': Icons.cable_rounded,
      'storage': Icons.storage_rounded,
    };
    return iconMap[name] ?? Icons.category_rounded;
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF424242),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
