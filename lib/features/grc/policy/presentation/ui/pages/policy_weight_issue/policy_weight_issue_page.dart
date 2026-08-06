/// Module: Policy Management
/// Description: Page opened from GrcModuleDetailsPage's "Policy Weight
///              Issue" button. Two tabs: "Policies Weight" (an editable
///              table of the Active/Scheduled policies making up the
///              module's weight total, with Equal Weight / manual editing)
///              and "History" (every recorded weight change).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, get_it, PolicyWeightIssueCubit,
///               PolicyWeightHistoryCubit, PolicyWeightHistoryTab
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:grc_module/core/custom/11_custom_confirm_diaolog.dart';
import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:grc_module/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart';
import 'package:grc_module/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_tab.dart';
import 'package:grc_module/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_cubit.dart';
import 'package:grc_module/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_row.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_l10n.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';

/// class name: [PolicyWeightIssuePage]
///
/// purpose: host the Policies Weight / History tabs for one GRC Module,
///          provisioning its own [PolicyWeightIssueCubit] and
///          [PolicyWeightHistoryCubit] (same pattern as
///          GrcPreviousModuleOwnersPage / AddChampionPage provisioning
///          their own cubits when pushed).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightIssuePage extends StatelessWidget {
  final GRCModuleEntity module;

  const PolicyWeightIssuePage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PolicyWeightIssueCubit>(
          create: (_) =>
              GetIt.instance<PolicyWeightIssueCubit>()..load(module.moduleId),
        ),
        BlocProvider<PolicyWeightHistoryCubit>(
          create: (_) => GetIt.instance<PolicyWeightHistoryCubit>(),
        ),
      ],
      child: _PolicyWeightIssueBody(module: module),
    );
  }
}

class _PolicyWeightIssueBody extends StatefulWidget {
  final GRCModuleEntity module;

  const _PolicyWeightIssueBody({required this.module});

  @override
  State<_PolicyWeightIssueBody> createState() => _PolicyWeightIssueBodyState();
}

class _PolicyWeightIssueBodyState extends State<_PolicyWeightIssueBody> {
  int _selectedTab = 0;
  bool _historyLoaded = false;
  bool _applyingDialogShown = false;

