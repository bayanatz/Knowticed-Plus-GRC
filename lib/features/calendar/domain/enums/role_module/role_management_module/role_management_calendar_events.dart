/// Module: calendar
///
///*************************** FILE INFO ****************************///
/// File Name: role_management_calendar_events.dart
/// Module:    Role Management
/// Purpose: Every calendar entry the role-management module can place on the
///          calendar — the opening and closing of a role's access window.
/// Author: Knowticed Plus team
/// Created at: 12/8/2026
///
/// Written to complete CR-SKEL-CAL-N03, alongside `services_calendar_events`
/// and `user_access_calendar_events`.
///
/// The notification module's `role_management_events.dart` covers role CRUD
/// (created / updated / deleted / status changed) and has no twin for the
/// access-window entries below, so the wording here follows the register of
/// `user_access_events.dart`, which is the closest existing copy.
///
/// SOURCE: `From_Date` and `To_Date` on the role document. Both are history
/// lists, which is what lets [accessGrantedDateUpdated] and
/// [accessRevokedDateUpdated] exist at all — the builder detects a change by
/// comparing the last two entries. User Access cannot do the same because its
/// equivalent fields are single strings.
///
/// Every call site passes both `accessGrantedDate` and `accessRevokedDate`,
/// so each entry declares only the one it actually renders; the assert in
/// [CalendarEventModel.fromType] requires the declared set to be a subset of
/// what is passed, never the reverse.
library;

import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/features/calendar/domain/enums/calendar_event_type.dart';

enum RoleManagementCalendarEvent implements CalendarEventType {
  // ── Access window opens ───────────────────────────────────────────────────

  accessGrantedImmediate(
    key: 'access_granted_immediate',
    scope: 'Access Window',
    trigger: 'Role Access Granted',
    titleEn: 'Role Access Granted',
    titleAr: 'تم منح صلاحية الدور',
    descriptionEn:
        'You were given this role on {{accessGrantedDate}}. Review the permissions it gives you.',
    descriptionAr:
        'تم منحك هذا الدور في {{accessGrantedDate}}. راجع الصلاحيات التي يمنحها لك.',
    statusCode: 'Milestone',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.accessGrantedDate},
    schedulingNote:
        'Placed on `From_Date`. Emitted unconditionally whenever a start date exists, including retrospectively for windows that opened in the past.',
  ),

  accessStartsToday(
    key: 'access_starts_today',
    scope: 'Access Window',
    trigger: 'Role Access Window Opens Today',
    titleEn: 'Role Access Starts Today',
    titleAr: 'بدء صلاحية الدور اليوم',
    descriptionEn:
        'Your access to this role starts today. Review the permissions it gives you.',
    descriptionAr:
        'تبدأ اليوم صلاحيتك لهذا الدور. راجع الصلاحيات التي يمنحها لك.',
    statusCode: 'Scheduled',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.accessGrantedDate},
    schedulingNote:
        'Also placed on `From_Date`, so it lands on the same day as [accessGrantedImmediate]; the two are deliberately separate cards, one stating the grant and one marking the day.',
  ),

  accessScheduled14DaysBeforeStart(
    key: 'access_scheduled_14_days_before_start',
    scope: 'Access Window',
    trigger: 'Role Access Scheduled — 14-Day Advance Notice',
    titleEn: 'Role Access Scheduled',
    titleAr: 'جدولة صلاحية الدور',
    descriptionEn:
        'Your access to this role will start on {{accessGrantedDate}}. You will be notified when it is active.',
    descriptionAr:
        'ستبدأ صلاحيتك لهذا الدور في {{accessGrantedDate}}. سيصلك إشعار عند تفعيلها.',
    statusCode: 'Reminders',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: -14,
    variables: {TemplateVariable.accessGrantedDate},
    schedulingNote:
        'Fourteen days before `From_Date`, and only when the start is still in the future — a window that already opened gets no advance notice. The offset is applied by `CalendarEventType.dateFor`, so the builder passes the raw start date.',
  ),

  accessGrantedDateUpdated(
    key: 'access_granted_date_updated',
    scope: 'Access Window',
    trigger: 'Role Access Start Date Changed',
    titleEn: 'Start Date Changed',
    titleAr: 'تغيير تاريخ البدء',
    descriptionEn:
        'Your access to this role was moved to start on {{accessGrantedDate}}.',
    descriptionAr: 'تم نقل بدء صلاحيتك لهذا الدور إلى {{accessGrantedDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.accessGrantedDate},
    schedulingNote:
        'Emitted only when `From_Date` has more than one history entry AND the last two differ — an unchanged re-save must not raise a card.',
  ),

  // ── Access window closes ──────────────────────────────────────────────────

  accessExpiringIn14Days(
    key: 'access_expiring_in_14_days',
    scope: 'Access Window',
    trigger: 'Role Access Expires in 14 Days',
    titleEn: 'Role Access Ending Soon',
    titleAr: 'اقتراب انتهاء صلاحية الدور',
    descriptionEn:
        'Your access to this role ends on {{accessRevokedDate}}. Ask your administrator for an extension if you still need it.',
    descriptionAr:
        'تنتهي صلاحيتك لهذا الدور في {{accessRevokedDate}}. اطلب التمديد من المسؤول إن كنت ما زلت بحاجة إليها.',
    statusCode: 'Expiring',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: -14,
    variables: {TemplateVariable.accessRevokedDate},
    schedulingNote:
        'Fourteen days before `To_Date`. Unlike the start-side reminder this is emitted whenever an end date exists, so an already-expired window still shows the run-up on the calendar.',
  ),

  accessRevokedExpiryDateReached(
    key: 'access_revoked_expiry_date_reached',
    scope: 'Access Window',
    trigger: 'Role Access Expiry Date Reached',
    titleEn: 'Role Access Ends',
    titleAr: 'انتهاء صلاحية الدور',
    descriptionEn:
        'Your access to this role ends on {{accessRevokedDate}}. Its permissions no longer apply after that date.',
    descriptionAr:
        'تنتهي صلاحيتك لهذا الدور في {{accessRevokedDate}}. لن تكون صلاحياته سارية بعد هذا التاريخ.',
    statusCode: 'Expiring',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.accessRevokedDate},
    schedulingNote: 'Placed on `To_Date` itself.',
  ),

  accessRevokedDateUpdated(
    key: 'access_revoked_date_updated',
    scope: 'Access Window',
    trigger: 'Role Access End Date Changed',
    titleEn: 'End Date Changed',
    titleAr: 'تغيير تاريخ الانتهاء',
    descriptionEn:
        'Your access to this role was moved to end on {{accessRevokedDate}}.',
    descriptionAr:
        'تم نقل انتهاء صلاحيتك لهذا الدور إلى {{accessRevokedDate}}.',
    statusCode: 'Scheduled',
    colorValue: 0xFFE91E63,
    reminderOffsetDays: 0,
    variables: {TemplateVariable.accessRevokedDate},
    schedulingNote:
        'The `To_Date` mirror of [accessGrantedDateUpdated], with the same two-entry comparison.',
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
  AppModule get module => AppModule.roleManagement;

  @override
  String get id => '${module.key}_$key';

  static RoleManagementCalendarEvent? fromKey(String key) {
    for (final RoleManagementCalendarEvent e in values) {
      if (e.key == key) return e;
    }
    return null;
  }
}
