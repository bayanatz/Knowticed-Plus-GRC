import 'package:flutter/cupertino.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/data_grc_module/core/extensions/extensions.dart';
import 'package:demo_app/features/roles/user_management/controller/user_management_cubit.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_font_weights.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import 'package:demo_app/features/roles/role_management/utils/constants.dart';

class AccessInfo extends StatelessWidget {
  AccessInfo({super.key});
  late UserManagementAccessCubit controller;
  @override
  Widget build(BuildContext context) {
    controller = context.read<UserManagementAccessCubit>();

    return Column(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(controller.selectedRole),
          style: AppTextStyles.font16BlackSemiBoldCairo,
        ),
        Row(
          spacing: 10.sp,
          children: [
            Expanded(
                child: mainBlock(
                    title: "Creation Date".tr,
                    value: DateFormat(Constants.userAccessDateFormat,
                            context.isArabic ? 'ar' : 'en')
                        .format(controller.creationDate!))),
            Expanded(
                child: mainBlock(
                    title: 'Total Employees'.tr,
                    value: controller.employeeToGiveAccess.length.toString())),
            Expanded(
                child: mainBlock(
                    title: 'Total Departments'.tr,
                    value: controller.employeeToGiveAccess
                        .map((e) => e.departmentId)
                        .toSet()
                        .length
                        .toString())),
          ],
        )
      ],
    );
  }

  Widget mainBlock({required String title, required String value}) {
    return Container(
        height: 75.sp,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
              child: Text(title,
                  style: AppTextStyles.font14BlackSemiBoldCairo
                      .copyWith(fontSize: 13.sp)),
            ),
            Text(value,
                style: AppTextStyles.font14SecondaryBlackCairo.copyWith(
                    fontSize: 13.sp, fontWeight: AppFontWeights.semiBold)),
          ],
        ));
  }
}
