/// Module: knowledge_hub/kh6_approvals/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: status_list.dart
/// Description: Status list — Approvals (S6) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/presentation/controller/approvals_states.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

Widget statusList(
  BuildContext context, {
  required bool isMobile,
  required int selectedIndex,
}) {
  final S s = S.of(context);
  // Translated label, the language-independent key the cubit uses, and the
  // label colour.
  final List<(String, String, Color)> statuses = [
    (s.all, 'all', AppColors.blackButton),
    (s.approved, 'approved', AppColors.lightGreen),
    (s.pending, 'pending', AppColors.orange),
    (s.rejected, 'rejected', AppColors.red),
    (s.removed, 'removed', AppColors.redCrimson),
  ];

  return BlocBuilder<ApprovalsCubit, ApprovalsStates>(
    buildWhen: (previous, current) =>
        current is FetchingApprovalsSuccessState ||
        current is FetchingApprovalsEmptyState,
    builder: (context, state) {
      final cubit = context.read<ApprovalsCubit>();
      return SizedBox(
        height: isMobile ? 35.h : 45.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: statuses.length,
          itemBuilder: (context, index) {
            final (String label, String key, Color color) = statuses[index];
            return GestureDetector(
              onTap: () {
                HapticController.low(); // list row: on the tap (X-117)
                cubit.filterByStatusKey(key, index);
              },
              child: _buildStatusItem(
                context,
                label: label,
                color: color,
                count: cubit.getStatusCountByKey(key),
                selected: selectedIndex == index,
                isMobile: isMobile,
              ),
            );
          },
        ),
      );
    },
  );
}

/// The count square and the label of one status.
Widget _buildStatusItem(
  BuildContext context, {
  required String label,
  required Color color,
  required int count,
  required bool selected,
  required bool isMobile,
}) {
  return Padding(
    padding: const EdgeInsetsDirectional.only(end: 30),
    child: Row(
      children: [
        Container(
          width: isMobile ? 35.h : 45.h,
          height: isMobile ? 35.w : 45.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: selected ? AppColors.primary : AppColors.card,
          ),
          child: Center(
            child: Text(
              KhLocale.digits(context, count),
              style: (isMobile
                      // 22/10/2026 — Owner (phone): count chips match Notifications — box 35, number 14/400, label 14/600.
                      ? StyleText.fontSize14Weight400
                      : StyleText.fontSize20Weight500)
                  .copyWith(
                color:
                    selected ? AppColors.textButton : AppColors.secondaryText,
              ),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Text(
          label,
          style: (isMobile
                  ? StyleText.fontSize14Weight600
                  : StyleText.fontSize16Weight600)
              .copyWith(color: color),
        ),
      ],
    ),
  );
}
