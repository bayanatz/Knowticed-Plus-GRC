/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_person_card.dart
/// Purpose: Shared list-item card that renders a single employee (by email)
///          with avatar, name, department, job title, and a Message action.
///          Used by the Control Champions and Control Owners tabs of
///          GrcModuleDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026
library;

import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/helper/main_helper/employee_helper.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/generated/l10n.dart';

/// class name: [GrcModulePersonCard]
///
/// purpose: private list-item card that displays a single employee identified
///          by [email], resolving their name, department, job title, and photo
///          via the shared employee helpers. Tapping invokes [onTap].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class GrcModulePersonCard extends StatelessWidget {
  final String email;
  final VoidCallback? onTap;

  const GrcModulePersonCard({super.key, required this.email, this.onTap});

  @override
  Widget build(BuildContext context) {
    final employee = findEmployeeByEmail(email);
    final name = employeeDisplayName(context, email);
    final department = employee != null
        ? EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: employee, context: context)
        : '';
    final jobTitle = employee != null
        ? (EmployeeHelper.getEmployeeLocalizedTitle(
                    employee: employee, context: context)
                ?.toString() ??
            '')
        : '';
    final photo = employee != null
        ? EmployeeHelper.getEmployeeImage(employee: employee)
        : 'assets/icons_assets/main_icons_assets/assets_male.svg';

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.barrierColor,
                backgroundImage:
                    photo.startsWith('http') ? NetworkImage(photo) : null,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name,
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (department.isNotEmpty)
                      Text(department,
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    if (jobTitle.isNotEmpty)
                      Text(jobTitle,
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.secondaryText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              customButtonWithSvg(
                colorBorder: AppColors.primary,
                space: 6.w,
                widthImage: 14.w,
                heightImage: 14.h,
                function: () {},
                title: S.of(context).msg,
                textStyle: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.textButton),
                image: 'assets/icons_assets/data_grc_assets/messages_new.svg',
                color: AppColors.primary,
                svgColor: AppColors.textButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
