/// Module: database/db2_database_details
///
///*************************** FILE INFO ****************************///
/// File Name: department_chips.dart
/// Description: `EditAccessDepartmentChips` widget, `EditAccessPillButton` widget — its own library so the page stays under 800 lines.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

library;

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';

/// The horizontal chips under the Department multi-select (Figma 7398:9476 —
/// "Marketing / Design / Finance").
///
/// These are the departments already PICKED, not the ones available. Tapping
/// one focuses it — the yellow chip — which scopes the permission fields and
/// the employee list below.
class EditAccessDepartmentChips extends StatelessWidget {
  const EditAccessDepartmentChips({
    super.key,
    required this.departments,
    required this.selectedId,
    required this.onSelected,
  });

  final List<DatabaseDepartment> departments;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (departments.isEmpty) return const SizedBox.shrink();
    final bool isArabic = context.isArabic;

    return SizedBox(
      height: 28.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: departments.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (BuildContext context, int index) {
          final DatabaseDepartment dept = departments[index];
          final bool selected = dept.id == selectedId;

          return GestureDetector(
            onTap: withHaptic(() => onSelected(dept.id), HapticLevel.low),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.transparent,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                dept.localizedName(isArabic: isArabic),
                style: StyleText.fontSize14Weight400.copyWith(
                  color: selected ? AppColors.textButton : AppColors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The yellow "Deselect All" pill (Figma 7398:9476).
class EditAccessPillButton extends StatelessWidget {
  const EditAccessPillButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: withHaptic(onTap, HapticLevel.low),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ),
    );
  }
}
