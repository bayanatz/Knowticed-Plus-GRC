/// Module: roles/r1_role_management
///
///*************************** FILE INFO ****************************///
/// File Name: role_cubit_methods_2.dart
/// Description: Methods of `RoleCubit` — split out of `role_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../role_cubit.dart';

// Split from role_cubit.dart to keep every file under 700 lines.

extension RoleCubitMethods2 on RoleCubit {
  /// Function Name: [pickRoleImage]
  ///
  /// Purpose: Pick and validate the avatar attached to a role.
  ///
  /// Layering note: the picker plugin used to be instantiated here
  /// (`ImagePicker()` inside the cubit), which §16/§20 forbid. The cubit now
  /// depends on [MediaPickerService] — the single owner of `ImagePicker` /
  /// `FilePicker` — and only validates and stores the result.
  ///
  /// Parameters:
  /// - [camera]: `true` to open the camera, `false` for the gallery.
  ///
  /// Returns: [Future<void>]; the picked file lands on [roleImage] and
  /// `RoleImagePicked` is emitted, or `RoleError` carries the reason.
  Future<void> pickRoleImage({required bool camera}) async {
    try {
      final PickedFileData? picked = await mediaPickerService.pickImage(
        fromCamera: camera,
        imageQuality: 85,
      );

      // User cancelled the picker.
      if (picked == null || picked.path == null) return;

      final String extension = picked.path!.split('.').last.toLowerCase();
      const List<String> validFormats = <String>[
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'bmp',
        'heic',
      ];
      if (!validFormats.contains(extension)) {
        if (isClosed) return;
        emitSafely(RoleError("Invalid format. Please use JPG, PNG, or WEBP"));
        return;
      }

      final File file = File(picked.path!);
      if (!await file.exists()) {
        if (isClosed) return;
        emitSafely(RoleError("Image file not found"));
        return;
      }

      final Uint8List bytes = Uint8List.fromList(picked.bytes);

      // Decode once to prove the bytes really are an image.
      try {
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        frameInfo.image.dispose();
        codec.dispose();
      } catch (_) {
        if (isClosed) return;
        emitSafely(RoleError("Invalid or corrupted image file"));
        return;
      }

      if (bytes.length > 10 * 1024 * 1024) {
        if (isClosed) return;
        emitSafely(
          RoleError("Image too large. Please use an image under 10MB"),
        );
        return;
      }

      roleImage = file;
      if (isClosed) return;
      emitSafely(RoleImagePicked());
    } catch (e) {
      if (isClosed) return;
      emitSafely(RoleError("Failed to load image: $e"));
    }
  }

  void filterRoles() {
    // REMOVE emit(RoleLoading()) from here if roles are already loaded

    filteredRoles = [];
    String searchText = searchController.text.toLowerCase().trim();

    for (var role in roles) {
      bool matchesStatus = (role.currentStatus == selectedRoleStatus ||
          selectedRoleStatus == RoleStatus.all);

      bool matchesSearch = searchText.isEmpty ||
          role.currentRoleName.toLowerCase().contains(searchText) ||
          role.currentRoleNameAr.contains(searchController.text.trim());

      if (matchesStatus && matchesSearch) {
        filteredRoles.add(role);
      }
    }

    emitSafely(RoleFiltered());

    // ADDED 21/9/2026 — a role card spins until its permissions are in
    // `_rolePermissionsCache`, but the cache was only ever filled for the roles
    // visible when `getUnDeletedRoles` ran. Change a role's status (e.g.
    // Inactive -> Active) while a status chip hides it, switch chips, and the
    // card that appears has no cache entry and nothing to load one: it spun
    // forever (bug report p.3). Load whatever the new filter reveals.
    _preloadMissingRolePermissions();
  }

  Future<void> selectRole(RoleHistoryModel role) async {
    selectedRole = role;

    // Canonicalised (23/8/2026): `updateRole` walks `selectedModules` and looks
    // each name up in `modulePermissions`, which `_loadAllModulePermissions`
    // keys canonically. A stored `form_builder` here would miss that bucket —
    // or, worse, match a stale one. See [ModuleNameAliases].
    selectedModules = role.currentSelectedModules
        .map(RoleCubit.canonicalModuleName)
        .toSet()
        .toList();

    roleNameController.text = role.currentRoleName;
    roleNameControllerAr.text = role.currentRoleNameAr;
    roleDescriptionController.text = role.currentRoleDescription;
    roleDescriptionControllerAr.text = role.currentRoleDescriptionAr;

    roleImage = null;

    isEditing = (role.currentStatus != RoleStatus.draft);
    isActive = role.currentStatus == RoleStatus.active;

    await ensureSettingsSelected();

    await _loadAllModulePermissions(role);

    restrictedCountryCodes = await roleRepository.getRestrictedCountryCodes(
      role.roleId,
    );

    emitSafely(RoleSelected());
  }

