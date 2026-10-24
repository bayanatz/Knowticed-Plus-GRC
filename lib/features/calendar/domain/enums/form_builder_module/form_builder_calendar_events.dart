/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: form_builder_calendar_events.dart
/// Module:    Form Builder
/// Description: Every calendar entry the Form Builder module places on a
///          recipient's calendar, per the Form Builder rows of section 2 of
///          "Knowticed Plus — Notification & Validation".
/// Author: Amr Mesbah
/// Created at: 12/10/2026
///
/// ─── WHERE THE DATES COME FROM ───────────────────────────────────────
/// All five entries hang off the recipient's row in the form's privacy
/// document (`Form Privacy/<formId>` → `Users`), which stores parallel lists:
/// `Emails`, `Status`, `Access Begin`, `Access End`, `Edit Permission` and —
/// since 12/10/2026 — `Shared`.
///
///   * [formAssigned] / [formShared]  — source date = Access Begin, offset 0.
///     Which of the two applies is read from `Shared[i]`: the Share screen
///     (`ShareRepository.grantAccess`) writes `true`, publishing writes
///     nothing, so a missing flag means "assigned at publish".
///   * [accessEndingSoon]             — source date = Access End, offset -14.
///     Only for recipients who have not submitted, per the spec.
///   * [accessExpired]                — source date = Access End, offset 0.
///   * [submissionReminder]           — one entry per timestamp in the
///     recipient's response document `Reminder` list (what the owner's
///     "Send Reminder" button records), offset 0.
///
/// Aligned with `notification/domain/enums/form_builder_module/
/// form_builder_events.dart` so a calendar card and the notification that
/// accompanies it read the same.
///
/// ⚠️ STATUS CODES ARE ENGLISH AND MUST STAY MATCHED — only codes other
/// modules already use (`Milestone`, `Reminder`, `Expired`), so the calendar
/// screen's filter chips keep working in Arabic.
library;

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/calendar_event_type.dart';

enum FormBuilderCalendarEvent implements CalendarEventType {
  formAssigned(
    key: 'form_assigned',
    scope: 'Form Access',
    trigger: 'Form Assigned (Access Start Date)',
    titleEn: 'Form Assigned',
    titleAr: 'تم إسناد نموذج',
    descriptionEn:
        'Open "{{formName}}" and submit your answers by {{accessEndDate}}.',
    descriptionAr: 'افتح "{{formName}}" وأرسل إجاباتك قبل {{accessEndDate}}.',
    statusCode: 'Milestone',
    colorValue: 0xFF4BB609,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.formName, TemplateVariable.accessEndDate},
    schedulingNote:
        "Calendar entry is created when the form is assigned. The event appears on the employee's calendar on the access start date.",
  ),

  formShared(
    key: 'form_shared',
    scope: 'Form Access',
    trigger: 'Form Shared',
    titleEn: 'Form Shared',
    titleAr: 'تمت مشاركة نموذج',
    descriptionEn:
        '"{{formName}}" was shared with you. Open it and submit your answers by {{accessEndDate}}.',
    descriptionAr:
        'تمت مشاركة "{{formName}}" معك. افتحه وأرسل إجاباتك قبل {{accessEndDate}}.',
    statusCode: 'Milestone',
    colorValue: 0xFF4BB609,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.formName, TemplateVariable.accessEndDate},
    schedulingNote:
        "Calendar entry is created when an existing form is shared. Appears on the employee's calendar from the access start date.",
  ),

  accessEndingSoon(
    key: 'access_ending_soon',
    scope: 'Form Access',
    trigger: '14 Days Before Access End',
    titleEn: 'Form Closing Soon',
    titleAr: 'النموذج يُغلق قريباً',
    descriptionEn:
        'Your access ends on {{accessEndDate}}. Submit "{{formName}}" before then.',
    descriptionAr:
        'ينتهي وصولك في {{accessEndDate}}. أرسل "{{formName}}" قبل ذلك.',
    statusCode: 'Reminder',
    colorValue: 0xFF4BB609,
    // -14: placed two weeks BEFORE the access end date. The builder passes
    // the end date itself and fromType does the subtraction.
    reminderOffsetDays: -14,
    variables: {TemplateVariable.formName, TemplateVariable.accessEndDate},
    schedulingNote:
        'Reminder appears automatically 14 days before the access end date. Only for recipients who have not submitted the form.',
  ),

  accessExpired(
    key: 'access_expired',
    scope: 'Form Access',
    trigger: 'Access End Date Reached',
    titleEn: 'Form Closed',
    titleAr: 'النموذج مغلق',
    // Large-screen bug report p.6: the expired entry read "ends on <date>"
    // like the reminder; it now says the access HAS expired.
    descriptionEn:
        'Access to "{{formName}}" closes on this day. After that, ask the form owner if you still need it.',
    descriptionAr:
        'ينتهي الوصول إلى "{{formName}}" في هذا اليوم. بعد ذلك تواصل مع مالك النموذج إن كنت بحاجة إليه.',
    statusCode: 'Expired',
    colorValue: 0xFF4BB609,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.formName},
    schedulingNote:
        'Triggered automatically on the access end date. The calendar event changes to expired and can optionally disappear after a defined retention period.',
  ),

  submissionReminder(
    key: 'submission_reminder',
    scope: 'Reminders',
    trigger: 'Scheduled Reminder Date',
    titleEn: 'Form Reminder',
    titleAr: 'تذكير بالنموذج',
    descriptionEn:
        'The form owner sent you a reminder to complete "{{formName}}". Submit it before {{accessEndDate}}.',
    descriptionAr:
        'أرسل مالك النموذج تذكيراً بإكمال "{{formName}}". أرسله قبل {{accessEndDate}}.',
    statusCode: 'Reminder',
    colorValue: 0xFF4BB609,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.formName, TemplateVariable.accessEndDate},
    schedulingNote:
        'Appears according to the reminder schedule configured by the form owner. One event is generated for each scheduled reminder.',
  );

  const FormBuilderCalendarEvent({
    required this.key,
    required this.scope,
    required this.trigger,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.statusCode,
    required this.colorValue,
    required this.reminderOffsetDays,
    required this.schedulingNote,
    this.variables = const <TemplateVariable>{},
  });

  @override
  final String key;
  @override
  final String scope;
  @override
  final String trigger;
  @override
  final String titleEn;
  @override
  final String titleAr;
  @override
  final String descriptionEn;
  @override
  final String descriptionAr;
  @override
  final String statusCode;
  @override
  final int colorValue;
  @override
  final int reminderOffsetDays;
  @override
  final String schedulingNote;
  @override
  final Set<TemplateVariable> variables;

  @override
  AppModule get module => AppModule.formBuilder;

  @override
  String get id => '${module.key}_$key';

  static FormBuilderCalendarEvent? fromKey(String key) {
    for (final FormBuilderCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
