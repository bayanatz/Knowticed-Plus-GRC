// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_preview_page.dart
/// Module: GRC Control Bulk Upload
/// Description: Editable preview table for the Control bulk upload flow.
///              Mirrors policy_bulk_upload_preview_page.dart's toolbar/
///              error-nav/per-cell structure; adds a per-row (not
///              page-footer) Applied Departments Total Weight box, shown
///              only once that row's Applied Departments cell itself has
///              no error (a bad sum still shows the box, in red, per the
///              'departmentWeight' error key — see ControlBulkRowForm).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, ControlBulkUploadCubit, ControlBulkRowForm

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_cubit.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

const List<_ColumnSpec> _columns = [
  _ColumnSpec('controlNameEn', 'Control Name', 150),
  _ColumnSpec('controlNameAr', 'اسم ضابط', 150),
  _ColumnSpec('controlNumberEn', 'Control Number', 110),
  _ColumnSpec('controlNumberAr', 'رقم ضابط', 110),
  _ColumnSpec('controlDescriptionEn', 'Control Description', 180),
  _ColumnSpec('controlDescriptionAr', 'وصف ضابط', 180),
  _ColumnSpec('startDate', 'Start Date', 110),
  _ColumnSpec('endDate', 'End Date', 110),
  _ColumnSpec('controlWeight', 'Control Weight', 100),
  _ColumnSpec('frequency', 'Frequency', 110),
  _ColumnSpec('controlChampion', 'Control Champion', 180),
  _ColumnSpec('controlOwner', 'Control Owner', 180),
  _ColumnSpec('appliedDepartments', 'Applied Departments', 200),
  _ColumnSpec('departmentWeight', 'Department Weight', 150),
];

class _ColumnSpec {
  final String fieldKey;
  final String label;
  final double width;
  const _ColumnSpec(this.fieldKey, this.label, this.width);
}

class ControlBulkUploadPreviewPage extends StatefulWidget {
  final String moduleId;
  final String policyId;

  const ControlBulkUploadPreviewPage({
    super.key,
    required this.moduleId,
    required this.policyId,
  });

  @override
  State<ControlBulkUploadPreviewPage> createState() =>
      _ControlBulkUploadPreviewPageState();
}

class _ControlBulkUploadPreviewPageState
    extends State<ControlBulkUploadPreviewPage> {
  int _currentErrorIndex = -1;

  void _jumpToError(bool next, ControlBulkUploadRows rowsData) {
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

  Future<void> _onActivate(ControlBulkUploadCubit cubit) async {
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
    await cubit.submit(moduleId: widget.moduleId, policyId: widget.policyId);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ControlBulkUploadCubit>();

    return BlocConsumer<ControlBulkUploadCubit, ControlBulkUploadState>(
      listener: (context, state) {
        if (state is ControlBulkUploadSubmitResult) {
          if (state.succeededCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.succeededCount} ${'control(s) created'.tr}',
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
        final submitting = state is ControlBulkUploadSubmitting;
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
                    screensTitles: ['GRC'.tr, 'Control Bulk Upload Preview'.tr],
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
    ControlBulkUploadCubit cubit,
    ControlBulkUploadRows rowsData,
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
        SizedBox(width: 140.w),
      ],
    );
  }

  Widget _buildRow(
    ControlBulkUploadCubit cubit,
    ControlBulkUploadRows rowsData,
    int index,
  ) {
    final row = rowsData.rows[index];
    final controllers = <String, TextEditingController>{
      'controlNameEn': row.controlNameEnController,
      'controlNameAr': row.controlNameArController,
      'controlNumberEn': row.controlNumberEnController,
      'controlNumberAr': row.controlNumberArController,
      'controlDescriptionEn': row.controlDescriptionEnController,
      'controlDescriptionAr': row.controlDescriptionArController,
      'startDate': row.startDateController,
      'endDate': row.endDateController,
      'controlWeight': row.controlWeightController,
      'frequency': row.frequencyController,
      'controlChampion': row.controlChampionController,
      'controlOwner': row.controlOwnerController,
      'appliedDepartments': row.appliedDepartmentsController,
      'departmentWeight': row.departmentWeightController,
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
          _buildRowTotalWeight(row),
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

  /// Renders the per-row Applied-Departments Total Weight box: hidden when
  /// the row has no departments at all ([ControlBulkRowForm.departmentNames]
  /// empty — either genuinely empty or the names/count themselves errored,
  /// in which case the red-bordered Applied Departments cell above already
  /// communicates the problem); green when the pair is fully valid; red
  /// (with a "should be 100" message) when the names/count are fine but the
  /// weights don't sum to 100 (['departmentWeight'] error present).
  Widget _buildRowTotalWeight(ControlBulkRowForm row) {
    if (row.departmentNames.isEmpty) return SizedBox(width: 140.w);

    final total = row.departmentWeights.fold<double>(0, (sum, w) => sum + w);
    final valid = !row.errors.containsKey('departmentWeight');

    return SizedBox(
      width: 140.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: valid ? AppColors.green : AppColors.red),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${'Total Weight'.tr} : ${total.toStringAsFixed(0)}',
                style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
              ),
            ),
            if (!valid)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  'Total Weight should be 100'.tr,
                  style: StyleText.fontSize10Weight500.copyWith(color: AppColors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
