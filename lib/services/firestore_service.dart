import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/listing.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Get reference to listings collection
  CollectionReference get _listingsCollection => _firestore.collection('listings');

  // Create a new listing
  Future<Listing> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
    required String createdBy,
  }) async {
    try {
      final String id = _uuid.v4();
      final Listing listing = Listing(
        id: id,
        name: name,
        category: category,
        address: address,
        contactNumber: contactNumber,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: createdBy,
        timestamp: DateTime.now(),
      );

      await _listingsCollection.doc(id).set(listing.toMap());
      return listing;
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  // Get all listings (real-time stream)
  Stream<List<Listing>> getAllListings() {
    return _listingsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get listings by user (real-time stream)
  Stream<List<Listing>> getListingsByUser(String userId) {
    return _listingsCollection
        .where('createdBy', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get single listing by ID
  Future<Listing?> getListingById(String id) async {
    try {
      final DocumentSnapshot doc = await _listingsCollection.doc(id).get();
      if (doc.exists) {
        return Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get listing: $e');
    }
  }

  // Update a listing
  Future<Listing> updateListing({
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
      final Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (category != null) updateData['category'] = category;
      if (address != null) updateData['address'] = address;
      if (contactNumber != null) updateData['contactNumber'] = contactNumber;
      if (description != null) updateData['description'] = description;
      if (latitude != null) updateData['latitude'] = latitude;
      if (longitude != null) updateData['longitude'] = longitude;

      await _listingsCollection.doc(id).update(updateData);

      // Get updated listing
      final updatedDoc = await _listingsCollection.doc(id).get();
      return Listing.fromMap(id, updatedDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  // Delete a listing
  Future<void> deleteListing(String id) async {
    try {
      await _listingsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete listing: $e');
    }
  }

  // Rate a listing - calculates new average rating
  Future<void> rateListing({
    required String listingId,
    required double newRating,
  }) async {
    try {
      // Get current listing data
      final doc = await _listingsCollection.doc(listingId).get();
      if (!doc.exists) {
        throw Exception('Listing not found');
      }

      final currentData = doc.data() as Map<String, dynamic>;
      final currentAverage = (currentData['AverageRating'] ?? 0.0).toDouble();
      final currentCount = (currentData['NumRatings'] ?? 0) as int;

      // Calculate new average
      final newCount = currentCount + 1;
      final newAverage = ((currentAverage * currentCount) + newRating) / newCount;

      // Update Firestore
      await _listingsCollection.doc(listingId).update({
        'AverageRating': newAverage,
        'NumRatings': newCount,
      });
    } catch (e) {
      throw Exception('Failed to rate listing: $e');
    }
  }

  // Search listings by name
  Future<List<Listing>> searchListingsByName(String query) async {
    try {
      final QuerySnapshot snapshot = await _listingsCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        return Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }

  // Get listings by category
  Stream<List<Listing>> getListingsByCategory(String category) {
    return _listingsCollection
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get all listings (one-time fetch)
  Future<List<Listing>> getAllListingsOnce() async {
    try {
      final QuerySnapshot snapshot = await _listingsCollection
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get listings: $e');
    }
  }
}

