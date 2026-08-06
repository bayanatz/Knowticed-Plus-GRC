/// Module: GRC Policy Management
/// Description: Compact preview card for an uploaded policy document.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyDocumentInfo
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-15 - Added `readOnly` mode (hides the remove
///                                button) for already-uploaded documents
///                                shown on the Policy Details page
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_document_preview_widget.dart
/// Purpose: Contains PolicyDocumentPreviewWidget, a compact card that
///          displays document metadata and, unless read-only, a remove
///          button.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// class name: [PolicyDocumentPreviewWidget]
///
/// purpose: stateless card that shows a PDF icon, document name, size (if
///          known), date (if known), and — unless [readOnly] — a red remove
///          button. Used in the policy info form, each control card, and
///          the read-only Policy Details page.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class PolicyDocumentPreviewWidget extends StatelessWidget {
  final PolicyDocumentInfo document;
  final VoidCallback? onRemove;
  final bool readOnly;

  const PolicyDocumentPreviewWidget({
    super.key,
    required this.document,
    this.onRemove,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withOpacity(.4)),
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.background,
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red, size: 26.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  document.name,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis,
                ),
                if (document.sizeLabel.isNotEmpty)
                  Text(
                    document.sizeLabel,
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.secondaryText),
                  ),
              ],
            ),
          ),
          if (document.dateLabel.isNotEmpty) ...[
            SizedBox(width: 8.w),
            Text(
              'Date: ${document.dateLabel}',
              style: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.secondaryText),
            ),
          ],
          if (!readOnly) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onRemove,
              child: CircleAvatar(
                radius: 10.r,
                backgroundColor: Colors.red,
                child: Icon(Icons.remove, color: Colors.white, size: 14.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
