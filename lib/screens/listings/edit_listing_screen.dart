// lib/screens/listings/edit_listing_screen.dart
// Pre-populated form to update an existing listing. Owner only.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_button.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  final ListingModel listing;
  const EditListingScreen({super.key, required this.listing});

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  late final GlobalKey<FormState> _formKey = GlobalKey();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late ListingCategory _category;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _nameCtrl  = TextEditingController(text: l.placeName);
    _addrCtrl  = TextEditingController(text: l.address);
    _phoneCtrl = TextEditingController(text: l.contactNumber);
    _descCtrl  = TextEditingController(text: l.description);
    _latCtrl   = TextEditingController(text: l.latitude.toString());
    _lngCtrl   = TextEditingController(text: l.longitude.toString());
    _category  = l.category;
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _addrCtrl, _phoneCtrl, _descCtrl, _latCtrl, _lngCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(listingCrudProvider.notifier).update(widget.listing.id, {
      'placeName':     _nameCtrl.text.trim(),
      'category':      _category.value,
      'address':       _addrCtrl.text.trim(),
      'contactNumber': _phoneCtrl.text.trim(),
      'description':   _descCtrl.text.trim(),
      'latitude':      double.tryParse(_latCtrl.text) ?? widget.listing.latitude,
      'longitude':     double.tryParse(_lngCtrl.text) ?? widget.listing.longitude,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Listing updated!'),
        behavior: SnackBarBehavior.floating,
      ));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(listingCrudProvider).isLoading;

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
      appBar: AppBar(title: const Text('Edit Listing')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(controller: _nameCtrl, label: 'Place name',
                prefixIcon: Icons.storefront_outlined,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 16),

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Category', style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<ListingCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined, size: 20, color: AppColors.textSecondary),
                ),
                items: ListingCategory.values.map((c) =>
                    DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                onChanged: (c) => setState(() => _category = c!),
              ),
            ]),
            const SizedBox(height: 16),

            AppTextField(controller: _addrCtrl, label: 'Address',
                prefixIcon: Icons.location_on_outlined,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 16),

            AppTextField(controller: _phoneCtrl, label: 'Contact number',
                prefixIcon: Icons.call_outlined, keyboardType: TextInputType.phone,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 16),

            AppTextField(controller: _descCtrl, label: 'Description',
                prefixIcon: Icons.notes_outlined, maxLines: 4,
                validator: (v) => v!.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: AppTextField(
                controller: _latCtrl, label: 'Latitude',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                prefixIcon: Icons.my_location,
                validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
              )),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(
                controller: _lngCtrl, label: 'Longitude',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                prefixIcon: Icons.my_location,
                validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
              )),
            ]),
            const SizedBox(height: 32),

            LoadingButton(label: 'Save Changes', isLoading: isLoading, onPressed: _submit),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
