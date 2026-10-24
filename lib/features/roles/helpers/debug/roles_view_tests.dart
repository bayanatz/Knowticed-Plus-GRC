/// Module: roles / helpers / debug
///
///*************************** FILE INFO ****************************///
/// File Name: roles_view_tests.dart
/// Purpose: DEBUG ONLY. Sends the signed-in user one Roles-area notification
///          per View landing, each pointing at a real record, so the owner can
///          check that View opens the record (owner, 22/10/2026: View opens
///          the record, not the module).
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Only READS accounts, employees and roles; the only writes are the
/// notification documents themselves, through the same path the real
/// senders use (`AppNotificationSender.sendEvent`, same event, `pageKey` and
/// `Request_Id` encoding as AccountStatus / UserManagement /
/// RoleManagement notification services) — only the receiver differs.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_event.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/role_management_module/role_management_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/role_management_module/role_management_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/user_access_module/user_access_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/user_access_module/user_access_notification_pages.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/user_management_module/user_management_events.dart';
import 'package:knowticed_plus/features/notification/domain/enums/roles/user_management_module/user_management_notification_pages.dart';
import 'package:knowticed_plus/features/notification/helpers/services/app_notification_sender.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/data/repository/user_access_repository.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/usecases/get_user_access_entities_use_case.dart';

