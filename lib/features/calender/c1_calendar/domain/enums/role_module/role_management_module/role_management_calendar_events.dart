/// ************************* FILE INFO *************************
/// File Name: role_management_calendar_events.dart
/// Module:    Role Management
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

enum RoleManagementCalendarEvent implements CalendarEventType {
  accessGrantedImmediate(
    key: 'access_granted_immediate',
    scope: '',
    trigger: 'Access Granted (Immediate)',
    titleEn: 'Role Access Granted',
    titleAr: 'تم منح صلاحية الدور',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Calendar event is created immediately when access is granted. Event date = {AccessGrantedDate}. Visible to the assigned employee.',
    variables: {TemplateVariable.accessGrantedDate},
  ),
  accessScheduled14DaysBeforeStart(
    key: 'access_scheduled_14_days_before_start',
    scope: '',
    trigger: 'Access Scheduled (14 Days Before Start)',
    titleEn: 'Upcoming Role Access',
    titleAr: 'اقتراب موعد تفعيل الدور',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: -14,
    schedulingNote: 'Reminder appears 14 days before {AccessGrantedDate} only if the access start date is in the future.',
    variables: {TemplateVariable.accessGrantedDate},
  ),
  accessStartsToday(
    key: 'access_starts_today',
    scope: '',
    trigger: 'Access Starts Today',
    titleEn: 'Role Access Activated',
    titleAr: 'تم تفعيل صلاحية الدور',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Triggered on {AccessGrantedDate} when the scheduled access becomes active.',
    variables: {TemplateVariable.accessGrantedDate},
  ),
  accessExpiringIn14Days(
    key: 'access_expiring_in_14_days',
    scope: '',
    trigger: 'Access Expiring in 14 Days',
    titleEn: 'Role Access Expiring Soon',
    titleAr: 'اقتراب انتهاء صلاحية الدور',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: -14,
    schedulingNote: 'Reminder appears 14 days before {AccessRevokedDate}.',
    variables: {TemplateVariable.accessRevokedDate},
  ),
  accessRevokedExpiryDateReached(
    key: 'access_revoked_expiry_date_reached',
    scope: '',
    trigger: 'Access Revoked (Expiry Date Reached)',
    titleEn: 'Role Access Expired',
    titleAr: 'انتهت صلاحية الدور',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'Triggered on {AccessRevokedDate}. Access is considered expired and the calendar event is marked as completed.',
    variables: {TemplateVariable.accessRevokedDate},
  ),
  accessGrantedDateUpdated(
    key: 'access_granted_date_updated',
    scope: '',
    trigger: 'Access Granted Date Updated',
    titleEn: 'Role Access Start Updated',
    titleAr: 'تم تعديل تاريخ بدء صلاحية الدور',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'If {AccessGrantedDate} changes, the existing calendar event is automatically updated to the new date. No duplicate event is created.',
    variables: {TemplateVariable.accessGrantedDate},
  ),
  accessRevokedDateUpdated(
    key: 'access_revoked_date_updated',
    scope: '',
    trigger: 'Access Revoked Date Updated',
    titleEn: 'Role Access Expiry Updated',
    titleAr: 'تم تعديل تاريخ انتهاء صلاحية الدور',
    descriptionEn: '',
    descriptionAr: '',
    statusCode: '',
    colorValue: 0xFF9FADAF,
    reminderOffsetDays: 0,
    schedulingNote: 'If {AccessRevokedDate} changes, the expiry reminder and expiry event are automatically rescheduled.',
    variables: {TemplateVariable.accessRevokedDate},
  );

  const RoleManagementCalendarEvent({
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
  AppModule get module => AppModule.roleManagement;

  @override
  String get id => '${module.key}_$key';

  static RoleManagementCalendarEvent? fromKey(String key) {
    for (final e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
