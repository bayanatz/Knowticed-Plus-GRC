/// Module: roles / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: role_management_demo_service.dart
/// Description: Debug-only showcase data for Role Management: roles in every
///              status, access lines in every status, accounts in every
///              status and System Logs from several employees — plus the
///              matching Remove. Writes only through the module's own
///              repositories / data sources (soft deletes, indexed history).
/// Author: Moataz Handousa
/// Created at: 21/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/access/constants.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/data/data_source/remote_data_source/user_access_remote_data_source.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/data_source/remote_data_source/system_logs_remote_data_source.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/models/system_logs_model.dart';

/// One showcase role.
class _DemoRole {
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final RoleStatus status;

  const _DemoRole(
    this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    this.status,
  );
}

/// What a load wrote, so Remove can undo exactly that.
class RoleDemoResult {
  final int roles;
  final int accessLines;
  final int accounts;
  final int logs;
  final List<String> problems;

  const RoleDemoResult({
    required this.roles,
    required this.accessLines,
    required this.accounts,
    required this.logs,
    required this.problems,
  });
}

class RoleManagementDemoService {
  RoleManagementDemoService({
    RoleRepository? roleRepository,
    UserManagementAccessRepository? accessRepository,
    UserAccessRemoteDataSource? accountSource,
    SystemLogsRemoteDataSource? logSource,
    GetStorage? storage,
  })  : _roles = roleRepository ?? RoleRepository(),
        _access = accessRepository ?? UserManagementAccessRepository(),
        _accounts = accountSource ?? UserAccessRemoteDataSource(),
        _logs = logSource ?? SystemLogsRemoteDataSource(),
        _storage = storage ?? GetStorage();

  final RoleRepository _roles;
  final UserManagementAccessRepository _access;
  final UserAccessRemoteDataSource _accounts;
  final SystemLogsRemoteDataSource _logs;
  final GetStorage _storage;

  /// Local note of what was seeded on this device (never in Firestore).
  static const String _storageKey = 'roles_demo_seed_v1';

  static const List<_DemoRole> _demoRoles = <_DemoRole>[
    _DemoRole(
      'Records Management Officer',
      'مسؤول إدارة السجلات',
      'Manages official correspondence, archives and document retention schedules across all departments.',
      'يدير المراسلات الرسمية والأرشيف وجداول حفظ الوثائق في جميع الإدارات.',
      RoleStatus.active,
    ),
    _DemoRole(
      'Internal Audit Specialist',
      'أخصائي التدقيق الداخلي',
      'Reviews controls, approvals and attendance records to confirm compliance with internal policies.',
      'يراجع الضوابط والموافقات وسجلات الحضور للتأكد من الالتزام بالسياسات الداخلية.',
      RoleStatus.active,
    ),
    _DemoRole(
      'Procurement Coordinator',
      'منسق المشتريات',
      'Prepares purchase requests, follows supplier quotations and tracks delivery of approved orders.',
      'يعد طلبات الشراء ويتابع عروض الموردين وتسليم الطلبات المعتمدة.',
      RoleStatus.inactive,
    ),
    _DemoRole(
      'Media Relations Officer',
      'مسؤول العلاقات الإعلامية',
      'Coordinates press statements, media requests and publication approvals for official announcements.',
      'ينسق البيانات الصحفية وطلبات الإعلام واعتماد النشر للإعلانات الرسمية.',
      RoleStatus.inactive,
    ),
    _DemoRole(
      'Data Quality Analyst',
      'محلل جودة البيانات',
      'Checks completeness and accuracy of employee and service data and reports issues to data owners.',
      'يتحقق من اكتمال ودقة بيانات الموظفين والخدمات ويرفع الملاحظات لمالكي البيانات.',
      RoleStatus.draft,
    ),
    _DemoRole(
      'Strategy Planning Advisor',
      'مستشار التخطيط الاستراتيجي',
      'Supports the annual operating plan, follows strategic initiatives and prepares progress reports.',
      'يدعم الخطة التشغيلية السنوية ويتابع المبادرات الاستراتيجية ويعد تقارير الإنجاز.',
      RoleStatus.draft,
    ),
  ];

  /// Actions written to System Logs for the other employees.
  static const List<(Modules, String)> _logActions = <(Modules, String)>[
    (Modules.roles, 'View Role Management Home'),
    (Modules.roles, 'Grant User Access'),
    (Modules.roles, 'Update Role'),
    (Modules.roles, 'Export Users'),
    (Modules.services, 'Create Service Request'),
    (Modules.services, 'Approve Service Request'),
    (Modules.timeTracker, 'Check In'),
    (Modules.timeTracker, 'Create Time Tracker Request'),
    (Modules.todo, 'Create Task'),
    (Modules.knowledgeHub, 'Open Knowledge Document'),
    (Modules.inventory, 'Update Stock Item'),
    (Modules.settings, 'Update Personal Information'),
  ];

