// [module-file:form_builder] — deleted when the form_builder module is split out
/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_notification_service.dart
/// Description: ALL notifications raised by the Form Builder module (section
///          2.3 of "Knowticed Plus — Notification & Validation").
/// Author: Amr Mesbah
/// Created at: 12/10/2026
///
/// Same shape as RoleManagementNotificationService: intent-named static
/// methods, no raw strings, everything delegated to AppNotificationSender, so
/// the Firestore template an admin edits in Notification Control still wins.
///
/// ─── REPLACES ────────────────────────────────────────────────────────
/// The form builder used to call `NotificationControllerCubit().sendNotification`
/// with hard-coded English/Arabic strings and `type: "formBuilder"` — text that
/// matched nothing in the spec and could not be edited from Notification
/// Control. Every one of those call sites now goes through here.
///
/// ─── CALL SITES ──────────────────────────────────────────────────────
///   HomeCubit.addFormPrivacyAccess        → [notifyAccessListChanged]
///                                    (Form Assigned / Deadline Updated /
///                                     Edit Permission Enabled)
///   HomeCubit.editFormModel /
///   updateExistingForm             → [notifyFormContentUpdated]
///   ShareCubit.grantAccess         → [notifyFormShared]
///   ResultCubit.remindClicked      → [notifyReminder]
///   SendResponseUseCase.execute    → [notifyResponse]
///                                    (Submission Received / Resubmitted /
///                                     All Responses Received)
///   FormsGroupCubit                → [notifyAddedToGroup],
///                                    [notifyRemovedFromGroup],
///                                    [notifyGroupRenamed]
///   FormBuilderNotificationScheduler → [notifyAccessEndsIn14Days],
///                                      [notifyAccessEnded]
///
/// ─── FAILURE POLICY ──────────────────────────────────────────────────
/// Fire-and-forget from the caller's point of view: every method swallows and
/// logs its own errors and returns how many notifications went out. A failed
/// notification must never fail the save that triggered it.
///
/// ─── LANGUAGE ────────────────────────────────────────────────────────
/// Names (form, employee, group) are passed in both languages: `variables`
/// fills the English template and `variablesAr` overrides it for the Arabic
/// one, so each recipient reads the form's own Arabic title.
library;

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_access_row.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder/data/models/users_model.dart';
import 'package:knowticed_plus/features/notification/domain/enums/form_builder/form_builder_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/form_builder/form_builder_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_event.dart';
import 'package:knowticed_plus/features/notification/helpers/services/app_notification_sender.dart';

/// Shape of `AppNotificationSender.sendEvent`, minus the push switch.
typedef FbSendEvent = Future<bool> Function({
  required NotificationEvent event,
  required String pageKey,
  required String senderEmail,
  required String receiverEmail,
  required bool isArabic,
  Map<TemplateVariable, String> variables,
  Map<TemplateVariable, String> variablesAr,
  bool isPinned,
  String requestId,
});

class FormBuilderNotificationService {
  FormBuilderNotificationService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The dispatcher [_send] goes through. Tests swap it for a recorder to
  /// check what was sent (page, recipient, `requestId`).
  @visibleForTesting
  static FbSendEvent sendEvent = AppNotificationSender.sendEvent;

  // ═══════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════

  static bool get _isArabic => Get.locale?.languageCode == 'ar';

  static MainCoreEmployeeController? get _employees =>
      Get.isRegistered<MainCoreEmployeeController>()
          ? Get.find<MainCoreEmployeeController>()
          : null;

  /// The signed-in user — the actor of every event raised from the UI.
  static String get currentUserEmail =>
      _employees?.employeeEntity?.email?.trim() ?? '';

  /// Display name of [email] in one language, falling back to the email so a
  /// template never renders an empty `{{employeeName}}`.
  static String _name(String email, {required bool english}) {
    final String name =
        _employees?.getEmployeeNameEnglishArabic(email, english).trim() ?? '';
    return name.isEmpty ? email : name;
  }

  /// Dates are rendered DD/MM/YYYY, the format the spec's validation section
  /// uses, with Latin digits in both languages.
  static String formatDate(DateTime? date) =>
      date == null ? '' : DateFormat('dd/MM/yyyy', 'en').format(date);

