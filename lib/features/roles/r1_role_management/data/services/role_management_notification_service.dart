/// ************************* FILE INFO ************************* ///
/// File Name: role_management_notification_service.dart
/// Purpose: ALL notifications sent by the Role Management module, as
///          intent-named methods. UI pages and cubits must NOT call
///          AppNotificationSender directly - they call this service.
/// Pattern: One `<module>_notification_service.dart` per module.
///          Mirrors ServicesNotificationService.
///
/// Recipients are passed in rather than resolved here: who should hear
/// about a role change depends on the tenant (role owners, master admins,
/// the affected members), and that policy belongs to the caller, not to
/// the notification layer.

import 'package:grc_module/core/enums/template_variable.dart';
import 'package:grc_module/features/notification/domain/enums/role_module/role_management_module/role_management_events.dart';
import 'package:grc_module/features/notification/domain/enums/role_module/role_management_module/role_management_notification_pages.dart';
import 'package:grc_module/features/notification/services/app_notification_sender.dart';

class RoleManagementNotificationService {
  RoleManagementNotificationService._();

  /// A new role was created. Template: role_management_role_created
  static Future<int> notifyOfRoleCreated({
    required String senderEmail,
    required Iterable<String> receiverEmails,
    required String roleName,
    required String actorName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEventToAll(
      event: RoleManagementNotificationEvent.roleCreated,
      pageKey: RoleManagementNotificationPage.roleDetailsPage.key,
      senderEmail: senderEmail,
      receiverEmails: receiverEmails,
      isArabic: isArabic,
      variables: {
        TemplateVariable.roleName: roleName,
        TemplateVariable.userName: actorName,
      },
    );
  }

  /// A role's permissions or details changed.
  /// Template: role_management_role_updated
  static Future<int> notifyOfRoleUpdated({
    required String senderEmail,
    required Iterable<String> receiverEmails,
    required String roleName,
    required String actorName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEventToAll(
      event: RoleManagementNotificationEvent.roleUpdated,
      pageKey: RoleManagementNotificationPage.roleDetailsPage.key,
      senderEmail: senderEmail,
      receiverEmails: receiverEmails,
      isArabic: isArabic,
      variables: {
        TemplateVariable.roleName: roleName,
        TemplateVariable.userName: actorName,
      },
    );
  }

  /// A role was removed. Template: role_management_role_deleted
  ///
  /// Lands on the role LIST, not the details page - the role it described
  /// no longer exists.
  static Future<int> notifyOfRoleDeleted({
    required String senderEmail,
    required Iterable<String> receiverEmails,
    required String roleName,
    required String actorName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEventToAll(
      event: RoleManagementNotificationEvent.roleDeleted,
      pageKey: RoleManagementNotificationPage.roleScreen.key,
      senderEmail: senderEmail,
      receiverEmails: receiverEmails,
      isArabic: isArabic,
      variables: {
        TemplateVariable.roleName: roleName,
        TemplateVariable.userName: actorName,
      },
    );
  }

  /// A role moved between states, e.g. active -> inactive.
  /// Template: role_management_role_status_changed
  static Future<int> notifyOfRoleStatusChanged({
    required String senderEmail,
    required Iterable<String> receiverEmails,
    required String roleName,
    required String oldStatus,
    required String newStatus,
    required String actorName,
    required bool isArabic,
  }) {
    return AppNotificationSender.sendEventToAll(
      event: RoleManagementNotificationEvent.roleStatusChanged,
      pageKey: RoleManagementNotificationPage.roleDetailsPage.key,
      senderEmail: senderEmail,
      receiverEmails: receiverEmails,
      isArabic: isArabic,
      variables: {
        TemplateVariable.roleName: roleName,
        TemplateVariable.oldStatus: oldStatus,
        TemplateVariable.newStatus: newStatus,
        TemplateVariable.userName: actorName,
      },
    );
  }
}
