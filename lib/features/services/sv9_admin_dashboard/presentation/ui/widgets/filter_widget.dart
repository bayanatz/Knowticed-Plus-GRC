/// Module: services / sv9_admin_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: filter_widget.dart
/// Purpose: The department chips over the admin dashboard — "All" first,
///          then each department by request count.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/services/helpers/services_text.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class DepartmentFilterWidget extends StatelessWidget {
  final int totalServices;
  final String selectedStatus;
  final Map<String, int> departmentCounts;
  final Function(String) onStatusChanged;
  final Widget Function(
    String count,
    String label,
    String key, {
    required bool isSelected,
  }) statusChipBuilder;

  const DepartmentFilterWidget({
    super.key,
    required this.totalServices,
    required this.selectedStatus,
    required this.departmentCounts,
    required this.onStatusChanged,
    required this.statusChipBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.svcIsArabic;
    const all = DashboardAdminCubit.allDepartments;

    // ✅ Get Arabic names dynamically from controller
    final departmentController = context.read<MainCoreDepartmentCubit>();

    String getDisplayName(String englishName) {
      // W27: no try/catch in the widget (§11.2); the controller lookups are
      // null-safe and fall back to the English name.
      if (!isArabic) return englishName;
      final deptId = departmentController.getDepartmentIdFromDepartmentName(
        departmentName: englishName.toLowerCase(),
      );
      if (deptId != null) {
        return departmentController.getArabicDepartmentNameFromDepartmentId(
              departmentId: deptId,
            ) ??
            englishName;
      }
      return englishName;
    }

    // Create department data list sorted by count descending
    List<Map<String, dynamic>> departmentData = departmentCounts.entries
        .map((entry) => {"key": entry.key, "count": entry.value})
        .toList();

    departmentData.sort((a, b) => b['count'].compareTo(a['count']));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // First item: All
          GestureDetector(
            onTap: withHaptic(() => onStatusChanged(all), HapticLevel.low),
            child: statusChipBuilder(
              context.svcNumber(totalServices),
              S.of(context).all,
              all,
              isSelected: selectedStatus == all,
            ),
          ),
          // Dynamic departments
          ...departmentData.map(
            (dept) => GestureDetector(
              onTap: withHaptic(
                () => onStatusChanged(dept['key']),
                HapticLevel.low,
              ),
              child: statusChipBuilder(
                context.svcNumber(dept['count'] as int),
                getDisplayName(dept['key']),
                dept['key'],
                isSelected: selectedStatus == dept['key'],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
