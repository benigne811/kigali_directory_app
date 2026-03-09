// lib/widgets/search_bar_widget.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class KigaliSearchBar extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String hint;

  const KigaliSearchBar({
    super.key,
    this.initialValue = '',
    required this.onChanged,
    this.hint = 'Search for a service or place…',
  });

  @override
  State<KigaliSearchBar> createState() => _KigaliSearchBarState();
}

class _KigaliSearchBarState extends State<KigaliSearchBar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: _ctrl,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.bodyMedium,
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppColors.textHint),
                  onPressed: () { _ctrl.clear(); widget.onChanged(''); setState(() {}); },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: AppTextStyles.bodyLarge,
      ),
    );
  }
}
