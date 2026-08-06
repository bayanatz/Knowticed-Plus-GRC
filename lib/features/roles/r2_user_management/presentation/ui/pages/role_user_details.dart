import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/data_grc_module/core/extensions/extensions.dart';

import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/custom/cross_axis_count_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';

import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/access_info.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/access_search_and_filter.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/person_state_view.dart';
import './edit_role_user_access.dart';
import 'package:grc_module/generated/l10n.dart';

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
                S.of(context).platformControlsAndManagement,
                S.of(context).userAccessDetails
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  customButtonWithSvg(
                    // Empty title on phone → renders as a square icon-only button.
                    title: ContextExtension(context).isTablett ? S.of(context).Edit : '',
                    function: () {
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
                    image: 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg',
                    widthImage: 20.sp,
                    heightImage: 20.sp,
                    space: 10.sp,
                    color: AppColors.primary,
                    svgColor: AppColors.textButton,
                    colorBorder: AppColors.transparent,
                    textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
                      color: AppColors.textButton,
                    ),
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
