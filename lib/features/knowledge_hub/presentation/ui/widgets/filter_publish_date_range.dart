/// Module: knowledge_hub/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: filter_publish_date_range.dart
/// Description: The one "Published Date" field inside FilterSearchDialog.
/// Author: Amr Mesbah
/// Created at: 28/8/2026
///
/// KH large-screen report p.5: "remove these two, there
/// will be only one filter for date (Published Date)" and "in date filter the
/// title will be in the field not above it".
///
/// The From/To pair is now ONE field. Its title is the placeholder inside the
/// box (no label line above), and it is the same 36-high, background-filled box
/// as the Document Type dropdown beside it, so the two read as one row.
/// Picking a day filters to documents published ON that day; the dialog passes
/// it to the cubit as both ends of the existing range, so the cubit's filter
/// code is unchanged.
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/kh_filter_fields.dart';

/// Now the shared [KhFilterDateField], so it matches the
/// Submissions / Approvals date fields exactly; the clear (×) is kept.
class FilterPublishedDate extends StatelessWidget {
  final bool lightMode;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const FilterPublishedDate({
    super.key,
    required this.lightMode,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return KhFilterDateField(
      value: value,
      hint: S.of(context).published_date,
      onPicked: onChanged,
      onClear: () => onChanged(null),
    );
  }
}
