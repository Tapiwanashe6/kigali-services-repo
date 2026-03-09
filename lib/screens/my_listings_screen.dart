import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'add_edit_listing_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> with WidgetsBindingObserver {
  // App Theme Colors
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color accentColor = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadListings();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh listings when app is resumed
      _refreshListings();
    }
  }

  void _loadListings() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user != null) {
      context.read<ListingsProvider>().initializeMyListingsStream(user.uid);
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          final authProvider = context.read<AuthProvider>();
          final user = authProvider.user;
          if (user != null) {
            context.read<ListingsProvider>().initializeMyListingsStream(user.uid);
          }
        }
      });
    }
  }

  void _refreshListings() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user != null) {
      // Force refresh to get latest listings
      context.read<ListingsProvider>().initializeMyListingsStream(user.uid, forceRefresh: true);
    }
  }

  void _showDeleteDialog(Listing listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Delete Listing'),
          ],
        ),
        content: Text('Are you sure you want to delete "${listing.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final listingsProvider = context.read<ListingsProvider>();
              Navigator.pop(context);
              final success = await listingsProvider.deleteListing(listing.id);
              if (success) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        const Text('Listing deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAddListing() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddEditListingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true) {
      _loadListings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: primaryColor,
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'My Listings',
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
            ),

            // Content
            Consumer2<AuthProvider, ListingsProvider>(
              builder: (context, authProvider, listingsProvider, child) {
                if (listingsProvider.myListingsLoading) {
                  return const SliverFillRemaining(
                    child: _LoadingState(),
                  );
                }

                final myListings = listingsProvider.myListings;

                if (myListings.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(onAddPressed: _navigateToAddListing),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listing = myListings[index];
                        return ListingCard(
                          listing: listing,
                          showActions: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    ListingDetailScreen(listingId: listing.id),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 250),
                              ),
                            );
                          },
                          onEdit: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditListingScreen(listing: listing),
                              ),
                            );
                            if (result == true) {
                              _loadListings();
                            }
                          },
                          onDelete: () => _showDeleteDialog(listing),
                        );
                      },
                      childCount: myListings.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddListing,
        backgroundColor: accentColor,
        foregroundColor: primaryColor,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Future<void> _onRefresh() async {
    _refreshListings();
    // Wait a bit to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// Loading State Widget
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading your listings...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Empty State Widget
class _EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyState({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_business_outlined,
                size: 60,
                color: const Color(0xFF1A237E).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Listings Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start adding your business or service to the Kigali directory',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Your First Listing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
