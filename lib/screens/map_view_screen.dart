import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/directory_map.dart';

/// Map View Screen - Modern OpenStreetMap Integration
class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> with SingleTickerProviderStateMixin {
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
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().initializeListingsStream();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Map View',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, Color(0xFF283593)],
                  ),
                ),
              ),
            ),
            actions: [
              // Filter info badge
              Consumer<ListingsProvider>(
                builder: (context, provider, child) {
                  final count = provider.filteredListings.isNotEmpty 
                      ? provider.filteredListings.length 
                      : provider.listings.length;
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.place, size: 16, color: accentColor),
                        const SizedBox(width: 4),
                        Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Map Content
          SliverFillRemaining(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Consumer<ListingsProvider>(
                builder: (context, provider, child) {
                  final listings = provider.filteredListings.isNotEmpty 
                      ? provider.filteredListings 
                      : provider.listings;
                  
                  if (provider.state == ListingsState.loading && listings.isEmpty) {
                    return _LoadingState();
                  }
                  
                  if (listings.isEmpty) {
                    return _EmptyMapState();
                  }
                  
                  return DirectoryMap(
                    listings: listings,
                    showPopup: true,
                    initialZoom: 7.0,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Loading State
class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Loading map...',
            style: TextStyle(
              color: Color(0xFF6B7A8A),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// Empty Map State
class _EmptyMapState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map_outlined,
                size: 50,
                color: const Color(0xFF1A237E).withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Locations to Show',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add some listings to see them on the map',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7A8A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
