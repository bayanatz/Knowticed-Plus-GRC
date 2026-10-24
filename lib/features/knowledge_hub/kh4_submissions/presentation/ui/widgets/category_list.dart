/// Module: knowledge_hub/kh4_submissions/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: category_list.dart
/// Description: Category list — Submissions (S4) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/presentation/controller/submissions_states.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

Widget categoryList(
  BuildContext context, {
  required bool isMobile,
  required int selectedIndex,
}) {
  final S s = S.of(context);
  // Translated label, the constant English value the cubit filters on, and
  // the label colour.
  final List<(String, String, Color)> statusItems = [
    (s.all, 'All', AppColors.blackButton),
    (s.published, 'Published', AppColors.fileExcel),
    (s.approved, 'Approved', AppColors.lightGreen),
    (s.pending, 'Pending', AppColors.orange),
    (s.rejected, 'Rejected', AppColors.darkRed),
    (s.removed, 'Removed', AppColors.darkRed),
    (s.archive, 'Archive', AppColors.secondaryBlack),
  ];
  // Square size using .sp for a perfect square on all screens.
  final double squareSize = isMobile ? 35.sp : 45.sp;

  return BlocBuilder<SubmissionsCubit, SubmissionsStates>(
    builder: (context, state) {
      final cubit = context.read<SubmissionsCubit>();
      return SizedBox(
        height: squareSize,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: statusItems.length,
          itemBuilder: (context, index) {
            final (String label, String value, Color color) =
                statusItems[index];
            return GestureDetector(
              onTap: () {
                HapticController.low(); // list row: on the tap (X-117)
                cubit.filterByStatus(value, index);
              },
              child: _buildCategoryItem(
                context,
                label: label,
                color: color,
                count: cubit.getStatusCount(value),
                selected: selectedIndex == index,
                isMobile: isMobile,
                squareSize: squareSize,
              ),
            );
          },
        ),
      );
    },
  );
}

/// The count square and the status label of one category.
Widget _buildCategoryItem(
  BuildContext context, {
  required String label,
  required Color color,
  required int count,
  required bool selected,
  required bool isMobile,
  required double squareSize,
}) {
  final TextStyle countStyle =
      (isMobile ? StyleText.fontSize14Weight600 : StyleText.fontSize20Weight500)
          .copyWith(
    color: selected ? AppColors.textButton : AppColors.secondaryText,
  );
  return Padding(
    padding: const EdgeInsetsDirectional.only(end: 30),
    child: Row(
      children: [
        Container(
          width: squareSize,
          height: squareSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: selected ? AppColors.primary : AppColors.card,
          ),
          child: Center(
            child: Text(KhLocale.digits(context, count), style: countStyle),
          ),
        ),
        SizedBox(width: 15.w),
        Text(
          label,
          style: (isMobile
                  // 22/10/2026 — Owner (phone): count chips match Notifications — box 35, number 14/400, label 14/600.
                  ? StyleText.fontSize14Weight400
                  : StyleText.fontSize18Weight500)
              .copyWith(color: color),
        ),
      ],
    ),
  );
}