  String _fmt(DateTime d) =>
      DateFormat(Constants.userAccessDateFormat, 'en').format(d);

  /// Function Name: [load]
  ///
  /// Purpose: Write the showcase data. Safe to run twice: roles that already
  /// exist by name are skipped, and only employees with no current access /
  /// an Active account are used.
  ///
  /// Returns: [Future<RoleDemoResult>] — counts plus any step that failed
  /// (e.g. a seat limit), so the owner sees what did not land.
  Future<RoleDemoResult> load() async {
    final String me = AppControllers.employee.employeeEntity?.email ?? '';
    if (me.isEmpty) {
      return const RoleDemoResult(
          roles: 0,
          accessLines: 0,
          accounts: 0,
          logs: 0,
          problems: <String>['Not signed in']);
    }
    final List<String> problems = <String>[];
    final Map<String, dynamic> seeded = _readSeeded();

    // ── 1. Roles ───────────────────────────────────────────────────────────
    final List<RoleHistoryModel> existing = await _existingRoles();
    final RoleHistoryModel? template =
        existing.firstWhereOrNullStatus(RoleStatus.active);
    final List<String> roleIds =
        List<String>.from(seeded['roles'] ?? const <String>[]);
    int rolesMade = 0;
    if (template == null) {
      problems.add('No active role to copy permissions from');
    } else {
      final Map<String, Map<String, bool>> perms =
          await _permissionsOf(template);
      for (final _DemoRole r in _demoRoles) {
        if (existing.any((RoleHistoryModel e) => e.currentRoleName == r.name)) {
          continue;
        }
        final Either<Failure, dynamic> res = await _roles.addNewRole(
          selectedModules: template.currentSelectedModules,
          roleName: r.name,
          roleNameAr: r.nameAr,
          roleDescription: r.description,
          roleDescriptionAr: r.descriptionAr,
          createdBy: me,
          roleImage: null,
          modulePermissions: perms,
          status: r.status,
        );
        res.fold((Failure f) => problems.add('Role ${r.name}: ${f.errMessage}'),
            (_) => rolesMade++);
      }
      for (final RoleHistoryModel e in await _existingRoles()) {
        if (_demoRoles.any((_DemoRole r) => r.name == e.currentRoleName) &&
            !roleIds.contains(e.roleId)) {
          roleIds.add(e.roleId);
        }
      }
    }

    // ── 2. User Management: Active · Scheduled · Expiring Soon · Ended ────
    final List<EmployeeEntityPro> people = _candidates(me);
    final Set<String> holding = await _currentHolders();
    final List<EmployeeEntityPro> free =
        people.where((EmployeeEntityPro e) => !holding.contains(e.id)).toList();
    final DateTime now = DateTime.now();
    final List<(String, DateTime, DateTime, int)> plan =
        <(String, DateTime, DateTime, int)>[
      (
        _demoRoles[0].name,
        now.subtract(const Duration(days: 20)),
        now.add(const Duration(days: 250)),
        2
      ),
      (
        _demoRoles[1].name,
        now.subtract(const Duration(days: 40)),
        now.add(const Duration(days: 300)),
        1
      ),
      (
        _demoRoles[1].name,
        now.add(const Duration(days: 10)),
        now.add(const Duration(days: 375)),
        2
      ),
      (
        _demoRoles[0].name,
        now.subtract(const Duration(days: 180)),
        now.add(const Duration(days: 6)),
        2
      ),
      (
        _demoRoles[1].name,
        now.subtract(const Duration(days: 300)),
        now.subtract(const Duration(days: 15)),
        2
      ),
    ];
    final List<String> accessIds =
        List<String>.from(seeded['access'] ?? const <String>[]);
    int linesMade = 0;
    int next = 0;
    for (final (String role, DateTime from, DateTime to, int count) in plan) {
      if (next + count > free.length) {
        problems.add('Not enough employees without access for "$role"');
        break;
      }
      final List<EmployeeEntityPro> group = free.sublist(next, next + count);
      next += count;
      final Either<Failure, dynamic> res =
          await _access.updateSelectedMembersPermission(
        currentUserEmail: me,
        accessName: role,
        startDate: _fmt(from),
        endDate: _fmt(to),
        selectedMembers: group,
      );
      res.fold((Failure f) => problems.add('Access "$role": ${f.errMessage}'),
          (_) {
        linesMade += count;
        accessIds.addAll(group.map((EmployeeEntityPro e) => e.id!));
      });
    }

    // ── 3. User Access: Deactivated · Locked · Scheduled (both ways) ──────
    final List<String> accountIds =
        List<String>.from(seeded['accounts'] ?? const <String>[]);
    final List<EmployeeEntityPro> accountPool = people.reversed
        .where((EmployeeEntityPro e) =>
            !accessIds.contains(e.id) && !accountIds.contains(e.id))
        .toList();
    final List<(EmployeeStatusEnum, String, String)> states =
        <(EmployeeStatusEnum, String, String)>[
      (EmployeeStatusEnum.deactivated, '', ''),
      (EmployeeStatusEnum.deactivated, '', ''),
      (EmployeeStatusEnum.locked, '', ''),
      (EmployeeStatusEnum.lockedWithRequest, '', ''),
      (EmployeeStatusEnum.active, _fmt(now.add(const Duration(days: 9))), ''),
      (EmployeeStatusEnum.active, _fmt(now.add(const Duration(days: 23))), ''),
      (
        EmployeeStatusEnum.deactivated,
        '',
        _fmt(now.add(const Duration(days: 5)))
      ),
      (
        EmployeeStatusEnum.deactivated,
        '',
        _fmt(now.add(const Duration(days: 14)))
      ),
    ];
    int accountsMade = 0;
    for (int i = 0; i < states.length && i < accountPool.length; i++) {
      final (EmployeeStatusEnum status, String deact, String act) = states[i];
      final bool ok = await _setAccount(accountPool[i].id!, status, deact, act);
      if (ok) {
        accountsMade++;
        accountIds.add(accountPool[i].id!);
      } else {
        problems.add('Account ${accountPool[i].email}: could not be saved');
      }
    }
    if (accountPool.length < states.length) {
      problems.add('Only ${accountPool.length} employees left for User Access');
    }

    // ── 4. System Logs from several employees, spread over two weeks ──────
    int logsMade = 0;
    final List<EmployeeEntityPro> loggers = people.take(8).toList();
    for (int i = 0; i < loggers.length * 3; i++) {
      final EmployeeEntityPro who = loggers[i % loggers.length];
      final (Modules module, String action) =
          _logActions[i % _logActions.length];
      final DateTime at =
          now.subtract(Duration(hours: 5 + i * 9, minutes: (i * 17) % 60));
      final bool ok = await _writeLog(who, module, action, at);
      if (ok) logsMade++;
    }

    _storage.write(_storageKey, <String, dynamic>{
      'roles': roleIds,
      'access': accessIds,
      'accounts': accountIds,
    });

    return RoleDemoResult(
      roles: rolesMade,
      accessLines: linesMade,
      accounts: accountsMade,
      logs: logsMade,
      problems: problems,
    );
  }

