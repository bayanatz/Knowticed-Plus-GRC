/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: roles_filter_row.dart
/// Purpose: Declares `RolesFilterRow`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/navigation/custom_filter_app.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

class RolesFilterRow extends StatelessWidget {
  const RolesFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final RoleCubit controller = context.read<RoleCubit>();
    // Owner 21/10/2026: status filter uses the standard StatusChipFilter (count box + label, like User Access) instead of coloured text on grey chips.
    return StatusChipFilter(
      selectedKey: controller.selectedRoleStatus.name,
      onSelected: (key) => controller.updateSelectedRoleStatus(
        RoleStatus.filterStatus.firstWhere((status) => status.name == key),
      ),
      items: [
        for (final RoleStatus status in RoleStatus.filterStatus)
          StatusChipItem(
            key: status.name,
            label: status.localizedName(context),
            count: status == RoleStatus.all
                ? controller.roles.length
                : controller.roles
                    .where((role) => role.currentStatus == status)
                    .length,
            labelColor: status.color,
          ),
      ],
    );
  }
}
