import 'package:grc_module/core/constants/app_assets.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:grc_module/features/external/services_mangment_module/core/new_theme.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

import 'package:grc_module/core/helper/main_helper/employee_helper.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/custom/custom_title_value_widget.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/helper/role/main_core_employee_controller.dart';

class RoleInformation extends StatefulWidget {
  const RoleInformation({super.key});

  @override
  State<RoleInformation> createState() => _RoleInformationState();
}

class _RoleInformationState extends State<RoleInformation> {
  late bool isTablet;
  late RoleCubit controller;
  bool isHide = false;

  @override
  Widget build(BuildContext context) {
    controller = context.read<RoleCubit>();
    isTablet = MediaQuery.of(context).size.width > 600;
    return roleInformation();
  }

  roleInformation() {
    return Column(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              S.of(context).roleInformation,
              style: AppTextStyles.font16BlackSemiBoldCairo,
            ),
            Spacer(),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                setState(() {
                  isHide = !isHide;
                });
              },
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isHide ? S.of(context).show : S.of(context).hide,
                      style: AppTextStyles.font10BlackCairoRegular.copyWith(
                        color: AppColors.blue,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      height: 1,
                      color: AppColors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (!isHide)
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: isTablet ? tabletInformation() : mobileInformation(),
          )
      ],
    );
  }

  Widget tabletInformation() {
    // ✅ FIXED: Use firstWhereOrNull to handle missing employees gracefully
    var creatorEmployee = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities
        ?.firstWhereOrNull((employee) =>
    employee.email == controller.selectedRole!.currentCreatedBy);

    // ✅ FIXED: Provide fallback values if employee not found
    String image = creatorEmployee != null
        ? EmployeeHelper.getEmployeeImage(employee: creatorEmployee)
        : 'assets/icons_assets/main_icons_assets/person_outline.png'; // Default avatar

    String name = creatorEmployee != null
        ? EmployeeHelper.getEmployeeLocalizedName(
        employee: creatorEmployee, context: context)
        : controller.selectedRole!.currentCreatedBy; // Show email as fallback
    final isArabic = Get.locale?.languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10.sp,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            roleImage(75.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                      isArabic ?  FormatHelper.capitalize(controller.selectedRole!.currentRoleNameAr) :
                      FormatHelper.capitalize(controller.selectedRole!.currentRoleName),

                        style: AppTextStyles.font16BlackSemiBoldCairo,
                      ),
                      CustomTitleValueWidget(
                        title: "${S.of(context).creationDate}: ",
                        value: DateFormat(
                            'dd MMM yyyy', context.isArabic ? 'ar' : 'en')
                            .format(
                            controller.selectedRole!.currentCreatedAt.toDate()),
                      )
                    ],
                  ),
                  SizedBox(height: 10.sp),
                  CustomTitleValueWidget(
                      value: controller.selectedRole!.currentRoleDescription.isNotEmpty
                          ? isArabic ? FormatHelper.capitalize(controller.selectedRole!.currentRoleDescriptionAr) :FormatHelper.capitalize(controller.selectedRole!.currentRoleDescription)
                          : "",
                      title: "${S.of(context).role_description}: "),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 10.sp),
        Text(
          S.of(context).createdBy,
          style: AppTextStyles.font14BlackSemiBoldCairo.copyWith(height: 1.3),
        ),
        SizedBox(height: 5.sp),
        Row(
          children: [
            Container(
              width: 410.sp,
              padding: EdgeInsets.all(4.sp),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.sp),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15.sp,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: (image.contains('http')
                          ? Image.network(
                        image,
                        errorBuilder: (context, error, stackTrace) {
                          // ✅ FIXED: Handle network image errors
                          return Image.asset('assets/icons_assets/main_icons_assets/person_outline.png');
                        },
                      )
                          : Image.asset(
                        image,
                        errorBuilder: (context, error, stackTrace) {
                          // ✅ FIXED: Handle asset image errors
                          return Icon(Icons.person, size: 30.sp);
                        },
                      )),
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: Text(
                      FormatHelper.capitalize(name),
                      style: AppTextStyles.font12BlackCairoRegular,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  mobileInformation() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // ✅ FIXED: Use firstWhereOrNull to handle missing employees gracefully
    var creatorEmployee = Get.find<MainCoreEmployeeController>()
        .allEmployeesEntities
        ?.firstWhereOrNull((employee) =>
    employee.email == controller.selectedRole!.currentCreatedBy);

    // ✅ FIXED: Provide fallback values if employee not found
    String image = creatorEmployee != null
        ? EmployeeHelper.getEmployeeImage(employee: creatorEmployee)
        : 'assets/icons_assets/main_icons_assets/person_outline.png';

    String name = creatorEmployee != null
        ? EmployeeHelper.getEmployeeLocalizedName(
        employee: creatorEmployee, context: context)
        : controller.selectedRole!.currentCreatedBy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            roleImage(50.sp),
            SizedBox(width: 10.sp),
            Container(
              height: 50.sp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    !isArabic ?
                    FormatHelper.capitalize(controller.selectedRole!.currentRoleName) :
                    FormatHelper.capitalize(controller.selectedRole!.currentRoleNameAr),
                    style: AppTextStyles.font16BlackSemiBoldCairo,
                  ),
                  CustomTitleValueWidget(
                    title: "${S.of(context).creationDate}: ",
                    value: DateFormat(
                        'dd MMM yyyy', context.isArabic ? 'ar' : 'en')
                        .format(controller.selectedRole!.currentCreatedAt.toDate()),
                  )
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 10.sp),
        CustomTitleValueWidget(
            value:      ! isArabic ?  controller.selectedRole!.currentRoleDescription:
            controller.selectedRole!.currentRoleDescriptionAr,
            title: "${S.of(context).role_description}: "),

        SizedBox(height: 10.sp),
        Text(
          S.of(context).createdBy,
          style: StyleText.fontSize10Weight400.copyWith(
              color: Theme.of(context).brightness == Brightness.light ? AppColors.blackButton:AppColors.white
          ),
        ),
        SizedBox(height: 10.sp),
        SizedBox(height: 5.sp),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.sp),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.sp),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15.sp,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: (image.contains('http')
                      ? Image.network(
                    image,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/icons_assets/main_icons_assets/person_outline.png');
                    },
                  )
                      : Image.asset(
                    image,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 30.sp);
                    },
                  )),
                ),
              ),
              SizedBox(width: 10.sp),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.font12BlackCairoRegular,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget roleImage(double imageSize) {
    if (controller.selectedRole!.currentRoleImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.sp),
        child: Image.network(
          controller.selectedRole!.currentRoleImage,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // ✅ FIXED: Handle image loading errors
            return Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              width: imageSize,
              height: imageSize,
              child: CustomSvgImage(assetPath: 
                'assets/icons_assets/roles_assets/roles_people_gear.svg',
                width: imageSize - 20.sp,
                height: imageSize - 20.sp,
                color: AppColors.text,
              ),
            );
          },
        ),
      );
    }
    return Container(
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        width: imageSize,
        height: imageSize,
        child: CustomSvgImage(assetPath: 
          'assets/icons_assets/roles_assets/roles_people_gear.svg',
          width: imageSize - 20.sp,
          height: imageSize - 20.sp,
          color: AppColors.text,
        ));
  }
}