/// Function Name: [sendRolesViewTests]
///
/// Purpose: One notification per Roles-area View landing, to [receiverEmail]:
///  1. User Access — account outlined at the top (an unlocked account).
///  2. User Access — Unlock dialog (a locked account).
///  3. User Management — employee details (`RoleEmployeeDetailsPage` key).
///  4. User Management — employee details (`SettingsSwitchesPage` key).
///  5. Role Management — role details.
///  6. Role Management — role details + editor.
///  7. Role Management — role deleted: the list (no record id, by design).
///
/// A kind with no record to point at is skipped with a `debugPrint`.
///
/// Parameters:
/// - [receiverEmail]: the signed-in user, who receives every test.
/// - [isArabic]: the language of the text.
///
/// Returns: [Future<int>] — how many were sent. Never throws.
Future<int> sendRolesViewTests({
  required String receiverEmail,
  required bool isArabic,
}) async {
  if (!kDebugMode) return 0;
  int sent = 0;

  Future<void> send(
    NotificationEvent event, {
    required String pageKey,
    required String requestId,
    Map<TemplateVariable, String> variables = const {},
  }) async {
    try {
      final bool ok = await AppNotificationSender.sendEvent(
        event: event,
        pageKey: pageKey,
        senderEmail: receiverEmail,
        receiverEmail: receiverEmail,
        isArabic: isArabic,
        variables: variables,
        requestId: requestId,
      );
      if (ok) sent++;
      debugPrint('[RolesViewTests] ${event.titleEn} → '
          '${ok ? 'sent' : 'NOT sent'} ($pageKey, id "$requestId")');
    } catch (e) {
      debugPrint('[RolesViewTests] ${event.titleEn} failed: $e');
    }
  }

  // ── User Access ─────────────────────────────────────────────────────────
  try {
    final Either<Failure, dynamic> result =
        await GetUserAccessEntitiesUseCase(UserAccessRepository()).execute();
    final List<UserAccessEntity> accounts = result.fold(
      (_) => <UserAccessEntity>[],
      (dynamic data) => ((data as Map<EmployeeStatusEnum,
                  List<UserAccessEntity>>?)?[EmployeeStatusEnum.all] ??
              const <UserAccessEntity>[])
          .where((UserAccessEntity a) => a.email.trim().isNotEmpty)
          .toList(),
    );
    bool locked(UserAccessEntity a) => a.isLocked || a.isLockedWithRequest;

    final UserAccessEntity? open =
        accounts.where((UserAccessEntity a) => !locked(a)).firstOrNull;
    if (open == null) {
      debugPrint('[RolesViewTests] skipped User Access (outline): '
          'no unlocked account');
    } else {
      await send(
        UserAccessNotificationEvent.accountActivatedAdmin,
        pageKey: UserAccessNotificationPage.accountStatusPage.key,
        requestId: open.email,
        variables: {TemplateVariable.userName: open.englishName},
      );
    }

    final UserAccessEntity? lockedAccount = accounts.where(locked).firstOrNull;
    if (lockedAccount == null) {
      debugPrint('[RolesViewTests] skipped User Access (Unlock dialog): '
          'no locked account');
    } else {
      await send(
        UserAccessNotificationEvent.accountUnlockRequestedAdmin,
        pageKey: UserAccessNotificationPage.accountStatusPage.key,
        requestId: lockedAccount.email,
        variables: {TemplateVariable.userName: lockedAccount.englishName},
      );
    }
  } catch (e) {
    debugPrint('[RolesViewTests] skipped User Access: $e');
  }

  // ── User Management ─────────────────────────────────────────────────────
  try {
    final Either<Failure, dynamic> result =
        await UserManagementAccessRepository().getUsersPermissionsData();
    final UserPermissionEntity? employee = result
        .fold(
          (_) => <UserPermissionEntity>[],
          (dynamic data) =>
              (data as List<UserPermissionEntity>?) ??
              const <UserPermissionEntity>[],
        )
        .where((UserPermissionEntity u) => u.employeeEmail.trim().isNotEmpty)
        .firstOrNull;
    if (employee == null) {
      debugPrint('[RolesViewTests] skipped User Management: no employee '
          'with access');
    } else {
      await send(
        UserManagementNotificationEvent.accessUpdatedUser,
        pageKey: UserManagementNotificationPage.roleEmployeeDetailsPage.key,
        requestId: employee.employeeEmail,
      );
      await send(
        UserManagementNotificationEvent.accessRevokedAdmin,
        pageKey: UserManagementNotificationPage.settingsSwitchesPage.key,
        requestId: employee.employeeEmail,
        variables: {TemplateVariable.userName: employee.englishName},
      );
    }
  } catch (e) {
    debugPrint('[RolesViewTests] skipped User Management: $e');
  }

  // ── Role Management ─────────────────────────────────────────────────────
  try {
    final Either<Failure, dynamic> result =
        await RoleRepository().getUnDeletedRoles();
    final RoleHistoryModel? role = result
        .fold(
      (_) => <RoleHistoryModel>[],
      (dynamic data) =>
          (data as List<RoleHistoryModel>?) ?? const <RoleHistoryModel>[],
    )
        .where((RoleHistoryModel r) {
      final String name = r.currentRoleName.toLowerCase();
      // The list hides Master Admin and opens drafts in the editor.
      return name != 'master admin' &&
          r.currentStatus != RoleStatus.draft &&
          r.roleId.isNotEmpty;
    }).firstOrNull;
    if (role == null) {
      debugPrint('[RolesViewTests] skipped Role Management: no listed role');
    } else {
      final Map<TemplateVariable, String> variables = {
        TemplateVariable.roleName: role.currentRoleName,
        TemplateVariable.userName: receiverEmail,
      };
      await send(
        RoleManagementNotificationEvent.roleCreated,
        pageKey: RoleManagementNotificationPage.roleDetailsPage.key,
        requestId: role.roleId,
        variables: variables,
      );
      await send(
        RoleManagementNotificationEvent.roleUpdated,
        pageKey: RoleManagementNotificationPage.editingRolePage.key,
        requestId: role.roleId,
        variables: variables,
      );
    }
  } catch (e) {
    debugPrint('[RolesViewTests] skipped Role Management: $e');
  }

  // Role deleted carries no id: the role is gone, View lands on the list.
  await send(
    RoleManagementNotificationEvent.roleDeleted,
    pageKey: RoleManagementNotificationPage.roleScreen.key,
    requestId: '',
    variables: {
      TemplateVariable.roleName: 'View test role',
      TemplateVariable.userName: receiverEmail,
    },
  );

  debugPrint('[RolesViewTests] $sent sent');
  return sent;
}