  /// The form's Arabic title, or the English one when it has none.
  static String _ar(String nameEn, String? nameAr) =>
      (nameAr == null || nameAr.trim().isEmpty) ? nameEn : nameAr;

  /// Single funnel every event goes through.
  ///
  /// [recordId] is stored as the notification's `Request_Id`: the form's id,
  /// so View opens that form. Group events pass '' — see [notifyAddedToGroup].
  ///
  /// [excludeSender] drops the actor from the recipients — telling someone
  /// what they just did is noise. The time-driven sweep turns it off: there the
  /// "sender" is only whoever happened to open the module, and may well be the
  /// recipient.
  static Future<int> _send(
    FormBuilderNotificationEvent event, {
    required FormBuilderNotificationPage page,
    required Iterable<String> to,
    required String recordId,
    required Map<TemplateVariable, String> variables,
    Map<TemplateVariable, String> variablesAr = const {},
    String? senderEmail,
    bool excludeSender = true,
  }) async {
    try {
      final String sender = (senderEmail ?? currentUserEmail).trim();
      final Set<String> recipients = <String>{
        for (final String email in to)
          if (email.trim().isNotEmpty &&
              !(excludeSender &&
                  email.trim().toLowerCase() == sender.toLowerCase()))
            email.trim(),
      };
      if (recipients.isEmpty) return 0;

      // One send per recipient rather than `sendEventToAll`, which has no
      // `requestId`: every copy carries [recordId] so its View opens the
      // form (owner, 22/10/2026).
      final List<bool> results = await Future.wait(
        recipients.map(
          (String email) => sendEvent(
            event: event,
            pageKey: page.key,
            senderEmail: sender,
            receiverEmail: email,
            isArabic: _isArabic,
            variables: variables,
            variablesAr: variablesAr,
            requestId: recordId,
          ),
        ),
      );
      return results.where((bool ok) => ok).length;
    } catch (e) {
      log('⚠️ ${event.key} failed: $e', name: 'FormBuilderNotifications');
      return 0;
    }
  }

