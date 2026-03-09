class Listing {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;
  final double averageRating; // Average rating (0-5,)
  final int numRatings; // Number of ratings

  Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
    this.averageRating = 0.0, // Default rating
    this.numRatings = 0, // Default rating count
  });

  // Create Listing from Firestore document
  factory Listing.fromMap(String id, Map<String, dynamic> data) {
    return Listing(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'].millisecondsSinceEpoch,)
          : DateTime.now(),
      averageRating: (data['AverageRating'] ?? 0.0).toDouble(),
      numRatings: data['NumRatings'] ?? 0,
    );
  }

  // Convert Listing to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': timestamp,
      'AverageRating': averageRating,
      'NumRatings': numRatings,
    };
  }

  // Create a copy with modified fields
  Listing copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? timestamp,
    double? averageRating,
    int? numRatings,
  }) {
    return Listing(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
      averageRating: averageRating ?? this.averageRating,
      numRatings: numRatings ?? this.numRatings,
    );
  }
}

// Categories for listings
class ListingCategory {
  static const String hospital = 'Hospital';
  static const String pharmacy = 'Pharmacy';
  static const String police = 'Police';
  static const String library = 'Library';
  static const String restaurant = 'Restaurant';
  static const String cafe = 'Café';
  static const String park = 'Park';
  static const String touristAttraction = 'Tourist Attraction';

  static List<String> get all => [
    hospital,
    pharmacy,
    police,
    library,
    restaurant,
    cafe,
    park,
    touristAttraction,
  ];
}

