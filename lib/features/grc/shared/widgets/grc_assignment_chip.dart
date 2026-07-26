/// A single Policy/Control assignment pill used across GRC champion/owner
/// pages. Read-only when [onRemove] is null (details pages); shows a
/// remove icon when [onRemove] is provided (edit/reassign pages).
/// Extracted because both variants were copy-pasted 3x each on the
/// champion side and 3x each on the owner side.
library;

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrcAssignmentChip extends StatelessWidget {
  final String label;
  final VoidCallback? onRemove;

  const GrcAssignmentChip({super.key, required this.label, this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (onRemove == null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.remove_circle, color: Colors.red, size: 18),
          ),
        ],
      ),
    );
  }
}
