/// ************************* FILE INFO *************************
/// File Name: qiyas_calendar_events.dart
/// Module:    Qiyas
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

enum QiyasCalendarEvent implements CalendarEventType {
  evidenceAssignedToChampion(
    key: 'evidence_assigned_to_champion',
    scope: '',
    trigger: 'Evidence Assigned to Champion',
    titleEn: 'Evidence Assignment — Action Required',
    titleAr: 'تم تعيين الدليل — يتطلب اتخاذ إجراء',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Entry appears immediately upon champion assignment. Includes Due Date and Duration (Manager view).',
    variables: const {},
  ),
  submissionToSupervisor(
    key: 'submission_to_supervisor',
    scope: '',
    trigger: 'Submission to Supervisor',
    titleEn: 'Evidence Submitted — Pending Approval',
    titleAr: 'تم إرسال الدليل — بانتظار الموافقة',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Entry is created simultaneously for both the Champion and the Supervisor at the point of submission.',
    variables: const {},
  ),
  DayOverdueThresholdReached(
    key: '14_day_overdue_threshold_reached',
    scope: '',
    trigger: '14-Day Overdue Threshold Reached',
    titleEn: 'Evidence Overdue',
    titleAr: 'الدليل متأخر عن الموعد المحدد',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'If no action is taken by the submission due date, the record is marked Overdue for Champion and Manager.',
    variables: const {},
  );

  const QiyasCalendarEvent({
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
  AppModule get module => AppModule.qiyas;

  @override
  String get id => '${module.key}_$key';

  static QiyasCalendarEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
