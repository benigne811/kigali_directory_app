// lib/screens/directory/directory_screen.dart
//
// Screen 1: Home / Directory
// Features:
//   - Personalised greeting
//   - Search bar (drives searchQueryProvider)
//   - Category chip row (drives activeCategoryProvider)
//   - Real-time listing list via filteredListingsProvider
//   - Shimmer loading skeletons
//   - FAB to add a new listing

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/category_chip_row.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/shimmer_card.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});
  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  bool _seeded = false;

  // Seed Firestore once per session after the first frame
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeSeed());
  }

  Future<void> _maybeSeed() async {
    if (_seeded) return;
    _seeded = true;
    final uid = ref.read(authStateProvider).value?.uid ?? '';
    if (uid.isNotEmpty) {
      await ref.read(listingServiceProvider).seedIfEmpty(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredListingsProvider);
    final activecat     = ref.watch(activeCategoryProvider);
    final user          = ref.watch(currentUserProvider).value;
    final greeting      = user?.email.split('@').first ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kigali City'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accent,
              child: Text(
                greeting.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-listing'),
        tooltip: 'Add a place',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allListingsProvider),
        child: CustomScrollView(
          slivers: [
            // ── Header with search bar ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $greeting 👋', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 4),
                    const Text('What are you looking for?', style: AppTextStyles.displayMedium),
                    const SizedBox(height: 16),
                    KigaliSearchBar(
                      onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
                    ),
                  ],
                ),
              ),
            ),

            // ── Category chips ────────────────────────────────────
            SliverToBoxAdapter(
              child: CategoryChipRow(
                selected: activecat,
                onChanged: (cat) =>
                    ref.read(activeCategoryProvider.notifier).state = cat,
              ),
            ),

            // ── Section header ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activecat == null ? 'Near You' : activecat.label,
                      style: AppTextStyles.titleLarge,
                    ),
                    filteredAsync.when(
                      data: (l) => Text('${l.length} places', style: AppTextStyles.caption),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Listing list ──────────────────────────────────────
            filteredAsync.when(
              data: (listings) {
                if (listings.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(
                      hasFilters: activecat != null ||
                          ref.read(searchQueryProvider).isNotEmpty,
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ListingCard(listing: listings[i]),
                      childCount: listings.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: ShimmerList(),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  const _EmptyState({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.location_off_outlined,
              size: 64, color: AppColors.textHint,
            ),
            const SizedBox(height: 20),
            Text(
              hasFilters ? 'No results found' : 'No listings yet',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try a different search or category.'
                  : 'Be the first to add a place in Kigali!',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
