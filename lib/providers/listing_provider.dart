// lib/providers/listing_provider.dart
//
// PURPOSE: All listing / review / bookmark / search / filter state.
//
// Provider map:
//   listingServiceProvider    → ListingService singleton
//   allListingsProvider       → real-time stream of all listings
//   categoryListingsProvider  → real-time stream filtered by category
//   myListingsProvider        → listings created by current user
//   reviewsProvider           → reviews for a specific listing
//   searchQueryProvider       → the string the user typed
//   activeCategoryProvider    → the chip the user tapped
//   filteredListingsProvider  → derived: allListings filtered by search + category
//   bookmarkNotifierProvider  → Set<String> persisted in SharedPreferences
//   bookmarkedListingsProvider→ full ListingModel objects for bookmarked IDs
//   listingCrudProvider       → async state for create / update / delete

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';
import 'auth_provider.dart';

// ── Service singleton ────────────────────────────────────────────
final listingServiceProvider =
    Provider<ListingService>((ref) => ListingService());

// ── All listings (real-time stream) ─────────────────────────────
final allListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  return ref.watch(listingServiceProvider).allListings();
});

// ── Listings by category (parameterised stream) ──────────────────
// Usage: ref.watch(categoryListingsProvider(ListingCategory.cafe))
final categoryListingsProvider =
    StreamProvider.family<List<ListingModel>, ListingCategory>(
  (ref, category) =>
      ref.watch(listingServiceProvider).listingsByCategory(category),
);

// ── My listings ──────────────────────────────────────────────────
final myListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(listingServiceProvider).myListings(uid);
});

// ── Reviews for a listing ────────────────────────────────────────
final reviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>(
  (ref, listingId) =>
      ref.watch(listingServiceProvider).reviews(listingId),
);

// ══════════════════════════════════════════════════════════════
//  SEARCH & FILTER STATE
// ══════════════════════════════════════════════════════════════

// The text typed into the search bar
final searchQueryProvider = StateProvider<String>((ref) => '');

// The active category chip (null = show all)
final activeCategoryProvider =
    StateProvider<ListingCategory?>((ref) => null);

// Derived provider: combines stream data + search + category filter.
// This is a synchronous Provider because the data is already loaded.
final filteredListingsProvider =
    Provider<AsyncValue<List<ListingModel>>>((ref) {
  final allAsync   = ref.watch(allListingsProvider);
  final query      = ref.watch(searchQueryProvider).toLowerCase().trim();
  final activecat  = ref.watch(activeCategoryProvider);

  return allAsync.whenData((all) {
    var result = all;

    // Category filter
    if (activecat != null) {
      result = result.where((l) => l.category == activecat).toList();
    }

    // Text search on name, address, category label
    if (query.isNotEmpty) {
      result = result.where((l) =>
          l.placeName.toLowerCase().contains(query) ||
          l.address.toLowerCase().contains(query) ||
          l.category.label.toLowerCase().contains(query)).toList();
    }

    return result;
  });
});

// ══════════════════════════════════════════════════════════════
//  BOOKMARKS
//  Stored in SharedPreferences as a List<String> of listing IDs.
//  This persists across app restarts without needing Firestore.
// ══════════════════════════════════════════════════════════════

class BookmarkNotifier extends StateNotifier<Set<String>> {
  static const _key = 'bookmarked_listing_ids';

  BookmarkNotifier() : super({}) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    state = saved.toSet();
  }

  Future<void> toggle(String listingId) async {
    final next = Set<String>.from(state);
    if (next.contains(listingId)) {
      next.remove(listingId);
    } else {
      next.add(listingId);
    }
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, next.toList());
  }

  bool isBookmarked(String id) => state.contains(id);
}

final bookmarkNotifierProvider =
    StateNotifierProvider<BookmarkNotifier, Set<String>>(
  (_) => BookmarkNotifier(),
);

// Full ListingModel objects for all bookmarked IDs
final bookmarkedListingsProvider = Provider<List<ListingModel>>((ref) {
  final ids      = ref.watch(bookmarkNotifierProvider);
  final allAsync = ref.watch(allListingsProvider);
  final all      = allAsync.value ?? [];
  return all.where((l) => ids.contains(l.id)).toList();
});

// ══════════════════════════════════════════════════════════════
//  LISTING CRUD STATE
// ══════════════════════════════════════════════════════════════

class ListingCrudNotifier extends StateNotifier<AsyncValue<void>> {
  final ListingService _svc;
  final String         _uid;

  ListingCrudNotifier(this._svc, this._uid)
      : super(const AsyncValue.data(null));

  Future<String?> create(ListingModel listing) async {
    state = const AsyncValue.loading();
    try {
      final id = await _svc.createListing(
          listing.copyWith(createdBy: _uid));
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _svc.updateListing(id, data);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _svc.deleteListing(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addReview({
    required String listingId,
    required ReviewModel review,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _svc.addReview(listingId: listingId, review: review);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() => state = const AsyncValue.data(null);
}

final listingCrudProvider =
    StateNotifierProvider<ListingCrudNotifier, AsyncValue<void>>((ref) {
  final svc = ref.watch(listingServiceProvider);
  final uid = ref.watch(authStateProvider).value?.uid ?? '';
  return ListingCrudNotifier(svc, uid);
});
