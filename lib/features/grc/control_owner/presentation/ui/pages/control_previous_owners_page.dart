/// Module: Control Owner Management
/// Description: Page that shows every completed Control Owner assignment
///              stint for one Control, including who assigned them and the
///              date range of each completed stint.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-21
/// Dependencies: flutter_bloc, ControlPreviousOwnersCubit, EmployeeHelper,
///               PaginationAppBar, AppColors, AppTheme, intl
/// Revision History: 2026-07-21 - Initial creation
library;

import 'package:grc_module/core/extension/context_extensions.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/features/grc/control/domain/entities/control_entity.dart';
import 'package:grc_module/features/grc/control_owner/domain/entities/control_owner_history_entry.dart';
import 'package:grc_module/features/grc/control_owner/presentation/controller/control_previous_owners_cubit.dart';
import 'package:grc_module/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:grc_module/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:grc_module/core/helper/main_helper/pagination_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_l10n.dart';

/// class name: [ControlPreviousOwnersPage]
///
/// purpose: entry-point widget for the Previous Control Owners screen.
///          Provides its own [ControlPreviousOwnersCubit] and loads history
///          for the given {module, policy, control}.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 21/7/2026
class ControlPreviousOwnersPage extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;
  final ControlEntity control;

  const ControlPreviousOwnersPage({
    super.key,
    required this.module,
    required this.policy,
    required this.control,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ControlPreviousOwnersCubit>()
        ..loadHistory(
          moduleId: module.moduleId,
          policyId: policy.id,
          controlId: control.id,
        ),
      child: _ControlPreviousOwnersBody(
        module: module,
        policy: policy,
        control: control,
      ),
    );
  }
}

class _ControlPreviousOwnersBody extends StatelessWidget {
  final GRCModuleEntity module;
  final PolicyEntity policy;
  final ControlEntity control;

  const _ControlPreviousOwnersBody({
    required this.module,
    required this.policy,
    required this.control,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    return BlocBuilder<ControlPreviousOwnersCubit, ControlPreviousOwnersState>(
      builder: (context, state) {
        final List<ControlOwnerHistoryEntry> entries =
            state is ControlPreviousOwnersLoaded ? state.entries : const [];

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
                        S.of(context).grc,
                        isArabic ? module.moduleNameAr : module.moduleNameEn,
                        isArabic ? policy.policyNameAr : policy.policyNameEn,
                        isArabic
                            ? control.controlsNameAr
                            : control.controlsNameEn,
                        S.of(context).historyOfControlOwners,
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
    ControlPreviousOwnersState state,
    List<ControlOwnerHistoryEntry> entries,
  ) {
    if (state is ControlPreviousOwnersLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state is ControlPreviousOwnersFailure) {
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
              onPressed: () =>
                  context.read<ControlPreviousOwnersCubit>().loadHistory(
                        moduleId: module.moduleId,
                        policyId: policy.id,
                        controlId: control.id,
                      ),
              child: Text(S.of(context).retry),
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
            S.of(context).noPreviousControlOwners,
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
            _buildHeaderRow(context),
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

  TableRow _buildHeaderRow(BuildContext context) {
    final headers = [
      'NO',
      'Control Owner',
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
              child: Text(grcTr(context, header),
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
    required ControlOwnerHistoryEntry entry,
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
            employeeDisplayName(context, entry.ownerEmail),
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _cell(
          Text(
            employeeDisplayName(context, entry.assignedByEmail),
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
