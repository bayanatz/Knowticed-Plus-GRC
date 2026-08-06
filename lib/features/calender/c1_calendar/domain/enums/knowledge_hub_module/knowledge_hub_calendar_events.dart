/// ************************* FILE INFO *************************
/// File Name: knowledge_hub_calendar_events.dart
/// Module:    Knowledge Hub
/// Purpose:   Every calendar entry this module can put on the shared
///            calendar, exactly as specified in "Knowticed Plus —
///            Notification & Validation", Section 2 (Calendar Event
///            Triggers).
///
/// Each value carries its bilingual title, the reminder offset (0 = the
/// event day itself, -14 = the two-week-ahead reminder) and the spec's
/// scheduling note, so calendar_data_service never hardcodes a label,
/// a colour or an offset again.
///
/// RULE: never write a calendar event key or title as a raw string.

import '../calendar_event_type.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/core/enums/template_variable.dart';

enum KnowledgeHubCalendarEvent implements CalendarEventType {
  documentPublishedImmediate(
    key: 'document_published_immediate',
    scope: '',
    trigger: 'Document Published (immediate)',
    titleEn: 'Document Published and Effective',
    titleAr: 'تم نشر المستند وأصبح ساريًا',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    schedulingNote: 'Appears on calendar immediately upon publication. Expiry date is visible if an End Date is set.',
    variables: const {},
  ),
  documentScheduledForPublication(
    key: 'document_scheduled_for_publication',
    scope: '',
    trigger: 'Document Scheduled for Publication',
    titleEn: 'Document Scheduled',
    titleAr: 'تمت جدولة نشر المستند',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar entry is created at the point of scheduling, reflecting the planned publish date.',
    variables: const {},
  ),
  expiringIn14Days(
    key: 'expiring_in_14_days',
    scope: '',
    trigger: 'Expiring in 14 Days',
    titleEn: 'Document Validity Expiring Soon',
    titleAr: 'اقتراب انتهاء صلاحية المستند',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: -14,
    schedulingNote: 'Reminder appears 14 days prior to the document End Date. Requires immediate owner action.',
    variables: const {},
  ),
  approvalPending(
    key: 'approval_pending',
    scope: '',
    trigger: 'Approval Pending',
    titleEn: 'Approval Request Pending',
    titleAr: 'طلب الموافقة قيد الانتظار',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFFCD7F32,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar entry is generated automatically at the time of submission to the approver.',
    variables: const {},
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
    required this.variables,
  });

  @override
  final String key;

  /// Sub-area inside the module (e.g. 'Policy', 'Control Champion').
  /// Empty when the module has no sub-areas.
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

  @override
  String get id => '${module.key}_$key';

  static KnowledgeHubCalendarEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
