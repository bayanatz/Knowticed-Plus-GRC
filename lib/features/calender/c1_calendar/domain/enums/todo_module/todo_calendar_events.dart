/// ************************* FILE INFO *************************
/// File Name: todo_calendar_events.dart
/// Module:    To-Do List
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

enum TodoCalendarEvent implements CalendarEventType {
  taskStartAndEndDateDefined(
    key: 'task_start_and_end_date_defined',
    scope: '',
    trigger: 'Task Start and End Date Defined',
    titleEn: 'Task Scheduled',
    titleAr: 'تمت جدولة المهمة',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9C27B0,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar entry is created at the time of task creation.',
    variables: const {},
  ),
  taskOverdue(
    key: 'task_overdue',
    scope: '',
    trigger: 'Task Overdue',
    titleEn: 'Task Overdue — Action Required',
    titleAr: 'المهمة متأخرة — يتطلب اتخاذ إجراء',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9C27B0,
    reminderOffsetDays: 0,
    schedulingNote: 'Triggered when the task due date passes without a completed status being recorded.',
    variables: const {},
  ),
  recurringFrequencySetDailyWeeklyMonthly(
    key: 'recurring_frequency_set_daily_weekly_monthly',
    scope: '',
    trigger: 'Recurring Frequency Set (Daily/Weekly/Monthly)',
    titleEn: 'Recurring Task Reminder',
    titleAr: 'تذكير بالمهمة الدورية',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9C27B0,
    reminderOffsetDays: 0,
    schedulingNote: 'Reminders are generated automatically in accordance with the defined recurrence pattern.',
    variables: const {},
  );

  const TodoCalendarEvent({
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
  AppModule get module => AppModule.todo;

  @override
  String get id => '${module.key}_$key';

  static TodoCalendarEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