  String moduleEnumToString(Modules module) {
    switch (module) {
      case Modules.employees:
        return 'employees';
      case Modules.services:
        return 'services';
      case Modules.tasks:
        return 'tasks';
      case Modules.todo:
        return 'todo';
      case Modules.events:
        return 'events';
      case Modules.notes:
        return 'notes';
      case Modules.requests:
        return 'requests';
      case Modules.knowledgeHub:
        return 'knowledge_hub';
      case Modules.qiyas:
        return 'qiyas';
      case Modules.tracking:
        return 'tracking';
      case Modules.inventory:
        return 'inventory';
      case Modules.messages:
        return 'messages';
      case Modules.database:
        return 'database_builder';
      case Modules.formBuilder:
        return 'services_app';
      case Modules.roles:
        return 'roles';
      case Modules.settings:
        return 'settings';
      case Modules.hr: // ✅ ADDED
        return 'hr';
      case Modules.crm: // ✅ ADDED
        return 'crm';
      case Modules.notification: // ✅ ADDED
        return 'notification';
      // ADDED 13/9/2026. Without this case GRC fell through to the default
      // and answered 'employees' — so the GRC block would have read and
      // WRITTEN the employees permission document. The silent-default shape of
      // this switch is why that would never have thrown; it would just have
      // corrupted a neighbouring module's permissions.
      //
      // 'grc' matches the key the admin dashboard writes
      // (_getDefaultPermissionsForModule('grc')) and the one
      // _isModuleLicensed / _getModuleEnum already use elsewhere.
      case Modules.grc:
        return 'grc';
      case Modules.timeTracker: // ADDED 8/10/2026 — Time Tracker
        return 'time_tracker';
      default:
        return 'employees';
    }
  }

