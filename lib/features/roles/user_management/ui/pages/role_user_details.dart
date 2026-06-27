import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/data_grc_module/core/extensions/extensions.dart';

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/cross_axis_count_helper.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_icon_button.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/roles/user_management/controller/user_management_cubit.dart';
import 'package:demo_app/features/roles/user_management/ui/widgets/access_info.dart';
import 'package:demo_app/features/roles/user_management/ui/widgets/access_search_and_filter.dart';
import 'package:demo_app/features/roles/user_management/ui/widgets/person_state_view.dart';
import 'edit_role_user_access.dart';

class RoleUserDetails extends StatelessWidget {
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
                'Platform Controls and Management'.tr,
                'User Access Details'.tr
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomIconButton(
                    width: ContextExtension(context).isTablet ? 135.sp : null,
                    buttonText: context.isTablett ? 'Edit'.tr : '',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              BlocProvider<UserManagementAccessCubit>.value(
                            value: controller,
                            child: EditRoleUserAccess(),
                          ),
                        ),
                      );
                    },
                    iconPath: 'assets/icons/edit.svg',
                  ),
                ],
              ),
              SizedBox(height: 20.sp),
              AccessInfo(),
              SizedBox(height: 20.sp),
              Row(
                children: [
                  AccessSearchAndFilter(),
                ],
              ),
              SizedBox(height: 10.sp),
              BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
                builder: (context, state) {
                  return Expanded(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: CrossAxisCountHelper
                              .getCrossAxisCountForDefaultTablet2(context),
                          mainAxisExtent: 96.sp,
                          mainAxisSpacing: 10.sp,
                          crossAxisSpacing: 10.sp,
                        ),
                        itemCount:
                            controller.filteredEmployeeToGiveAccess.length,
                        itemBuilder: (context, index) {
                          return PersonStateView(
                              showAccessDates: true,
                              onTap: null,
                              isSelected: controller
                                  .selectedUsersIdToChangeAccess
                                  .contains(controller
                                      .filteredEmployeeToGiveAccess[index]
                                      .employeeId),
                              person: controller
                                  .filteredEmployeeToGiveAccess[index]);
                        }),
                  );
                },
              ),
              SizedBox(height: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
