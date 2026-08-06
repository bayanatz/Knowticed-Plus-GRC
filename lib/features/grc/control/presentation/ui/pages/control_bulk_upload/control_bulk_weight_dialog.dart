// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_weight_dialog.dart
/// Module: GRC Control Bulk Upload
/// Description: Blocking Yes/No dialog shown the first time the user
///              initiates a file upload on ControlBulkUploadPage (Browse
///              Files tap or a file drop), before the file picker/parser
///              runs, asking whether every department gets an equal weight
///              share for this whole uploaded batch. Yes (true)
///              means equal split — 100 / department count per row,
///              Department Weight column ignored entirely. No (false) means
///              the existing distinct/manual per-row Department Weight
///              column behavior. The answer applies to the whole batch, not
///              per row, and isn't editable once the dialog closes.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-22
/// Dependencies: flutter/material, AppColors, StyleText, customButton
library;

import 'package:grc_module/core/custom/5-custom_button.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';

import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/generated/l10n.dart';

/// function name: [showControlBulkWeightDialog]
///
/// purpose: block the Control Bulk Upload page behind a non-dismissible
///          Yes/No dialog until the user answers whether every department
///          should get an equal weight share for the whole uploaded batch.
///
/// parameters:
///            [BuildContext] context: the page's context to show the dialog over
///
/// return type: [Future<bool>] - true for Yes (equal split), false for No (distinct weights)
Future<bool> showControlBulkWeightDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.transparent,
        child: Container(
          width: 420.w,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).doesEachDepartmentCarryADistinctWeighting,
                textAlign: TextAlign.center,
                style: StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: customButton(
                      title: S.of(context).no,
                      function: () => Navigator.of(dialogContext).pop(false),
                      height: 38.h,
                      color: AppColors.secondaryText,
                      textStyle:
                          StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: customButton(
                      title: S.of(context).yes,
                      function: () => Navigator.of(dialogContext).pop(true),
                      height: 38.h,
                      color: AppColors.primary,
                      textStyle: StyleText.fontSize16Weight600
                          .copyWith(color: AppColors.textButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result ?? false;
}