  /// The form's current privacy document, or null when it has none yet.
  static Future<UsersModel?> readAccessList(String formId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection(getBaseUrl(FormApiConstants.formPrivacy))
          .doc(formId)
          .get();
      final Map<String, dynamic>? data = doc.data();
      if (data == null) return null;
      return FormPrivacyModel.fromMap(data).usersModel;
    } catch (e) {
      log('⚠️ readAccessList($formId) failed: $e',
          name: 'FormBuilderNotifications');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Access list: Form Assigned / Deadline Updated / Edit Enabled
  //
  // Trigger: the owner publishes a form, or re-publishes it with a changed
  // access list (HomeCubit.addFormPrivacyAccess). [before] is the privacy document
  // as it was BEFORE the save — null for a first publish.
  //
  //   * a recipient who was not on [before]          → Form Assigned
  //   * a recipient whose Access End moved           → Form Deadline Updated
  //   * a recipient whose Edit Permission turned on  → Response Editing Enabled
  // ═══════════════════════════════════════════════════════════
  static Future<int> notifyAccessListChanged({
    required String formId,
    required UsersModel? before,
    required UsersModel? after,
    required String formNameEn,
    String? formNameAr,
  }) async {
    final Map<String, FormAccessRow> old = FormAccessRow.mapFrom(before);
    final List<FormAccessRow> now = FormAccessRow.activeFrom(after);
    final String owner = currentUserEmail;

    // Recipients that share a value are sent as one batch.
    final Map<String, List<String>> assignedByEnd = <String, List<String>>{};
    final Map<String, List<String>> movedByDates = <String, List<String>>{};
    final Map<String, List<String>> editByEnd = <String, List<String>>{};

    for (final FormAccessRow row in now) {
      final FormAccessRow? previous = old[row.email.toLowerCase()];
      final String end = formatDate(row.accessEnd);

      if (previous == null || !previous.isActive) {
        assignedByEnd.putIfAbsent(end, () => <String>[]).add(row.email);
        continue;
      }

      final String previousEnd = formatDate(previous.accessEnd);
      if (previousEnd != end && end.isNotEmpty) {
        movedByDates
            .putIfAbsent('$previousEnd|$end', () => <String>[])
            .add(row.email);
      }
      if (!previous.editPermission && row.editPermission) {
        editByEnd.putIfAbsent(end, () => <String>[]).add(row.email);
      }
    }

    final String ar = _ar(formNameEn, formNameAr);
    int sent = 0;

    for (final MapEntry<String, List<String>> e in assignedByEnd.entries) {
      sent += await _send(
        FormBuilderNotificationEvent.formAssigned,
        recordId: formId,
        page: FormBuilderNotificationPage.formDetailsScreen,
        to: e.value,
        variables: {
          TemplateVariable.employeeName: _name(owner, english: true),
          TemplateVariable.formName: formNameEn,
          TemplateVariable.accessEndDate: e.key,
        },
        variablesAr: {
          TemplateVariable.employeeName: _name(owner, english: false),
          TemplateVariable.formName: ar,
        },
      );
    }

    for (final MapEntry<String, List<String>> e in movedByDates.entries) {
      final List<String> dates = e.key.split('|');
      sent += await _send(
        FormBuilderNotificationEvent.endDateUpdated,
        recordId: formId,
        page: FormBuilderNotificationPage.formDetailsScreen,
        to: e.value,
        variables: {
          TemplateVariable.formName: formNameEn,
          TemplateVariable.previousAccessEndDate: dates.first,
          TemplateVariable.newAccessEndDate: dates.last,
        },
        variablesAr: {TemplateVariable.formName: ar},
      );
    }

    for (final MapEntry<String, List<String>> e in editByEnd.entries) {
      sent += await _send(
        FormBuilderNotificationEvent.editPermissionEnabled,
        recordId: formId,
        page: FormBuilderNotificationPage.formDetailsScreen,
        to: e.value,
        variables: {
          TemplateVariable.formName: formNameEn,
          TemplateVariable.accessEndDate: e.key,
        },
        variablesAr: {TemplateVariable.formName: ar},
      );
    }
    return sent;
  }

  // ═══════════════════════════════════════════════════════════
  // Form Shared With You
  //
  // Trigger: the owner adds people to an existing form from the Share screen.
  // ═══════════════════════════════════════════════════════════
  static Future<int> notifyFormShared({
    required String formId,
    required Iterable<String> recipients,
    required String formNameEn,
    String? formNameAr,
    required DateTime? accessEnd,
  }) {
    final String owner = currentUserEmail;
    return _send(
      FormBuilderNotificationEvent.formShared,
      recordId: formId,
      page: FormBuilderNotificationPage.formDetailsScreen,
      to: recipients,
      variables: {
        TemplateVariable.ownerName: _name(owner, english: true),
        TemplateVariable.formName: formNameEn,
        TemplateVariable.accessEndDate: formatDate(accessEnd),
      },
      variablesAr: {
        TemplateVariable.ownerName: _name(owner, english: false),
        TemplateVariable.formName: _ar(formNameEn, formNameAr),
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Form Updated
  //
  // Trigger: the owner saves changes to a published form's content. Goes to
  // every recipient who currently holds access.
  // ═══════════════════════════════════════════════════════════
  static Future<int> notifyFormContentUpdated({
    required String formId,
    required String formNameEn,
    String? formNameAr,
  }) async {
    final List<FormAccessRow> rows =
        FormAccessRow.activeFrom(await readAccessList(formId));
    if (rows.isEmpty) return 0;
    final String owner = currentUserEmail;
    return _send(
      FormBuilderNotificationEvent.formContentUpdated,
      recordId: formId,
      page: FormBuilderNotificationPage.formDetailsScreen,
      to: rows.map((FormAccessRow r) => r.email),
      variables: {
        TemplateVariable.formName: formNameEn,
        TemplateVariable.ownerName: _name(owner, english: true),
      },
      variablesAr: {
        TemplateVariable.formName: _ar(formNameEn, formNameAr),
        TemplateVariable.ownerName: _name(owner, english: false),
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Form Submission Reminder
  //
  // Trigger: the owner presses "Send Reminder" on the Results → Pending tab.
  // The recipient's own Access End is read from the privacy document so the
  // template's "before {{accessEndDate}}" is that person's deadline.
  // ═══════════════════════════════════════════════════════════
  static Future<int> notifyReminder({
    required String formId,
    required String recipientEmail,
    required String formNameEn,
    String? formNameAr,
  }) async {
    final FormAccessRow? row = FormAccessRow.mapFrom(
        await readAccessList(formId))[recipientEmail.trim().toLowerCase()];
    return _send(
      FormBuilderNotificationEvent.reminderSent,
      recordId: formId,
      page: FormBuilderNotificationPage.formDetailsScreen,
      to: <String>[recipientEmail],
      variables: {
        TemplateVariable.formName: formNameEn,
        TemplateVariable.accessEndDate: formatDate(row?.accessEnd),
      },
      variablesAr: {TemplateVariable.formName: _ar(formNameEn, formNameAr)},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Responses: Submission Received / Response Resubmitted /
  //            All Responses Received
  //
  // Trigger: a recipient submits (or re-submits) a response. All three go to
  // the form OWNER. "All Responses Received" is checked only on a first
  // submission — a re-submission cannot complete a form that was not already
  // complete — and fires once every active recipient has a response.
  // ═══════════════════════════════════════════════════════════
  static Future<int> notifyResponse({
    required String formId,
    required String ownerEmail,
    required String formNameEn,
    String? formNameAr,
    required bool isResubmission,
  }) async {
    final String submitter = currentUserEmail;
    final String ar = _ar(formNameEn, formNameAr);
    final String submitterEn = _name(submitter, english: true);
    final String submitterAr = _name(submitter, english: false);

    if (isResubmission) {
      return _send(
        FormBuilderNotificationEvent.responseResubmitted,
        recordId: formId,
        page: FormBuilderNotificationPage.resultScreen,
        to: <String>[ownerEmail],
        variables: {
          TemplateVariable.employeeName: submitterEn,
          TemplateVariable.formName: formNameEn,
        },
        variablesAr: {
          TemplateVariable.employeeName: submitterAr,
          TemplateVariable.formName: ar,
        },
      );
    }

    int sent = await _send(
      FormBuilderNotificationEvent.submissionReceived,
      recordId: formId,
      page: FormBuilderNotificationPage.resultScreen,
      to: <String>[ownerEmail],
      variables: {
        TemplateVariable.employeeName: submitterEn,
        TemplateVariable.formName: formNameEn,
        TemplateVariable.submissionDate: formatDate(DateTime.now()),
      },
      variablesAr: {
        TemplateVariable.employeeName: submitterAr,
        TemplateVariable.formName: ar,
      },
    );

    if (await _allRecipientsSubmitted(formId, ownerEmail)) {
      sent += await _send(
        FormBuilderNotificationEvent.allSubmissionsCompleted,
        recordId: formId,
        page: FormBuilderNotificationPage.resultScreen,
        to: <String>[ownerEmail],
        variables: {TemplateVariable.formName: formNameEn},
        variablesAr: {TemplateVariable.formName: ar},
      );
    }
    return sent;
  }

  /// Every active recipient (the owner excluded) has a submitted response.
  ///
  /// A response document can exist WITHOUT a submission: "Send Reminder"
  /// creates one with an empty `Timestamps` list just to record the reminder
  /// (ResultRepository.remindUser). Only a non-empty `Timestamps` counts.
  static Future<bool> _allRecipientsSubmitted(
      String formId, String ownerEmail) async {
    try {
      final Set<String> expected =
          FormAccessRow.activeFrom(await readAccessList(formId))
              .map((FormAccessRow r) => r.email.toLowerCase())
              .where((String e) => e != ownerEmail.trim().toLowerCase())
              .toSet();
      if (expected.isEmpty) return false;

      final QuerySnapshot<Map<String, dynamic>> responses = await _firestore
          .collection(getBaseUrl(
              '${FormApiConstants.formResponses}/$formId/${FormApiConstants.responses}'))
          .get();
      final Set<String> submitted = <String>{
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
            in responses.docs)
          if ((doc.data()['Timestamps'] as List?)?.isNotEmpty ?? false)
            doc.id.toLowerCase(),
      };
      return submitted.containsAll(expected);
    } catch (e) {
      log('⚠️ all-submitted check failed for $formId: $e',
          name: 'FormBuilderNotifications');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Groups: Added / Removed / Renamed
  //
  // Trigger: the owner creates a group (everyone in it is "added"), removes
  // members while editing it, or renames it. Members are emails.
  //
  // No record id: a group lives under its OWNER (`formGroups/<owner>/groups`)
  // and `GroupScreen` is the owner's picker inside Share — a member has no
  // page that shows a group, so View opens the Form Builder home.
  // ═══════════════════════════════════════════════════════════
  static Future<int> notifyAddedToGroup({
    required Iterable<String> members,
    required String groupName,
  }) {
    final String owner = currentUserEmail;
    return _send(
      FormBuilderNotificationEvent.addedToGroup,
      recordId: '',
      page: FormBuilderNotificationPage.groupScreen,
      to: members,
      variables: {
        TemplateVariable.groupName: groupName,
        TemplateVariable.ownerName: _name(owner, english: true),
      },
      variablesAr: {TemplateVariable.ownerName: _name(owner, english: false)},
    );
  }

  static Future<int> notifyRemovedFromGroup({
    required Iterable<String> members,
    required String groupName,
  }) {
    final String owner = currentUserEmail;
    return _send(
      FormBuilderNotificationEvent.removedFromGroup,
      recordId: '',
      page: FormBuilderNotificationPage.groupScreen,
      to: members,
      variables: {
        TemplateVariable.groupName: groupName,
        TemplateVariable.ownerName: _name(owner, english: true),
      },
      variablesAr: {TemplateVariable.ownerName: _name(owner, english: false)},
    );
  }

  static Future<int> notifyGroupRenamed({
    required Iterable<String> members,
    required String oldGroupName,
    required String newGroupName,
  }) {
    final String owner = currentUserEmail;
    return _send(
      FormBuilderNotificationEvent.groupNameUpdated,
      recordId: '',
      page: FormBuilderNotificationPage.groupScreen,
      to: members,
      variables: {
        TemplateVariable.oldGroupName: oldGroupName,
        TemplateVariable.newGroupName: newGroupName,
        TemplateVariable.ownerName: _name(owner, english: true),
      },
      variablesAr: {TemplateVariable.ownerName: _name(owner, english: false)},
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Time-driven: Access Ends in 14 Days / Access Has Ended
  //
  // Raised only by FormBuilderNotificationScheduler, which also makes sure
  // each one goes out once. [senderEmail] is whoever's session ran the sweep.
  // ═══════════════════════════════════════════════════════════
  static Future<int> notifyAccessEndsIn14Days({
    required String formId,
    required String recipientEmail,
    required String senderEmail,
    required String formNameEn,
    String? formNameAr,
    required DateTime accessEnd,
  }) {
    return _send(
      FormBuilderNotificationEvent.accessEndsIn14Days,
      recordId: formId,
      page: FormBuilderNotificationPage.formDetailsScreen,
      to: <String>[recipientEmail],
      senderEmail: senderEmail,
      excludeSender: false,
      variables: {
        TemplateVariable.formName: formNameEn,
        TemplateVariable.accessEndDate: formatDate(accessEnd),
      },
      variablesAr: {TemplateVariable.formName: _ar(formNameEn, formNameAr)},
    );
  }

  static Future<int> notifyAccessEnded({
    required String formId,
    required String recipientEmail,
    required String senderEmail,
    required String formNameEn,
    String? formNameAr,
  }) {
    return _send(
      FormBuilderNotificationEvent.accessEnded,
      recordId: formId,
      page: FormBuilderNotificationPage.homeScreen,
      to: <String>[recipientEmail],
      senderEmail: senderEmail,
      excludeSender: false,
      variables: {TemplateVariable.formName: formNameEn},
      variablesAr: {TemplateVariable.formName: _ar(formNameEn, formNameAr)},
    );
  }
}
