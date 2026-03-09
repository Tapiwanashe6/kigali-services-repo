import 'package:flutter/material.dart';
import '../models/listing.dart';
import 'dart:math' as math;

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final double? userLatitude;
  final double? userLongitude;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
    this.userLatitude,
    this.userLongitude,
  });

  // App Theme Colors
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFFFFD700);

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
        return const Color(0xFFE53935);
      case 'Pharmacy':
        return const Color(0xFF00897B);
      case 'Police':
        return const Color(0xFF1E88E5);
      case 'Library':
        return const Color(0xFF6D4C41);
      case 'Restaurant':
        return const Color(0xFFFB8C00);
      case 'Café':
        return const Color(0xFFFFB300);
      case 'Park':
        return const Color(0xFF43A047);
      case 'Tourist Attraction':
        return const Color(0xFF8E24AA);
      default:
        return const Color(0xFF757575);
    }
  }

  double? _calculateDistance() {
    if (userLatitude == null || userLongitude == null) return null;
    if (listing.latitude == 0 && listing.longitude == 0) return null;

    const double earthRadius = 6371;
    final double lat1Rad = userLatitude! * math.pi / 180;
    final double lat2Rad = listing.latitude * math.pi / 180;
    final double deltaLat = (listing.latitude - userLatitude!) * math.pi / 180;
    final double deltaLng = (listing.longitude - userLongitude!) * math.pi / 180;

    final double a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLng / 2) * math.sin(deltaLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(listing.category);
    final distance = _calculateDistance();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: categoryColor.withValues(alpha: 0.1),
            highlightColor: categoryColor.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category Icon Container
                  Hero(
                    tag: 'listing_icon_${listing.id}',
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(listing.category),
                        color: categoryColor,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Listing Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          listing.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E2A3A),
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),

                        // Category & Rating Row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                listing.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Rating display (only show for listings with ratings,)
                            if (listing.numRatings > 0,)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Color(0xFFFFB300),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      listing.averageRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E2A3A),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '(${listing.numRatings})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7A8A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Address Row with distance
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: Color(0xFF6B7A8A),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                listing.address,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7A8A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (distance != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  distance < 1
                                      ? '${(distance * 1000).toInt()}m'
                                      : '${distance.toStringAsFixed(1)}km',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E2A3A),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action buttons or chevron
                  const SizedBox(width: 8),
                  if (showActions,)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null) ...[
                          _ActionButton(
                            icon: Icons.edit_outlined,
                            color: primaryColor,
                            onTap: onEdit!,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (onDelete != null,)
                          _ActionButton(
                            icon: Icons.delete_outline,
                            color: const Color(0xFFE53935),
                            onTap: onDelete!,
                          ),
                      ],
                    ,)
                  else
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }
}
