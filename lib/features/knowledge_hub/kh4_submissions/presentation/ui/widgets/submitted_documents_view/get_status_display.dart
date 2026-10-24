/// Module: knowledge_hub/kh4_submissions/presentation/ui/widgets/submitted_documents_view
///
///*************************** FILE INFO ****************************///
/// File Name: get_status_display.dart
/// Description: `_getStatusDisplay()`, `_getStatusColor()`, `_getExtensionBadgeColor()` — split out of `submitted_documents_view.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../submitted_documents_view.dart';

// Split from submitted_documents_view.dart to keep every file under 700 lines.

String _getStatusDisplay(BuildContext context, String status) {
  switch (status.toLowerCase()) {
    case 'published':
      return S.of(context).published;
    case 'approved':
      return S.of(context).approved;
    // 14/10/2026 — KH report p.13: 'scheduled' is a request still WAITING
    // for approval (it only carries a future publish date). It sits under the
    // Pending tab and the details page already calls it Pending, so the card
    // says Pending too.
    case 'pending_approval':
    case 'scheduled':
      return S.of(context).pending;
    case 'rejected':
      return S.of(context).rejected;
    case 'revision_requested': // KH-APPROVE-04
      return S.of(context).revisionRequested;
    case 'removed':
      return S.of(context).removed;
    case 'archived':
      return S.of(context).archive;
    default:
      return status;
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'published':
      return AppColors.fileExcel;
    case 'approved':
      return AppColors.lightGreen;
    case 'pending_approval':
    case 'scheduled':
      return AppColors.orange;
    case 'rejected':
      return AppColors.darkRed;
    case 'revision_requested': // KH-APPROVE-04
      return AppColors.orange;
    case 'removed':
      return AppColors.darkRed;
    case 'archived':
      return AppColors.secondaryBlack;
    default:
      return AppColors.grey;
  }
}
