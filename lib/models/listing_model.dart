// lib/models/listing_model.dart
//
// PURPOSE: Dart representation of one Firestore document in `listings`.
// Every place in the directory (café, hospital, park…) is a ListingModel.
// The enum keeps category values type-safe; no raw strings in business logic.

import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────
// CATEGORY ENUM
// Using enum prevents typos like 'cofee' vs 'cafe' in Firestore.
// .value  → the string stored in Firestore
// .label  → the human-readable string shown in the UI
// ─────────────────────────────────────────────────────────────────
enum ListingCategory {
  cafe,
  hospital,
  pharmacy,
  policeStation,
  park,
  library,
  restaurant,
  touristAttraction,
  other;

  String get value {
    switch (this) {
      case ListingCategory.cafe:               return 'cafe';
      case ListingCategory.hospital:           return 'hospital';
      case ListingCategory.pharmacy:           return 'pharmacy';
      case ListingCategory.policeStation:      return 'police_station';
      case ListingCategory.park:               return 'park';
      case ListingCategory.library:            return 'library';
      case ListingCategory.restaurant:         return 'restaurant';
      case ListingCategory.touristAttraction:  return 'tourist_attraction';
      case ListingCategory.other:              return 'other';
    }
  }

  String get label {
    switch (this) {
      case ListingCategory.cafe:               return 'Café';
      case ListingCategory.hospital:           return 'Hospital';
      case ListingCategory.pharmacy:           return 'Pharmacy';
      case ListingCategory.policeStation:      return 'Police Station';
      case ListingCategory.park:               return 'Park';
      case ListingCategory.library:            return 'Library';
      case ListingCategory.restaurant:         return 'Restaurant';
      case ListingCategory.touristAttraction:  return 'Tourist Attraction';
      case ListingCategory.other:              return 'Other';
    }
  }

  // Parse a Firestore string back to enum. Falls back to `other`.
  static ListingCategory fromValue(String? value) {
    return ListingCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ListingCategory.other,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// LISTING MODEL
// ─────────────────────────────────────────────────────────────────
class ListingModel {
  final String          id;            // Firestore document ID
  final String          placeName;
  final ListingCategory category;
  final String          address;
  final String          contactNumber;
  final String          description;
  final double          latitude;
  final double          longitude;
  final String          createdBy;     // uid of creator
  final DateTime        timestamp;
  final double          averageRating; // denormalised — updated by transaction
  final int             reviewCount;   // denormalised

  const ListingModel({
    required this.id,
    required this.placeName,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
    this.averageRating = 0.0,
    this.reviewCount   = 0,
  });

  // ── Firestore DocumentSnapshot → Dart ─────────────────────────
  factory ListingModel.fromDocument(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id:            doc.id,
      placeName:     (d['placeName']     as String?)  ?? '',
      category:      ListingCategory.fromValue(d['category'] as String?),
      address:       (d['address']       as String?)  ?? '',
      contactNumber: (d['contactNumber'] as String?)  ?? '',
      description:   (d['description']  as String?)  ?? '',
      latitude:      (d['latitude']  as num?)?.toDouble()  ?? -1.9441,
      longitude:     (d['longitude'] as num?)?.toDouble()  ?? 30.0619,
      createdBy:     (d['createdBy']     as String?)  ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      averageRating: (d['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount:   (d['reviewCount']   as int?)    ?? 0,
    );
  }

  // ── Dart → Firestore ───────────────────────────────────────────
  // Note: `id` is the Firestore doc ID, not stored inside the document
  Map<String, dynamic> toMap() => {
    'placeName':     placeName,
    'category':      category.value,
    'address':       address,
    'contactNumber': contactNumber,
    'description':   description,
    'latitude':      latitude,
    'longitude':     longitude,
    'createdBy':     createdBy,
    'timestamp':     Timestamp.fromDate(timestamp),
    'averageRating': averageRating,
    'reviewCount':   reviewCount,
  };

  // ── Immutable update ───────────────────────────────────────────
  ListingModel copyWith({
    String? id, String? placeName, ListingCategory? category,
    String? address, String? contactNumber, String? description,
    double? latitude, double? longitude, String? createdBy,
    DateTime? timestamp, double? averageRating, int? reviewCount,
  }) => ListingModel(
    id:            id            ?? this.id,
    placeName:     placeName     ?? this.placeName,
    category:      category      ?? this.category,
    address:       address       ?? this.address,
    contactNumber: contactNumber ?? this.contactNumber,
    description:   description   ?? this.description,
    latitude:      latitude      ?? this.latitude,
    longitude:     longitude     ?? this.longitude,
    createdBy:     createdBy     ?? this.createdBy,
    timestamp:     timestamp     ?? this.timestamp,
    averageRating: averageRating ?? this.averageRating,
    reviewCount:   reviewCount   ?? this.reviewCount,
  );

  @override
  String toString() => 'ListingModel(id: $id, placeName: $placeName, category: ${category.label})';
}

// ─────────────────────────────────────────────────────────────────
// REVIEW MODEL
// Stored in: listings/{listingId}/reviews/{reviewId}
// ─────────────────────────────────────────────────────────────────
class ReviewModel {
  final String   id;
  final String   userId;
  final String   userEmail;
  final double   rating;
  final String   comment;
  final DateTime timestamp;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory ReviewModel.fromDocument(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id:        doc.id,
      userId:    (d['userId']    as String?) ?? '',
      userEmail: (d['userEmail'] as String?) ?? '',
      rating:    (d['rating'] as num?)?.toDouble() ?? 0.0,
      comment:   (d['comment']   as String?) ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId':    userId,
    'userEmail': userEmail,
    'rating':    rating,
    'comment':   comment,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}
