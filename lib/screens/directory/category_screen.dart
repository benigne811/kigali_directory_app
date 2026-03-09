// lib/screens/directory/category_screen.dart
// Screen 2: All listings in one category.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/shimmer_card.dart';

class CategoryScreen extends ConsumerWidget {
  final ListingCategory category;
  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(categoryListingsProvider(category));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(category.label)),
      body: listingsAsync.when(
        data: (listings) {
          if (listings.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.location_off_outlined, size: 56, color: AppColors.textHint),
                const SizedBox(height: 16),
                Text('No ${category.label} listings yet',
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (_, i) => ListingCard(listing: listings[i]),
          );
        },
        loading: () => const ShimmerList(),
        error:   (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
