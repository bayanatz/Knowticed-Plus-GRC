/// Module: Policy Management
/// Description: Page opened from PolicyViewModeWidget's "Control Weight
///              Issue" banner. Two tabs: "Controls Weight" (an editable
///              table of the Controls under this Policy, with Equal Weight
///              / manual editing) and "History" (every recorded weight
///              change).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter_bloc, get_it, ControlWeightIssueCubit,
///               ControlWeightHistoryCubit, ControlWeightHistoryTab
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_tab.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_row.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

/// class name: [ControlWeightIssuePage]
///
/// purpose: host the Controls Weight / History tabs for one Policy's
///          Controls, provisioning its own [ControlWeightIssueCubit] and
///          [ControlWeightHistoryCubit] (same pattern as
///          `PolicyWeightIssuePage`).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightIssuePage extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;

  const ControlWeightIssuePage({
    super.key,
    required this.module,
    required this.policy,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ControlWeightIssueCubit>(
          create: (_) => GetIt.instance<ControlWeightIssueCubit>()
            ..load(module.moduleId, policy.id),
        ),
        BlocProvider<ControlWeightHistoryCubit>(
          create: (_) => GetIt.instance<ControlWeightHistoryCubit>()
            ..loadHistory(module.moduleId, policy.id),
        ),
      ],
      child: _ControlWeightIssueBody(module: module, policy: policy),
    );
  }
}

class _ControlWeightIssueBody extends StatefulWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;

  const _ControlWeightIssueBody({required this.module, required this.policy});

  @override
  State<_ControlWeightIssueBody> createState() => _ControlWeightIssueBodyState();
}

class _ControlWeightIssueBodyState extends State<_ControlWeightIssueBody> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [
                  'GRC'.tr,
                  context.isArabic ? widget.module.moduleNameAr : widget.module.moduleNameEn,
                  context.isArabic ? widget.policy.policyNameAr : widget.policy.policyNameEn,
                  'Control Weight Issue'.tr,
                ],
              ),
              SizedBox(height: 15.h),
              _buildTabs(),
              SizedBox(height: 15.h),
              Expanded(
                child: _selectedTab == 0
                    ? _buildControlsWeightTab(context)
                    : const ControlWeightHistoryTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _tabItem('Controls Weight', 0),
        SizedBox(width: 24.w),
        _tabItem('History', 1),
      ],
    );
  }

  Widget _tabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr,
            style: StyleText.fontSize16Weight500.copyWith(
              color: isSelected ? AppColors.primary : AppColors.secondaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          if (isSelected)
            Container(height: 2.h, width: 90.w, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildControlsWeightTab(BuildContext context) {
    return BlocConsumer<ControlWeightIssueCubit, ControlWeightIssueState>(
      listener: (context, state) {
        if (state is ControlWeightIssueApplySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You Have Successfully Edited Controls Weights'.tr)),
          );
        }
        if (state is ControlWeightIssueFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is ControlWeightIssueLoading || state is ControlWeightIssueInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final cubit = context.read<ControlWeightIssueCubit>();

        // A failure on the very first load means `_rowsData` was never set
        // (cubit.rowsData would throw) — show the error instead of the
        // table. A failure from Apply Changes never reaches here because
        // applyChanges() only emits Failure before touching `_rowsData`.
        if (state is ControlWeightIssueFailure && !cubit.hasRows) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(
                state.message,
                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final isEditing = state is ControlWeightIssueLoaded && state.isEditing;
        final rowsData = cubit.rowsData;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (isEditing)
                  customButton(
                    title: 'Equal Control Weight'.tr,
                    function: cubit.applyEqualWeight,
                    width: 170.w,
                    height: 36.h,
                    color: AppColors.black,
                  ),
                const Spacer(),
                if (!isEditing)
                  customButton(
                    title: 'Edit'.tr,
                    function: cubit.enterEditMode,
                    width: 100.w,
                    height: 36.h,
                    color: AppColors.primary,
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: _buildTable(context, rowsData, isEditing, cubit),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Align(alignment: Alignment.centerRight, child: _buildTotalWeight(rowsData)),
            SizedBox(height: 12.h),
            if (isEditing)
              Row(
                children: [
                  customButton(
                    title: 'Discard Changes'.tr,
                    function: cubit.discardChanges,
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.secondaryText,
                  ),
                  const Spacer(),
                  customButton(
                    title: 'Apply Changes'.tr,
                    function: rowsData.totalWeightValid
                        ? () => cubit.applyChanges(widget.module.moduleId, widget.policy.id)
                        : () {},
                    width: 150.w,
                    height: 38.h,
                    color: rowsData.totalWeightValid ? AppColors.primary : AppColors.secondaryText,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  static const List<double> _columnWidths = [40, 110, 150, 200, 110, 130, 110, 110];
  static const List<String> _headers = [
    'NO', 'Control Number', 'Control Name', 'Control Description',
    'Control Weight', 'No of Departments', 'Start Date', 'End Date',
  ];

  Widget _buildTable(
    BuildContext context,
    ControlWeightIssueRows rowsData,
    bool isEditing,
    ControlWeightIssueCubit cubit,
  ) {
    final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < _headers.length; i++)
              SizedBox(
                width: _columnWidths[i].w,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(_headers[i].tr, style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text)),
                ),
              ),
          ],
        ),
        for (var i = 0; i < rowsData.rows.length; i++)
          _buildRow(context, rowsData.rows[i], i, isEditing, cubit, dateFormat),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    ControlWeightIssueRow row,
    int index,
    bool isEditing,
    ControlWeightIssueCubit cubit,
    DateFormat dateFormat,
  ) {
    final isArabic = context.isArabic;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cell(0, Text('${index + 1}', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
          _cell(1, Text(isArabic ? row.controlsNumberAr : row.controlsNumberEn, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
          _cell(2, Text(isArabic ? row.controlsNameAr : row.controlsNameEn, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
          _cell(3, Text(isArabic ? row.controlsDescriptionAr : row.controlsDescriptionEn, style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
          _cell(
            4,
            isEditing
                ? TextField(
                    controller: row.weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => cubit.revalidate(),
                    style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.r)),
                    ),
                  )
                : Text(formatControlWeight(row.currentWeight), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
          ),
          _cell(5, Text('${row.noOfDepartments}', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
          _cell(6, Text(dateFormat.format(row.startDate), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
          _cell(7, Text(dateFormat.format(row.endDate), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        ],
      ),
    );
  }

  Widget _cell(int columnIndex, Widget child) {
    return SizedBox(
      width: _columnWidths[columnIndex].w,
      child: Padding(padding: EdgeInsets.symmetric(horizontal: 4.w), child: child),
    );
  }

  Widget _buildTotalWeight(ControlWeightIssueRows rowsData) {
    final valid = rowsData.totalWeightValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border.all(color: valid ? AppColors.green : AppColors.red),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '${'Total Weight'.tr} : ${formatControlWeight(rowsData.totalWeight)}',
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        if (!valid) ...[
          SizedBox(height: 4.h),
          Text(
            'Total Weight Should be 100'.tr,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red),
          ),
        ],
      ],
    );
  }
}
