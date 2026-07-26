/// Module: Policy Management
/// Description: The Control Weight Issue page's History tab: a table of
///              every recorded weight change across one Policy's Controls.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-20
/// Dependencies: flutter_bloc, ControlWeightHistoryCubit, EmployeeHelper, intl
/// Revision History: 2026-07-20 - Initial creation
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_weight_history_entry.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_history_cubit.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';

/// class name: [ControlWeightHistoryTab]
///
/// purpose: render the History tab of the Control Weight Issue page,
///          reading an already-provided [ControlWeightHistoryCubit] (the
///          parent page owns the [BlocProvider]).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 20/7/2026
class ControlWeightHistoryTab extends StatelessWidget {
  const ControlWeightHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ControlWeightHistoryCubit, ControlWeightHistoryState>(
      builder: (context, state) {
        if (state is ControlWeightHistoryLoading || state is ControlWeightHistoryInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (state is ControlWeightHistoryFailure) {
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

        final loaded = state as ControlWeightHistoryLoaded;
        if (loaded.entries.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Center(
              child: Text(
                'No Weight Changes'.tr,
                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText),
              ),
            ),
          );
        }

        final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');

        return SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.secondaryText.withOpacity(.15)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(52),
                  1: FlexColumnWidth(2.2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(1.4),
                  4: FlexColumnWidth(1.4),
                  5: FlexColumnWidth(1.4),
                  6: FlexColumnWidth(1.6),
                },
                children: [
                  _headerRow(),
                  for (var i = 0; i < loaded.entries.length; i++)
                    _dataRow(
                      context: context,
                      entry: loaded.entries[i],
                      noOfDepartments: loaded.departmentCounts[loaded.entries[i].controlId] ?? 0,
                      index: i,
                      dateFormat: dateFormat,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TableRow _headerRow() {
    final headers = [
      'NO',
      'Changed By',
      'Control Name',
      'No of Departments',
      'Control Weight Current',
      'Control Weight Previous',
      'Date Of Action',
    ];
    return TableRow(
      decoration: const BoxDecoration(color: Colors.black),
      children: headers
          .map(
            (header) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              child: Text(
                header.tr,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  TableRow _dataRow({
    required BuildContext context,
    required ControlWeightHistoryEntry entry,
    required int noOfDepartments,
    required int index,
    required DateFormat dateFormat,
  }) {
    final isEven = index % 2 == 0;
    return TableRow(
      decoration: BoxDecoration(color: isEven ? AppColors.background : AppColors.field),
      children: [
        _cell(Text('${index + 1}', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(employeeDisplayName(context, entry.changedByEmail),
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
        _cell(Text(context.isArabic ? entry.controlsNameAr : entry.controlsNameEn,
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
        _cell(Text('$noOfDepartments', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(formatControlWeight(entry.weightCurrent), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text))),
        _cell(Text(formatControlWeight(entry.weightPrevious), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(dateFormat.format(entry.dateOfAction), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
      ],
    );
  }

  Widget _cell(Widget child) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h), child: child);
  }
}
