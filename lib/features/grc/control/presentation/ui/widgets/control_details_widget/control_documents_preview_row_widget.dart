/// Module: GRC Policy Management
/// Description: Read-only Control Document (English/Arabic) preview row for
///              the Control Details page, extracted from
///              ControlDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter, ProductWarrantyCard
/// Revision History: 2026-07-21 - Initial creation (inline in
///                                control_details_page.dart)
///                   2026-07-28 - Split out into its own widget file
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_documents_preview_row_widget.dart
/// Purpose: Contains ControlDocumentsPreviewRowWidget, the read-only
///          document card(s) for a Control's English/Arabic documents.
///          Renders nothing when neither document is set.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/7/2026

import 'package:demo_app/core/custom/22-custom_uploaded_document_card.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;

/// class name: [ControlDocumentsPreviewRowWidget]
///
/// purpose: renders one or two read-only document preview cards for a
///          Control's English/Arabic documents, side by side.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/7/2026
class ControlDocumentsPreviewRowWidget extends StatelessWidget {
  final String? documentEnUrl;
  final String? documentArUrl;
  final DateTime lastModifiedDate;
  final DateFormat dateFormat;

  const ControlDocumentsPreviewRowWidget({
    super.key,
    required this.documentEnUrl,
    required this.documentArUrl,
    required this.lastModifiedDate,
    required this.dateFormat,
  });

  Widget _documentCard(String url) => Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: ProductWarrantyCard(
            fileName: url.split('/').last,
            date: dateFormat.format(lastModifiedDate),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hasEn = documentEnUrl != null;
    final hasAr = documentArUrl != null;
    if (!hasEn && !hasAr) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasEn) _documentCard(documentEnUrl!),
          if (hasEn && hasAr) SizedBox(width: 12.w),
          if (hasAr) _documentCard(documentArUrl!),
        ],
      ),
    );
  }
}
