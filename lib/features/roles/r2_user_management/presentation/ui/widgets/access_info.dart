import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/data_grc_module/core/extensions/extensions.dart';
import 'package:grc_module/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_font_weights.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/helper/role/constants.dart';
import 'package:grc_module/generated/l10n.dart';

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
                    title: S.of(context).creationDate,
                    value: DateFormat(Constants.userAccessDateFormat,
                            context.isArabic ? 'ar' : 'en')
                        .format(controller.creationDate!))),
            Expanded(
                child: mainBlock(
                    title: S.of(context).totalEmployees,
                    value: controller.employeeToGiveAccess.length.toString())),
            Expanded(
                child: mainBlock(
                    title: S.of(context).totalDepartments,
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
