// lib/widgets/category_chip_row.dart
//
// Horizontal scrolling row of category filter chips.
// The active chip is highlighted in primary green.
// Tapping an already-active chip clears the filter.

import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../utils/app_theme.dart';

class CategoryChipRow extends StatelessWidget {
  final ListingCategory? selected;
  final ValueChanged<ListingCategory?> onChanged;

  const CategoryChipRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(null,  'All',             Icons.grid_view_rounded),
          ...ListingCategory.values.map((cat) =>
            _chip(cat, cat.label, _icon(cat)),
          ),
        ],
      ),
    );
  }

  Widget _chip(ListingCategory? cat, String label, IconData icon) {
    final isActive = selected == cat;
    return GestureDetector(
      onTap: () => onChanged(isActive && cat != null ? null : cat),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
          boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                )),
          ],
        ),
      ),
    );
  }

  IconData _icon(ListingCategory c) {
    switch (c) {
      case ListingCategory.cafe:              return Icons.coffee_outlined;
      case ListingCategory.hospital:          return Icons.local_hospital_outlined;
      case ListingCategory.pharmacy:          return Icons.medication_outlined;
      case ListingCategory.policeStation:     return Icons.local_police_outlined;
      case ListingCategory.park:              return Icons.park_outlined;
      case ListingCategory.library:           return Icons.local_library_outlined;
      case ListingCategory.restaurant:        return Icons.restaurant_outlined;
      case ListingCategory.touristAttraction: return Icons.camera_alt_outlined;
      case ListingCategory.other:             return Icons.place_outlined;
    }
  }
}
