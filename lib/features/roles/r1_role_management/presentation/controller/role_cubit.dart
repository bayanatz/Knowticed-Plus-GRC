/// Module: roles / r1_role_management / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: role_cubit.dart
/// Description: Declares `RoleCubit`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 9/10/2026 - Time Tracker QA KP-TT-001: [RoleCubit.newRoleDefaults]
/// — a new role starts with every Time Tracker switch OFF.
library;

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
// REPLACED 30/8/2026: path_provider — the only call was the
// getApplicationDocumentsDirectory() in exportRolesToCsv, now behind
// ExportDirectory.
// RE-ADDED 8/9/2026: getTemporaryDirectory(), where the phone export stages the
// CSV before handing it to the system save sheet. The user-visible destination
// is still ExportDirectory's business, not path_provider's.
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/core/helper/export_directory.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';

import 'package:knowticed_plus/core/network/api_constants.dart'
    hide FirebaseCollections;
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/repository/role_repository.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/module_name_aliases.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';

import 'dart:ui' as ui;

import 'package:knowticed_plus/core/constants/firebase_collections.dart';
part 'role_state.dart';
part 'role_cubit/role_cubit_methods.dart';
part 'role_cubit/role_cubit_methods_2.dart';
part 'role_cubit/role_cubit_methods_3.dart';

/// App-wide shared RoleCubit instance.
///
/// Moved here from role_responsive_page.dart so the many non-UI callers
/// (login, drawer, nav bar, active directory, system logs, user management…)
/// depend on the controller library instead of a UI page. Top-level variables
/// are lazily initialised in Dart, so this is only constructed on first use.
RoleCubit roleCubit = RoleCubit();

class RoleCubit extends Cubit<RoleState> {
  /// Public [emit] for this cubit's extension / part files and widgets
  /// ([emit] itself is protected).
  void emitState(RoleState state) => emit(state);

  RoleCubit() : super(RoleInitial());

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  Map<String, Map<String, bool>> modulePermissions = {};
  bool isActive = true;

  /// Cache for role permissions to avoid reloading
  final Map<String, Map<String, List<String>>> _rolePermissionsCache = {};

  void toggleActiveStatus(bool value) {
    isActive = value;
    emitSafely(RoleModuleSelected());
  }

  RoleRepository roleRepository = RoleRepository();
  final LiveRefresh _live = LiveRefresh();

  /// Single owner of the picker plugins (§16/§20) — the cubit never touches
  /// `ImagePicker` / `FilePicker` directly.
  final MediaPickerService mediaPickerService = MediaPickerService();

  File? roleImage;
  TextEditingController roleNameController = TextEditingController();
  TextEditingController roleNameControllerAr = TextEditingController();
  TextEditingController roleDescriptionController = TextEditingController();
  TextEditingController roleDescriptionControllerAr = TextEditingController();

  List<String> selectedModules = [];

  RoleStatus selectedRoleStatus = RoleStatus.all;
  List<RoleHistoryModel> roles = [];
  List<RoleHistoryModel> filteredRoles = [];
  RoleHistoryModel? selectedRole;
  TextEditingController searchController = TextEditingController();
  ModulesCubit modulesCubit = ModulesCubit();
  bool isEditing = false;

  /// ADDED 28/9/2026 — the Restricted Location allow-list being edited for
  /// this role: ISO country codes, picked on the third page of the role editor
  /// under the Restricted Location switch (`settings_switches_page.dart`).
  /// Saved with the role (see `RoleRepository.ROLE_RESTRICTED_LOCATIONS`) and
  /// enforced for its employees by `RestrictedLocationGuard`.
  List<String> restrictedCountryCodes = <String>[];

  /// Ticks / unticks one country in [restrictedCountryCodes].
  void toggleRestrictedCountry(String code) {
    if (!restrictedCountryCodes.remove(code)) {
      restrictedCountryCodes.add(code);
    }
    emitSafely(RoleSwitchToggled());
  }

