import 'package:get/get.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';

import 'package:grc_module/core/custom/cross_axis_count_helper.dart';
import 'package:grc_module/core/custom/confirm_dialog.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:grc_module/features/roles/r5_system_logs/role_log_service.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/access_details.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/access_search_and_filter.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/ui/widgets/person_state_view.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
class AddNewUsersAccess extends StatelessWidget {
  AddNewUsersAccess({super.key});
  late UserManagementAccessCubit controller;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    controller = context.read<UserManagementAccessCubit>();
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              start: isTablet ? 30.sp : 15.sp, end: 15.sp),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaginationAppBar(screensTitles: [
                  S.of(context).platformControlsAndManagement,
                  S.of(context).addingNewAccess
                ]),
                AccessDetails(),
                SizedBox(height: 20.sp),
                Text(S.of(context).employees,style: StyleText.fontSize16Weight500.copyWith(
                    color:AppColors.text
                ),),
                SizedBox(height: 10.sp),
                AccessSearchAndFilter(),
                SizedBox(height: 20.sp),


                BlocBuilder<UserManagementAccessCubit,
                    UserManagementAccessState>(
                  builder: (context, state) {
                    return Expanded(
                      child: GridView.builder(
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: CrossAxisCountHelper
                                .getCrossAxisCountForDefaultTablet2(context),
                            mainAxisExtent: 70.sp,
                            mainAxisSpacing: 10.sp,
                            crossAxisSpacing: 10.sp,
                          ),
                          itemCount:
                          controller.filteredEmployeeToGiveAccess.length,
                          itemBuilder: (context, index) {
                            return PersonStateView(
                                onTap: () {
                                  controller.selectUserToChangeAccess(controller
                                      .filteredEmployeeToGiveAccess[index]
                                      .employeeId);
                                },
                                color: AppColors.card,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customButton(
                      width: isTablet ? 135 : 120,
                      function: () {
                        Navigator.of(context).pop();
                      },
                      title: S.of(context).discard,
                      color: AppColors.secondaryButton,
                      textStyle: AppTextStyles.font16BlackRegularCairo.copyWith(
                        color: Colors.black
                      ),),
                    BlocBuilder<UserManagementAccessCubit,
                        UserManagementAccessState>(
                      buildWhen: (_, state) {
                        return true;
                      },
                      builder: (context, state) {
                        // Check all required conditions
                        bool isRoleSelected = controller.newAccessSelectedRole != null;
                        bool isEmployeeSelected = controller.selectedUsersIdToChangeAccess.isNotEmpty;
                        bool isAllConditionsMet = isRoleSelected && isEmployeeSelected;

                        return customButton(
                          width: isTablet ? 135 : 120,
                          function: () {
                            if (!isAllConditionsMet) {
                              // Show warning dialog if conditions not met
                              String warningMessage = '';
                              if (!isRoleSelected && !isEmployeeSelected) {
                                warningMessage = S.of(context).selectRoleAndEmployee;
                              } else if (!isRoleSelected) {
                                warningMessage = S.of(context).selectRoleType;
                              } else if (!isEmployeeSelected) {
                                warningMessage = S.of(context).selectAtLeastOneEmployee;
                              }

                              CustomDialogManager.showSuccess(
                                context: context,
                                lottiePath:
                                    'assets/lottie_assets/main_lottie_assets/warning.json',
                                title: warningMessage,
                              );
                            } else {
                              // Proceed with normal flow
                              if (formKey.currentState!.validate()) {
                                ConfirmDialog().show(context,
                                    title: S.of(context).addAccess,
                                    subtitle:
                                    S.of(context).confirmAddUsersAccess,
                                    icon: 'assets/lottie_assets/roles_lottie_assets/Edit Document.json',
                                    onCancel: () {},
                                    onConfirm: () async {
                                      RoleLogService.log(RoleLogService.actionGrantAccess);
                                      showLoadingIndicator();
                                      await controller
                                          .updateSelectedMembersAccess();
                                      hideLoadingIndicator();
                                      Navigator.of(context).pop();
                                    });
                              }
                            }
                          },
                          title: S.of(context).grantedAccess,
                          color: isAllConditionsMet
                              ? AppColors.primary
                              : AppColors.secondaryButton,
                          textStyle: AppTextStyles.font16BlackRegularCairo.copyWith(
                            color: AppColors.textButton,
                          ),);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}