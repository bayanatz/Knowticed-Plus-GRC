import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

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
              customButton(

                color: controller.selectedRoleStatus == status
                    ? AppColors.primary
                    : AppColors.field,
                textStyle: controller.selectedRoleStatus == status
                    ? null
                    : AppTextStyles.font14BlackRegularCairo
                    .copyWith(color: status.color),
                title: status.localizedName(context),
                function: () {
                  controller.updateSelectedRoleStatus(status);
                },
              )
          ],
        ),
      ],
    );
  }
}