  final List<String> availableModules = [
    'services',
    'services_app',
    'messages',
    'inventory',
    'settings',
    'qiyas',
    'knowledge_hub',
    'employees',
    'tasks',
    'events',
    'notes',
    'requests',
    'tracking',
    'database_builder',
    'roles',
    'hr', // ✅ ADDED
    'crm', // ✅ ADDED
    'notification', // ✅ ADDED
    // 'grc' was missing here while the module-selection UI offered it from
    // getDemoActiveModules(). _loadAdminRestrictions() only walks THIS list, so
    // no GRC template was ever fetched, isPermissionAllowedByAdmin('grc', …)
    // default-denied every key, and updateRole() reported every enabled GRC
    // permission as "restricted by administrator" with no switch able to clear
    // it. Same failure mode as `form_builder` — see [ModuleNameAliases].
    'grc',
    // ADDED 7/10/2026 — To-Do. Same failure mode as 'grc' above: absent from
    // this list, its `Demo_Permissions` template was never loaded and every
    // To-Do switch was default-denied.
    'todo',
    // ADDED 8/10/2026 — Time Tracker, same reason as 'todo' above.
    'time_tracker',
  ];

  /// The one name this class uses for a module, whatever spelling it arrived
  /// in. See [ModuleNameAliases] for why the spellings differ at all.
  static String canonicalModuleName(String moduleName) =>
      ModuleNameAliases.canonical(moduleName);

  final Map<String, Map<String, bool>> _adminRestrictions = {};

  String _getCompanyId() {
    try {
      String baseUrl = getBaseUrl('');
      String companyId =
          baseUrl.replaceAll('Demo/', '').replaceAll('/', '').trim();

      return companyId.isNotEmpty ? companyId : '';
    } catch (e) {
      return '';
    }
  }

  /// Preload permissions for all filtered roles
  Future<void> preloadAllRolePermissions() async {
    if (filteredRoles.isEmpty) {
      return;
    }

    await Future.wait(
      filteredRoles.map((role) => _preloadRolePermissions(role)),
    );
  }

  Map<String, List<String>>? getRolePermissions(String roleId) {
    return _rolePermissionsCache[roleId];
  }

  void clearPermissionsCache() {
    if (_rolePermissionsCache.isNotEmpty) {
      _rolePermissionsCache.clear();
    }
  }

  String _formatPermissionNameForDisplay(String permissionKey) {
    return permissionKey
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }

  /// Whether the admin permission template loaded successfully.
  ///
  /// When `false`, [isPermissionAllowedByAdmin] denies everything — see the
  /// comment there.
  bool _adminRestrictionsLoaded = true;

  /// Message from the last failed admin-restrictions load, if any.
  String? adminRestrictionsError;

  List<String> getBlockedPermissionsForModule(String moduleName) {
    if (!_adminRestrictions.containsKey(moduleName)) {
      return [];
    }

    Map<String, bool> moduleRestrictions = _adminRestrictions[moduleName]!;

    return moduleRestrictions.entries
        .where((entry) => entry.value == false)
        .map((entry) => entry.key)
        .toList();
  }

  Future<void> ensureSettingsSelected() async {
    if (!selectedModules.contains('settings')) {
      selectedModules.add('settings');
      if (!modulePermissions.containsKey('settings')) {
        modulePermissions['settings'] = await _getDefaultPermissionsForModule(
          'settings',
        );
      }
      emitSafely(RoleModuleSelected());
    } else {}
  }

  Future<void> initAddingRoleController() async {
    isEditing = false;
    isActive = true;
    roleImage = null;
    roleNameController.clear();
    roleNameControllerAr.clear();

    roleDescriptionController.clear();
    roleDescriptionControllerAr.clear();
    selectedModules = [];
    modulePermissions = {};
    restrictedCountryCodes = <String>[];

    await ensureSettingsSelected();
  }

  Future<Map<String, bool>> _getDefaultPermissionsForModule(
    String moduleName,
  ) async {
    Map<String, bool> permissions =
        await modulesCubit.getFilteredDefaultPermissionsForModule(moduleName);

    return newRoleDefaults(moduleName, permissions);
  }

