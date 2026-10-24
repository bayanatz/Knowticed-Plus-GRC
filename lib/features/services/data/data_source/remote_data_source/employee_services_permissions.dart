/// Module: services_management_module
///
///*************************** FILE INFO ****************************///
/// File Name: employee_services_permissions.dart
/// Purpose: Answers "may THIS employee (not the logged-in user) act as a
///          service provider / approver?" from the Services switches on the
///          employee's ROLE.
/// Author: Knowticed Plus team
/// Created at: 25/9/2026
///
/// WHY THIS EXISTS
/// ---------------
/// Services bug report p1–p2: the Service Provider picker and the Add
/// Approvals picker listed every employee, even those whose role has the
/// "Requested Services" / "Approval Permissions" switches OFF. Those people
/// can never open the screen that lets them act on the request, so choosing
/// them silently dead-ends the service.
///
/// [ServicesModuleAccess] only answers for the logged-in user (it reads the
/// controller's cached role). Here we load the `services` permission document
/// of every role the listed employees hold, once per picker load, and apply
/// the same rule [ServicesModuleAccess.can] does: the section master switch
/// AND the leaf switch must both be on.
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/approval_permission_work.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/employee_services.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

abstract class EmployeeServicesPermissions {
  static const String _servicesModule = 'services';
  static const String _superAdmin = 'super admin';

  /// normalised role name -> (permission database name -> value).
  /// A role that exists but has no Services module maps to an empty map.
  static final Map<String, Map<String, bool>> _byRole = {};

  /// False until the roles could be resolved. SVC-HOME-12: while false every
  /// check answers `false` (it used to answer `true`, which put EVERY
  /// employee in the provider and approver pickers). Pickers check
  /// [isReady] / [hasFailures] and show a loading or error state instead.
  static bool _ready = false;

  /// True when the last [preload] could not read at least one role's
  /// permissions; those employees are left out of the pickers.
  static bool _hasFailures = false;

  static String _norm(String? s) => (s ?? '').toLowerCase().trim();

  /// Loads the Services permissions for every role held by [employees].
  /// Always re-reads, so switches changed in the role editor apply the next
  /// time a picker opens.
  ///
  /// Rule "Layers depend one way" / "Inject repositories": the role list
  /// and the [RoleRepository] are passed in by the caller (this data class
  /// no longer imports the roles cubit or creates a repository).
  static Future<void> preload(
    Iterable<EmployeeEntityPro> employees, {
    required List<RoleHistoryModel> roles,
    required RoleRepository repository,
  }) async {
    final List<RoleHistoryModel> roleList = roles;
    _hasFailures = false;
    if (roleList.isEmpty) {
      _ready = false;
      return;
    }

    final roleNames = employees
        .map((e) => _norm(e.role))
        .where((r) => r.isNotEmpty && r != _superAdmin)
        .toSet();

    final repo = repository;
    final fresh = <String, Map<String, bool>>{};

    await Future.wait(
      roleNames.map((roleName) async {
        final RoleHistoryModel? role = roleList
            .where((r) => _norm(r.currentRoleName) == roleName)
            .firstOrNull;
        if (role == null) {
          fresh[roleName] = const {};
          return;
        }
        final String? moduleKey = role.currentSelectedModules
            .where((m) => _norm(m) == _servicesModule)
            .firstOrNull;
        if (moduleKey == null) {
          fresh[roleName] = const {};
          return;
        }
        final Either<FirebaseFailure, Map<String, dynamic>?> result = await repo
            .getRolePermissions(roleId: role.roleId, module: moduleKey);
        result.fold(
          (l) {
            _hasFailures = true;
            svcLog(
              'EmployeeServicesPermissions: load failed for $roleName: ${l.errMessage}',
            );
          },
          (data) {
            final map = <String, bool>{};
            data?.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                map[key] = value.last == true;
              } else if (value is bool) {
                map[key] = value;
              }
            });
            fresh[roleName] = map;
          },
        );
      }),
    );

    _byRole
      ..clear()
      ..addAll(fresh);
    _ready = true;
  }

  static bool _has(EmployeeEntityPro e, String section, String leaf) {
    final role = _norm(e.role);
    if (role == _superAdmin) return true;
    // SVC-HOME-12: unknown means "no", never "everyone".
    if (!_ready) return false;
    final perms = _byRole[role];
    // Role never loaded (e.g. its permission read failed) -> not eligible.
    if (perms == null) return false;
    return (perms[section] ?? false) && (perms[leaf] ?? false);
  }

  /// Role has "Requested Services" section + "Status Requested" on — the
  /// switches that let an employee work the requests sent to them.
  static bool canBeProvider(EmployeeEntityPro e) => _has(
        e,
        ServicePermissionsSections.requestedServices.getDataBaseName,
        RequestServicesModule.statusRequested.getDataBaseName,
      );

  /// Role has "Approval Permissions" section + "Approve And Reject" on.
  static bool canApprove(EmployeeEntityPro e) => _has(
        e,
        ServicePermissionsSections.approvalPermissions.getDataBaseName,
        ApprovalPermissionsServices.approveAndReject.getDataBaseName,
      );

  /// Whether [preload] resolved real role data (so the checks are meaningful).
  static bool get isReady => _ready;

  /// Whether some role permissions could not be read on the last [preload].
  static bool get hasFailures => _hasFailures;
}
