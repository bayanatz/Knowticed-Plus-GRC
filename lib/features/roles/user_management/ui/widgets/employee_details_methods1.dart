part of '../pages/employee_details.dart';

extension EmployeeDetailsMethods1 on _RoleEmployeeDetailsPageState {
  Future<void> _initializePage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roleCubit = context.read<RoleCubit>();
      if (roleCubit.roles.isEmpty) {
        await roleCubit.getUnDeletedRoles();
      }
      await _loadPermissions();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  void _loadEmployeeData() {
    try {
      currentEmployeeEntity =
          employeeController.allEmployeesEntities?.firstWhereOrNull(
                (employee) => employee.id == widget.userPermission.employeeId,
          );
      if (currentEmployeeEntity != null && mounted) setState(() {});
    } catch (e) {
    }
  }
  Future<void> _loadPermissions() async {
    if (_permissionsLoaded) return;

    final roleName = widget.userPermission.accessName;

    if (roleName == null || roleName.isEmpty) {
      setState(() {
        _permissionsLoaded = true;
        _isLoading = false;
      });
      return;
    }

    try {
      final roleCubit = context.read<RoleCubit>();

      if (roleCubit.roles.isEmpty) {
        await roleCubit.getUnDeletedRoles();
      }

      if (roleCubit.roles.isEmpty) {
        setState(() {
          _errorMessage = 'No roles found. Please try again.';
          _isLoading = false;
        });
        return;
      }

      final role = roleCubit.roles.firstWhereOrNull(
            (r) => r.roleId == roleName || r.currentRoleName == roleName,
      );

      if (role == null) {
        setState(() {
          _errorMessage = 'Role "$roleName" not found';
          _isLoading = false;
        });
        return;
      }

      activeModuleStrings = role.currentSelectedModules;

      var result = await roleCubit.roleRepository.getAllRolePermissions(
        roleId: role.roleId,
        selectedModules: activeModuleStrings,
      );

      if (result.isRight()) {
        Map<String, Map<String, dynamic>> allPermissions =
        result.getOrElse(() => {});

        for (String moduleName in activeModuleStrings) {
          List<String> activePermissions = [];

          if (allPermissions.containsKey(moduleName)) {
            Map<String, dynamic> moduleData = allPermissions[moduleName]!;

            moduleData.forEach((key, value) {
              if (key != 'Role_Id' && key != 'timestamps') {
                bool isActive = false;
                if (value is List && value.isNotEmpty) {
                  var lastValue = value.last;
                  isActive =
                  (lastValue == true || lastValue == 1 || lastValue == '1');
                } else if (value is bool) {
                  isActive = value;
                }
                if (isActive) activePermissions.add(key);
              }
            });
          }

          _modulePermissions[moduleName] = activePermissions;
        }
      }

      setState(() {
        _permissionsLoaded = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  String _formatPermissionName(String permissionKey) {
    String formatted = permissionKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
    return formatted.tr;
  }
  String _getModuleDisplayName(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'services':         return 'Services'.tr;
      case 'todo':             return 'To Do List'.tr;
      case 'notes':            return 'Notes'.tr;
      case 'knowledge_hub':    return 'Knowledge Hub'.tr;
      case 'notification':
      case 'notifications':    return S.of(context).notifications;
      case 'qiyas':
      case 'grc':              return 'Qiyas'.tr;
      case 'inventory':        return 'Inventory'.tr;
      case 'messages':         return 'Messages'.tr;
      case 'form_builder':     return 'Form Builder'.tr;
      case 'roles':            return 'Roles'.tr;
      case 'settings':         return 'Settings'.tr;
      case 'employees':        return 'Employees'.tr;
      case 'tasks':            return 'Tasks'.tr;
      case 'events':           return 'Events'.tr;
      case 'requests':         return 'Requests'.tr;
      case 'tracking':         return 'Tracking'.tr;
      case 'database_builder': return 'Database Builder'.tr;
      default:
        return moduleName
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : '')
            .join(' ')
            .tr;
    }
  }
  Modules? _getModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase().trim()) {
      case 'employees':         return Modules.employees;
      case 'services':          return Modules.services;
      case 'tasks':             return Modules.tasks;
      case 'todo':              return Modules.todo;
      case 'events':            return Modules.events;
      case 'notes':             return Modules.notes;
      case 'requests':          return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub':      return Modules.knowledgeHub;
      case 'qiyas':             return Modules.qiyas;
      case 'grc':               return Modules.grc;
      case 'tracking':          return Modules.tracking;
      case 'inventory':         return Modules.inventory;
      case 'messages':          return Modules.messages;
      case 'database_builder':
      case 'database':          return Modules.database;
      case 'form_builder':
      case 'formbuilder':       return Modules.formBuilder;
      case 'roles':             return Modules.roles;
      case 'settings':          return Modules.settings;
      case 'home':              return Modules.home;
      case 'notification':
      case 'notifications':     return Modules.notification;
      default:                  return null;
    }
  }
  String _getSupervisorName() {
    if (currentEmployeeEntity?.supervisor == null ||
        currentEmployeeEntity!.supervisor!.isEmpty) return '-';
    return employeeController
        .getEmployeeName(currentEmployeeEntity!.supervisor!);
  }
  String _getCurrentRoleName() {
    if (currentEmployeeEntity != null &&
        currentEmployeeEntity!.role != null &&
        currentEmployeeEntity!.role!.isNotEmpty) {
      final currentRole = currentEmployeeEntity!.role!;
      if (currentRole.isEmpty) return 'No Role'.tr;

      try {
        final roleCubit = context.read<RoleCubit>();
        final role = roleCubit.roles.firstWhereOrNull(
                (r) => r.roleId == currentRole || r.currentRoleName == currentRole);

        if (role != null) {
          final isArabic =
              Localizations.localeOf(context).languageCode == 'ar';
          return isArabic
              ? (role.currentRoleNameAr ?? role.currentRoleName)
              : role.currentRoleName;
        }
        return currentRole;
      } catch (e) {
        return currentRole;
      }
    }

    final roleName = widget.userPermission.getLocalizedRoleName();
    return roleName.isEmpty ? 'No Role'.tr : roleName;
  }
  String _getTotalModules() {
    if (widget.userPermission.accessName == null ||
        widget.userPermission.accessName!.isEmpty) return '0';
    try {
      final roleCubit = context.read<RoleCubit>();
      final role = roleCubit.roles.firstWhereOrNull((r) =>
      r.roleId == widget.userPermission.accessName ||
          r.currentRoleName == widget.userPermission.accessName);
      if (role != null && role.currentSelectedModules.isNotEmpty) {
        return role.currentSelectedModules.length.toString();
      }
      return '0';
    } catch (e) {
      return '0';
    }
  }
  Future<bool> _removeUserAccess({required String employeeId}) async {
    try {
      final userMgmtCubit = context.read<UserManagementAccessCubit>();
      final currentUserEmail =
      Get.find<MainCoreEmployeeController>().employeeEntity!.email!;

      final dynamic result =
      await userMgmtCubit.repository.deleteEmployeePermission(
        employeeId: employeeId,
        currentUserEmail: currentUserEmail,
      );

      final resultStr = result.toString();
      if (resultStr.startsWith('Left(')) return false;
      return true;
    } catch (e) {
      return false;
    }
  }
  void _showTimedSuccessDialog({
    required BuildContext context,
    required String lottiePath,
    required String title,
    required String message,
    int seconds = 3,
    required VoidCallback onAfterDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        Future.delayed(Duration(seconds: seconds), () {
          if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
            Navigator.of(dialogCtx, rootNavigator: true).pop();
          }
          onAfterDismiss();
        });
        return ConfirmationDialog(
          lottiePath: lottiePath,
          title: title,
          message: message,
        );
      },
    );
  }
}
