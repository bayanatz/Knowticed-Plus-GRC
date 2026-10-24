/// Module: knowledge_hub/kh5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab
/// ************************* FILE INFO *************************** ///
/// File Name: filter_statistics_dialog.dart
/// Description: Filter statistics dialog — Submission Details (S5) screen UI.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/controller/analytics/analytics_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/dropdowns/custom_dropdown.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';

class FilterStatisticsDialog extends StatefulWidget {
  const FilterStatisticsDialog({super.key});

  @override
  State<FilterStatisticsDialog> createState() => _FilterStatisticsDialogState();
}

class _FilterStatisticsDialogState extends State<FilterStatisticsDialog> {
  // IMPLEMENTED 22/9/2026. This dialog was a shell: `applyFilters` was a
  // commented-out body copied from another screen, Reset was commented out
  // too, and the only control was an Action dropdown whose value went nowhere.
  // Pressing Apply closed nothing and changed nothing.
  //
  // It now carries the reported Department filter alongside Action, and both
  // are pushed into [AnalyticsCubit], which owns the filter state the table,
  // the search field and the Export button all read.
  String? action;
  String? departmentId;

  @override
  void initState() {
    super.initState();
    // Reopening the dialog shows what is currently applied rather than
    // starting blank and silently implying "no filters".
    final cubit = context.read<AnalyticsCubit>();
    action = cubit.statisticsActionFilter;
    departmentId = cubit.statisticsDepartmentFilter;
  }

  void changeActionText(String? newText) {
    setState(() {
      action = newText;
    });
  }

  void changeDepartment(String? newDepartmentId) {
    setState(() {
      departmentId = newDepartmentId;
    });
  }

  void applyFilters() {
    context.read<AnalyticsCubit>().applyStatisticsFilters(
          action: action,
          departmentId: departmentId,
        );
    Navigator.of(context).pop();
  }

  void resetFilters() {
    setState(() {
      action = null;
      departmentId = null;
    });
    // The search box is left alone: it is a separate control the user can see
    // and clear themselves, and wiping it from here would look like a bug.
    context.read<AnalyticsCubit>().resetStatisticsFilters(clearSearch: false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    final Map<String, String> departmentOptions = context
        .read<AnalyticsCubit>()
        .statisticsDepartmentOptions(isEnglish: KhLocale.isEnglish(context));

    return Material(
      color: AppColors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 655.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.card,
        ),
        padding: EdgeInsets.all(15.sp),
        margin: EdgeInsets.symmetric(horizontal: 0.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            // 22/10/2026 — Owner: one dialog header everywhere (30 circle · 16 icon · 18/500 title).
            CustomDialogHeader(
              title: S.of(context).filter,
              icon:
                  'assets/icons_assets/main_icons_assets/ic_action_filter.svg',
            ),
            SizedBox(height: 15.h),
            _buildDropdowns(departmentOptions),

            SizedBox(height: 10.h),

            // Action buttons
            _buildActions(isMobile),
          ],
        ),
      ),
    );
  }

  /// The Action and Department dropdowns.
  Widget _buildDropdowns(Map<String, String> departmentOptions) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: CustomDropdown<String>(
              value: action,
              // Same rule as the Submissions filter dialog: padding
              // sets the height, so every field in the module is
              // 12.sp + one line + 12.sp. A pinned height would force
              // the dropdown's vertical padding to zero.
              triggerPadding: EdgeInsets.symmetric(
                vertical: 12.sp,
                horizontal: 12.sp,
              ),
              items: [
                {'key': 'download', 'value': S.of(context).downloads},
                {'key': 'view', 'value': S.of(context).views},
              ]
                  .map(
                    (e) => DropdownItem<String>(
                      value: e['key'] ?? '',
                      label: e['value'] ?? '',
                    ),
                  )
                  .toList(),
              onChanged: (v) => changeActionText(v),
              hint: S.of(context).action,
              hintStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              fillColor: kDropdownFillColor,
            ),
          ),
        ),
        SizedBox(width: 10.sp),
        // The reported Department filter. Its
        // options come from the rows on screen (see
        // `statisticsDepartmentOptions`), so it can never offer a
        // department this document has no activity from.
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: CustomDropdown<String>(
              value: departmentId,
              triggerPadding: EdgeInsets.symmetric(
                vertical: 12.sp,
                horizontal: 12.sp,
              ),
              items: departmentOptions.entries
                  .map(
                    (e) => DropdownItem<String>(value: e.key, label: e.value),
                  )
                  .toList(),
              onChanged: (v) => changeDepartment(v),
              hint: S.of(context).department,
              hintStyle: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
              maxOverlayHeight: 216.0,
              fillColor: kDropdownFillColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Reset and Apply.
  Widget _buildActions(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          height: 38.h,
          width: isMobile ? 130.w : 150.w,
          title: S.of(context).reset,
          function: resetFilters,
          color: AppColors.secondaryAction, // branding (KH mobile p.6/7/10)
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.onSecondaryAction,
          ),
        ),
        SizedBox(width: 45.w),
        customButton(
          height: 38.h,
          width: isMobile ? 130.w : 150.w,
          title: S.of(context).apply,
          function: applyFilters,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ],
    );
  }
}
