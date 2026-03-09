// lib/services/listing_service.dart
//
// PURPOSE: All Firestore CRUD for listings and reviews.
// UI widgets NEVER import cloud_firestore — they use this service.
//
// Key design decisions:
// • Streams → real-time updates (UI rebuilds automatically via Riverpod)
// • Transactions → atomic rating updates (averageRating always correct)
// • Batched deletes → remove subcollection before parent document

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _db;

  ListingService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Collection refs ─────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _listings =>
      _db.collection('listings');

  CollectionReference<Map<String, dynamic>> _reviews(String listingId) =>
      _db.collection('listings').doc(listingId).collection('reviews');

  // ══════════════════════════════════════════════════════════════
  //  STREAMS (real-time)
  // ══════════════════════════════════════════════════════════════

  /// All listings ordered by newest first.
  /// Riverpod StreamProvider listens here; UI rebuilds on every Firestore change.
  Stream<List<ListingModel>> allListings() {
    return _listings
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ListingModel.fromDocument).toList());
  }

  /// Listings filtered to a single category.
  Stream<List<ListingModel>> listingsByCategory(ListingCategory category) {
    return _listings
        .where('category', isEqualTo: category.value)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(ListingModel.fromDocument).toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  /// Listings created by a specific user (for "My Listings" / edit screen).
  Stream<List<ListingModel>> myListings(String uid) {
    return _listings
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(ListingModel.fromDocument).toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  /// Reviews for one listing, newest first.
  Stream<List<ReviewModel>> reviews(String listingId) {
    return _reviews(listingId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromDocument).toList());
  }

  // ══════════════════════════════════════════════════════════════
  //  ONE-SHOT READS
  // ══════════════════════════════════════════════════════════════

  Future<ListingModel?> getListing(String id) async {
    final doc = await _listings.doc(id).get();
    if (!doc.exists) return null;
    return ListingModel.fromDocument(doc);
  }

  // ══════════════════════════════════════════════════════════════
  //  WRITE OPERATIONS
  // ══════════════════════════════════════════════════════════════

  /// Create listing. Firestore auto-generates the document ID.
  Future<String> createListing(ListingModel listing) async {
    final ref = await _listings.add(listing.toMap());
    return ref.id;
  }

  /// Update arbitrary fields on a listing.
  Future<void> updateListing(String id, Map<String, dynamic> data) =>
      _listings.doc(id).update(data);

  /// Delete listing + all its reviews atomically via a Firestore Batch.
  /// Firestore does NOT cascade-delete subcollections automatically.
  Future<void> deleteListing(String id) async {
    final reviewDocs = await _reviews(id).get();
    final batch = _db.batch();
    for (final doc in reviewDocs.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_listings.doc(id));
    await batch.commit();
  }

  // ══════════════════════════════════════════════════════════════
  //  REVIEWS
  // ══════════════════════════════════════════════════════════════

  /// Add a review and atomically update the listing's denormalised rating.
  /// A Firestore Transaction guarantees the average is always accurate,
  /// even if multiple users submit reviews simultaneously.
  Future<void> addReview({
    required String      listingId,
    required ReviewModel review,
  }) async {
    await _db.runTransaction((tx) async {
      final listingRef = _listings.doc(listingId);
      final snap       = await tx.get(listingRef);

      if (!snap.exists) throw Exception('Listing not found');

      final data         = snap.data()!;
      final oldCount     = (data['reviewCount']   as int?)    ?? 0;
      final oldAvg       = (data['averageRating'] as num?)?.toDouble() ?? 0.0;
      final newCount     = oldCount + 1;
      // Incremental average formula: avoidd re-fetching all reviews
      final newAvg       = ((oldAvg * oldCount) + review.rating) / newCount;

      // Write the review document
      final reviewRef = _reviews(listingId).doc();
      tx.set(reviewRef, review.toMap());

      // Update listing's denormalised rating
      tx.update(listingRef, {
        'reviewCount':   newCount,
        'averageRating': double.parse(newAvg.toStringAsFixed(1)),
      });
    });
  }

  // ══════════════════════════════════════════════════════════════
  //  SEED DATA
  //  Call once after first login to pre-populate the database
  //  with realistic Kigali listings.
  // ══════════════════════════════════════════════════════════════
  Future<void> seedIfEmpty(String creatorUid) async {
    final existing = await _listings.limit(1).get();
    if (existing.docs.isNotEmpty) return; // already seeded

    final now = DateTime.now();
    final seeds = <Map<String, dynamic>>[
      {
        'placeName':     'Inzozi Coffee House',
        'category':      'cafe',
        'address':       'KG 11 Ave, Kacyiru, Kigali',
        'contactNumber': '+250 788 100 201',
        'description':   'Tucked into a quiet corner of Kacyiru, Inzozi serves single-origin Rwandan beans sourced directly from Huye Mountain. The terrace overlooks bougainvillea-filled gardens — ideal for morning meetings or a slow afternoon read.',
        'latitude': -1.9392, 'longitude': 30.0918,
        'createdBy': creatorUid,
        'timestamp':     Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'averageRating': 4.8, 'reviewCount': 41,
      },
      {
        'placeName':     'Ikirezi Pharmacy Kimihurura',
        'category':      'pharmacy',
        'address':       'KG 5 Rd, Kimihurura, Kigali',
        'contactNumber': '+250 788 305 400',
        'description':   'A well-stocked community pharmacy in the heart of Kimihurura. Qualified pharmacists offer free consultations Mon–Sat 7 am–9 pm. Prescription and OTC medications always available.',
        'latitude': -1.9465, 'longitude': 30.0947,
        'createdBy': creatorUid,
        'timestamp':     Timestamp.fromDate(now.subtract(const Duration(days: 5))),
        'averageRating': 4.5, 'reviewCount': 27,
      },
      {
        'placeName':     'Kacyiru District Hospital',
        'category':      'hospital',
        'address':       'KG 17 Ave, Kacyiru, Kigali',
        'contactNumber': '+250 252 580 060',
        'description':   'A government-run district hospital serving Kacyiru and surrounding sectors. Offers 24-hour emergency care, maternal health, general medicine, and a fully equipped laboratory.',
        'latitude': -1.9400, 'longitude': 30.0890,
        'createdBy': creatorUid,
        'timestamp':     Timestamp.fromDate(now.subtract(const Duration(days: 10))),
        'averageRating': 4.1, 'reviewCount': 19,
      },
      {
        'placeName':     'Remera Police Station',
        'category':      'police_station',
        'address':       'KG 14 Ave, Remera, Kigali',
        'contactNumber': '+250 788 311 155',
        'description':   'Kigali Metropolitan Police sub-station serving Remera sector. Handles crime reports, traffic incidents, community safety, and lost property. Emergency line available 24/7.',
        'latitude': -1.9501, 'longitude': 30.1025,
        'createdBy': creatorUid,
        'timestamp':     Timestamp.fromDate(now.subtract(const Duration(days: 7))),
        'averageRating': 3.9, 'reviewCount': 12,
      },
      {
        'placeName':     'Amahoro Botanical Garden',
        'category':      'park',
        'address':       'Boulevard de l\'Umuganda, Kimihurura',
        'contactNumber': '+250 788 000 123',
        'description':   'A beautifully maintained public garden near the Kimihurura roundabout. Walking paths, outdoor gym equipment, a children\'s play zone, and weekend food vendors make this a favourite for families and joggers.',
        'latitude': -1.9441, 'longitude': 30.0980,
        'createdBy': creatorUid,
        'timestamp':     Timestamp.fromDate(now.subtract(const Duration(days: 14))),
        'averageRating': 4.6, 'reviewCount': 53,
      },
      {
        'placeName':     'Nyamirambo Community Library',
        'category':      'library',
        'address':       'KN 3 St, Nyamirambo, Kigali',
        'contactNumber': '+250 252 570 020',
        'description':   'A peaceful public library funded by the Kigali City Council. Houses 9 000+ books in Kinyarwanda, French, and English. Free Wi-Fi, study rooms, and weekend reading clubs for children.',
        'latitude': -1.9800, 'longitude': 30.0370,
        'createdBy': creatorUid,
        'timestamp':     Timestamp.fromDate(now.subtract(const Duration(days: 21))),
        'averageRating': 4.4, 'reviewCount': 31,
      },
      {
        'placeName':     'Ibirunga Resto & Grill',
        'category':      'restaurant',
        'address':       'KG 9 Ave, Gishushu, Kigali',
        'contactNumber': '+250 788 721 300',
        'description':   'Authentic Rwandan cuisine in a lively rooftop setting above Gishushu. Signature dishes: isombe na ibirayi, brochettes ya inka, and fresh tilapia from Lake Kivu. Live music Friday evenings.',
        'latitude': -1.9517, 'longitude': 30.0741,
        'createdBy': creatorUid,
        'timestamp':     Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'averageRating': 4.9, 'reviewCount': 78,
      },
      {
        'placeName':     'Kandt House Museum',
        'category':      'tourist_attraction',
        'address':       'KN 67 St, Nyarugenge, Kigali',
        'contactNumber': '+250 252 576 515',
        'description':   'The oldest preserved house in Kigali, built by Dr Richard Kandt — the city\'s first European resident. Now a natural history and heritage museum. Open Tue–Sun, 9 am–5 pm. Entry 3 000 RWF.',
        'latitude': -1.9500, 'longitude': 30.0590,
        'createdBy': creatorUid,
        'timestamp':     Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        'averageRating': 4.3, 'reviewCount': 62,
      },
    ];

    final batch = _db.batch();
    for (final seed in seeds) {
      batch.set(_listings.doc(), seed);
    }
    await batch.commit();
  }
}
