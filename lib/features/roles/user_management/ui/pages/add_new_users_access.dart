import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/pagination_app_bar.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';

import 'package:demo_app/core/helper/main_helper/cross_axis_count_helper.dart';
import 'package:demo_app/features/roles/widgets/confirm_dialog.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/user_management/controller/user_management_cubit.dart';
import 'package:demo_app/features/roles/role_management/utils/role_log_service.dart';
import 'package:demo_app/features/roles/user_management/ui/widgets/access_details.dart';
import 'package:demo_app/features/roles/user_management/ui/widgets/access_search_and_filter.dart';
import 'package:demo_app/features/roles/user_management/ui/widgets/person_state_view.dart';
import 'package:demo_app/features/roles/user_management/ui/widgets/warining_dialog.dart';

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
                  'Platform Controls and Management'.tr,
                  'Adding New Access'.tr
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
                    CustomButton(
                      width: isTablet ? 135 : 120,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      buttonText: 'Discard'.tr,
                      buttonColor: AppColors.secondaryButton,
                      textStyle: AppTextStyles.font16BlackRegularCairo.copyWith(
                        color: Colors.black
                      ),
                    ),
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

                        return CustomButton(
                          width: isTablet ? 135 : 120,
                          onTap: () {
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

                              showWarningDialog(
                                context,
                                message: warningMessage,
                                lottieAsset: 'assets/lottie/warning.json',
                                width: 411,
                              );
                            } else {
                              // Proceed with normal flow
                              if (formKey.currentState!.validate()) {
                                ConfirmDialog().show(context,
                                    title: 'Add Access'.tr,
                                    subtitle:
                                    S.of(context).confirmAddUsersAccess,
                                    icon: 'assets/lottie/Edit Document.json',
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
                          buttonText: S.of(context).grantedAccess,
                          buttonColor: isAllConditionsMet
                              ? AppColors.primary
                              : AppColors.secondaryButton,
                          textStyle: AppTextStyles.font16BlackRegularCairo.copyWith(
                            color: AppColors.textButton,
                          ),
                        );
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