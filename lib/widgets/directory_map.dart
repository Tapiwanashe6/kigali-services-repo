import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';

/// Reusable OpenStreetMap widget for directory listings.
class DirectoryMap extends StatefulWidget {
  final List<Listing>? listings;
  final LatLng? initialCenter;
  final double initialZoom;
  final Function(Listing)? onMarkerTap;
  final bool showPopup;

  const DirectoryMap({
    super.key,
    this.listings,
    this.initialCenter,
    this.initialZoom = 7.0,
    this.onMarkerTap,
    this.showPopup = true,
  });

  @override
  State<DirectoryMap> createState() => _DirectoryMapState();
}

class _DirectoryMapState extends State<DirectoryMap> {
  Listing? _selectedListing;
  final MapController _mapController = MapController();

  static const LatLng _defaultCenter = LatLng(-1.9403, 30.0606);

  // Check valid coordinates (not 0,0,)
  bool _hasValidCoordinates(Listing listing) {
    return (listing.latitude != 0.0 || listing.longitude != 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingsProvider>(
      builder: (context, provider, child) {
        final List<Listing> listings = widget.listings ?? provider.listings;

        if (provider.state == ListingsState.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.state == ListingsState.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const const SizedBox(height: 16),
                Text(
                  'Error loading map data',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage ?? 'Unknown error occurred',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.initializeListingsStream(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Handle empty listings
        if (listings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  color: Colors.grey[400],
                  size: 48,
                ),
                const const SizedBox(height: 16),
                Text(
                  'No listings available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some listings to see them on the map',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate center from listings or use provided/default center
        LatLng mapCenter = widget.initialCenter ?? _defaultCenter;
        
        // If we have valid listings, calculate the center point
        final validListings = listings.where((l) => _hasValidCoordinates(l)).toList();
        
        if (validListings.isNotEmpty) {
          double sumLat = 0;
          double sumLng = 0;
          for (var listing in validListings) {
            sumLat += listing.latitude;
            sumLng += listing.longitude;
          }
          mapCenter = LatLng(sumLat / validListings.length, sumLng / validListings.length);
        }

        return Stack(
          children: [
            // OpenStreetMap using flutter_map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: widget.initialZoom,
                minZoom: 3.0,
                maxZoom: 18.0,
                // Enable zoom controls and panning
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (tapPosition, point) {
                  // Clear selection when tapping on map
                  if (_selectedListing != null) {
                    setState(() {
                      _selectedListing = null;
                    });
                  }
                },
              ),
              children: [
                // OpenStreetMap tile layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.kigali_services_directory',
                ),
                
                // Markers layer
                MarkerLayer(
                  markers: _buildMarkers(listings),
                ),
              ],
            ),

            // Selected listing popup/card
            if (_selectedListing != null && widget.showPopup,)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildListingCard(_selectedListing!),
              ),

            // Legend
            Positioned(
              top: 16,
              right: 16,
              child: _buildLegend(),
            ),

            // Zoom controls
            Positioned(
              bottom: _selectedListing != null ? 180 : 16,
              right: 16,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_in',
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out',
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'center_map',
                    onPressed: () {
                      _mapController.move(mapCenter, widget.initialZoom);
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build markers for all listings
  List<Marker> _buildMarkers(List<Listing> listings) {
    return listings.map((listing) {
      // Validate coordinates - skip invalid ones
      if (!_hasValidCoordinates(listing)) {
        return Marker(
          point: const LatLng(0, 0),
          width: 40,
          height: 40,
          child: const Tooltip(
            message: 'Invalid coordinates',
            child: Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 30,
            ),
          ),
        );
      }

      return Marker(
        point: LatLng(listing.latitude, listing.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _onMarkerTap(listing),
          child: Icon(
            _getCategoryIcon(listing.category),
            color: _getCategoryColor(listing.category),
            size: 36,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Handle marker tap
  void _onMarkerTap(Listing listing) {
    // Validate coordinates before selecting
    if (!_hasValidCoordinates(listing)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This listing has invalid coordinates'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _selectedListing = listing;
    });
    
    // Move map to selected marker
    _mapController.move(
      LatLng(listing.latitude, listing.longitude),
      _mapController.camera.zoom,
    );
    
    // Callback for external handling
    if (widget.onMarkerTap != null) {
      widget.onMarkerTap!(listing);
    }
  }

  /// Build listing info card
  Widget _buildListingCard(Listing listing) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIcon(listing.category),
                  color: _getCategoryColor(listing.category),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(listing.category).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          listing.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getCategoryColor(listing.category),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedListing = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    listing.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            if (listing.contactNumber.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    listing.contactNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openExternalMaps(listing),
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openListingDetails(listing),
                    icon: const Icon(Icons.info),
                    label: const Text('Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getCategoryColor(listing.category),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build legend widget
  Widget _buildLegend() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Legend',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            _buildLegendItem(Icons.local_hospital, Colors.red, 'Hospital'),
            _buildLegendItem(Icons.local_police, Colors.blue, 'Police'),
            _buildLegendItem(Icons.local_library, Colors.orange, 'Library'),
            _buildLegendItem(Icons.restaurant, Colors.amber, 'Restaurant'),
            _buildLegendItem(Icons.local_cafe, Colors.brown, 'Café'),
            _buildLegendItem(Icons.park, Colors.green, 'Park'),
            _buildLegendItem(Icons.attractions, Colors.purple, 'Tourist'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  /// Get icon for category
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
        return Icons.attractions;
      default:
        return Icons.location_on;
    }
  }

  /// Get color for category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Hospital':
        return Colors.red;
      case 'Police':
        return Colors.blue;
      case 'Library':
        return Colors.orange;
      case 'Restaurant':
        return Colors.amber;
      case 'Café':
        return Colors.brown;
      case 'Park':
        return Colors.green;
      case 'Tourist Attraction':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// Open external maps app for navigation
  /// Uses Google Maps URL format that works on both iOS and Android
  Future<void> _openExternalMaps(Listing listing) async {
    // Validate coordinates
    if (!_hasValidCoordinates(listing)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid coordinates for navigation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final double lat = listing.latitude;
    final double lng = listing.longitude;
    final String label = Uri.encodeComponent(listing.name);
    
    // Use search URL that works on both platforms
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng&q=$label';
    Uri googleUrl = Uri.parse(googleMapsUrl);
    
    // Apple Maps URL as fallback for iOS
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
      
      // If all fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening maps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Navigate to listing details
  void _openListingDetails(Listing listing) {
    // Import and navigate to listing detail screen
    // This would typically use Navigator context
    debugPrint('Navigate to listing: ${listing.id}');
  }

  /// Calculate route between two points (placeholder for future implementation,)
  Future<List<LatLng>> calculateRoute(LatLng start, LatLng end) async {
    debugPrint('Calculate route from $start to $end');
    return [];
  }

  /// Get turn-by-turn directions (placeholder for future implementation,)
  Future<List<String>> getTurnByTurnDirections(
    LatLng start, 
    LatLng end,
  ) async {
    debugPrint('Get turn-by-turn directions from $start to $end');
    return [];
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

