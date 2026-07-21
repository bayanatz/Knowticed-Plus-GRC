/// Module: GRC Policy Bulk Upload
/// Description: Editable preview table for the bulk upload flow. One row
///              per parsed policy, each field backed by a TextEditingController
///              so the user can fix flagged data before creating anything;
///              row selection drives Remove Selection / Duplication; the
///              footer shows the Total Weight sum for information only —
///              Activate is disabled only while a per-cell validation error
///              exists or the table is empty.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: flutter_bloc, PolicyBulkUploadCubit, PolicyBulkRowForm

import 'package:demo_app/core/custom/11_custom_confirm_diaolog.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_rows.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_preview_page.dart
/// Purpose: Contains PolicyBulkUploadPreviewPage, the editable table screen
///          the user reviews/fixes/activates from.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

const List<_ColumnSpec> _columns = [
  _ColumnSpec('policyNumberEn', 'Policy Number', 110),
  _ColumnSpec('policyNumberAr', 'Policy Number Ar', 110),
  _ColumnSpec('policyNameEn', 'Policy Name', 150),
  _ColumnSpec('policyNameAr', 'اسم السياسة', 150),
  _ColumnSpec('policyDescriptionEn', 'Policy Description', 180),
  _ColumnSpec('policyDescriptionAr', 'وصف السياسة', 180),
  _ColumnSpec('startDate', 'Start Date', 110),
  _ColumnSpec('endDate', 'End Date', 110),
  _ColumnSpec('policyWeight', 'Policy Weight', 100),
  _ColumnSpec('policyDocument', 'Policy Document', 160),
];

class _ColumnSpec {
  final String fieldKey;
  final String label;
  final double width;
  const _ColumnSpec(this.fieldKey, this.label, this.width);
}

/// class name: [PolicyBulkUploadPreviewPage]
///
/// purpose: render the bulk upload's editable table (mockup: "Policy Bulk
///          Upload Preview") for a [PolicyBulkUploadCubit] already provided
///          above it in the widget tree.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkUploadPreviewPage extends StatefulWidget {
  final String moduleId;

  const PolicyBulkUploadPreviewPage({super.key, required this.moduleId});

  @override
  State<PolicyBulkUploadPreviewPage> createState() =>
      _PolicyBulkUploadPreviewPageState();
}