  String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

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
                  S.of(context).grc,
                  context.isArabic
                      ? widget.module.moduleNameAr
                      : widget.module.moduleNameEn,
                  S.of(context).policyWeightIssue,
                ],
              ),
              SizedBox(height: 15.h),
              _buildTabs(),
              SizedBox(height: 15.h),
              Expanded(
                child: _selectedTab == 0
                    ? _buildPoliciesWeightTab(context)
                    : const PolicyWeightHistoryTab(),
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
        _tabItem('Policies Weight', 0),
        SizedBox(width: 24.w),
        _tabItem('History', 1),
      ],
    );
  }

  void _selectTab(int index) {
    setState(() => _selectedTab = index);
    if (index == 1 && !_historyLoaded) {
      _historyLoaded = true;
      context
          .read<PolicyWeightHistoryCubit>()
          .loadHistory(widget.module.moduleId);
    }
  }

  Widget _tabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => _selectTab(index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(grcTr(context, label),
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

  Widget _buildPoliciesWeightTab(BuildContext context) {
    return BlocConsumer<PolicyWeightIssueCubit, PolicyWeightIssueState>(
      listener: (context, state) {
        if (state is PolicyWeightIssueApplying) {
          _applyingDialogShown = true;
          showLoadingIndicator();
          return;
        }
        if (_applyingDialogShown) {
          _applyingDialogShown = false;
          hideLoadingIndicator();
        }
        if (state is PolicyWeightIssueApplySuccess) {
          showSuccessDialog(
            context: context,
            subtitle: S.of(context).youHaveSuccessfullyEditedPoliciesWeights,
          );
        }
        if (state is PolicyWeightIssueFailure) {
          CustomDialogManager.showMessage(
            context: context,
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
            title: S.of(context).unsuccessful,
            subtitle: state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is PolicyWeightIssueLoading ||
            state is PolicyWeightIssueInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        final cubit = context.read<PolicyWeightIssueCubit>();

        // A failure on the very first load means `_rowsData` was never set
        // (cubit.rowsData would throw) — show the error instead of the
        // table. A failure from Apply Changes never reaches here because
        // applyChanges() only emits Failure before touching `_rowsData`.
        if (state is PolicyWeightIssueFailure && !cubit.hasRows) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(
                state.message,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final isEditing =
            (state is PolicyWeightIssueLoaded && state.isEditing) ||
                state is PolicyWeightIssueApplying;
        final rowsData = cubit.rowsData;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (isEditing)
                  customButton(
                    title: S.of(context).equalPolicyWeight,
                    function: cubit.applyEqualWeight,
                    width: 160.w,
                    height: 36.h,
                    color: AppColors.black,
                  ),
                const Spacer(),
                if (!isEditing)
                  customButton(
                    title: S.of(context).Edit,
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
            Align(
                alignment: Alignment.centerRight,
                child: _buildTotalWeight(rowsData)),
            SizedBox(height: 12.h),
            if (isEditing)
              Row(
                children: [
                  customButton(
                    title: S.of(context).discardChange,
                    function: cubit.discardChanges,
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.secondaryText,
                  ),
                  const Spacer(),
                  customButton(
                    title: S.of(context).applyChanges,
                    function: rowsData.totalWeightValid
                        ? () => showConfirmDialog(
                              context: context,
                              title: S.of(context).editingPoliciesWeight,
                              cancelLabel: S.of(context).no,
                              confirmLabel: S.of(context).yes,
                              subtitle:
                                  S.of(context).areYouSureYouWantToEditPoliciesWeight,
                              onConfirm: () =>
                                  cubit.applyChanges(widget.module.moduleId),
                            )
                        : () {},
                    width: 150.w,
                    height: 38.h,
                    color: rowsData.totalWeightValid
                        ? AppColors.primary
                        : AppColors.secondaryText,
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  static const List<double> _columnWidths = [
    40,
    110,
    150,
    200,
    110,
    100,
    110,
    110
  ];
  static const List<String> _headers = [
    'NO',
    'Policy Number',
    'Policy Name',
    'Policy Description',
    'Policy Weight',
    'No of Controls',
    'Start Date',
    'End Date',
  ];

  Widget _buildTable(
    BuildContext context,
    PolicyWeightIssueRows rowsData,
    bool isEditing,
    PolicyWeightIssueCubit cubit,
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
                  child: Text(grcTr(context, _headers[i]),
                      style: StyleText.fontSize14Weight600
                          .copyWith(color: AppColors.text)),
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
    PolicyWeightIssueRow row,
    int index,
    bool isEditing,
    PolicyWeightIssueCubit cubit,
    DateFormat dateFormat,
  ) {
    final isArabic = context.isArabic;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _cell(
              0,
              Text('${index + 1}',
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryText))),
          _cell(
              1,
              Text(isArabic ? row.policyNumberAr : row.policyNumberEn,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis)),
          _cell(
              2,
              Text(isArabic ? row.policyNameAr : row.policyNameEn,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis)),
          _cell(
              3,
              Text(isArabic ? row.policyDescriptionAr : row.policyDescriptionEn,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  overflow: TextOverflow.ellipsis)),
          _cell(
            4,
            isEditing
                ? TextField(
                    controller: row.weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => cubit.revalidate(),
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.text),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.r)),
                    ),
                  )
                : Text(_formatWeight(row.currentWeight),
                    style: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.text)),
          ),
          _cell(
              5,
              Text('${row.noOfControls}',
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryText))),
          _cell(
              6,
              Text(dateFormat.format(row.startDate),
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryText))),
          _cell(
              7,
              Text(dateFormat.format(row.endDate),
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.secondaryText))),
        ],
      ),
    );
  }

  Widget _cell(int columnIndex, Widget child) {
    return SizedBox(
      width: _columnWidths[columnIndex].w,
      child:
          Padding(padding: EdgeInsets.symmetric(horizontal: 4.w), child: child),
    );
  }

  Widget _buildTotalWeight(PolicyWeightIssueRows rowsData) {
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
            '${S.of(context).totalWeight} : ${_formatWeight(rowsData.totalWeight)}',
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        if (!valid) ...[
          SizedBox(height: 4.h),
          Text(
            S.of(context).totalWeightShouldBe100,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red),
          ),
        ],
      ],
    );
  }
}
