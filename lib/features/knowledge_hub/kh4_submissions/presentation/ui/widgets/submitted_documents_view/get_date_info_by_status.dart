/// Module: knowledge_hub/kh4_submissions/presentation/ui/widgets/submitted_documents_view
///
///*************************** FILE INFO ****************************///
/// File Name: get_date_info_by_status.dart
/// Description: `_getDateInfoByStatus()` — split out of `submitted_documents_view.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../submitted_documents_view.dart';

// Split from submitted_documents_view.dart to keep every file under 700 lines.

Map<String, dynamic> _getDateInfoByStatus(
  BuildContext context,
  String status,
  DateTime? uploadDate,
  DateTime? lastEditDate,
  dynamic rawStartDate,
  dynamic rawEndDate,
) {
  DateTime? endDate;

  if (rawStartDate != null) {
    if (rawStartDate is int) {
      DateTime.fromMillisecondsSinceEpoch(rawStartDate);
    } else if (rawStartDate is DateTime) {}
  }

  if (rawEndDate != null) {
    if (rawEndDate is int) {
      endDate = DateTime.fromMillisecondsSinceEpoch(rawEndDate);
    } else if (rawEndDate is DateTime) {
      endDate = rawEndDate;
    }
  }

  switch (status.toLowerCase()) {
    case 'published':
      return {
        'firstLabel': S.of(context).publish_date,
        'firstDate': uploadDate,
        'secondLabel': '${S.of(context).last_edit}: ',
        'secondDate': lastEditDate,
      };

    case 'pending_approval':
    case 'scheduled': // 14/10/2026 — still pending (see _getStatusDisplay)
      return {
        'firstLabel': S.of(context).submittedDate,
        'firstDate': uploadDate,
        'secondLabel': null,
        'secondDate': null,
      };

    case 'approved':
      return {
        'firstLabel': S.of(context).publishingDate,
        'firstDate': uploadDate,
        'secondLabel': null,
        'secondDate': null,
      };

    case 'rejected':
      return {
        'firstLabel': S.of(context).submittedDate,
        'firstDate': uploadDate,
        'secondLabel': '${S.of(context).rejectedDate}: ',
        'secondDate': lastEditDate,
      };

    case 'removed':
      return {
        'firstLabel': S.of(context).publish_date,
        'firstDate': uploadDate,
        'secondLabel': S.of(context).removedDate,
        'secondDate': lastEditDate,
      };

    case 'archived':
      return {
        'firstLabel': S.of(context).publish_date,
        'firstDate': uploadDate,
        'secondLabel': '${S.of(context).end_date}: ',
        'secondDate': endDate ?? lastEditDate,
      };

    default:
      return {
        'firstLabel': S.of(context).publish_date,
        'firstDate': uploadDate,
        'secondLabel': '${S.of(context).last_edit}: ',
        'secondDate': lastEditDate,
      };
  }
}
