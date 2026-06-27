part of '../pages/adding_new_role.dart';

extension AddingNewRoleMethods1 on _AddingNewRoleState {
  bool _containsArabic(String text) {
    
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
  bool _containsEnglish(String text) {
    return RegExp(r'[a-zA-Z]').hasMatch(text);
  }
  // ─────────────────────────────────────────────
  // STATUS TOGGLE DIALOG — same style as services
  // ─────────────────────────────────────────────
  Future<bool> _showStatusConfirmDialog(BuildContext context, bool newValue) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _RoleStatusChangeDialog(activating: newValue),
    );
    return result ?? false;
  }
  // ── module loading helpers (unchanged) ──────────────────────────────────

  Future<List<String>> _getAllowedModulesForRoleCreation() async {
    try {
      ModulesController modulesController = Get.find<ModulesController>();
      List<String> masterAdminModules = modulesController.getDemoActiveModules();
      masterAdminModules.removeWhere((m) => m == 'home' || m == 'settings');

      Map<String, bool> companyLicensedModules = await _loadCompanyLicensedModules();

      List<String> allowedModules = [];
      for (var entry in companyLicensedModules.entries) {
        if (entry.value) allowedModules.add(entry.key);
      }
      return allowedModules;
    } catch (e) {
      return [];
    }
  }
  Future<Map<String, bool>> _loadCompanyLicensedModules() async {
    try {
      String? companyId = _extractCompanyId();

      if (companyId == null || companyId.isEmpty) {
        return {
          'services': true, 'tasks': true, 'tracking': true,
          'inventory': true, 'messages': true, 'roles': true,
          'knowledge_hub': true, 'knowledgehub': true, 'qiyas': true,
          'grc': true, 'form_builder': true, 'formbuilder': true,
          'todo': true, 'employees': true, 'events': true,
          'notes': true, 'requests': true, 'database': true,
          'notification': true, 'hr': true, 'database_builder': true,
        };
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('Demo_Requests')
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

      Map<String, bool> licensedModules = {};
      for (var entry in modulesData.entries) {
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
  String? _extractCompanyId() {
    if (ApiConstants.baseUri.isEmpty) return null;
    if (ApiConstants.baseUri.contains('/')) {
      List<String> parts = ApiConstants.baseUri.split('/');
      if (parts.length >= 2) return parts[1];
    }
    return null;
  }
  // ── field builders (unchanged) ──────────────────────────────────────────

  Widget _buildEnglishNameField() {
    return CustomTextField(
      label: 'Role Name',
      hint: 'Role Name',
      controller: controller.roleNameController,
      required: true,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      height: 65.h,
      valueStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
      labelStyle:
      AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp),
      onChanged: (value) => controller.emit(RoleModuleSelected()),
    );
  }
  Widget _buildArabicNameField() {
    return CustomTextField(
      label: 'اسم الدور',
      hint: 'اسم الدور',
      controller: controller.roleNameControllerAr,
      required: true,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      height: 65.h,
      valueStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
      labelStyle:
      AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp),
      onChanged: (value) => controller.emit(RoleModuleSelected()),
    );
  }
  Widget _buildEnglishDescriptionField() {
    return CustomTextField(
      label: 'Role Description',
      hint: 'Role Description',
      controller: controller.roleDescriptionController,
      required: true,
      maxLines: 3,
      minLines: 3,
      maxLength: 500,
      showCharCount: true,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      valueStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
      labelStyle:
      AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp),
    );
  }
  Widget _buildArabicDescriptionField() {
    return CustomTextField(
      label: 'وصف الدور',
      hint: 'اكتب وصف',
      controller: controller.roleDescriptionControllerAr,
      required: true,
      maxLines: 3,
      minLines: 3,
      maxLength: 500,
      showCharCount: true,
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(8),
      valueStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.secondaryText),
      hintStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
      labelStyle:
      AppTextStyles.font16BlackRegularCairo.copyWith(fontSize: 14.sp),
    );
  }
  Widget _moduleItem(Modules module, BuildContext context) {
    String moduleString = _moduleEnumToString(module);
    bool isSelected = controller.selectedModules.contains(moduleString);

    return InkWell(
      onTap: () async {
        if (module != Modules.settings) {
          await controller.selectModule(moduleString);
        }
      },
      child: Container(
        width: 40.sp,
        height: 40.sp,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: (isSelected || module == Modules.settings)
              ? AppColors.primary
              : AppColors.background,
          borderRadius: BorderRadius.circular(4.sp),
        ),
        child: SvgPicture.asset(
          module.iconPath,
          height: 30.sp,
          width: 30.sp,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(
            (isSelected || module == Modules.settings)
                ? AppColors.textButton
                : AppColors.secondaryBlack,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
  void _onNextPressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    RoleLogService.log(RoleLogService.actionCreateRole);

    hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact);

    await controller.ensureSettingsSelected();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider<RoleCubit>.value(
          value: controller,
          child: RolePermissionSwitches(),
        ),
      ),
    );
  }
  Modules _stringToModuleEnum(String moduleName) {
    switch (moduleName.toLowerCase()) {
      case 'services': return Modules.services;
      case 'employees': return Modules.employees;
      case 'tasks': return Modules.tasks;
      case 'todo': return Modules.todo;
      case 'notes': return Modules.notes;
      case 'events': return Modules.events;
      case 'requests': return Modules.requests;
      case 'knowledge_hub':
      case 'knowledgehub': return Modules.knowledgeHub;
      case 'qiyas': return Modules.qiyas;
      case 'inventory': return Modules.inventory;
      case 'tracking': return Modules.tracking;
      case 'grc': return Modules.grc;
      case 'database': return Modules.database;
      case 'messages': return Modules.messages;
      case 'form_builder':
      case 'formbuilder': return Modules.formBuilder;
      case 'roles': return Modules.roles;
      case 'settings': return Modules.settings;
      case 'notification': return Modules.notification;
      default: throw Exception("Unknown module: $moduleName");
    }
  }
  String _moduleEnumToString(Modules module) {
    switch (module) {
      case Modules.services: return 'services';
      case Modules.employees: return 'employees';
      case Modules.tasks: return 'tasks';
      case Modules.todo: return 'todo';
      case Modules.notes: return 'notes';
      case Modules.events: return 'events';
      case Modules.requests: return 'requests';
      case Modules.knowledgeHub: return 'knowledge_hub';
      case Modules.qiyas: return 'qiyas';
      case Modules.inventory: return 'inventory';
      case Modules.messages: return 'messages';
      case Modules.database: return 'database';
      case Modules.formBuilder: return 'form_builder';
      case Modules.grc: return 'grc';
      case Modules.tracking: return 'tracking';
      case Modules.notification: return 'notification';
      case Modules.hr: return 'hr';
      case Modules.roles: return 'roles';
      case Modules.settings: return 'settings';
      default: return 'settings';
    }
  }
}
