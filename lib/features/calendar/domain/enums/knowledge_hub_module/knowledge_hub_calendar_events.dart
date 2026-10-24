/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_calendar_events.dart
/// Module:    Knowledge Hub
/// Description: Every calendar entry the Knowledge Hub module can place on the
///          calendar.
/// Author: Amr Mesbah
/// Created at: 18/8/2026
///
/// Written to close the Knowledge Hub half of "Knowticed Plus — Notification
/// & Validation" §2 (Calendar Event Triggers). `calendar_data_service
/// .getKnowledgeHubCalendarEvents` already produced these entries, but built
/// every one of them from literals — hardcoded English/Arabic strings glued
/// together with ` / `, a hardcoded colour and a hardcoded status. Services,
/// Role Management and User Access all had a `*_calendar_events.dart`;
/// Knowledge Hub was the one module still un-migrated.
///
/// Wording is aligned with `notification/domain/enums/knowledge_hub_module/
/// knowledge_hub_events.dart` so a calendar card and the notification that
/// accompanies it read the same.
///
/// ⚠️ NO `{{documentName}}` PLACEHOLDER. The notification bodies interpolate
/// the document name, but on the calendar it is already the card's
/// `taskName` (every call site passes the bilingual `taskName`), so
/// repeating it in the body would print it twice. `variables` is asserted
/// against the call site in [CalendarEventModel.fromType], so declaring an
/// unused placeholder here would throw at runtime.
///
/// ─── TWO DELIBERATE DEPARTURES FROM THE SPEC TABLE ───────────────────
///
/// 1. `reminderOffsetDays` is 0 on [documentValidityExpiring], not -14.
///    The spec's note reads "Reminder appears 14 days prior to the document
///    End Date", but the existing builder places the card ON the end date
///    and uses the 14-day window only to decide which bucket the card falls
///    into. Shifting the date here would move every expiry card two weeks
///    earlier and detach it from the date it is about. The window test stays
///    at the call site; the card stays on the expiry date.
///
/// 2. [documentExpiringSoon] is not in the spec table. It is the builder's
///    real ">14 days out" bucket and dropping it would silently delete
///    cards, so it is catalogued rather than discarded.
///
/// ─── ONE BUG FIXED IN PASSING ────────────────────────────────────────
/// The builder emitted `status: 'Expiring Soon'`, but the filter chip in
/// `calendar_screen.dart` is `'Expiring'` and filtering is an exact string
/// compare (`event.status == englishStatus`). Every ">14 days" card was
/// therefore invisible under its own chip. [documentExpiringSoon] carries
/// `statusCode: 'Expiring'` so the chip finally matches — the same class of
/// fix the file already documents twice for 'Pending Approval'.
library;

/// ─── CHANGED 14/10/2026 — KH large-screen report p.3 / p.27–30 ──────────
/// "too long message for the calendar" + "Apply these messages in calendar as
/// they are in the document" + "add this new one (Expires Today)".
/// The card body is now the spec table's short NOTIFICATION TITLE, with the
/// document name and date filled in, instead of a two-sentence paragraph.
/// That brings `{{documentName}}` (and a date) back in, so the call sites in
/// calendar_data_service_methods_5.dart now pass them — the note above about
/// not using the placeholder no longer applies.

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/calendar_event_type.dart';

enum KnowledgeHubCalendarEvent implements CalendarEventType {
  // ── Publication ───────────────────────────────────────────────────────────

