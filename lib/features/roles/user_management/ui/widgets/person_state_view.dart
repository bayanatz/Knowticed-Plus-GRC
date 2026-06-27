import 'package:demo_app/core/constants/app_assets.dart';
import 'package:demo_app/core/custom/23-custom_check_box.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/form_builder_module/core/widgets/custom_check_box.dart';

import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/features/roles/widgets/custom_title_value_widget.dart';
// REMOVED_MODULE: import '../../../../../../external/form_builder_module/core/constants/app_assets.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/role_management/domain/entity/user_permission_entity.dart';

class PersonStateView extends StatelessWidget {
  PersonStateView(
      {required this.person,
      required this.onTap,
      this.isEdit = false,
      this.isSelected = false,
      this.showAccessDates = false,
      super.key,
      this.color});
  UserPermissionEntity person;
  var onTap;
  Color? color;
  bool isEdit;
  bool isSelected;
  bool showAccessDates;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsetsDirectional.all(10),
        child: Column(
          spacing: 10.sp,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20.sp,
                    backgroundColor: AppColors.primary,
                    backgroundImage: person.imagePath.contains('http')
                        ? NetworkImage(person.imagePath)
                        : AssetImage(person.imagePath),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      spacing: 2.sp,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          FormatHelper.capitalize(context.isArabic
                              ? person.arabicName
                              : person.englishName),
                          style: AppTextStyles.font14BlackCairoMedium.copyWith(
                            color: AppColors.text
                          ),
                        ),
                        Expanded(
                            child: Container(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            FormatHelper.capitalize(
                                person.departmentName(context.isArabic)),
                            style: AppTextStyles.font14SpanTextCairoMedium.copyWith(
                                color: AppColors.secondaryText
                            ),
                          ),
                        )),
                        Expanded(
                            child: Text(
                          FormatHelper.capitalize(
                              person.jobTitle(context.isArabic)),
                          style: AppTextStyles.font14SpanTextCairoMedium.copyWith(
                              color: AppColors.secondaryText
                          ),
                        )),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: (isEdit)
                            ? SvgPicture.asset(AppAssets.minusCircle)
                            : CustomCheckBox(isSelected: isSelected))
                ],
              ),
            ),
            if (showAccessDates)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    child: CustomTitleValueWidget(
                        title: 'Access Granted'.tr,
                        titleStyle: AppTextStyles
                            .font12SecondaryBlackCairoRegular
                            .copyWith(fontSize: 10.sp),
                        valueStyle: AppTextStyles
                            .font12SecondaryBlackCairoRegular
                            .copyWith(fontSize: 10.sp, color: AppColors.text),
                        value: person.startDate ?? '-'),
                  ),
                  Spacer(),
                  FittedBox(
                    child: CustomTitleValueWidget(
                        title: 'Access Revoked'.tr,
                        titleStyle: AppTextStyles
                            .font12SecondaryBlackCairoRegular
                            .copyWith(fontSize: 10.sp),
                        valueStyle: AppTextStyles
                            .font12SecondaryBlackCairoRegular
                            .copyWith(fontSize: 10.sp, color: AppColors.text),
                        value: person.endDate ?? '-'),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}

/*
Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  child: CustomTitleValueWidget(
                      title: 'Access Granted'.tr,
                      titleStyle: AppTextStyles.font12SecondaryBlackCairoRegular
                          .copyWith(fontSize: 10.sp),
                      valueStyle: AppTextStyles.font12SecondaryBlackCairoRegular
                          .copyWith(fontSize: 10.sp, color: AppColors.text),
                      value: person.startDate ?? '-'),
                ),
                FittedBox(
                  child: CustomTitleValueWidget(
                      title: 'Access Revoked'.tr,
                      titleStyle: AppTextStyles.font12SecondaryBlackCairoRegular
                          .copyWith(fontSize: 10.sp),
                      valueStyle: AppTextStyles.font12SecondaryBlackCairoRegular
                          .copyWith(fontSize: 10.sp, color: AppColors.text),
                      value: person.endDate ?? '-'),
                ),
              ],
            )
*
* */