  /// Modules the current company is licensed for, keyed by lowercase name.
  ///
  /// Falls back to "everything enabled" when no company id is resolvable, which
  /// preserves the previous behaviour for local/demo sessions.
  Future<Map<String, bool>> loadCompanyLicensedModules() async {
    try {
      final String? companyId = extractCompanyId();

      if (companyId == null || companyId.isEmpty) {
        return {
          'services': true, 'tasks': true, 'tracking': true,
          'inventory': true, 'messages': true, 'roles': true,
          'knowledge_hub': true, 'knowledgehub': true, 'qiyas': true,
          'grc': true, 'services_app': true, 'formbuilder': true,
          'todo': true, 'employees': true, 'events': true,
          'notes': true, 'requests': true, 'database': true,
          'notification': true,
          'hr': true,
          'crm': true,
          'database_builder': true,
          'time_tracker': true, // ADDED 8/10/2026 — Time Tracker
        };
      }

      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollections.demoRequests)
          .doc(companyId)
          .get();

      if (!snapshot.exists) return {};

      final data = snapshot.data();
      if (data == null) return {};

      Map? modulesData;
      if (data['Demo_Details'] is Map &&
          (data['Demo_Details'] as Map)['Modules'] is Map) {
        modulesData = (data['Demo_Details'] as Map)['Modules'] as Map;
      } else if (data['Modules'] is Map) {
        modulesData = data['Modules'] as Map;
      }

      if (modulesData == null) return {};

      final Map<String, bool> licensedModules = {};
      for (final entry in modulesData.entries) {
        final moduleName = entry.key.toString().toLowerCase();
        final moduleData = entry.value;
        bool isLicensed = false;

        if (moduleData is Map) {
          final values = moduleData['Values'];
          if (values is List && values.isNotEmpty) {
            isLicensed = values.last == true;
          }
        } else if (moduleData is bool) {
          isLicensed = moduleData;
        } else if (moduleData is List && moduleData.isNotEmpty) {
          isLicensed = moduleData.last == true;
        }

        licensedModules[moduleName] = isLicensed;
      }

      return licensedModules;
    } catch (e) {
      return {};
    }
  }

  /// Module names selectable when creating a role.
  Future<List<String>> getAllowedModulesForRoleCreation() async {
    try {
      // Was `Get.find<ModulesCubit>()`. GetX is banned, and the lookup was
      // fragile besides: nothing registers a ModulesCubit in the locator, so
      // this threw and the whole method fell through to its catch. This cubit
      // already owns an instance — use it.
      final List<String> masterAdminModules =
          modulesCubit.getDemoActiveModules();
      masterAdminModules.removeWhere((m) => m == 'home' || m == 'settings');

      final Map<String, bool> companyLicensedModules =
          await loadCompanyLicensedModules();

      final List<String> allowedModules = [];
      for (final entry in companyLicensedModules.entries) {
        if (entry.value) allowedModules.add(entry.key);
      }
      return allowedModules;
    } catch (e) {
      return [];
    }
  }

  /// Maps a stored module name to its [Modules] enum.
  ///
  /// Throws for unknown names so callers can skip modules they don't render.
  /// Paired with [moduleEnumToSelectionString] — use the two together so the
  /// name -> enum -> name round trip stays consistent. Note this is
  /// deliberately NOT the inverse of [moduleEnumToString], which serialises
  /// `database` as `database_builder` for the permissions payload.
  Modules stringToModuleEnum(String moduleName) {
    // Canonical first (23/8/2026): this used to throw on `form_builder` and
    // `database_builder`, and `moduleEnumsFor` swallows the throw — so a role
    // storing either name lost the module from the editor entirely, switches
    // and all. See [ModuleNameAliases].
    switch (RoleCubit.canonicalModuleName(moduleName)) {
      case 'services':
        return Modules.services;
      case 'employees':
        return Modules.employees;
      case 'tasks':
        return Modules.tasks;
      case 'todo':
        return Modules.todo;
      case 'notes':
        return Modules.notes;
      case 'events':
        return Modules.events;
      case 'requests':
        return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':
        return Modules.knowledgeHub;
      case 'qiyas':
        return Modules.qiyas;
      case 'inventory':
        return Modules.inventory;
      case 'tracking':
        return Modules.tracking;
      case 'grc':
        return Modules.grc;
      case 'database_builder':
        return Modules.database;
      case 'messages':
        return Modules.messages;
      case 'services_app':
        return Modules.formBuilder;
      case 'roles':
        return Modules.roles;
      case 'settings':
        return Modules.settings;
      case 'notification':
        return Modules.notification;
      case 'crm':
        return Modules.crm;
      case 'time_tracker':
        return Modules.timeTracker; // ADDED 8/10/2026
      case 'hr':
        return Modules.hr; // ✅ ADDED — was missing, so 'hr' threw and
      // the module grid in adding_new_role.dart silently skipped it.
      default:
        throw Exception("Unknown module: $moduleName");
    }
  }

  /// Function Name: [creatorEmployeeFor]
  ///
  /// Purpose: Resolve the employee record behind a role's `Created_By` email.
  ///
  /// Why this exists: `role_overview.dart` did this lookup inside a widget,
  /// wrapped in `try/catch` because the employee controller may not be
  /// registered yet — both forbidden in the UI layer (§11.2/§16). Callers get
  /// `null` and fall back to the raw email; no exception escapes.
  ///
  /// Parameters:
  /// - [createdBy]: The stored creator email.
  ///
  /// Returns: The matching employee entity, or `null` when unresolvable.
  dynamic creatorEmployeeFor(String createdBy) {
    if (createdBy.isEmpty) return null;
    try {
      return AppControllers.employee.getLocaleEmployee(createdBy);
    } catch (e) {
      return null;
    }
  }

  /// Function Name: [modulePermissionsSnapshotFor]
  ///
  /// Purpose: Read the on/off state of every permission of every module a role
  /// currently holds.
  ///
  /// Why this exists: `module_permissions_widget.dart` reached through the
  /// cubit into `controller.roleRepository` and ran the query itself — a widget
  /// talking to the data layer (§16). It now awaits this instead.
  ///
  /// Parameters:
  /// - [role]: The role whose permissions to read.
  ///
  /// Returns: [Future<Map<String, Map<String, bool>>>] keyed by module name;
  /// empty on failure.
  Future<Map<String, Map<String, bool>>> modulePermissionsSnapshotFor(
    RoleHistoryModel role,
  ) async {
    final List<String> moduleNames = role.currentSelectedModules
        .map(RoleCubit.canonicalModuleName)
        .toSet()
        .toList();
    if (moduleNames.isEmpty) return <String, Map<String, bool>>{};

    final result = await roleRepository.getAllRolePermissions(
      roleId: role.roleId,
      selectedModules: moduleNames,
    );
    if (result.isLeft()) return <String, Map<String, bool>>{};

    final Map<String, Map<String, dynamic>> allPermissions = result.getOrElse(
      () => {},
    );
    final Map<String, Map<String, bool>> snapshot =
        <String, Map<String, bool>>{};

    for (final String moduleName in moduleNames) {
      final Map<String, dynamic>? moduleData = allPermissions[moduleName];
      if (moduleData == null) continue;

      final Map<String, bool> permissions = <String, bool>{};
      moduleData.forEach((key, value) {
        if (key == 'Role_Id' || key == 'timestamps') return;
        if (value is List && value.isNotEmpty) {
          final last = value.last;
          permissions[key] = (last == true || last == 1);
        } else if (value is bool) {
          permissions[key] = value;
        }
      });
      snapshot[moduleName] = permissions;
    }

    return snapshot;
  }

  /// Function Name: [employeeByEmail]
  ///
  /// Purpose: Find a loaded employee record by email, case-insensitively.
  ///
  /// Why this exists: three widgets did this with `firstWhereOrNull` on
  /// `Get.find<MainCoreEmployeeController>().allEmployeesEntities`. That
  /// extension came from `package:get` (banned) and `collection` is only a
  /// transitive dependency here, so the lookup is a plain loop and lives on the
  /// cubit rather than in the UI layer.
  ///
  /// Parameters:
  /// - [email]: The address to match.
  ///
  /// Returns: The matching employee entity, or `null`.
  dynamic employeeByEmail(String email) {
    if (email.isEmpty) return null;

    final employees = AppControllers.employee.allEmployeesEntities;
    if (employees == null) return null;

    final String needle = email.toLowerCase();
    for (final dynamic e in employees) {
      if (e.email?.toString().toLowerCase() == needle) return e;
    }
    return null;
  }

  /// Function Name: [resolveCreatedByName]
  ///
  /// Purpose: Turn a `Created_By` email into a display name for the roles table.
  ///
  /// Why this exists: the same lookup lived in `table_widget.dart` behind a
  /// `try { ... } catch (_) {}` — a swallowed error in a widget (§11.2/§11.5).
  /// It also read the locale from `Get.locale`; the caller now passes it, so no
  /// GetX dependency remains.
  ///
  /// Parameters:
  /// - [createdBy]: The stored creator email.
  /// - [isArabic]: Whether to prefer the Arabic name fields.
  ///
  /// Returns: [String] full name, or a name parsed from the email as fallback.
  String resolveCreatedByName(String createdBy, {required bool isArabic}) {
    if (createdBy.isEmpty) return '-';

    try {
      final dynamic employee = employeeByEmail(createdBy);

      if (employee != null) {
        if (isArabic) {
          final String arName = '${employee.firstNameInArabic ?? ''} '
                  '${employee.middleNameInArabic ?? ''} '
                  '${employee.lastNameInArabic ?? ''}'
              .trim();
          if (arName.isNotEmpty) return arName;
        }
        final String enName = '${employee.firstName ?? ''} '
                '${employee.middleName ?? ''} '
                '${employee.lastName ?? ''}'
            .trim();
        if (enName.isNotEmpty) return enName;
      }
    } catch (e) {
      debugPrint('Ignored error: $e');
    }

    return _nameFromEmail(createdBy);
  }

  /// Function Name: [formatRoleDate]
  ///
  /// Purpose: Format a role timestamp for display.
  ///
  /// Why this exists: `table_widget.dart` called `DateFormat(...).format(...)`
  /// inside a `try/catch` because the locale data may not be initialised.
  /// Formatting policy is not a widget concern (§11.2).
  ///
  /// Parameters:
  /// - [date]: The value to format; `null` renders as `-`.
  /// - [isArabic]: Selects the `ar` or `en` locale.
  ///
  /// Returns: [String] formatted date, or `-` when unavailable.
  String formatRoleDate(DateTime? date, {required bool isArabic}) {
    if (date == null) return '-';
    try {
      return DateFormat('dd MMM yyyy', isArabic ? 'ar' : 'en').format(date);
    } catch (e) {
      return '-';
    }
  }

  /// Function Name: [loadActivePermissionsFor]
  ///
  /// Purpose: List the enabled permission names for one module of one role.
  ///
  /// Why this exists: `table_widget.dart` constructed its own `RoleRepository`
  /// and ran the read inside a widget-level `try/catch`, bypassing the cubit
  /// entirely (§11.2/§16). The widget now awaits this instead.
  ///
  /// Parameters:
  /// - [roleId]: Role document id.
  /// - [moduleName]: Module whose permissions to read.
  ///
  /// Returns: [Future<List<String>>] display-formatted permission names;
  /// empty on failure.
  Future<List<String>> loadActivePermissionsFor({
    required String roleId,
    required String moduleName,
  }) async {
    try {
      final result = await roleRepository.getRolePermissions(
        roleId: roleId,
        module: moduleName,
      );

      if (result.isLeft()) return const <String>[];

      final Map<String, dynamic>? moduleData = result.getOrElse(() => null);
      if (moduleData == null) return const <String>[];

      final List<String> activePermissions = <String>[];
      moduleData.forEach((key, value) {
        if (key == 'Role_Id' || key == 'timestamps') return;

        bool isActive = false;
        if (value is List && value.isNotEmpty) {
          final last = value.last;
          isActive = (last == true || last == 1 || last == '1');
        } else if (value is bool) {
          isActive = value;
        }

        if (isActive) {
          activePermissions.add(_formatPermissionNameForDisplay(key));
        }
      });

      return activePermissions;
    } catch (e) {
      return const <String>[];
    }
  }

  /// Function Name: [exportRolesToCsv]
  ///
  /// Purpose: Write a generated CSV payload somewhere the user can open it.
  ///
  /// Why this exists: `export_role_widget.dart` performed the filesystem write
  /// inside the widget behind a `try/catch` (§11.2). The widget now supplies
  /// the rendered CSV text and reacts to the result.
  ///
  /// FIXED 30/8/2026 — reported as "export in roles does not export". It did:
  /// this wrote to `getApplicationDocumentsDirectory()`, which under
  /// `com.apple.security.app-sandbox` is the container's Documents folder, NOT
  /// `~/Documents`. The write succeeded, the success dialog played, and the file
  /// sat in `~/Library/Containers/com.example.knowticedPlus/Data/Documents/`
  /// where nobody looks. [ExportDirectory.resolve] now picks the real Downloads
  /// folder, the same one the Knowledge Hub download uses.
  ///
  /// The UTF-8 BOM went in at the same time. Role names carry Arabic
  /// (`currentRoleNameAr`), and Excel reads a BOM-less UTF-8 CSV as the local
  /// codepage — the Arabic columns opened as mojibake. Every other CSV writer in
  /// the app already prefixes it.
  ///
  /// FIXED 8/9/2026 — reported again as "export does not work, nothing
  /// downloads", this time on PHONES. The 30/8 fix above is desktop-only:
  ///
  /// - Android: [ExportDirectory.resolve] writes straight into
  ///   `/storage/emulated/0/Download`. Scoped storage (API 29+) forbids that,
  ///   so `File.writeAsBytes` threw `Permission denied` and the export ended on
  ///   an error SnackBar — which the export dialog's own modal barrier covered,
  ///   so from the user's side the button simply did nothing.
  /// - iOS: the write SUCCEEDED, into the app's private Documents folder. There
  ///   is no user-visible Downloads on iOS and this app does not publish its
  ///   Documents folder to the Files app, so the file existed but could not be
  ///   reached from anywhere.
  ///
  /// Both platforms now stage the CSV in the temp folder and hand it to the
  /// system save sheet through `flutter_file_dialog` — SAF on Android, the
  /// share/"Save to Files" sheet on iOS — which is exactly what the Knowledge
  /// Hub download does (`knowledge_hub_file_operations.dart`) and the one path
  /// that needs no storage permission on any Android version. The user picks
  /// the destination, so there is no "where did it go" to answer.
  ///
  /// Desktop is unchanged: real Downloads via [ExportDirectory].
  ///
  /// Parameters:
  /// - [fileName]: User-entered name; `.csv` is appended when missing.
  /// - [csvContent]: The fully rendered CSV body.
  ///
  /// Returns: [Future<Either<String, String>>] Left = error message,
  /// Right = the saved file path, or [exportCancelled] when the user dismissed
  /// the system save sheet — nothing was written and nothing went wrong, so the
  /// caller shows neither a success nor an error.
  ///
  /// MOVED 10/9/2026 — the implementation is now `CSVHelper.exportForUser`, so
  /// the phone export screens get the same fixes instead of a second copy of
  /// this method's history. This is a thin forward; the contract is unchanged.
  Future<Either<String, String>> exportRolesToCsv({
    required String fileName,
    required String csvContent,
  }) {
    return CSVHelper().exportForUser(
      fileName: fileName,
      csvContent: csvContent,
    );
  }
}
