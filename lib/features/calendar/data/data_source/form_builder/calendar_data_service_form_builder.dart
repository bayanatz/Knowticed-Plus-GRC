// [module-file:form_builder] — deleted when the form_builder module is split out
/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service_form_builder.dart
/// Description: Form Builder calendar entries for the signed-in recipient —
///          the Form Builder rows of section 2 of "Knowticed Plus —
///          Notification & Validation".
/// Author: Amr Mesbah
/// Created at: 12/10/2026

part of '../calendar_data_service.dart';

extension CalendarDataServiceFormBuilder on CalendarDataService {
  /// Function Name: [getFormBuilderCalendarEvents]
  ///
  /// Purpose: Every Form Builder calendar entry for [currentUserEmail] as a
  /// RECIPIENT of a form. Title, description, status and colour all come
  /// from [FormBuilderCalendarEvent]; nothing here passes a literal for them.
  ///
  /// Source documents, per form the user can access:
  ///   * `Form Privacy/<formId>`                 — the user's row: access
  ///     begin / end and whether they were added from the Share screen.
  ///   * `Forms/<formId>`                        — title, and whether deleted.
  ///   * `Form Responses/<formId>/Responses/<email>` — submitted or not, and
  ///     the reminders the owner sent.
  ///
  /// Entries (see the enum for the spec's scheduling notes):
  ///   * Form Assigned / Form Shared   — on Access Begin.
  ///   * Form Access Ending Soon       — 14 days before Access End, only while
  ///     the end is still ahead AND the user has not submitted.
  ///   * Form Access Expired           — on Access End.
  ///   * Form Submission Reminder      — one per reminder the owner sent,
  ///     while the user has not submitted.
  Future<List<CalendarEventModel>> getFormBuilderCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];
    final String me = currentUserEmail.trim();
    if (me.isEmpty) return events;

    try {
      final bool isArabic = languageCode() == 'ar';
      final FirebaseFirestore db = FirebaseFirestore.instance;
      final DateTime now = DateTime.now();

      final QuerySnapshot<Map<String, dynamic>> privacyDocs = await db
          .collection(getBaseUrl(FormApiConstants.formPrivacy))
          .where(
            '${FormPrivacyModel.fieldUid}.${UsersModel.kEmailsfeild}',
            arrayContains: me,
          )
          .get();

      for (final QueryDocumentSnapshot<Map<String, dynamic>> privacyDoc
          in privacyDocs.docs) {
        try {
          final String formId = privacyDoc.id;
          final FormAccessRow? row = FormAccessRow.mapFrom(
            FormPrivacyModel.fromMap(privacyDoc.data()).usersModel,
          )[me.toLowerCase()];
          if (row == null || !row.isActive) continue;

          // ── The form itself ───────────────────────────────────────────
          final Map<String, dynamic>? form = (await db
                  .collection(getBaseUrl(FormApiConstants.forms))
                  .doc(formId)
                  .get())
              .data();
          if (form == null) continue;
          final List<String> statuses = CalendarDataService._historyList(
            form['Form_Status'],
          );
          if (statuses.isNotEmpty && statuses.last.toLowerCase() == 'deleted') {
            continue;
          }
          final List<String> titlesEn = CalendarDataService._historyList(
            form['English_Title'],
          );
          final List<String> titlesAr = CalendarDataService._historyList(
            form['Arabic_Title'],
          );
          final String nameEn = titlesEn.isNotEmpty ? titlesEn.last : formId;
          final String nameAr =
              (titlesAr.isNotEmpty && titlesAr.last.isNotEmpty)
                  ? titlesAr.last
                  : nameEn;
          final String formName = isArabic ? nameAr : nameEn;

          // ── My response: submitted? reminders? ────────────────────────
          final Map<String, dynamic>? response = (await db
                  .collection(
                    getBaseUrl(
                      '${FormApiConstants.formResponses}/$formId/${FormApiConstants.responses}',
                    ),
                  )
                  .doc(me)
                  .get())
              .data();
          final bool submitted =
              (response?['Timestamps'] as List?)?.isNotEmpty ?? false;
          final List<DateTime> reminders = <DateTime>[
            for (final dynamic r
                in (response?['Reminder'] as List?) ?? const <dynamic>[])
              if (r is Timestamp) r.toDate(),
          ];

          final DateTime? begin = row.accessBegin;
          final DateTime? end = row.accessEnd;
          final Map<TemplateVariable, String> variables =
              <TemplateVariable, String>{
            TemplateVariable.formName: formName,
            TemplateVariable.accessEndDate:
                end == null ? '' : DateFormat('dd/MM/yyyy', 'en').format(end),
          };

          void add(FormBuilderCalendarEvent type, DateTime source) {
            events.add(
              CalendarEventModel.fromType(
                type,
                sourceDate: source,
                isArabic: isArabic,
                taskName: formName,
                time: DateFormat('hh:mm a').format(source),
                userEmail: me,
                requestId: formId,
                variables: variables,
              ),
            );
          }

          if (begin != null) {
            add(
              row.isShared
                  ? FormBuilderCalendarEvent.formShared
                  : FormBuilderCalendarEvent.formAssigned,
              begin,
            );
          }

          if (end != null) {
            if (!submitted && end.isAfter(now)) {
              add(FormBuilderCalendarEvent.accessEndingSoon, end);
            }
            add(FormBuilderCalendarEvent.accessExpired, end);
          }

          if (!submitted) {
            for (final DateTime reminder in reminders) {
              add(FormBuilderCalendarEvent.submissionReminder, reminder);
            }
          }
        } catch (e) {
          // One bad form must not take the rest of the user's forms down.
          debugPrint('[calendar/form_builder] skipped ${privacyDoc.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('[calendar/form_builder] failed: $e');
    }
    return events;
  }
}
