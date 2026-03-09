import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/listing_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_filter_chips.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<ListingsProvider>().refreshListings();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1A237E);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: primaryColor,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Directory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, Color(0xFF283593)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 70),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Find services in Kigali',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    SearchBarWidget(
                      controller: _searchController,
                      hintText: 'Search by name or address...',
                      onChanged: (value) {
                        context.read<ListingsProvider>().setSearchQuery(value);
                      },
                      onClear: () {
                        context.read<ListingsProvider>().setSearchQuery('');
                      },
                    ),
                    const SizedBox(height: 16),
                    Consumer<ListingsProvider>(
                      builder: (context, provider, child) {
                        return CategoryFilterChips(
                          selectedCategory: provider.selectedCategory,
                          onChanged: (category) {
                            provider.setCategory(category);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Consumer<ListingsProvider>(
              builder: (context, provider, child) {
                final listings = provider.filteredListings;

                if (provider.state == ListingsState.loading) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }

                if (provider.state == ListingsState.error) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text('Error: ${provider.errorMessage ?? 'Something went wrong'}'),
                    ),
                  );
                }

                if (listings.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        provider.searchQuery.isNotEmpty || provider.selectedCategory != null
                            ? 'No Results Found'
                            : 'No Listings Yet',
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final listing = listings[index];
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListingCard(
                            listing: listing,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ListingDetailScreen(listingId: listing.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: listings.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}