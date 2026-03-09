// lib/screens/bookmarks/bookmarks_screen.dart
// Screen 5: Shows listings the user has bookmarked (saved to SharedPreferences).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked = ref.watch(bookmarkedListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bookmarks')),
      body: bookmarked.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.bookmark_border, size: 72, color: AppColors.textHint),
                const SizedBox(height: 20),
                Text('No bookmarks yet', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                const Text(
                  'Tap the bookmark icon on any listing\nto save it here for quick access.',
                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center,
                ),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarked.length,
              itemBuilder: (_, i) => ListingCard(listing: bookmarked[i]),
            ),
    );
  }
}
