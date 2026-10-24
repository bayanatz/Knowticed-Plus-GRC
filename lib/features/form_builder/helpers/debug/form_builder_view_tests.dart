/// Module: form_builder_module / helpers/debug/form_builder_view_tests.dart
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_view_tests.dart
/// Description: DEBUG ONLY — sends the signed-in user one Form Builder
///          notification per View landing, each about a REAL form or group,
///          so "View opens the record" can be checked on a device.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Reads forms, access lists, responses and groups; writes nothing but
/// notification documents. Goes through `AppNotificationSender.sendEvent`,
/// exactly as `FormBuilderNotificationService` does (same template,
/// `name_of_page`, and `Request_Id` = the form id; none for a group).
///
///   Submission Received     → ResultScreen      my published form → Results
///   Form Updated            → FormDetailsScreen my published form → details
///   Reminder                → FormDetailsScreen a form sent to me, not yet
///                                               answered → the form to fill
///   Response Editing Enabled→ FormDetailsScreen a form I answered → my
///                                               response (Submissions tab)
///   Added to Group          → GroupScreen       no id → Form Builder home
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_access_row.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/models/form_model.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/data/models/forms_group_model.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/features/notification/data/repository/form_builder_notification_service.dart';
import 'package:knowticed_plus/features/notification/domain/enums/form_builder/form_builder_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/form_builder/form_builder_notification_pages.dart';
import 'package:knowticed_plus/features/notification/helpers/services/app_notification_sender.dart';

/// Sends up to five test notifications to [receiverEmail]; returns how many
/// went out. Never throws.
Future<int> sendFormBuilderViewTests({
  required String receiverEmail,
  required bool isArabic,
}) async {
  if (!kDebugMode) return 0;
  final String me = receiverEmail.trim();
  if (me.isEmpty) return 0;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  int sent = 0;
  try {
    // ── My own published form: Results, and its details ───────────────────
    final QuerySnapshot<Map<String, dynamic>> own = await db
        .collection(getBaseUrl(FormApiConstants.forms))
        .where(FormModel.fieldCreatedByEmail, isEqualTo: me)
        .get();
    final QueryDocumentSnapshot<Map<String, dynamic>>? published = own.docs
        .where((d) =>
            _lastOf(d.data()[FormModel.fieldFormStatus]).toLowerCase() ==
            'publish')
        .firstOrNull;
    sent += await _sendOne(
      kind: 'results',
      formId: published?.id,
      form: published?.data(),
      event: FormBuilderNotificationEvent.submissionReceived,
      page: FormBuilderNotificationPage.resultScreen,
      receiverEmail: me,
      isArabic: isArabic,
    );
    sent += await _sendOne(
      kind: 'own details',
      formId: published?.id,
      form: published?.data(),
      event: FormBuilderNotificationEvent.formContentUpdated,
      page: FormBuilderNotificationPage.formDetailsScreen,
      receiverEmail: me,
      isArabic: isArabic,
    );

    // ── Forms sent to me: one still to fill, one already answered ─────────
    final QuerySnapshot<Map<String, dynamic>> privacy = await db
        .collection(getBaseUrl(FormApiConstants.formPrivacy))
        .limit(300)
        .get();
    String? toFill;
    String? answered;
    final DateTime now = DateTime.now();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> p in privacy.docs) {
      if (toFill != null && answered != null) break;
      final FormAccessRow? row = FormAccessRow.mapFrom(
          FormPrivacyModel.fromMap(p.data()).usersModel)[me.toLowerCase()];
      if (row == null || !row.isActive) continue;
      if (published != null && p.id == published.id) continue;
      final bool hasAnswered = await _hasSubmitted(db, p.id, me);
      if (hasAnswered) {
        answered ??= p.id;
      } else if ((row.accessBegin == null || !row.accessBegin!.isAfter(now)) &&
          (row.accessEnd == null || row.accessEnd!.isAfter(now))) {
        toFill ??= p.id;
      }
    }
    sent += await _sendOne(
      kind: 'fill',
      formId: toFill,
      form: await _form(db, toFill),
      event: FormBuilderNotificationEvent.reminderSent,
      page: FormBuilderNotificationPage.formDetailsScreen,
      receiverEmail: me,
      isArabic: isArabic,
    );
    sent += await _sendOne(
      kind: 'my response',
      formId: answered,
      form: await _form(db, answered),
      event: FormBuilderNotificationEvent.editPermissionEnabled,
      page: FormBuilderNotificationPage.formDetailsScreen,
      receiverEmail: me,
      isArabic: isArabic,
    );

    // ── A group of mine: no record id, lands on the home ──────────────────
    final QuerySnapshot<Map<String, dynamic>> groups = await db
        .collection(getBaseUrl(
            '${FormApiConstants.formGroups}/$me/${FormApiConstants.groups}'))
        .limit(1)
        .get();
    final String? groupName = groups.docs.isEmpty
        ? null
        : _lastOf(groups.docs.first.data()[FormsGroupModel.fieldName]);
    if (groupName == null || groupName.isEmpty) {
      debugPrint('[fb-view-test] group: skipped — $me has no groups');
    } else {
      sent += await _send(
        kind: 'group',
        event: FormBuilderNotificationEvent.addedToGroup,
        page: FormBuilderNotificationPage.groupScreen,
        receiverEmail: me,
        isArabic: isArabic,
        names: <TemplateVariable, String>{
          TemplateVariable.groupName: groupName
        },
        requestId: '',
      );
    }
  } catch (e) {
    debugPrint('[fb-view-test] failed: $e');
  }
  return sent;
}

