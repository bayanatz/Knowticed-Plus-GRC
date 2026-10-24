/// Module: knowledge_hub/presentation/ui/widgets/filter_search_dialog_widgets
///
///*************************** FILE INFO ****************************///
/// File Name: dropdowns.dart
/// Description: `buildDropdowns()`, `_buildDropdown()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/ui/widgets/kh_filter_fields.dart';

/// KH large-screen report p.5: "Owning Status" is gone
/// (it was struck out), and the row is now Document Type + the one
/// [publishedDateField], so the dialog is a single row of two equal fields.
Widget buildDropdowns(
  BuildContext context, {
  required bool isMobile,
  required bool lightMode,
  required void Function(String?) onDocTypeChanged,
  required List<Map<String, String>> docTypeItems,
  required String? docType,
  required Widget publishedDateField,
}) {
  final docTypeDropdown = _buildDropdown(
    selectedValue: docType,
    items: docTypeItems,
    onChanged: onDocTypeChanged,
    hint: S.of(context).document_type,
    lightMode: lightMode,
    isMobile: isMobile,
  );

  if (isMobile) {
    return Column(
      children: [
        docTypeDropdown,
        SizedBox(height: 15.h),
        publishedDateField,
      ],
    );
  }

  return Row(
    children: [
      Expanded(child: docTypeDropdown),
      SizedBox(width: 15.w),
      Expanded(child: publishedDateField),
    ],
  );
}

Widget _buildDropdown({
  required String? selectedValue,
  required List<Map<String, String>> items,
  required ValueChanged<String?> onChanged,
  required String hint,
  required bool lightMode,
  required bool isMobile,
}) {
  // The shared KH filter dropdown (kh_filter_fields.dart).
  return SizedBox(
    width: isMobile ? double.infinity : null,
    child: KhFilterDropdown(
      value: selectedValue,
      items: items,
      onChanged: onChanged,
      hint: hint,
    ),
  );
}
