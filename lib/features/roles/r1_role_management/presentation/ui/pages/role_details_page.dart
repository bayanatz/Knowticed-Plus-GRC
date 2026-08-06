import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/pages/adding_new_role.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/pages/role_management_home.dart';
import 'package:grc_module/generated/l10n.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/custom/confirm_dialog.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/role_mangment_permission.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/widgets/module select.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/widgets/modules_granted.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/ui/widgets/role_information.dart';
import 'package:flutter/services.dart';

import 'package:grc_module/features/roles/r1_role_management/presentation/ui/pages/role_screen.dart';
import 'package:grc_module/features/roles/r5_system_logs/role_log_service.dart';

class RoleDetailsPage extends StatefulWidget {
  RoleDetailsPage({super.key});

  @override
  State<RoleDetailsPage> createState() => _RoleDetailsPageState();
}

class _RoleDetailsPageState extends State<RoleDetailsPage> {
  late RoleCubit controller;
  late bool isTablet;

  @override
  void initState() {
    super.initState();
    controller = context.read<RoleCubit>();
    RoleLogService.log(RoleLogService.pageRoleDetails);
  }

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());

    isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: 15.sp,
            end: 15.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20.sp,
            children: [
              PaginationAppBar(
                screensTitles: [
                  S.of(context).platformControlsAndManagement,
                  S.of(context).roleDetails,
                ],
              ),
              if (controller.selectedRole!.currentRoleName.toLowerCase() !=
                  'master admin')
                Row(
                  spacing: 10.sp,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Get.find<MainCoreEmployeeController>().isHasPermission(
                      module: Modules.roles,
                      section: RolePermissionsSections.roleManagement,
                      permission: RoleManagement.editRole,
                    )
                        ? customButton(
                      title: S.of(context).edit,
                      function: () {
                        hapticController.triggerHapticFeedback(
                          vibration: VibrateType.mediumImpact,
                          hapticFeedback:
                          HapticFeedback.mediumImpact,
                        );
                        context
                            .read<RoleCubit>()
                            .selectRole(controller.selectedRole!);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                            BlocProvider<RoleCubit>.value(
                              value: controller,
                              child: AddingNewRole(),
                            ),
                          ),
                        );
                      },
                    )
                        : const SizedBox(),
                    Get.find<MainCoreEmployeeController>().isHasPermission(
                      module: Modules.roles,
                      section: RolePermissionsSections.roleManagement,
                      permission: RoleManagement.deleteRole,
                    )
                        ? customButton(
                      color: AppColors.red,
                      textStyle: AppTextStyles
                          .font14BlackCairoRegular
                          .copyWith(color: AppColors.white),
                      title: S.of(context).delete,
                      function: () {
                        hapticController.triggerHapticFeedback(
                          vibration: VibrateType.heavyImpact,
                          hapticFeedback:
                          HapticFeedback.heavyImpact,
                        );
                        ConfirmDialog().show(
                          context,
                          title: S.of(context).deleteRole,
                          subtitle: S
                              .of(context)
                              .areYouSureYouWantToDeleteThisRole,
                          onConfirm: () async {
                            showLoadingIndicator();
                            await controller.deleteRole();
                            hideLoadingIndicator();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider<RoleCubit>.value(
                                  value: controller,
                                  child: RoleScreen(selectedIndex: 0),
                                ),
                              ),
                                  (route) => route.isFirst,
                            );
                          },
                          icon: 'assets/lottie_assets/roles_lottie_assets/delete.json',
                          onCancel: () {},
                        );
                      },
                    )
                        : const SizedBox(),
                  ],
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 20.sp,
                    children: [
                      RoleInformation(),
                      ModulesGranted(),
                      ModulePermissionsWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}