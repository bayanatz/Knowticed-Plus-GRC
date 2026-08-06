///************************ FILE INFO ****************************///
/// File Name: user_access_status_row.dart
/// Purpose : Contains the ui for account status row in account status screen.
/// Author: Amr Mesbah
/// Created at : 28/1/2025
///
/// Uses the shared StatusChipFilter from core/custom/8-custom_filter_app.dart
/// instead of hand-rolling a Row of FilterBarItem widgets. StatusChipFilter
/// supplies its own SingleChildScrollView/Row and defaults chipSpacing to
/// 30.sp, which is what this row used before.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:grc_module/core/custom/8-custom_filter_app.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/helper/role/account_status_constants.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:grc_module/features/roles/r3_user_access/presentation/controller/user_access_state.dart';

class UserAccessStatusRow extends StatelessWidget {
  const UserAccessStatusRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to listen to state changes
    return BlocBuilder<UserAccessCubit, UserAccessState>(
      builder: (context, state) {
        final UserAccessCubit controller =
            context.read<UserAccessCubit>();
        final statuses = AccountStatusConstants.employeeStatus;

        // StatusChipFilter keys on a String, while selection here is an
        // EmployeeStatusEnum - so the enum's `name` is used as the key and
        // mapped back to the enum on tap.
        return StatusChipFilter(
          selectedKey: controller.selectedStatus.name,
          onSelected: (key) {
            controller.selectStatus(
              statuses.firstWhere((status) => status.name == key),
            );
          },
          items: [
            for (final status in statuses)
              StatusChipItem(
                key: status.name,
                label: FormatHelper.capitalize(status.localizedName(context)),
                count: controller.accountStatusEntities[status]?.length ?? 0,
                labelColor: status.color,
              ),
          ],
        );
      },
    );
  }
}