  /// Function Name: [newRoleDefaults]
  ///
  /// Purpose: ADDED 9/10/2026 (Time Tracker QA KP-TT-001, least privilege) —
  /// the switches a module starts with on a new role, from the admin
  /// [ceiling] (every allowed key = true). Time Tracker starts every allowed
  /// switch OFF (phase-1 spec "all OFF" — it used to start ALL ON, Approvals
  /// "All Departments" and Delete Location included); the admin turns on
  /// what the role needs. Other modules keep their behaviour (owner to
  /// decide — Notification shows the same pattern).
  ///
  /// Return type: [Map<String, bool>]
  static Map<String, bool> newRoleDefaults(
    String moduleName,
    Map<String, bool> ceiling,
  ) {
    if (ModuleNameAliases.canonical(moduleName) == 'time_tracker') {
      return <String, bool>{for (final String key in ceiling.keys) key: false};
    }
    return ceiling;
  }

  void updateSelectedRoleStatus(RoleStatus roleStatus) {
    selectedRoleStatus = roleStatus;
    filterRoles();
  }

  /// Role ids whose permission preload is already running, so `filterRoles`
  /// and `preloadAllRolePermissions` never fetch the same role twice.
  final Map<String, Future<void>> _preloadsInFlight = <String, Future<void>>{};

  /// Loads the permission summary for every visible role that has none yet,
  /// then rebuilds the list once. Best-effort: [_preloadRolePermissions]
  /// already caches `{}` on failure, so a card can never be left spinning.
  Future<void> _preloadMissingRolePermissions() async {
    final List<RoleHistoryModel> missing = filteredRoles
        .where((role) => !_rolePermissionsCache.containsKey(role.roleId))
        .toList();
    if (missing.isEmpty) return;

    await Future.wait(missing.map(_preloadRolePermissions));
    emitSafely(RoleFiltered());
  }

  void clearFilters() {
    searchController.clear();
    selectedRoleStatus = RoleStatus.all;
    filterRoles();
  }

  String _moduleEnumToString(Modules module) {
    return moduleEnumToString(module);
  }

  // ───────────────────────────────────────────────────────────────────────
  // ROLE CREATION LOGIC
  //
  // Moved here from adding_new_role_methods1.dart so the "Add new role" page
  // only builds widgets. Covers text-direction detection, company licence
  // lookup (Firestore) and the module name <-> enum mapping used while
  // picking modules for a new role.
  // ───────────────────────────────────────────────────────────────────────

  /// True when [text] contains any Arabic character.
  bool containsArabic(String text) => RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  /// True when [text] contains any Latin character.
  bool containsEnglish(String text) => RegExp(r'[a-zA-Z]').hasMatch(text);

  /// Company id parsed out of [ApiConstants.baseUri] (format: "Demo/`<id>`").
  String? extractCompanyId() {
    if (ApiConstants.baseUri.isEmpty) return null;
    if (ApiConstants.baseUri.contains('/')) {
      final List<String> parts = ApiConstants.baseUri.split('/');
      if (parts.length >= 2) return parts[1];
    }
    return null;
  }

