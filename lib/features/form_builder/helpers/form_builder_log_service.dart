/// Module: core/helper/form_builder
///
/// ************************* FILE INFO ************************* ///
/// File Name: form_builder_log_service.dart
/// Description: Centralized system log helper for the Form Builder module.
///          Call FormBuilderLogService.log(FormBuilderLogService.actionX)
///          after an action SUCCEEDS to record it in System Logs.
/// Author: Amr Mesbah
/// Created at: 12/10/2026
/// Pattern: Matches RoleLogService (roles/r5_system_logs/data/role_log_service.dart)
/// Spec: Knowticed Plus Notification & Validation, Section 3 — System Logs,
///       "Form Builder" rows. The action strings below are those rows,
///       lower-cased like every other module's log actions (the logs table
///       capitalizes them for display).
library;

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';

class FormBuilderLogService {
  // ─── Forms ──────────────────────────────────────────────────
  static const String actionCreateForm = 'create form';
  static const String actionPublishForm = 'publish form';
  static const String actionUpdateForm = 'update form';
  static const String actionDeleteForm = 'delete form';
  static const String actionConvertToPdf = 'convert to pdf';

  // ─── Sharing & access ───────────────────────────────────────
  static const String actionShareForm = 'share form';
  static const String actionUpdateFormAccess = 'update form access';
  static const String actionEnableResponseEditing = 'enable response editing';

  // ─── Responses ──────────────────────────────────────────────
  static const String actionFillOutForm = 'fill out form';
  static const String actionSubmitFormResponse = 'submit form response';
  static const String actionUpdateSubmittedResponse =
      'update submitted response';
  static const String actionSendReminder = 'send reminder';

  // ─── Results ────────────────────────────────────────────────
  static const String actionViewFormResults = 'view form results';
  static const String actionExportFormResults = 'export form results';

  // ─── Groups ─────────────────────────────────────────────────
  static const String actionCreateGroup = 'create group';
  static const String actionRenameGroup = 'rename group';
  static const String actionDeleteGroup = 'delete group';
  static const String actionAddGroupMembers = 'add group members';
  static const String actionRemoveGroupMembers = 'remove group members';

  /// Log an action for the Form Builder module.
  ///
  /// Fire-and-forget, like RoleLogService: logging must never break a UI
  /// flow, so a failure (e.g. SystemLogsController not registered yet) is
  /// swallowed here. `systemLogsAction` itself already skips the entry when
  /// the signed-in profile has not loaded.
  static void log(String action) {
    try {
      AppControllers.systemLogs
          .systemLogsAction(action, module: Modules.formBuilder);
    } catch (e) {
      // Telemetry only — never surface to the user.
    }
  }
}
