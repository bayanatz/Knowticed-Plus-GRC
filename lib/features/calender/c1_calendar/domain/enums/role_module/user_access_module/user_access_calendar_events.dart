/// ************************* FILE INFO *************************
/// File Name: user_access_calendar_events.dart
/// Module:    User Access
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

import '../../calendar_event_type.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/core/enums/template_variable.dart';

enum UserAccessCalendarEvent implements CalendarEventType {
  accountActivationToday(
    key: 'account_activation_today',
    scope: '',
    trigger: 'Account Activation Today',
    titleEn: 'Account Activated',
    titleAr: 'تم تفعيل الحساب',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar entry appears on the account activation date, indicating that access becomes active today.',
    variables: const {},
  ),
  accountActivationIn14Days(
    key: 'account_activation_in_14_days',
    scope: '',
    trigger: 'Account Activation in 14 Days',
    titleEn: 'Account Activation Reminder',
    titleAr: 'تذكير بتفعيل الحساب',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: -14,
    schedulingNote: 'Reminder appears 14 days before the scheduled account activation date.',
    variables: const {},
  ),
  accountDeactivationToday(
    key: 'account_deactivation_today',
    scope: '',
    trigger: 'Account Deactivation Today',
    titleEn: 'Account Deactivated',
    titleAr: 'تم إيقاف الحساب',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar entry appears on the scheduled deactivation date, indicating that access ends today.',
    variables: const {},
  ),
  accountDeactivationIn14Days(
    key: 'account_deactivation_in_14_days',
    scope: '',
    trigger: 'Account Deactivation in 14 Days',
    titleEn: 'Account Deactivation Reminder',
    titleAr: 'تذكير بإيقاف الحساب',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: -14,
    schedulingNote: 'Reminder appears 14 days before the scheduled account deactivation date.',
    variables: const {},
  ),
  accountLocked(
    key: 'account_locked',
    scope: '',
    trigger: 'Account Locked',
    titleEn: 'Account Locked',
    titleAr: 'تم قفل الحساب',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar entry is created immediately on the day the account is locked.',
    variables: const {},
  ),
  accountUnlocked(
    key: 'account_unlocked',
    scope: '',
    trigger: 'Account Unlocked',
    titleEn: 'Account Unlocked',
    titleAr: 'تم فتح الحساب',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar entry is created immediately on the day the account is unlocked.',
    variables: const {},
  ),
  scheduledActivationDateUpdated(
    key: 'scheduled_activation_date_updated',
    scope: '',
    trigger: 'Scheduled Activation Date Updated',
    titleEn: 'Account Activation Date Updated',
    titleAr: 'تم تحديث موعد تفعيل الحساب',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'If the scheduled account activation date changes, the existing calendar event is automatically updated from {OldActivationDate} to {NewActivationDate}.',
    variables: {TemplateVariable.oldActivationDate, TemplateVariable.newActivationDate},
  ),
  scheduledDeactivationDateUpdated(
    key: 'scheduled_deactivation_date_updated',
    scope: '',
    trigger: 'Scheduled Deactivation Date Updated',
    titleEn: 'Account Deactivation Date Updated',
    titleAr: 'تم تحديث موعد إيقاف الحساب',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'If the scheduled account deactivation date changes, the existing calendar event is automatically updated from {OldDeactivationDate} to {NewDeactivationDate}.',
    variables: {TemplateVariable.oldDeactivationDate, TemplateVariable.newDeactivationDate},
  );

  const UserAccessCalendarEvent({
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
  AppModule get module => AppModule.userAccess;

  @override
  String get id => '${module.key}_$key';

  static UserAccessCalendarEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
