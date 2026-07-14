/// Module: GRC Module Management
/// Description: Page that shows all previously removed owners for a GRC
///              Module, including who assigned them and the date range of
///              each completed stint.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-13
/// Dependencies: flutter_bloc, GrcPreviousOwnersCubit, EmployeeHelper,
///               PaginationAppBar, AppColors, AppTheme, intl
/// Revision History: 2026-07-13 - Initial creation
///                    2026-07-13 - Table now spans full width and page
///                                 scrolls vertically instead of the table
///                                 scrolling horizontally.
library;

import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/helper/main_helper/employee_helper.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/domain/entities/grc_module_entity.dart';
import 'package:demo_app/features/grc/domain/entities/grc_module_owner_history_entry.dart';
import 'package:demo_app/features/grc/presentation/controller/grc_previous_owners_cubit.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class GrcPreviousModuleOwnersPage extends StatelessWidget {
  final GRCModuleEntity module;

  const GrcPreviousModuleOwnersPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<GrcPreviousOwnersCubit>()
        ..loadHistory(module.moduleId),
      child: _GrcPreviousModuleOwnersBody(module: module),
    );
  }
}

class _GrcPreviousModuleOwnersBody extends StatelessWidget {
  final GRCModuleEntity module;

  const _GrcPreviousModuleOwnersBody({required this.module});

  String _displayName(BuildContext context, String email) {
    try {
      return EmployeeHelper.getEmployeeLocalizedNameWithEmail(
        employeeEmail: email,
      );
    } catch (_) {
      return email;
    }
  }

  String _displayEmail(String email) => email;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GrcPreviousOwnersCubit, GrcPreviousOwnersState>(
      builder: (context, state) {
        final List<GRCModuleOwnerHistoryEntry> entries =
            state is GrcPreviousOwnersLoaded ? state.entries : const [];

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaginationAppBar(
                      screensTitles: [
                        'GRC'.tr,
                        context.isArabic
                            ? module.moduleNameAr
                            : module.moduleNameEn,
                        'Previous Module Owners'.tr,
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildBody(context, state, entries),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    GrcPreviousOwnersState state,
    List<GRCModuleOwnerHistoryEntry> entries,
  ) {
    if (state is GrcPreviousOwnersLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state is GrcPreviousOwnersFailure) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.message,
              style:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => context
                  .read<GrcPreviousOwnersCubit>()
                  .loadHistory(module.moduleId),
              child: Text('Retry'.tr),
            ),
          ],
        ),
      );
    }

    if (entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            'No Previous Module Owners'.tr,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      );
    }

    final dateFormat = DateFormat('d MMM yyyy', context.isArabic ? 'ar' : 'en');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.secondaryText.withOpacity(.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(52.w),
            1: FlexColumnWidth(2.4),
            2: FlexColumnWidth(2.4),
            3: FlexColumnWidth(1.4),
            4: FlexColumnWidth(1.4),
          },
          children: [
            _buildHeaderRow(),
            for (var i = 0; i < entries.length; i++)
              _buildDataRow(
                context: context,
                entry: entries[i],
                index: i,
                dateFormat: dateFormat,
              ),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow() {
    final headers = [
      'NO',
      'Previous Owner',
      'Assigned By',
      'Start Date',
      'End Date',
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

  TableRow _buildDataRow({
    required BuildContext context,
    required GRCModuleOwnerHistoryEntry entry,
    required int index,
    required DateFormat dateFormat,
  }) {
    final isEven = index % 2 == 0;
    return TableRow(
      decoration: BoxDecoration(
        color: isEven ? AppColors.background : AppColors.field,
      ),
      children: [
        _cell(
          Text(
            '${index + 1}',
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
        _cell(
          Text(
            _displayName(context, entry.ownerEmail),
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _cell(
          Text(
            _displayName(context, entry.assignedByEmail),
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _cell(
          Text(
            dateFormat.format(entry.startDate),
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
        _cell(
          Text(
            dateFormat.format(entry.endDate),
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
        ),
      ],
    );
  }

  Widget _cell(Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      child: child,
    );
  }
}
