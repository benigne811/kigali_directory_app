// lib/widgets/listing_card.dart
//
// PURPOSE: The primary card component used in Directory, Bookmarks, and
// Category screens. Shows: icon, name, category badge, address, rating.
// Tapping navigates to the detail screen. The bookmark icon toggles instantly.

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/listing_model.dart';
import '../providers/listing_provider.dart';
import '../utils/app_theme.dart';

class ListingCard extends ConsumerWidget {
  final ListingModel listing;
  final bool showBookmark;

  const ListingCard({
    super.key,
    required this.listing,
    this.showBookmark = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked = ref.watch(bookmarkNotifierProvider).contains(listing.id);

    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}', extra: listing),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category icon tile
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: _chipColor(listing.category),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_categoryIcon(listing.category),
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + bookmark
                  Row(children: [
                    Expanded(
                      child: Text(listing.placeName,
                          style: AppTextStyles.titleSmall,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (showBookmark)
                      GestureDetector(
                        onTap: () => ref
                            .read(bookmarkNotifierProvider.notifier)
                            .toggle(listing.id),
                        child: Icon(
                          bookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: bookmarked ? AppColors.primary : AppColors.textHint,
                          size: 20,
                        ),
                      ),
                  ]),
                  const SizedBox(height: 4),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _chipColor(listing.category),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(listing.category.label,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 6),

                  // Address
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(listing.address,
                          style: AppTextStyles.bodyMedium,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                  const SizedBox(height: 6),

                  // Rating
                  Row(children: [
                    RatingBarIndicator(
                      rating: listing.averageRating,
                      itemCount: 5,
                      itemSize: 13,
                      itemBuilder: (_, __) =>
                          const Icon(Icons.star_rounded, color: AppColors.starFilled),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${listing.averageRating.toStringAsFixed(1)}  '
                      '(${listing.reviewCount} reviews)',
                      style: AppTextStyles.caption,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────
Color _chipColor(ListingCategory c) {
  switch (c) {
    case ListingCategory.cafe:              return AppColors.chipCafe;
    case ListingCategory.hospital:          return AppColors.chipHospital;
    case ListingCategory.pharmacy:          return AppColors.chipPharmacy;
    case ListingCategory.policeStation:     return AppColors.chipPolice;
    case ListingCategory.park:              return AppColors.chipPark;
    case ListingCategory.library:           return AppColors.chipLibrary;
    case ListingCategory.restaurant:        return AppColors.chipRestaurant;
    case ListingCategory.touristAttraction: return AppColors.chipTourist;
    case ListingCategory.other:             return AppColors.surfaceAlt;
  }
}

IconData _categoryIcon(ListingCategory c) {
  switch (c) {
    case ListingCategory.cafe:              return Icons.coffee_outlined;
    case ListingCategory.hospital:          return Icons.local_hospital_outlined;
    case ListingCategory.pharmacy:          return Icons.medication_outlined;
    case ListingCategory.policeStation:     return Icons.local_police_outlined;
    case ListingCategory.park:              return Icons.park_outlined;
    case ListingCategory.library:           return Icons.local_library_outlined;
    case ListingCategory.restaurant:        return Icons.restaurant_outlined;
    case ListingCategory.touristAttraction: return Icons.camera_alt_outlined;
    case ListingCategory.other:             return Icons.place_outlined;
  }
}
