import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/custom/cross_axis_count_helper.dart';
import 'package:grc_module/core/custom/confirm_dialog.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
import 'package:grc_module/features/roles/r2_user_management/domain/entity/user_permission_entity.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:grc_module/features/roles/r5_system_logs/role_log_service.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/access_info.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/access_search_and_filter.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/person_state_view.dart';
import 'package:grc_module/generated/l10n.dart';

class EditRoleUserAccess extends StatelessWidget {
  EditRoleUserAccess({super.key});

  late UserManagementAccessCubit controller;
  @override
  Widget build(BuildContext context) {
    controller = context.read<UserManagementAccessCubit>();
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              start: isTablet ? 30.sp : 15.sp, end: 15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(screensTitles: [
                S.of(context).platformControlsAndManagement,
                S.of(context).userAccessDetails,
                S.of(context).Editing
              ]),
              AccessInfo(),
              SizedBox(height: 20.sp),
              AccessSearchAndFilter(),
              SizedBox(height: 10.sp),
              BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
                builder: (context, state) {
                  List<UserPermissionEntity> userPermissions = [];
                  for (UserPermissionEntity permission
                      in controller.filteredEmployeeToGiveAccess) {
                    if (!controller.selectedUsersIdToChangeAccess
                        .contains(permission.employeeId)) {
                      userPermissions.add(permission);
                    }
                  }

                  return Expanded(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: CrossAxisCountHelper
                              .getCrossAxisCountForDefaultTablet2(context),
                          mainAxisExtent: 100.sp,
                          mainAxisSpacing: 10.sp,
                          crossAxisSpacing: 10.sp,
                        ),
                        itemCount: userPermissions.length,
                        itemBuilder: (context, index) {
                          return PersonStateView(
                              onTap: () {

                                ConfirmDialog().show(context,
                                    title: S.of(context).remove_access,
                                    subtitle:
                                    S.of(context).areYouSureYouWantToRemoveThisAccess,
                                    icon: 'assets/lottie_assets/roles_lottie_assets/delete.json',
                                    onCancel: () {}, onConfirm: () async {
                                      RoleLogService.log(RoleLogService.actionRevokeAccess);
                                      showLoadingIndicator();
                                      controller.selectUserToChangeAccess(
                                          userPermissions[index].employeeId);
                                      await controller.removeUserAccess(userPermissions[index]);
                                      hideLoadingIndicator();

                                    });
                              },
                              showAccessDates: true,
                              isEdit: true,
                              isSelected: controller
                                  .selectedUsersIdToChangeAccess
                                  .contains(userPermissions[index].employeeId),
                              person: userPermissions[index]);
                        }),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
