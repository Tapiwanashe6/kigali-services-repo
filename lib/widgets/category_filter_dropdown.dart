import 'package:flutter/material.dart';
import '../models/listing.dart';

class CategoryFilterDropdown extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onChanged;
  final bool showAllOption;

  const CategoryFilterDropdown({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCategory,
          hint: const Text('All Categories'),
          isExpanded: true,
          icon: const Icon(Icons.filter_list),
          items: [
            if (showAllOption,)
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Categories'),
              ),
            ...ListingCategory.all.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 20,
                      color: _getCategoryColor(category),
                    ),
                    const SizedBox(width: 12),
                    Text(category),
                  ],
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hospital':
        return Icons.local_hospital;
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
}