  /// Function Name: [remove]
  ///
  /// Purpose: Undo [load] — soft only: roles → Deleted, access lines →
  /// removed, accounts → Active with no schedule. Logs stay (a log is never
  /// edited, S-37).
  ///
  /// Returns: [Future<int>] how many records were reverted.
  Future<int> remove() async {
    final String me = AppControllers.employee.employeeEntity?.email ?? '';
    final Map<String, dynamic> seeded = _readSeeded();
    int undone = 0;
    final List<RoleHistoryModel> roles = await _existingRoles();
    for (final String id
        in List<String>.from(seeded['roles'] ?? const <String>[])) {
      final RoleHistoryModel? role =
          roles.where((RoleHistoryModel r) => r.roleId == id).firstOrNull;
      if (role == null) continue;
      final Either<Failure, dynamic> res =
          await _roles.deleteRole(role: role, currentUserEmail: me);
      if (res.isRight()) undone++;
    }
    for (final String id
        in List<String>.from(seeded['access'] ?? const <String>[])) {
      final Either<Failure, dynamic> res = await _access
          .deleteEmployeePermission(employeeId: id, currentUserEmail: me);
      if (res.isRight()) undone++;
    }
    for (final String id
        in List<String>.from(seeded['accounts'] ?? const <String>[])) {
      if (await _setAccount(id, EmployeeStatusEnum.active, '', '')) undone++;
    }
    _storage.remove(_storageKey);
    return undone;
  }

  /// Whether this device has seeded data that [remove] can undo.
  bool get hasSeeded => _storage.read(_storageKey) != null;

  // ── helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _readSeeded() {
    final Object? raw = _storage.read(_storageKey);
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<List<RoleHistoryModel>> _existingRoles() async {
    final Either<FirebaseFailure, dynamic> res =
        await _roles.getUnDeletedRoles();
    return res.fold(
      (_) => <RoleHistoryModel>[],
      (dynamic r) => List<RoleHistoryModel>.from(r as List),
    );
  }

  /// The template role's switches as plain bools (last history value).
  Future<Map<String, Map<String, bool>>> _permissionsOf(
      RoleHistoryModel role) async {
    final Either<FirebaseFailure, Map<String, Map<String, dynamic>>> res =
        await _roles.getAllRolePermissions(
      roleId: role.roleId,
      selectedModules: role.currentSelectedModules,
    );
    final Map<String, Map<String, dynamic>> raw =
        res.getOrElse(() => <String, Map<String, dynamic>>{});
    return <String, Map<String, bool>>{
      for (final MapEntry<String, Map<String, dynamic>> m in raw.entries)
        m.key: <String, bool>{
          for (final MapEntry<String, dynamic> p in m.value.entries)
            if (p.key != 'Role_Id' && p.key != 'timestamps')
              p.key: p.value is List
                  ? ((p.value as List).isNotEmpty &&
                      (p.value as List).last == true)
                  : p.value == true,
        },
    };
  }

  /// Employees the demo may touch: never the signed-in user or the company
  /// admin.
  List<EmployeeEntityPro> _candidates(String me) {
    final String? admin =
        AppControllers.company.state.company?.email?.emails?.last;
    return (AppControllers.employee.allEmployeesEntities ??
            const <EmployeeEntityPro>[])
        .where((EmployeeEntityPro e) =>
            (e.id ?? '').isNotEmpty &&
            (e.email ?? '').isNotEmpty &&
            e.email!.toLowerCase() != me.toLowerCase() &&
            e.email!.toLowerCase() != (admin ?? '').toLowerCase())
        .toList();
  }

  /// Employee ids whose current access line is not removed.
  Future<Set<String>> _currentHolders() async {
    final QuerySnapshot snap =
        await _access.remoteDataSource.accessEmployeeCollection.get();
    return <String>{
      for (final QueryDocumentSnapshot d in snap.docs)
        if (d.data() is Map<String, dynamic> &&
            _lastRole(d.data() as Map<String, dynamic>) !=
                Constants.removedEmployeePermission &&
            _lastRole(d.data() as Map<String, dynamic>).isNotEmpty)
          d.id,
    };
  }

  String _lastRole(Map<String, dynamic> data) {
    final Object? role = data['Role'];
    if (role is List) return role.isEmpty ? '' : role.last.toString();
    return role?.toString() ?? '';
  }

  Future<bool> _setAccount(
      String id, EmployeeStatusEnum status, String deact, String act) async {
    final Either<Failure, dynamic> read = await _accounts.getEmployeeModel(id);
    final Object? data = read.getOrElse(() => null);
    if (data is! Map<String, dynamic>) return false;
    final NewEmployeeModelHistory model =
        NewEmployeeModelHistory.fromMap(data).copyWithUpdateSynchronized(
      id: id,
      status: status.name,
      deactivationDate: deact,
      activationDate: act,
    );
    final Either<Failure, dynamic> saved =
        await _accounts.updateEmployeeModel(model);
    return saved.isRight();
  }

  Future<bool> _writeLog(
      EmployeeEntityPro who, Modules module, String action, DateTime at) async {
    try {
      final SystemLogsModel log = SystemLogsModel(
        module: module,
        userEmail: who.email,
        firstName: who.firstName ?? '',
        middleName: who.middleName ?? '',
        lastName: who.lastName ?? '',
        firstNameInArabic: who.firstNameInArabic ?? '',
        middleNameInArabic: who.middleNameInArabic ?? '',
        lastNameInArabic: who.lastNameInArabic ?? '',
        role: who.title ?? '',
        country: 'Egypt',
        city: 'New Administrative Capital',
        lat: '30.0370',
        long: '31.3453',
        action: action,
        timestamp: Timestamp.fromDate(at),
      );
      await _logs.addActivityLog(log);
      return true;
    } catch (_) {
      // One failed log line must not stop the rest of the demo data.
      return false;
    }
  }
}

extension on List<RoleHistoryModel> {
  RoleHistoryModel? firstWhereOrNullStatus(RoleStatus status) {
    for (final RoleHistoryModel r in this) {
      if (r.currentStatus == status && r.currentSelectedModules.isNotEmpty) {
        return r;
      }
    }
    return null;
  }
}