String _lastOf(Object? value) =>
    value is List && value.isNotEmpty ? '${value.last}' : '${value ?? ''}';

Future<Map<String, dynamic>?> _form(FirebaseFirestore db, String? id) async {
  if (id == null) return null;
  final DocumentSnapshot<Map<String, dynamic>> doc =
      await db.collection(getBaseUrl(FormApiConstants.forms)).doc(id).get();
  return doc.data();
}

/// A response with a non-empty `Timestamps` — "Send Reminder" creates empty
/// ones (see `FormBuilderNotificationService._allRecipientsSubmitted`).
Future<bool> _hasSubmitted(
    FirebaseFirestore db, String formId, String email) async {
  try {
    final DocumentSnapshot<Map<String, dynamic>> doc = await db
        .collection(getBaseUrl(
            '${FormApiConstants.formResponses}/$formId/${FormApiConstants.responses}'))
        .doc(email)
        .get();
    return (doc.data()?['Timestamps'] as List?)?.isNotEmpty ?? false;
  } catch (_) {
    return false;
  }
}

Future<int> _sendOne({
  required String kind,
  required String? formId,
  required Map<String, dynamic>? form,
  required FormBuilderNotificationEvent event,
  required FormBuilderNotificationPage page,
  required String receiverEmail,
  required bool isArabic,
}) {
  if (formId == null || form == null) {
    debugPrint('[fb-view-test] $kind: skipped — no suitable form');
    return Future<int>.value(0);
  }
  final String nameEn = _lastOf(form[FormModel.fieldEnglishTitle]);
  final String nameAr = _lastOf(form[FormModel.fieldArabicTitle]);
  return _send(
    kind: kind,
    event: event,
    page: page,
    receiverEmail: receiverEmail,
    isArabic: isArabic,
    names: <TemplateVariable, String>{TemplateVariable.formName: nameEn},
    namesAr: <TemplateVariable, String>{
      TemplateVariable.formName: nameAr.isEmpty ? nameEn : nameAr,
    },
    requestId: formId,
  );
}

Future<int> _send({
  required String kind,
  required FormBuilderNotificationEvent event,
  required FormBuilderNotificationPage page,
  required String receiverEmail,
  required bool isArabic,
  required Map<TemplateVariable, String> names,
  Map<TemplateVariable, String> namesAr = const {},
  required String requestId,
}) async {
  try {
    final String today =
        FormBuilderNotificationService.formatDate(DateTime.now());
    final bool ok = await AppNotificationSender.sendEvent(
      event: event,
      pageKey: page.key,
      senderEmail: receiverEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      // Every placeholder the event declares gets a value (sendEvent asserts
      // it); dates read as today, names as "Test".
      variables: <TemplateVariable, String>{
        for (final TemplateVariable v in event.variables)
          v: v.name.toLowerCase().contains('date') ? today : 'Test',
        ...names,
      },
      variablesAr: namesAr,
      requestId: requestId,
    );
    debugPrint('[fb-view-test] $kind → ${page.key} '
        '(${requestId.isEmpty ? 'no id' : requestId}): '
        '${ok ? 'sent' : 'NOT sent'}');
    return ok ? 1 : 0;
  } catch (e) {
    debugPrint('[fb-view-test] $kind failed: $e');
    return 0;
  }
}