  documentPublished(
    key: 'document_published',
    scope: 'Publication',
    trigger: 'Document Published (immediate)',
    titleEn: 'Document Published',
    titleAr: 'تم نشر الوثيقة',
    descriptionEn:
        '{{documentName}} was published and is available to readers.',
    descriptionAr: 'تم نشر {{documentName}} وهي متاحة للقراء.',
    statusCode: 'Release',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.documentName},
    schedulingNote:
        'Appears on calendar immediately upon publication. Expiry date is visible if an End Date is set.',
  ),

  documentScheduled(
    key: 'document_scheduled',
    scope: 'Publication',
    trigger: 'Document Scheduled for Publication',
    titleEn: 'Document Scheduled',
    titleAr: 'جدولة الوثيقة',
    descriptionEn: '{{documentName}} will be published on {{startDate}}.',
    descriptionAr: 'سيتم نشر {{documentName}} في {{startDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.documentName, TemplateVariable.startDate},
    schedulingNote:
        'Calendar entry is created at the point of scheduling, reflecting the planned publish date. Placed on `startDateTime` and shown only while that date is still in the future.',
  ),

  // ── Validity ──────────────────────────────────────────────────────────────

  documentExpiringSoon(
    key: 'document_expiring_soon',
    scope: 'Validity',
    trigger: 'End Date Set, More Than 14 Days Away',
    titleEn: 'Expiry Date Set',
    titleAr: 'تحديد انتهاء الوثيقة',
    descriptionEn:
        '{{documentName}} expires on {{endDate}}. Review it and renew it if it is still needed.',
    descriptionAr:
        'تنتهي {{documentName}} في {{endDate}}. راجعها وجدّدها إن كانت لا تزال مطلوبة.',
    statusCode: 'Expiring',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.documentName, TemplateVariable.endDate},
    schedulingNote:
        'Placed on the document `endDateTime` while that date is more than 14 days away. Not in the spec table — this is the builder\'s existing long-range bucket, kept so no card is lost.',
  ),

  documentValidityExpiring(
    key: 'document_validity_expiring',
    scope: 'Validity',
    trigger: 'Expiring in 14 Days',
    titleEn: 'Expires Within 14 Days',
    titleAr: 'تنتهي خلال 14 يوماً',
    descriptionEn:
        '{{documentName}} expires on {{endDate}}, within 14 days. Renew it now if it is still needed.',
    descriptionAr:
        'تنتهي {{documentName}} في {{endDate}}، أي خلال 14 يوماً. جدّدها الآن إن كانت لا تزال مطلوبة.',
    statusCode: 'Reminders',
    colorValue: 0xFFCD7F32,
    // CHANGED 14/10/2026 — placed 14 days BEFORE the End Date, as §2 says
    // (departure 1 in the header no longer applies).
    reminderOffsetDays: -14,
    variables: {TemplateVariable.documentName, TemplateVariable.endDate},
    schedulingNote:
        'Spec: "Reminder appears 14 days prior to the document End Date. Requires immediate owner action." Placed on End Date − 14 days.',
  ),

  /// ADDED 14/10/2026 — KH report p.3 "add this new one": on the End Date
  /// itself.
  documentExpiresToday(
    key: 'document_expires_today',
    scope: 'Validity',
    trigger: 'Expires Today',
    titleEn: 'Document Expires Today',
    titleAr: 'تنتهي الوثيقة اليوم',
    descriptionEn: '{{documentName}} expires today. Renew it or archive it.',
    descriptionAr: 'تنتهي {{documentName}} اليوم. جدّدها أو أرشفها.',
    statusCode: 'Reminders',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.documentName},
    schedulingNote: "Reminder appears on the document's End Date.",
  ),

  // ── Approval cycle ────────────────────────────────────────────────────────

  approvalPending(
    key: 'approval_pending',
    scope: 'Approvals',
    trigger: 'Approval Pending',
    titleEn: 'Approval Needed',
    titleAr: 'مطلوب اعتماد',
    descriptionEn:
        '{{documentName}} is waiting for your decision. Review it, then approve or reject.',
    descriptionAr:
        '{{documentName}} بانتظار قرارك. راجعها ثم اعتمدها أو ارفضها.',
    statusCode: 'Pending Approval',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.documentName},
    schedulingNote:
        'Calendar entry is generated automatically at the time of submission to the approver. Placed on the latest `timestamps` entry, and shown only to the creator\'s supervisor, a super admin, or a Knowledge Hub approver.',
  );

  const KnowledgeHubCalendarEvent({
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
  AppModule get module => AppModule.knowledgeHub;

  /// `<module>_<key>` — see [CalendarEventType.id].
  @override
  String get id => '${module.key}_$key';

  static KnowledgeHubCalendarEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
