import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/DatePicker.dart';
import 'package:demo_app/features/roles/widgets/expanded_content.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/custom_drop_down.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/services_mangment_module/core/new_theme.dart';
import 'package:demo_app/features/roles/role_management/utils/constants.dart';

import 'package:demo_app/features/roles/core_widgets/main_widget/custom_drop_down.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/roles/user_management/controller/user_management_cubit.dart';

class AccessDetails extends StatefulWidget {
  AccessDetails({super.key});

  @override
  State<AccessDetails> createState() => _AccessDetailsState();
}

class _AccessDetailsState extends State<AccessDetails> {
  late UserManagementAccessCubit controller;

  @override
  Widget build(BuildContext context) {
    controller = context.read<UserManagementAccessCubit>();
    bool isTablet = MediaQuery.of(context).size.width > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return ExpandedContent(
      title: 'Access Details'.tr,
      content: BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: (isTablet)
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 305.w, child: roleSelector()),


                // accessGranted
                SizedBox(
                    width: isPortrait ? 150.w : 250.w,
                    child: accessGranted(context)),
                // accessRevoked
                SizedBox(
                    width: isPortrait ? 150.w : 250.w,
                    child: accessRevoked(context))
              ],
            )
                : Column(
              children: [
                SizedBox(width: double.infinity, child: roleSelector()),
                SizedBox(height: 15.sp),
                SizedBox(
                    width: double.infinity,
                    child: accessGranted(context)),
                SizedBox(height: 15.sp),
                SizedBox(
                    width: double.infinity,
                    child: accessRevoked(context))
              ],
            ),
          );
        },
      ),
    );
  }

    Widget roleSelector() {

    // Build roles list filtering out 'master admin'
    List<String> filteredRoles = [];

    for (int i = 0; i < controller.rolesName.length; i++) {
      String enName = controller.rolesName[i];
      if (enName.toLowerCase() != 'master admin') {
        filteredRoles.add(enName);
      }
    }

    if (filteredRoles.isEmpty) {
      filteredRoles = ['No Roles'];
    }

    // Get corresponding Arabic names
    List<String> filteredRolesAr = [];
    for (String enRole in filteredRoles) {
      int originalIndex = controller.rolesName.indexOf(enRole);
      if (originalIndex >= 0 && originalIndex < controller.rolesNameAr.length) {
        filteredRolesAr.add(controller.rolesNameAr[originalIndex]);
      } else {
        filteredRolesAr.add(enRole); // Fallback to EN if no AR available
      }
    }

    // Get current language
    bool isArabic = Get.locale?.languageCode == 'ar';

    return CustomDropdown<String>(
      label: isArabic ? 'نوع الدور' : 'Role Type',
      hint: isArabic ? 'اختر نوع الدور' : 'Select Role Type',
      items: filteredRoles.map((role) {
        int index = filteredRoles.indexOf(role);
        final label = (index >= 0 && index < filteredRolesAr.length)
            ? (isArabic ? filteredRolesAr[index] : role)
            : role;
        return DropdownItem<String>(value: role, label: label);
      }).toList(),
      value: controller.newAccessSelectedRole,
      onChanged: (selectedRole) {
        controller.newAccessSelectedRole = selectedRole;
        controller.emit(UserPermissionsDataLoaded());
      },
      fillColor: AppColors.background,
      labelStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.text,
      ),
      hintStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.secondaryText.withOpacity(.7),
      ),
      itemStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.text,
      ),
      triggerPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      borderRadius: BorderRadius.circular(4.r),
      required: false,
    );
  }

  Widget accessGranted(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Text('Access Granted'.tr,
            style: AppTextStyles.font14BlackCairoRegular.copyWith(
                color: AppColors.text)),
        InkWell(
          onTap: () async {
            List<DateTime?>? dates = await DatePicker().showDatePicker(
                context,
                [controller.accessGranted],
                DateTime.now(),
                CalendarDatePicker2Type.single,
                firstDate: DateTime.now());
            if (dates != null && dates.first != null) {
              controller.accessGranted = dates.first!;
              controller.emit(UserPermissionsDataLoaded());
            }
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
              height: 36.sp,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.sp),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.accessGranted == null
                        ? 'Select Access Granted'.tr
                        : DateFormat('d MMM yyyy',
                        context.isArabic ? 'ar' : 'en')
                        .format(controller.accessGranted!),
                    style: AppTextStyles.font12SecondaryBlackCairoRegular.copyWith(
                    color: AppColors.text
                    ),
                  ),
                  SvgPicture.asset(
                    width: 20.w,
                    height: 20.h,
                    fit: BoxFit.fill,
                    'assets/svg/Calendar.svg',
                    color: AppColors.secondaryText,
                  )
                ],
              )),
        )
      ],
    );
  }

  Widget accessRevoked(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.sp,
      children: [
        Text('Access Revoked'.tr,
            style: AppTextStyles.font14BlackCairoRegular.copyWith(
                color: AppColors.text)),
        InkWell(
          onTap: () async {
            List<DateTime?>? dates = await DatePicker().showDatePicker(
                context,
                [controller.accessRevoked],
                DateTime.now(),
                CalendarDatePicker2Type.single,
                firstDate: DateTime.now());
            if (dates != null && dates.first != null) {
              controller.accessRevoked = dates.first!;
              controller.emit(UserPermissionsDataLoaded());
            }
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
              height: 36.sp,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.sp),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.accessRevoked == null
                        ? 'Select Access Revoked'.tr
                        : DateFormat('d MMM yyyy',
                        context.isArabic ? 'ar' : 'en')
                        .format(controller.accessRevoked!),
                    style: AppTextStyles.font12SecondaryBlackCairoRegular.copyWith(
                      color: AppColors.text
                    )
                  ),
                  SvgPicture.asset(
                    width: 20.w,
                    height: 20.h,
                    fit: BoxFit.fill,
                    'assets/svg/Calendar.svg',
                    color: AppColors.secondaryText,
                  )
                ],
              )),
        )
      ],
    );
  }
}