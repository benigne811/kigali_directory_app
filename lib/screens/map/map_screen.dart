// lib/screens/map/map_screen.dart
//
// Tab 3 — shows ALL listings on an embedded Google Map (WebView).
// Tapping a pin opens the detail screen.
// No API key needed — uses maps.google.com/maps embed URL.

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/listing_model.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(allListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Map View'),
        automaticallyImplyLeading: false,
      ),
      body: listingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error loading map: $e', style: AppTextStyles.bodyMedium),
        ),
        data: (listings) {
          if (listings.isEmpty) {
            return const Center(
              child: Text('No listings to show on map yet.'),
            );
          }

          // Build a Google Maps embed URL centred on Kigali with
          // search markers for every listing address
          final centre = listings.isNotEmpty
              ? '${listings.first.latitude},${listings.first.longitude}'
              : '-1.9441,30.0619'; // Kigali CBD fallback

          final mapUrl =
              'https://maps.google.com/maps?q=$centre&z=13&output=embed';

          return Column(
            children: [
              // ── Embedded map ──────────────────────────────────
              Expanded(
                flex: 3,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(mapUrl)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    displayZoomControls: false,
                    builtInZoomControls: true,
                    useWideViewPort: true,
                    loadWithOverviewMode: true,
                    mixedContentMode:
                        MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  ),
                ),
              ),

              // ── Listing chips below the map ───────────────────
              Container(
                color: AppColors.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${listings.length} places in Kigali',
                        style: AppTextStyles.titleSmall,
                      ),
                    ),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: listings.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) =>
                            _ListingChip(listing: listings[i]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ListingChip extends StatelessWidget {
  final ListingModel listing;
  const _ListingChip({required this.listing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}', extra: listing),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon(listing.category),
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 8),
            Text(listing.placeName,
                style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(listing.category.label,
                style: AppTextStyles.caption, maxLines: 1),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.starFilled, size: 12),
              const SizedBox(width: 3),
              Text(listing.averageRating.toStringAsFixed(1),
                  style: AppTextStyles.caption),
            ]),
          ],
        ),
      ),
    );
  }

  IconData _icon(ListingCategory c) {
    switch (c) {
      case ListingCategory.cafe:
        return Icons.coffee_outlined;
      case ListingCategory.hospital:
        return Icons.local_hospital_outlined;
      case ListingCategory.pharmacy:
        return Icons.medication_outlined;
      case ListingCategory.policeStation:
        return Icons.local_police_outlined;
      case ListingCategory.park:
        return Icons.park_outlined;
      case ListingCategory.library:
        return Icons.local_library_outlined;
      case ListingCategory.restaurant:
        return Icons.restaurant_outlined;
      case ListingCategory.touristAttraction:
        return Icons.camera_alt_outlined;
      case ListingCategory.other:
        return Icons.place_outlined;
    }
  }
}
