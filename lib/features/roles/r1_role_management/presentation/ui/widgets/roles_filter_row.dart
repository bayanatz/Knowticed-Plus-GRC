/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: roles_filter_row.dart
/// Purpose: Declares `RolesFilterRow`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_theme.dart';

import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

class RolesFilterRow extends StatelessWidget {
  const RolesFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    !kpIsPhoneLayout(context);
    final RoleCubit controller = context.read<RoleCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 10.sp,
          children: [
            for (RoleStatus status in RoleStatus.filterStatus)
              customButton(
                wrapContent: true,
                contentHorizontalPadding: 10.sp,
                color: controller.selectedRoleStatus == status
                    ? AppColors.primary
                    : AppColors.card,
                textStyle: controller.selectedRoleStatus == status
                    ? null
                    : StyleText.fontSize14Weight400
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
