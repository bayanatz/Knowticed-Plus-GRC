/// Module: knowledge_hub/data/utils
/// ************************* FILE INFO *************************** ///
/// File Name: kh_system_log.dart
/// Description: Writes Knowledge Hub actions to Platform Controls → System Logs.
/// Author: Amr Mesbah
/// Created at: 14/10/2026
///
/// The action names are the ten Knowledge Hub rows of "Knowticed Plus –
/// Notification & Validation", Section 3 — System Logs. Use the
/// [KhLogAction] constants; do not pass free text, so the log's Action filter
/// shows one entry per action.
///
/// Best-effort, like every other system-log write: never throws, never
/// blocks the action it describes.
library;

import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';

/// Section 3 — System Logs, Knowledge Hub rows.
abstract class KhLogAction {
  static const String submitDocument = 'Submit Document';
  static const String approveDocument = 'Approve Document';
  static const String rejectDocument = 'Reject Document';
  static const String publishDocument = 'Publish Document';
  static const String withdrawDocument = 'Withdraw Document';
  static const String archiveDocument = 'Archive Document';
  static const String requestDocumentRevision = 'Request Document Revision';
  static const String submitInquiryComment = 'Submit Inquiry / Comment';
  static const String issueReviewReminder = 'Issue Review Reminder';
  static const String assignReviewRequest = 'Assign Review Request';

  /// Publish when the document went live straight away, otherwise nothing —
  /// for callers that already logged the step that led here.
  static bool isPublished(String? status) =>
      (status ?? '').trim().toLowerCase() == 'published';
}

void khSystemLog(String action) {
  try {
    if (!Get.isRegistered<SystemLogsController>()) return;
    Get.find<SystemLogsController>().systemLogsAction(
      action,
      module: Modules.knowledgeHub,
    );
  } catch (_) {
    // Telemetry only — a dropped log must never affect the user's action.
  }
}
