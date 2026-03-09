import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../services/firestore_service.dart';

enum ListingsState {
  initial,
  loading,
  loaded,
  error,
}

class ListingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  ListingsState _state = ListingsState.initial;
  bool _myListingsLoading = false;
  List<Listing> _listings = [];
  List<Listing> _myListings = [];
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategory;
  StreamSubscription<List<Listing>>? _listingsSubscription;
  StreamSubscription<List<Listing>>? _myListingsSubscription;
  
  // Track if streams are already initialized
  bool _listingsStreamInitialized = false;
  bool _myListingsStreamInitialized = false;
  String? _currentUserIdForMyListings;

  // Getters
  ListingsState get state => _state;
  bool get myListingsLoading => _myListingsLoading;
  List<Listing> get listings => _listings;
  List<Listing> get myListings => _myListings;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isLoading => _state == ListingsState.loading;

  // Get filtered listings
  List<Listing> get filteredListings {
    List<Listing> result = _listings;

    // Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      result = result.where((l) => l.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      result = result.where((l) =>
        l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        l.address.toLowerCase().contains(_searchQuery.toLowerCase(),)
      ).toList();
    }

    return result;
  }

  // Initialize listings stream
  void initializeListingsStream() {
    // Only initialize if not already done
    if (_listingsStreamInitialized) {
      return;
    }
    
    _listingsStreamInitialized = true;
    _listingsSubscription?.cancel();
    _listingsSubscription = _firestoreService.getAllListings().listen(
      (List<Listing> listings) {
        _listings = listings;
        _state = ListingsState.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _state = ListingsState.error;
        notifyListeners();
      },
    );
  }

  // Initialize user listings stream
  void initializeMyListingsStream(String userId, {bool forceRefresh = false}) {
    // Only initialize if not already done for this user (unless force refresh,)
    if (_myListingsStreamInitialized && _currentUserIdForMyListings == userId && !forceRefresh) {
      return;
    }
    
    _myListingsLoading = true;
    _currentUserIdForMyListings = userId;
    _myListingsStreamInitialized = true;
    notifyListeners();
    
    _myListingsSubscription?.cancel();
    _myListingsSubscription = _firestoreService.getListingsByUser(userId).listen(
      (List<Listing> listings) {
        _myListings = listings;
        _myListingsLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _myListingsLoading = false;
        notifyListeners();
      },
    );
  }

  // Force refresh user's listings
  void refreshMyListings() {
    final userId = _currentUserIdForMyListings;
    if (userId != null) {
      _myListingsStreamInitialized = false;
      initializeMyListingsStream(userId, forceRefresh: true);
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set category filter
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // Create a new listing
  Future<bool> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
    required String createdBy,
  }) async {
    _state = ListingsState.loading;
    notifyListeners();

    try {
      await _firestoreService.createListing(
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: createdBy,
      );
      _state = ListingsState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ListingsState.error;
      notifyListeners();
      return false;
    }
  }

  // Update a listing
  Future<bool> updateListing({
    required String id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await _firestoreService.updateListing(
        id: id,
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
      );
      // Manually update local list for immediate UI update
      final index = _myListings.indexWhere((listing) => listing.id == id);
      if (index != -1) {
        _myListings[index] = _myListings[index].copyWith(
          name: name,
          category: category,
          address: address,
          contactNumber: contactNumber,
          description: description,
          latitude: latitude,
          longitude: longitude,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete a listing
  Future<bool> deleteListing(String id) async {
    try {
      await _firestoreService.deleteListing(id);
      // Manually remove from local list for immediate UI update
      _myListings.removeWhere((listing) => listing.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Rate a listing
  Future<bool> rateListing({
    required String listingId,
    required double rating,
  }) async {
    try {
      await _firestoreService.rateListing(
        listingId: listingId,
        newRating: rating,
      );
      
      // Get updated listing and update local state
      final updatedListing = await _firestoreService.getListingById(listingId);
      if (updatedListing != null) {
        // Update in myListings
        final myIndex = _myListings.indexWhere((l) => l.id == listingId);
        if (myIndex != -1) {
          _myListings[myIndex] = updatedListing;
        }
        // Update in all listings
        final index = _listings.indexWhere((l) => l.id == listingId);
        if (index != -1) {
          _listings[index] = updatedListing;
        }
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get listing by ID - checks local cache first
  Future<Listing?> getListingById(String id) async {
    // First, check local cache (_listings,)
    final cachedListing = _listings.where((l) => l.id == id).firstOrNull;
    if (cachedListing != null) {
      return cachedListing;
    }
    
    // Second, check local cache (_myListings,)
    final cachedMyListing = _myListings.where((l) => l.id == id).firstOrNull;
    if (cachedMyListing != null) {
      return cachedMyListing;
    }
    
    // If not in cache, fetch from Firestore
    try {
      return await _firestoreService.getListingById(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh listings
  Future<void> refreshListings() async {
    initializeListingsStream();
  }

  // Dispose subscriptions
  @override
  void dispose() {
    _listingsSubscription?.cancel();
    _myListingsSubscription?.cancel();
    super.dispose();
  }
}

