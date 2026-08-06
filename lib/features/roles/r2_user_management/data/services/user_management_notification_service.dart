/// ************************* FILE INFO ************************* ///
/// File Name: user_management_notification_service.dart
/// Purpose: ALL notifications sent by the User Management & Permissions
///          module, as intent-named methods. UI pages and cubits must NOT
///          call AppNotificationSender directly - they call this service.
/// Pattern: One `<module>_notification_service.dart` per module.
///          Mirrors ServicesNotificationService.
///
/// The spec pairs several of these: the affected employee gets one
/// wording, the administrator gets another. Methods that notify both take
/// [adminEmails] and fan out, so a caller cannot accidentally send the
/// employee-facing text to an admin.

import 'package:grc_module/core/enums/template_variable.dart';
import 'package:grc_module/features/notification/domain/enums/role_module/user_management_module/user_management_events.dart';
import 'package:grc_module/features/notification/domain/enums/role_module/user_management_module/user_management_notification_pages.dart';
import 'package:grc_module/features/notification/services/app_notification_sender.dart';

class UserManagementNotificationService {
  UserManagementNotificationService._();

  static const _employeePage = UserManagementNotificationPage.settingsSwitchesPage;
  static const _adminPage = UserManagementNotificationPage.roleEmployeeDetailsPage;

  /// Access rights were assigned to an employee.
  /// Template: user_management_access_granted_user
  static Future<bool> notifyEmployeeOfAccessGranted({
    required String senderEmail,
    required String employeeEmail,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: UserManagementNotificationEvent.accessGrantedUser,
      pageKey: _employeePage.key,
      senderEmail: senderEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
    );
  }

  /// An employee's permissions changed.
  /// Template: user_management_access_updated_user
  static Future<bool> notifyEmployeeOfAccessUpdated({
    required String senderEmail,
    required String employeeEmail,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: UserManagementNotificationEvent.accessUpdatedUser,
      pageKey: _employeePage.key,
      senderEmail: senderEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
    );
  }

  /// Access was revoked. Tells the employee, then confirms to the admins.
  /// Templates: user_management_access_revoked_user
  ///          + user_management_access_revoked_admin
  static Future<void> notifyOfAccessRevoked({
    required String senderEmail,
    required String employeeEmail,
    required String employeeName,
    required Iterable<String> adminEmails,
    required bool isArabic,
  }) async {
    await AppNotificationSender.sendEvent(
      event: UserManagementNotificationEvent.accessRevokedUser,
      pageKey: _employeePage.key,
      senderEmail: senderEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
    );
    await AppNotificationSender.sendEventToAll(
      event: UserManagementNotificationEvent.accessRevokedAdmin,
      pageKey: _adminPage.key,
      senderEmail: senderEmail,
      receiverEmails: adminEmails,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: employeeName},
    );
  }

  /// A permission change was booked for a future date.
  /// Template: user_management_access_change_scheduled_user
  static Future<bool> notifyEmployeeOfScheduledChange({
    required String senderEmail,
    required String employeeEmail,
    required String scheduledDate,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: UserManagementNotificationEvent.accessChangeScheduledUser,
      pageKey: _employeePage.key,
      senderEmail: senderEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
      variables: {TemplateVariable.scheduledDate: scheduledDate},
    );
  }

  /// The booked change ran. Tells the employee, then confirms to the admins.
  /// Templates: user_management_scheduled_access_applied_user
  ///          + user_management_scheduled_access_applied_admin
  static Future<void> notifyOfScheduledChangeApplied({
    required String senderEmail,
    required String employeeEmail,
    required String employeeName,
    required Iterable<String> adminEmails,
    required bool isArabic,
  }) async {
    await AppNotificationSender.sendEvent(
      event: UserManagementNotificationEvent.scheduledAccessAppliedUser,
      pageKey: _employeePage.key,
      senderEmail: senderEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
    );
    await AppNotificationSender.sendEventToAll(
      event: UserManagementNotificationEvent.scheduledAccessAppliedAdmin,
      pageKey: _adminPage.key,
      senderEmail: senderEmail,
      receiverEmails: adminEmails,
      isArabic: isArabic,
      variables: {TemplateVariable.userName: employeeName},
    );
  }

  /// A booked change was called off before it ran.
  /// Template: user_management_scheduled_access_cancelled_user
  static Future<bool> notifyEmployeeOfScheduledChangeCancelled({
    required String senderEmail,
    required String employeeEmail,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEvent(
      event: UserManagementNotificationEvent.scheduledAccessCancelledUser,
      pageKey: _employeePage.key,
      senderEmail: senderEmail,
      receiverEmail: employeeEmail,
      isArabic: isArabic,
    );
  }
}
