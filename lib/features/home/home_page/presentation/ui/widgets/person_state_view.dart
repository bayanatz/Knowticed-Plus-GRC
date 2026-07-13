import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/custom/23-custom_check_box.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class PersonStateView extends StatelessWidget {
  PersonStateView(
      {required this.person,
      required this.onTap,
      this.isEdit = false,
      this.isSelected = false,
      super.key,
      this.color});
  EmployeeEntityPro person;
  var onTap;
  Color? color;
  bool isEdit;
  bool isSelected;
  @override
  Widget build(BuildContext context) {
    String image = EmployeeHelper.getEmployeeImage(employee: person);
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.field,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsetsDirectional.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20.sp,
              backgroundColor: AppColors.primary,
              backgroundImage: image.contains('http')
                  ? NetworkImage(image)
                  : AssetImage(image),
            ),
            SizedBox(width: 10.sp),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      FormatHelper.capitalize(
                          EmployeeHelper.getEmployeeLocalizedName(
                              employee: person, context: context)),
                      style: AppTextStyles.font14BlackCairoMedium
                          .copyWith(height: 1),
                    ),
                  ),
                  Expanded(
                      child: Text(
                    EmployeeHelper.getEmployeeLocalizeDepartment(
                            employee: person, context: context) ??
                        '',
                    style: AppTextStyles.font12SecondaryBlackCairoRegular,
                  )),
                  Expanded(
                      child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      FormatHelper.capitalize(
                              EmployeeHelper.getEmployeeLocalizedTitle(
                                  employee: person, context: context)) ??
                          '',
                      style: AppTextStyles.font12SecondaryBlackCairoRegular,
                    ),
                  )),
                ],
              ),
            ),
            if (onTap != null)
              Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: CustomCheckBox(isSelected: isSelected)),
          ],
        ),
      ),
    );
  }
}
