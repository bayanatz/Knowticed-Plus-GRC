import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/adding_new_role.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/role_management_home.dart';
import 'package:demo_app/generated/l10n.dart';

import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/features/roles/widgets/confirm_dialog.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_icon_button.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/roles/role_mangment_permission.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/module select.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/modules_granted.dart';
import 'package:demo_app/features/roles/role_management/ui/widgets/role_information.dart';
import 'package:flutter/src/services/haptic_feedback.dart';

import 'package:demo_app/features/roles/role_management/ui/pages/role_screen.dart';
import 'package:demo_app/features/roles/role_management/utils/role_log_service.dart';

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
                        ? CustomIconButton(
                      width: isTablet ? 135 : null,
                      iconPath:
                      'assets/edit.svg',
                      buttonText: isTablet ? S.of(context).edit : '',
                      onTap: () {
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
                        ? CustomIconButton(
                      width: isTablet ? 135 : null,
                      buttonColor: AppColors.red,
                      textStyle: AppTextStyles
                          .font14BlackCairoRegular
                          .copyWith(color: AppColors.white),
                      iconColor: AppColors.white,
                      iconPath: 'assets/icons/trash.svg',
                      buttonText:
                      isTablet ? S.of(context).delete : '',
                      onTap: () {
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
                          icon: 'assets/lottie/delete.json',
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