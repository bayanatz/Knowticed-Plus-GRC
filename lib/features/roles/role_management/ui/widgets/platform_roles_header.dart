import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/constants/skeleton_assets.dart';
import 'package:demo_app/core/custom/2-custom_textfield.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:flutter/src/services/haptic_feedback.dart';
import 'dart:async';

import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_icon_button.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/roles/role_mangment_permission.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/adding_new_role.dart';

class PlatformRolesHeader extends StatefulWidget {
  const PlatformRolesHeader({super.key});

  @override
  State<PlatformRolesHeader> createState() => _PlatformRolesHeaderState();
}

class _PlatformRolesHeaderState extends State<PlatformRolesHeader> {
  late RoleCubit controller;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      controller.filterRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final HapticController hapticController = Get.put(HapticController());
    var lightMode = Theme.of(context).brightness == Brightness.light;
    controller = context.read<RoleCubit>();
    bool isTablet = MediaQuery.of(context).size.width >= 600;

    return BlocBuilder<RoleCubit, RoleState>(
      buildWhen: (previous, current) =>
      current is RoleFetched ||
          current is RoleFiltered ||
          current is RoleAdded ||
          current is RoleUpdated ||
          current is RoleDeleted ||
          current is RoleDraftSaved ||
          current is RoleActivated,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Platform Roles".tr,
              style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.text
              ),
            ),
            SizedBox(height: 8.sp),
            Row(
              spacing: 15.sp,
              children: [
                Expanded(
                  child: CustomTextField(
                    height: 36.h,
                    hint: Get.locale?.languageCode == 'ar' ? 'بحث' : 'Search',
                    controller: controller.searchController,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: controller.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.filterRoles();
                            },
                          )
                        : null,
                    fillColor: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                    valueStyle: StyleText.fontSize16Weight400.copyWith(
                        color: AppColors.text
                    ),
                    onChanged: _onSearchChanged,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h
                    ),
                  ),
                ),
                Get.find<MainCoreEmployeeController>().isHasPermission(
                  module: Modules.roles,
                  section: RolePermissionsSections.roleManagement,
                  permission: RoleManagement.createRoleManagement,
                )
                    ? CustomIconButton(
                  width: isTablet ? 100 : 38,
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton
                  ),
                  buttonText: isTablet ? 'Role'.tr : "",
                  iconPath: SkeletonAssets.roleIcon,
                  iconColor: AppColors.textButton,
                  onTap: () {
                    hapticController.triggerHapticFeedback(
                        vibration: VibrateType.mediumImpact,
                        hapticFeedback: HapticFeedback.mediumImpact
                    );

                    context.read<RoleCubit>().initAddingRoleController();
                    Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => BlocProvider<RoleCubit>.value(
                              value: controller,
                              child: AddingNewRole(),
                            )
                        )
                    );
                  },
                )
                    : SizedBox()
              ],
            )
          ],
        );
      },
    );
  }
}