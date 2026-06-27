import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/helper/main_helper/format_helper.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/features/roles/core_widgets/main_widget/custom_button.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/role_status.dart';
import 'package:demo_app/features/roles/role_management/controller/role_cubit.dart';

class RolesFilterRow extends StatelessWidget {
  RolesFilterRow({super.key});
  late RoleCubit controller;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    controller = context.read<RoleCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 10.sp,
          children: [
            for (RoleStatus status in RoleStatus.filterStatus)
              CustomButton(
                padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                buttonColor: controller.selectedRoleStatus == status
                    ? AppColors.primary
                    : AppColors.field,
                textStyle: controller.selectedRoleStatus == status
                    ? null
                    : AppTextStyles.font14BlackRegularCairo
                    .copyWith(color: status.color),
                buttonText: status.localizedName, // ✅ No .tr needed!
                onTap: () {
                  controller.updateSelectedRoleStatus(status);
                },
              )
          ],
        ),
      ],
    );
  }
}