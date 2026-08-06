part of '../pages/adding_new_role.dart';

extension AddingNewRoleMethods1 on _AddingNewRoleState {
  // Text-direction, company-licence and module-mapping logic now lives on
  // RoleCubit; these thin wrappers keep the existing call sites readable.
  bool _containsArabic(String text) => controller.containsArabic(text);

  bool _containsEnglish(String text) => controller.containsEnglish(text);
  // ─────────────────────────────────────────────
  // STATUS TOGGLE DIALOG — shared CustomDialogManager flow
  // ─────────────────────────────────────────────
  Future<void> _showStatusConfirmDialog(
      BuildContext context, bool newValue) async {
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: 'assets/lottie_assets/roles_lottie_assets/Edit Document.json',
      confirmTitle: S.of(context).changingStatus,
      confirmSubtitle: newValue
          ? S.of(context).areYouSureYouWantToActivateThisRole
          : S.of(context).areYouSureYouWantToDeactivateThisRole,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        controller.toggleActiveStatus(newValue);
        return true;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/check.json',
      successTitle: S.of(context).changingStatus,
      successSubtitle: newValue
          ? S.of(context).activated
          : S.of(context).employeeStatusDeactivated,
    );
  }
  // ── module loading helpers (unchanged) ──────────────────────────────────

  Future<List<String>> _getAllowedModulesForRoleCreation() =>
      controller.getAllowedModulesForRoleCreation();

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
        child: CustomSvgImage(assetPath: 
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
  Modules _stringToModuleEnum(String moduleName) =>
      controller.stringToModuleEnum(moduleName);

  String _moduleEnumToString(Modules module) =>
      controller.moduleEnumToSelectionString(module);
}
