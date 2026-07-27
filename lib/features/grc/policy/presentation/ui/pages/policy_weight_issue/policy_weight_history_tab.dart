/// Module: Policy Management
/// Description: The Policy Weight Issue page's History tab: a table of
///              every recorded weight change across the module's policies.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, PolicyWeightHistoryCubit, EmployeeHelper, intl
/// Revision History: 2026-07-19 - Initial creation
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/policy/domain/entities/policy_weight_history_entry.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart';
import 'package:demo_app/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';

/// class name: [PolicyWeightHistoryTab]
///
/// purpose: render the History tab of the Policy Weight Issue page,
///          reading an already-provided [PolicyWeightHistoryCubit] (the
///          parent page owns the [BlocProvider], same convention as the
///          Policies/Champions/Owners tabs on GrcModuleDetailsPage).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 19/7/2026
class PolicyWeightHistoryTab extends StatelessWidget {
  const PolicyWeightHistoryTab({super.key});

  String _formatWeight(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PolicyWeightHistoryCubit, PolicyWeightHistoryState>(
      builder: (context, state) {
        if (state is PolicyWeightHistoryLoading || state is PolicyWeightHistoryInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 60.h),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (state is PolicyWeightHistoryFailure) {
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

        final loaded = state as PolicyWeightHistoryLoaded;
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
                  3: FlexColumnWidth(1.2),
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
                      noOfControls: loaded.controlCounts[loaded.entries[i].policyId] ?? 0,
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
      'Policy Name',
      'No of Controls',
      'Policy Weight Current',
      'Policy Weight Previous',
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
    required PolicyWeightHistoryEntry entry,
    required int noOfControls,
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
        _cell(Text(context.isArabic ? entry.policyNameAr : entry.policyNameEn,
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text), overflow: TextOverflow.ellipsis)),
        _cell(Text('$noOfControls', style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(_formatWeight(entry.weightCurrent), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text))),
        _cell(Text(_formatWeight(entry.weightPrevious), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
        _cell(Text(dateFormat.format(entry.dateOfAction), style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryText))),
      ],
    );
  }

  Widget _cell(Widget child) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h), child: child);
  }
}
