import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';

/// Listing Detail Screen - Modern & Sleek Design
class ListingDetailScreen extends StatefulWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> with SingleTickerProviderStateMixin {
  Listing? _listing;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // App Theme Colors
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadListing();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadListing() async {
    final provider = context.read<ListingsProvider>();
    final listing = await provider.getListingById(widget.listingId);
    if (mounted) {
      setState(() {
        _listing = listing;
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  bool _hasValidCoordinates() {
    if (_listing == null) return false;
    return _listing!.latitude != 0.0 || _listing!.longitude != 0.0;
  }

  LatLng? _getListingLocation() {
    if (_listing == null || !_hasValidCoordinates()) return null;
    return LatLng(_listing!.latitude, _listing!.longitude);
  }

  Future<void> _openNavigation() async {
    if (_listing == null) return;
    
    if (!_hasValidCoordinates()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.location_off, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Invalid coordinates for navigation'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }
    
    final double lat = _listing!.latitude;
    final double lng = _listing!.longitude;
    final String label = Uri.encodeComponent(_listing!.name);
    
    // Try Google Maps first
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$label';
    Uri googleUrl = Uri.parse(googleMapsUrl);
    
    // Alternative: Use universal URL that works on both platforms
    String appleMapsUrl = 'https://maps.apple.com/?daddr=$lat,$lng&q=$label';
    Uri appleUrl = Uri.parse(appleMapsUrl);
    
    try {
      // Try Google Maps first
      if (await canLaunchUrl(googleUrl)) {
        final result = await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
        if (result) return;
      }
      
      // Fallback to Apple Maps on iOS
      if (await canLaunchUrl(appleUrl)) {
        await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
        return;
      }
      
      // If all fails, show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.map_outlined, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text('Could not open maps application'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showRatingDialog() {
    double userRating = _listing?.averageRating ?? 0;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.star_rounded, color: accentColor, size: 24),
            ),
            const SizedBox(width: 14),
            const Text('Rate this Service'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How would you rate this service?',
              style: TextStyle(color: Color(0xFF6C757D)),
            ),
            const SizedBox(height: 24),
            StatefulBuilder(
              builder: (context, setDialogState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          userRating = (index + 1).toDouble();
                        });
                      },
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < userRating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFFFFB300),
                          size: 42,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setDialogState) {
                return Text(
                  '${userRating.toInt()} / 5 stars',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text('Submitting your rating...'),
                    ],
                  ),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 1),
                ),
              );
              
              final listingsProvider = context.read<ListingsProvider>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success = await listingsProvider.rateListing(
                listingId: widget.listingId,
                rating: userRating,
              );
              
              if (success && mounted) {
                await _loadListing();
                
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        const Text('Thank you for your rating!'),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              } else if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(listingsProvider.errorMessage ?? 'Failed to submit rating'),
                      ],
                    ),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Loading details...',
                style: TextStyle(color: Color(0xFF6B7A8A), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_listing == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, size: 40, color: Color(0xFF6B7A8A)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Listing not found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E2A3A)),
              ),
            ],
          ),
        ),
      );
    }

    final categoryColor = _getCategoryColor(_listing!.category);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Hero Header with Image Placeholder and Map
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: categoryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _listing!.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          categoryColor.withValues(alpha: 0.8),
                          categoryColor,
                        ],
                      ),
                    ),
                  ),
                  
                  // Center Icon
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'listing_icon_${_listing!.id}',
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              _getCategoryIcon(_listing!.category),
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _listing!.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                  
                  // Map Preview or Location Status
                  if (_hasValidCoordinates(),)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 130,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: _getListingLocation()!,
                              initialZoom: 14,
                              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.kigali_services_directory',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _getListingLocation()!,
                                    width: 44,
                                    height: 44,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: categoryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: categoryColor.withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(_listing!.category),
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ,)
                  else
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_off, color: Colors.grey.shade400, size: 32),
                              const SizedBox(height: 4),
                              Text(
                                'Location not available',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Details Section
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating & Info Cards
                    Row(
                      children: [
                        // Rating Badge
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.star_rounded,
                            iconColor: const Color(0xFFFFB300),
                            label: 'Rating',
                            value: _listing!.numRatings > 0
                                ? '${_listing!.averageRating.toStringAsFixed(1)} (${_listing!.numRatings})'
                                : 'Not rated',
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Status Badge
                        Expanded(
                          child: _InfoCard(
                            icon: _listing!.numRatings > 0 ? Icons.verified : Icons.fiber_new,
                            iconColor: _listing!.numRatings > 0 ? Colors.green : Colors.blue,
                            label: 'Status',
                            value: _listing!.numRatings > 0 ? 'Active' : 'New',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Section Title
                    const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const const SizedBox(height: 16),
                    
                    // Address
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: _listing!.address,
                    ),
                    const const SizedBox(height: 16),
                    
                    // Contact
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Contact',
                      value: _listing!.contactNumber,
                      action: _listing!.contactNumber.isNotEmpty
                          ? () {
                              final uri = Uri(scheme: 'tel', path: _listing!.contactNumber);
                              launchUrl(uri);
                            }
                          : null,
                    ),
                    const const SizedBox(height: 16),
                    
                    // Description
                    _DetailRow(
                      icon: Icons.description_outlined,
                      label: 'Description',
                      value: _listing!.description,
                    ),
                    const const SizedBox(height: 16),
                    
                    // Coordinates
                    if (_hasValidCoordinates()) ...[
                      _DetailRow(
                        icon: Icons.my_location_outlined,
                        label: 'Coordinates',
                        value: '${_listing!.latitude.toStringAsFixed(6)}, ${_listing!.longitude.toStringAsFixed(6)}',
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Action Buttons
                    Row(
                      children: [
                        // Rate Button
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: accentColor, width: 1.5),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: _showRatingDialog,
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star_border_rounded, color: primaryColor, size: 22),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rate',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Navigate Button
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _hasValidCoordinates() ? _openNavigation : null,
                              icon: Icon(
                                _hasValidCoordinates() ? Icons.navigation_rounded : Icons.not_listed_location,
                                size: 22,
                              ),
                              label: const Text(
                                'Get Directions',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                disabledBackgroundColor: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Info Card Widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7A8A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E2A3A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Row Widget
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? action;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1A237E), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7A8A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasValue ? value : 'Not available',
                  style: TextStyle(
                    fontSize: 15,
                    color: hasValue ? const Color(0xFF1E2A3A) : const Color(0xFF6B7A8A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (action != null && hasValue,)
            IconButton(
              onPressed: action,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF6B7A8A)),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