class _PolicyBulkUploadPreviewPageState
    extends State<PolicyBulkUploadPreviewPage> {
  int _currentErrorIndex = -1;

  void _jumpToError(bool next, PolicyBulkUploadRows rowsData) {
    final locations = rowsData.errorLocations;
    if (locations.isEmpty) return;

    setState(() {
      _currentErrorIndex = next
          ? (_currentErrorIndex + 1) % locations.length
          : (_currentErrorIndex - 1 + locations.length) % locations.length;
    });

    final (rowIndex, fieldKey) = locations[_currentErrorIndex];
    final row = rowsData.rows[rowIndex];
    final rowContext = row.key.currentContext;
    if (rowContext != null) {
      Scrollable.ensureVisible(
        rowContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
      );
    }
    row.focusNodes[fieldKey]?.requestFocus();
  }

  Future<void> _onActivate(PolicyBulkUploadCubit cubit) async {
    final rowsData = cubit.rowsData;
    if (!rowsData.isValid) {
      if (rowsData.errorLocations.isNotEmpty) {
        _jumpToError(true, rowsData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add at least one row'.tr)),
        );
      }
      return;
    }
    await showConfirmDialog(
      context: context,
      title: 'Activate Policies'.tr,
      subtitle: 'Are you sure you want to activate these policies?'.tr,
      confirmLabel: 'Activate'.tr,
      cancelLabel: 'Cancel'.tr,
      onConfirm: () => cubit.submit(moduleId: widget.moduleId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PolicyBulkUploadCubit>();

    return BlocConsumer<PolicyBulkUploadCubit, PolicyBulkUploadState>(
      listener: (context, state) {
        if (state is PolicyBulkUploadSubmitResult) {
          if (state.succeededCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.succeededCount} ${'polic(y/ies) created'.tr}',
                ),
              ),
            );
          }
          if (state.failed.isEmpty) {
            Navigator.pop(context, true);
          }
        }
      },
      builder: (context, state) {
        final submitting = state is PolicyBulkUploadSubmitting;
        final rowsData = cubit.rowsData;
        final activateEnabled = !submitting && rowsData.isValid;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaginationAppBar(
                    screensTitles: ['GRC'.tr, 'Policy Bulk Upload Preview'.tr],
                  ),
                  SizedBox(height: 15.h),
                  _buildToolbar(context, cubit, rowsData),
                  SizedBox(height: 15.h),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderRow(),
                            for (var i = 0; i < rowsData.rows.length; i++)
                              _buildRow(cubit, rowsData, i),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildTotalWeight(rowsData),
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      customButton(
                        title: 'Discard'.tr,
                        function: () => Navigator.pop(context),
                        width: 150.w,
                        height: 38.h,
                        color: AppColors.secondaryText,
                        textStyle: StyleText.fontSize16Weight600
                            .copyWith(color: AppColors.text),
                      ),
                      const Spacer(),
                      customButton(
                        title: 'Activate'.tr,
                        function: submitting ? () {} : () => _onActivate(cubit),
                        width: 150.w,
                        height: 38.h,
                        color: activateEnabled ? AppColors.primary : AppColors.secondaryText,
                        textStyle: StyleText.fontSize16Weight600
                            .copyWith(color: AppColors.textButton),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    PolicyBulkUploadCubit cubit,
    PolicyBulkUploadRows rowsData,
  ) {
    final errorCount = rowsData.errorCount;
    return Row(
      children: [
        Container(
          height: 30.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 16.sp,
                onPressed: () => _jumpToError(false, rowsData),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${'Error'.tr}: '
                '${errorCount > 0 ? '${_currentErrorIndex + 1}/$errorCount' : '0'}',
                style: StyleText.fontSize14Weight500.copyWith(
                  color: errorCount > 0 ? AppColors.red : AppColors.text,
                ),
              ),
              IconButton(
                iconSize: 16.sp,
                onPressed: () => _jumpToError(true, rowsData),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const Spacer(),
        customButton(
          title: 'Remove Selection'.tr,
          function: () {
            if (rowsData.selectedRows.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Select at least one row'.tr)),
              );
              return;
            }
            cubit.removeSelectedRows();
          },
          width: 150.w,
          height: 30.h,
          color: AppColors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
        SizedBox(width: 10.w),
        customButton(
          title: 'Duplication'.tr,
          function: () {
            if (rowsData.selectedRows.length != 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Select exactly one row to duplicate'.tr)),
              );
              return;
            }
            cubit.duplicateSelectedRow();
          },
          width: 100.w,
          height: 30.h,
          color: AppColors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
        SizedBox(width: 10.w),
        customButton(
          title: '+ Row'.tr,
          function: cubit.addRow,
          width: 90.w,
          height: 30.h,
          color: AppColors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        SizedBox(width: 40.w),
        for (final column in _columns)
          SizedBox(
            width: column.width.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                column.label,
                style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(
    PolicyBulkUploadCubit cubit,
    PolicyBulkUploadRows rowsData,
    int index,
  ) {
    final row = rowsData.rows[index];
    final controllers = <String, TextEditingController>{
      'policyNumberEn': row.policyNumberEnController,
      'policyNumberAr': row.policyNumberArController,
      'policyNameEn': row.policyNameEnController,
      'policyNameAr': row.policyNameArController,
      'policyDescriptionEn': row.policyDescriptionEnController,
      'policyDescriptionAr': row.policyDescriptionArController,
      'startDate': row.startDateController,
      'endDate': row.endDateController,
      'policyWeight': row.policyWeightController,
      'policyDocument': row.policyDocumentController,
    };

    return Container(
      key: row.key,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.w,
            child: Checkbox(
              value: rowsData.selectedRows.contains(index),
              activeColor: AppColors.primary,
              onChanged: (_) => cubit.toggleRowSelected(index),
            ),
          ),
          for (final column in _columns)
            _buildCell(
              width: column.width.w,
              controller: controllers[column.fieldKey]!,
              focusNode: row.focusNodes[column.fieldKey]!,
              error: row.errors[column.fieldKey],
              onChanged: () => cubit.revalidateRow(index),
            ),
        ],
      ),
    );
  }

  Widget _buildCell({
    required double width,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String? error,
    required VoidCallback onChanged,
  }) {
    final borderColor = error != null ? AppColors.red : Colors.transparent;
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (_) => onChanged(),
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.card,
            contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            suffixIcon: error != null
                ? Tooltip(
                    message: error,
                    child: Icon(Icons.error, color: AppColors.red, size: 16.sp),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalWeight(PolicyBulkUploadRows rowsData) {
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
            '${'Total Weight'.tr} : ${rowsData.totalWeight.toStringAsFixed(0)}',
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        if (!valid) ...[
          SizedBox(height: 4.h),
          Text(
            'Total Weight should be 100'.tr,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red),
          ),
        ],
      ],
    );
  }
}
