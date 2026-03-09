// lib/screens/listings/add_listing_screen.dart
//
// Form to create a new listing.
// All input is validated before writing to Firestore.
// The createdBy field is automatically set from the auth state.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_button.dart';

class AddListingScreen extends ConsumerStatefulWidget {
  const AddListingScreen({super.key});
  @override
  ConsumerState<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends ConsumerState<AddListingScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _addrCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _latCtrl     = TextEditingController(text: '-1.9441');
  final _lngCtrl     = TextEditingController(text: '30.0619');
  ListingCategory _category = ListingCategory.cafe;

  @override
  void dispose() {
    for (final c in [_nameCtrl, _addrCtrl, _phoneCtrl, _descCtrl, _latCtrl, _lngCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final listing = ListingModel(
      id:            '',
      placeName:     _nameCtrl.text.trim(),
      category:      _category,
      address:       _addrCtrl.text.trim(),
      contactNumber: _phoneCtrl.text.trim(),
      description:   _descCtrl.text.trim(),
      latitude:      double.tryParse(_latCtrl.text) ?? -1.9441,
      longitude:     double.tryParse(_lngCtrl.text) ?? 30.0619,
      createdBy:     '', // provider fills this
      timestamp:     DateTime.now(),
    );

    final id = await ref.read(listingCrudProvider.notifier).create(listing);
    if (id != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Listing created successfully!'),
        behavior: SnackBarBehavior.floating,
      ));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final crudAsync = ref.watch(listingCrudProvider);

    ref.listen<AsyncValue<void>>(listingCrudProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(state.error.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(listingCrudProvider.notifier).clear();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add New Place')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _section('Place Information'),
            AppTextField(
              controller: _nameCtrl, label: 'Place name',
              hint: 'e.g. Inzozi Coffee House',
              prefixIcon: Icons.storefront_outlined,
              validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Category picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category', style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<ListingCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined, size: 20, color: AppColors.textSecondary),
                  ),
                  items: ListingCategory.values.map((c) =>
                      DropdownMenuItem(value: c, child: Text(c.label))
                  ).toList(),
                  onChanged: (c) => setState(() => _category = c!),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _addrCtrl, label: 'Address',
              hint: 'e.g. KG 11 Ave, Kacyiru',
              prefixIcon: Icons.location_on_outlined,
              validator: (v) => v!.trim().isEmpty ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _phoneCtrl, label: 'Contact number',
              hint: '+250 788 000 000',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.call_outlined,
              validator: (v) => v!.trim().isEmpty ? 'Contact is required' : null,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _descCtrl, label: 'Description',
              hint: 'Describe this place in detail…',
              prefixIcon: Icons.notes_outlined,
              maxLines: 4,
              validator: (v) => v!.trim().isEmpty ? 'Description is required' : null,
            ),
            const SizedBox(height: 24),

            _section('Location Coordinates'),
            const Text(
              'Find coordinates: open Google Maps → long-press a point → copy the numbers shown.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: AppTextField(
                controller: _latCtrl, label: 'Latitude',
                hint: '-1.9441',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                prefixIcon: Icons.my_location,
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d < -90 || d > 90) return 'Invalid';
                  return null;
                },
              )),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(
                controller: _lngCtrl, label: 'Longitude',
                hint: '30.0619',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                prefixIcon: Icons.my_location,
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d < -180 || d > 180) return 'Invalid';
                  return null;
                },
              )),
            ]),
            const SizedBox(height: 32),

            LoadingButton(
              label: 'Create Listing',
              isLoading: crudAsync.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(title, style: AppTextStyles.titleMedium),
  );
}
