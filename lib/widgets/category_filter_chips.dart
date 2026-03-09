import 'package:flutter/material.dart';
import '../models/listing.dart';

/// A horizontal scrollable filter chips widget for categories.
/// This replaces the dropdown filter with a more modern UI.
class CategoryFilterChips extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onChanged;
  final bool showAllOption;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    this.showAllOption = true,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return Icons.local_hospital;
      case 'Pharmacy':
        return Icons.local_pharmacy;
      case 'Police':
        return Icons.local_police;
      case 'Library':
        return Icons.local_library;
      case 'Restaurant':
        return Icons.restaurant;
      case 'Café':
        return Icons.local_cafe;
      case 'Park':
        return Icons.park;
      case 'Tourist Attraction':
        return Icons.tour;
      default:
        return Icons.place;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Hospital':
        return Colors.red;
      case 'Pharmacy':
        return Colors.teal;
      case 'Police':
        return Colors.blue;
      case 'Library':
        return Colors.brown;
      case 'Restaurant':
        return Colors.orange;
      case 'Café':
        return Colors.amber;
      case 'Park':
        return Colors.green;
      case 'Tourist Attraction':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "All" chip
          if (showAllOption,)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All'),
                selected: selectedCategory == null,
                onSelected: (selected) {
                  if (selected) {
                    onChanged(null);
                  }
                },
                selectedColor: const Color(0xFFFFD700).withValues(alpha: 0.3),
                checkmarkColor: const Color(0xFF1A237E),
                labelStyle: TextStyle(
                  color: selectedCategory == null
                      ? const Color(0xFF1A237E,)
                      : Colors.grey[700],
                  fontWeight: selectedCategory == null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                avatar: selectedCategory == null
                    ? const Icon(Icons.check, size: 18, color: Color(0xFF1A237E),)
                    : null,
              ),
            ),
          // Category chips
          ...ListingCategory.all.map((category) {
            final isSelected = selectedCategory == category;
            final color = _getCategoryColor(category);
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  onChanged(selected ? category : null);
                },
                selectedColor: color.withValues(alpha: 0.2),
                checkmarkColor: color,
                labelStyle: TextStyle(
                  color: isSelected ? color : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                avatar: Icon(
                  _getCategoryIcon(category),
                  size: 18,
                  color: isSelected ? color : Colors.grey[600],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