  /// Fallback used by [resolveCreatedByName] when no employee record matches.
  String _nameFromEmail(String email) {
    if (email.isEmpty) return '-';
    if (!email.contains('@')) return email;

    final String username = email.split('@').first;
    return username
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// The [Right] value [exportRolesToCsv] returns when the user dismissed the
  /// system save sheet without choosing a destination. Kept as an alias of
  /// `CSVHelper.exportCancelled` so the existing call sites read unchanged.
  static const String exportCancelled = CSVHelper.exportCancelled;

  Future<void> updateRole() async {
    if (selectedRole == null) return;

    // Retired keys first: they are invisible in the editor, so letting them
    // reach the scan below produces an error the user cannot clear.
    pruneRetiredPermissions();

    bool hasViolations = false;
    List<String> violations = [];

    for (String moduleName in selectedModules) {
      if (modulePermissions.containsKey(moduleName)) {
        Map<String, bool> modulePerms = modulePermissions[moduleName]!;

        modulePerms.forEach((permKey, permValue) {
          if (permValue == true &&
              !isPermissionAllowedByAdmin(moduleName, permKey)) {
            hasViolations = true;
            violations.add("$moduleName.$permKey");
          }
        });
      }
    }

    if (hasViolations) {
      emitSafely(
        RoleError(
          "Cannot update role: The following permissions are restricted by administrator:\n${violations.join('\n')}",
        ),
      );
      return;
    }

    Either<Failure, dynamic> result = await roleRepository.updateRole(
      role: selectedRole!,
      status: isActive ? RoleStatus.active : RoleStatus.inactive,
      currentUserEmail: AppControllers.employee.employeeEntity!.email!,
      roleDescription: roleDescriptionController.text,
      roleDescriptionAr: roleDescriptionControllerAr.text,
      roleNameAr: roleNameControllerAr.text,
      roleImage: roleImage?.path,
      selectedModules: selectedModules,
      modulePermissions: modulePermissions,
      restrictedCountryCodes: restrictedCountryCodes,
    );

    if (result.isRight()) {
      searchController.clear();

      // ✅ FIX: Invalidate this role's cache so preload fetches fresh data
      _rolePermissionsCache.remove(selectedRole!.roleId);

      await getUnDeletedRoles();
      await _refreshSignedInUserPermissionsIfAffected();
      emitSafely(RoleUpdated());
    } else {
      emitSafely(
        RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')),
      );
    }
  }

  /// Function Name: [employeesHoldingSelectedRole]
  ///
  /// Purpose: How many employees still hold [selectedRole] (ADDED 21/10/2026,
  /// X-87). Delete is offered only at 0.
  ///
  /// Returns: [Future<int?>] — `null` when the count could not be read.
  Future<int?> employeesHoldingSelectedRole() async {
    final RoleHistoryModel? role = selectedRole;
    if (role == null) return null;
    try {
      return await UserManagementAccessRepository().countCurrentHolders(
        roleId: role.roleId,
        roleName: role.currentRoleName,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteRole() async {
    if (selectedRole == null) {
      emitSafely(RoleError('No role selected'));
      return;
    }

    // ADDED 21/10/2026 (X-87): never delete a role employees still hold.
    final int? holders = await employeesHoldingSelectedRole();
    if (holders == null || holders > 0) {
      emitSafely(RoleError(holders == null
          ? 'Could not check who holds this role'
          : 'Role still held by $holders employees'));
      return;
    }

    Either<FirebaseFailure, dynamic> result = await roleRepository.deleteRole(
      role: selectedRole!,
      currentUserEmail: AppControllers.employee.employeeEntity!.email!,
    );

    if (result.isRight()) {
      // CLEAR SEARCH TEXT HERE
      searchController.clear();
      _rolePermissionsCache.remove(selectedRole!.roleId);
      await getUnDeletedRoles();
      emitSafely(RoleDeleted());
    } else {
      String errorMessage = result.fold(
        (l) => l.errMessage,
        (r) => 'Unknown error',
      );
      emitSafely(RoleError(errorMessage));
    }
  }

  bool isAdminAccessActive(Modules module) {
    return adminAccessModules.contains(module);
  }

  void toggleAdminAccess({required Modules module}) {
    if (adminAccessModules.contains(module)) {
      adminAccessModules.remove(module);
    } else {
      adminAccessModules.add(module);
    }
    emitSafely(RoleSwitchToggled());
  }

  bool isSectionActive(Modules module, ModulePermissionsSections section) {
    String moduleName = moduleEnumToString(module);

    if (!modulePermissions.containsKey(moduleName)) {
      return false;
    }

    if (section is ModulePermissionsSectionsPermission) {
      String sectionKey = _convertToDbFormat(
        (section as ModulePermissionsSectionsPermission).getDataBaseName,
      );
      return modulePermissions[moduleName]?[sectionKey] ?? false;
    }

    return false;
  }

  bool isSwitchActive(
    Modules module,
    ModulePermissionsSections section,
    ModulePermissionsSectionsPermission permission,
  ) {
    String moduleName = moduleEnumToString(module);
    String permissionKey = _convertToDbFormat(permission.getDataBaseName);

    return modulePermissions[moduleName]?[permissionKey] ?? false;
  }

  void toggleSwitchState({
    required Modules module,
    required ModulePermissionsSections section,
    required ModulePermissionsSectionsPermission permission,
  }) async {
    String moduleName = moduleEnumToString(module);
    String permissionKey = _convertToDbFormat(permission.getDataBaseName);

    if (!modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(
        moduleName,
      );
    }

    bool currentValue = modulePermissions[moduleName]![permissionKey] ?? false;
    bool newValue = !currentValue;

    if (newValue == true &&
        !isPermissionAllowedByAdmin(moduleName, permissionKey)) {
      emitSafely(
        RoleError(
          "Cannot enable '${permission.getDataBaseName}': This permission is restricted by the administrator.",
        ),
      );
      return;
    }

    modulePermissions[moduleName]![permissionKey] = newValue;

    emitSafely(RoleSwitchToggled());
  }

  String _convertToDbFormat(String displayName) {
    return displayName.trim().replaceAll(RegExp(r'\s+'), '_');
  }

  bool isModuleSelected(String moduleName) {
    return selectedModules.contains(moduleName);
  }

  Map<String, bool> getModulePermissions(String moduleName) {
    return Map<String, bool>.from(modulePermissions[moduleName] ?? {});
  }

  bool getPermissionValue(String moduleName, String permission) {
    return modulePermissions[moduleName]?[permission] ?? false;
  }

  void addModule(String moduleName) async {
    if (!selectedModules.contains(moduleName)) {
      selectedModules.add(moduleName);
      modulePermissions[moduleName] = await _getDefaultPermissionsForModule(
        moduleName,
      );
      emitSafely(RoleModuleSelected());
    }
  }

  void removeModule(String moduleName) {
    if (moduleName == 'settings') {
      return;
    }

    selectedModules.remove(moduleName);
    modulePermissions.remove(moduleName);
    emitSafely(RoleModuleSelected());
  }

  void updateModulePermissions(
    String moduleName,
    Map<String, bool> permissions,
  ) {
    if (modulePermissions.containsKey(moduleName)) {
      modulePermissions[moduleName]!.addAll(permissions);
      emitSafely(RolePermissionUpdated());
    }
  }

  Future<void> saveModulePermissions(String moduleName) async {
    if (selectedRole == null || !modulePermissions.containsKey(moduleName)) {
      return;
    }

    String roleId = selectedRole!.currentRoleName;
    Either<FirebaseFailure, String> result =
        await roleRepository.updateModulePermissions(
      roleId: roleId,
      module: moduleName,
      permissions: modulePermissions[moduleName]!,
    );

    if (result.isRight()) {
      emitSafely(RolePermissionSaved());
    } else {
      emitSafely(
        RoleError(result.fold((l) => l.errMessage, (r) => 'Unknown error')),
      );
    }
  }

  bool validateSelectedModules() {
    if (selectedModules.isEmpty) return false;

    for (String module in selectedModules) {
      if (!availableModules.contains(module)) {
        return false;
      }
    }

    return true;
  }

  List<String> getAvailableModules() {
    return availableModules
        .where((module) => !selectedModules.contains(module))
        .toList();
  }

  List<String> getDemoActiveModules() {
    return modulesCubit.getDemoActiveModules();
  }

  void clearAllPermissions() async {
    modulePermissions.clear();
    selectedModules.clear();
    await ensureSettingsSelected();
    emitSafely(RolePermissionsCleared());
  }

  Map<String, dynamic> exportRoleConfiguration() {
    return {
      'roleName': roleNameController.text,
      'roleNameAr': roleNameControllerAr.text,
      'roleDescription': roleDescriptionController.text,
      'roleDescriptionAr': roleDescriptionControllerAr.text,
      'selectedModules': selectedModules,
      'modulePermissions': modulePermissions,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> getRoleStatistics() {
    return {
      'totalRoles': roles.length,
      'activeRoles':
          roles.where((r) => r.currentStatus == RoleStatus.active).length,
      'draftRoles':
          roles.where((r) => r.currentStatus == RoleStatus.draft).length,
      'selectedModulesCount': selectedModules.length,
      'totalPermissionsCount': modulePermissions.values
          .map((perms) => perms.length)
          .fold(0, (total, value) => total + value),
    };
  }

  @Deprecated('Use new architecture methods instead')
  Map<
      Modules,
      Map<ModulePermissionsSections,
          Set<ModulePermissionsSectionsPermission>>> activeSwitches = {};

  @Deprecated('Use new architecture methods instead')
  Set<Modules> adminAccessModules = {};

  @Deprecated('Use new architecture methods instead')
  Map<Modules, Set<ModulePermissionsSections>> moduleSectionsHasFullAccess = {};

  @Deprecated('Use selectModule(String) instead')
  void selectModuleEnum(Modules module) {
    String moduleName = _moduleEnumToString(module);
    selectModule(moduleName);
  }

  String? get roleName => selectedRole?.currentRoleName;
}
