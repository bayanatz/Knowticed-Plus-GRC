// [module-file:form_builder] — deleted when the form_builder module is split out
/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_notification_scheduler.dart
/// Description: Client-side sweep that raises the two time-driven Form Builder
///          notifications: "Form Access Ends in 14 Days" and "Form Access Has
///          Ended".
/// Author: Amr Mesbah
/// Created at: 12/10/2026
///
/// ─── WHY A SWEEP ─────────────────────────────────────────────────────
/// The app has no server-side cron, so nothing fires "on" a date. Same answer
/// the Knowledge Hub uses (KnowledgeHubNotificationScheduler): whenever anyone
/// opens the Form Builder module, scan every form's access list once and raise
/// whatever has fallen due since the last scan. Run from
/// `FormResponsivePageLayout.initState`, not awaited.
///
/// ─── ONCE EACH ───────────────────────────────────────────────────────
/// Every raised notification first claims a marker document in
/// `Modules/form_builder/Notification_Log`, keyed
/// `<formId>__<email>__<eventKey>__<accessEndMillis>`. The access end date is
/// part of the key on purpose: if the owner moves the deadline, the new date
/// is a new warning. If the log cannot be written, nothing is sent — a sweep
/// that cannot remember would re-send everything on every module open.
///
/// ─── RULES ───────────────────────────────────────────────────────────
///   * 14 days before   — access end is 1..14 days away, the recipient is
///                        active and has NOT submitted.
///   * Access ended     — access end has passed, the recipient is active. Only
///                        for ends within the last [endedLookBackDays] days, so
///                        the first sweep after deploying does not notify for
///                        every form that closed months ago.
///   * Deleted forms are skipped.
library;

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_access_row.dart';
import 'package:knowticed_plus/features/form_builder/data/models/form_privacy_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/form_builder_notification_service.dart';
import 'package:knowticed_plus/features/notification/domain/enums/form_builder/form_builder_events.dart';

class FormBuilderNotificationScheduler {
  FormBuilderNotificationScheduler._();

  /// "Form Access Ends in 14 Days".
  static const int warningDays = 14;

  /// How far back an already-passed end date still earns an "ended" notice.
  static const int endedLookBackDays = 14;

  /// One sweep per app session — the module page rebuilds often.
  static bool _sweptThisSession = false;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Run the sweep. Returns how many notifications went out.
  ///
  /// [actingUserEmail] is stored as the sender: these are system-raised, so it
  /// is only "whose session checked the clock", never the cause.
  static Future<int> sweep({
    required String actingUserEmail,
    bool force = false,
  }) async {
    if (actingUserEmail.trim().isEmpty) return 0;
    if (_sweptThisSession && !force) return 0;
    _sweptThisSession = true;

    int sent = 0;
    try {
      final QuerySnapshot<Map<String, dynamic>> privacy = await _firestore
          .collection(getBaseUrl(FormApiConstants.formPrivacy))
          .get()
          .timeout(const Duration(seconds: 20));

      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in privacy.docs) {
        try {
          final String formId = doc.id;
          final List<FormAccessRow> rows = FormAccessRow.activeFrom(
              FormPrivacyModel.fromMap(doc.data()).usersModel);

          // Only rows whose end date is inside one of the two windows.
          final List<FormAccessRow> due = rows.where((FormAccessRow r) {
            final DateTime? end = r.accessEnd;
            if (end == null) return false;
            final int days = _dayOf(end).difference(today).inDays;
            return (days > 0 && days <= warningDays) ||
                (!end.isAfter(now) && days >= -endedLookBackDays);
          }).toList();
          if (due.isEmpty) continue;

          final _FormName? name = await _formName(formId);
          if (name == null) continue; // missing or deleted

          for (final FormAccessRow row in due) {
            final DateTime end = row.accessEnd!;
            if (end.isAfter(now)) {
              if (await _hasSubmitted(formId, row.email)) continue;
              if (!await _claim(formId, row.email,
                  FormBuilderNotificationEvent.accessEndsIn14Days, end)) {
                continue;
              }
              sent +=
                  await FormBuilderNotificationService.notifyAccessEndsIn14Days(
                formId: formId,
                recipientEmail: row.email,
                senderEmail: actingUserEmail,
                formNameEn: name.en,
                formNameAr: name.ar,
                accessEnd: end,
              );
            } else {
              if (!await _claim(formId, row.email,
                  FormBuilderNotificationEvent.accessEnded, end)) {
                continue;
              }
              sent += await FormBuilderNotificationService.notifyAccessEnded(
                formId: formId,
                recipientEmail: row.email,
                senderEmail: actingUserEmail,
                formNameEn: name.en,
                formNameAr: name.ar,
              );
            }
          }
        } catch (e) {
          log('[fb-sweep] skipped ${doc.id}: $e');
        }
      }
    } catch (e) {
      // Not an error the user sees — the next module open tries again.
      log('[fb-sweep] failed: $e');
      _sweptThisSession = false;
    }
    return sent;
  }

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// English / Arabic title of a live form; null when it is gone or deleted.
  static Future<_FormName?> _formName(String formId) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
        .collection(getBaseUrl(FormApiConstants.forms))
        .doc(formId)
        .get();
    final Map<String, dynamic>? data = doc.data();
    if (data == null) return null;
    final String status = _last(data['Form_Status']).toLowerCase();
    if (status == 'deleted') return null;
    final String en = _last(data['English_Title']);
    return _FormName(en.isEmpty ? formId : en, _last(data['Arabic_Title']));
  }

  /// The recipient has a response with at least one submission timestamp.
  /// (A reminder alone creates a response document with none.)
  static Future<bool> _hasSubmitted(String formId, String email) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection(getBaseUrl(
              '${FormApiConstants.formResponses}/$formId/${FormApiConstants.responses}'))
          .doc(email)
          .get();
      return (doc.data()?['Timestamps'] as List?)?.isNotEmpty ?? false;
    } catch (_) {
      // Unknown — err on the side of not warning.
      return true;
    }
  }

  static Future<bool> _claim(
    String formId,
    String email,
    FormBuilderNotificationEvent event,
    DateTime due,
  ) async {
    try {
      final DocumentReference<Map<String, dynamic>> ref = _firestore
          .collection(getBaseUrl(FormApiConstants.notificationLog))
          .doc('${formId}__${email.toLowerCase()}__${event.key}__'
              '${due.millisecondsSinceEpoch}');
      if ((await ref.get()).exists) return false;
      await ref.set(<String, dynamic>{
        'formId': formId,
        'email': email,
        'eventKey': event.key,
        'dueMillis': due.millisecondsSinceEpoch,
        'raisedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('[fb-sweep] claim failed for $formId/$email/${event.key}: $e');
      return false;
    }
  }

  static String _last(dynamic value) =>
      (value is List && value.isNotEmpty) ? '${value.last ?? ''}'.trim() : '';
}

class _FormName {
  const _FormName(this.en, this.ar);
  final String en;
  final String ar;
}
