// lib/screens/detail/service_detail_screen.dart
// Full detail view with embedded WebView map + reviews + rating sheet.

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  final String listingId;
  final ListingModel? listing;

  const ServiceDetailScreen({
    super.key,
    required this.listingId,
    this.listing,
  });

  @override
  ConsumerState<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  double _rating = 3;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _openDirections(ListingModel l) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${l.latitude},${l.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _showRatingSheet(ListingModel l) {
    _rating = 3;
    _commentCtrl.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 28,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: StatefulBuilder(
            builder: (ctx, setModal) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text('Rate ${l.placeName}',
                        style: AppTextStyles.titleLarge),
                    const SizedBox(height: 20),
                    Center(
                      child: RatingBar.builder(
                        initialRating: 3,
                        minRating: 1,
                        itemCount: 5,
                        itemSize: 46,
                        itemBuilder: (_, __) => const Icon(Icons.star_rounded,
                            color: AppColors.starFilled),
                        onRatingUpdate: (r) => setModal(() => _rating = r),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _commentCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText: 'Share your experience (optional)…'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submitReview(l),
                        child: const Text('Submit Review'),
                      ),
                    ),
                  ],
                )),
      ),
    );
  }

  Future<void> _submitReview(ListingModel l) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    final review = ReviewModel(
      id: '',
      userId: user.uid,
      userEmail: user.email ?? '',
      rating: _rating,
      comment: _commentCtrl.text.trim(),
      timestamp: DateTime.now(),
    );
    await ref
        .read(listingCrudProvider.notifier)
        .addReview(listingId: l.id, review: review);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Review submitted — thank you!'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _confirmDelete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete listing'),
        content: const Text('This cannot be undone. Remove this place?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(listingCrudProvider.notifier).delete(id);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    if (l == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final uid = ref.watch(authStateProvider).value?.uid;
    final isOwner = uid == l.createdBy;
    final bookmarked = ref.watch(bookmarkNotifierProvider).contains(l.id);
    final reviews = ref.watch(reviewsProvider(l.id));

    final mapUrl = 'https://maps.google.com/maps?q=${l.latitude},${l.longitude}'
        '&z=16&output=embed';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading:
                BackButton(color: Colors.white, onPressed: () => context.pop()),
            actions: [
              IconButton(
                icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white),
                onPressed: () =>
                    ref.read(bookmarkNotifierProvider.notifier).toggle(l.id),
              ),
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () =>
                      context.push('/edit-listing/${l.id}', extra: l),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () => _confirmDelete(l.id),
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(l.placeName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(_catIcon(l.category),
                      size: 80, color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(l.category.label,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                    ),
                    const Spacer(),
                    const Icon(Icons.star_rounded,
                        color: AppColors.starFilled, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${l.averageRating.toStringAsFixed(1)}  (${l.reviewCount})',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _row(Icons.location_on_outlined, l.address),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _call(l.contactNumber),
                    child: _row(Icons.call_outlined, l.contactNumber,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text('About', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Text(l.description, style: AppTextStyles.bodyLarge),
                  const SizedBox(height: 28),

                  // ── Embedded map ─────────────────────────────────
                  const Text('Location', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 240,
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
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openDirections(l),
                      icon: const Icon(Icons.directions_outlined, size: 18),
                      label: const Text('Get Directions'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRatingSheet(l),
                      icon: const Icon(Icons.star_border_rounded, size: 18),
                      label: const Text('Rate this service'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Reviews ───────────────────────────────────────
                  const Text('Reviews', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  reviews.when(
                    data: (list) => list.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('No reviews yet. Be the first!',
                                style: AppTextStyles.bodyMedium))
                        : Column(
                            children: list
                                .map((r) => _ReviewTile(review: r))
                                .toList()),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, {Color? color}) => Row(children: [
        Icon(icon, size: 18, color: color ?? AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: AppTextStyles.bodyLarge.copyWith(color: color))),
      ]);
}

IconData _catIcon(ListingCategory c) {
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

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              review.userEmail.isNotEmpty
                  ? review.userEmail[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.userEmail,
                  style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(DateFormat('dd MMM yyyy').format(review.timestamp),
                  style: AppTextStyles.caption),
            ],
          )),
          RatingBarIndicator(
            rating: review.rating,
            itemCount: 5,
            itemSize: 14,
            itemBuilder: (_, __) =>
                const Icon(Icons.star_rounded, color: AppColors.starFilled),
          ),
        ]),
        if (review.comment.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(review.comment, style: AppTextStyles.bodyMedium),
        ],
      ]),
    );
  }
}
