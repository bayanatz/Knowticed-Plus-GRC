// ***************************** FILE INFO ***************************** //
// File Name: salary_tab_page.dart
// Purpose: Displays searchable employee salary and position details.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:knowticed_plus/core/custom/layout/fill_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/hr/helpers/constants/hr_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/hr/helpers/hr_routes.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/hr/presentation/controller/hr_module_data_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/hr_fields/hr_employee_entity.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/enums/employee_upload_controllers/employee_info.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/hr_table_display_value.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/salary_table_value_resolver.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/hr_table_excel_export_action.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/hr_table_viewport.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

/// Renders one salary row for every employee.
class SalaryTabPage extends StatefulWidget {
  const SalaryTabPage({super.key});

  @override
  State<SalaryTabPage> createState() => _SalaryTabPageState();
}

class _SalaryTabPageState extends State<SalaryTabPage> {
  final _searchController = TextEditingController();
  final HrTableExcelExportAction _exportAction = HrTableExcelExportAction();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HrModuleDataCubit, HrModuleDataState>(
        builder: (context, state) {
          final employees = _employeesFor(state);
          return Column(children: [
            _toolbar(context, employees),
            SizedBox(height: 16.h),
            Expanded(child: _table(context, employees)),
          ]);
        },
      );

  Widget _toolbar(BuildContext context, List<HrEmployeeEntity> employees) {
    final actions = [
      CustomFilterIcon(
        title: S.of(context).filter,
        onTap: () {},
        color: AppColors.card,
        svgColor: AppColors.secondaryBlack,
        // 22/10/2026 — Owner: dead textStyle removed — CustomFilterIcon draws its
        // label from ToolbarStyle (14 medium) since 18/10.
      ),
      customButtonWithSvg(
          title: S.of(context).export,
          function: () => _exportSalaries(context, employees),
          // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
          color: AppColors.primary,
          image: AppAssets.export,
          widthImage: 20.sp,
          heightImage: 20.sp,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton),
      customButtonWithSvg(
          title: S.of(context).bulkUpload,
          function: () async {
            final updated = await Navigator.of(context)
                .pushNamed(HRRoutes.hrModuleBulkUploadSalariesPage);
            if (updated == true && mounted) setState(() {});
          },
          // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton),
          color: AppColors.primary,
          image: HRAssets.hrEmployeeOperations,
          widthImage: 20.sp,
          heightImage: 20.sp,
          colorBorder: AppColors.transparent,
          svgColor: AppColors.textButton),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final search = AppSearchTextField(
          controller: _searchController,
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()));
      return constraints.maxWidth < 720.w
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              search,
              SizedBox(height: 12.h),
              Wrap(spacing: 12.w, runSpacing: 12.h, children: actions)
            ])
          : Row(children: [
              search,
              SizedBox(width: 16.w),
              actions[0],
              SizedBox(width: 12.w),
              actions[1],
              SizedBox(width: 12.w),
              actions[2]
            ]);
    });
  }

  /// Method Name: [_exportSalaries]
  ///
  /// Purpose: Exports salary rows matching the active search query.
  ///
  /// Parameters:
  /// - [context]: Provides localized spreadsheet labels.
  /// - [employees]: Current HR employee values before search filtering.
  ///
  /// Returns: Completes after the export action finishes.
  Future<void> _exportSalaries(
    BuildContext context,
    List<HrEmployeeEntity> employees,
  ) {
    final localization = S.of(context);
    final rows = employees.where(_matchesQuery).toList(growable: false);
    return _exportAction.export(
      context: context,
      fileName: 'salaries',
      headers: [
        localization.number,
        localization.employeeId,
        EmployeeInfo.firstName.name,
        EmployeeInfo.middleName.name,
        EmployeeInfo.lastName.name,
        EmployeeInfo.firstNameArabic.name,
        EmployeeInfo.middleNameArabic.name,
        EmployeeInfo.lastNameArabic.name,
        localization.jobType,
        localization.currency,
        localization.salary,
        localization.daysOff,
        localization.startTime,
        localization.endTime,
      ],
      rows: rows.indexed.map((entry) {
        final employee = entry.$2;
        return <String>[
          '${entry.$1 + 1}',
          employee.id ?? '',
          employee.firstName ?? '',
          employee.middleName ?? '',
          employee.lastName ?? '',
          employee.firstNameInArabic ?? '',
          employee.middleNameInArabic ?? '',
          employee.lastNameInArabic ?? '',
          SalaryTableValueResolver.jobType(employee.jobType ?? ''),
          SalaryTableValueResolver.currency(employee.currency ?? ''),
          employee.salary ?? '',
          SalaryTableValueResolver.daysOff(employee.daysOff ?? ''),
          employee.startTime ?? '',
          employee.endTime ?? '',
        ];
      }).toList(growable: false),
    );
  }

  Widget _table(BuildContext context, List<HrEmployeeEntity> employees) {
    final rows = employees.where(_matchesQuery).toList();
    final labels = [
      S.of(context).number,
      S.of(context).employeeId,
      EmployeeInfo.firstName.name,
      EmployeeInfo.middleName.name,
      EmployeeInfo.lastName.name,
      EmployeeInfo.firstNameArabic.name,
      EmployeeInfo.middleNameArabic.name,
      EmployeeInfo.lastNameArabic.name,
      S.of(context).jobType,
      S.of(context).currency,
      S.of(context).salary,
      S.of(context).daysOff,
      S.of(context).startTime,
      S.of(context).endTime
    ];
    return HrTableViewport(
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
        child: AnimatedSizeWrap(
            child: DataTable(
          headingRowColor: WidgetStatePropertyAll(AppColors.header),
          dataRowMinHeight: 46.h,
          dataRowMaxHeight: 46.h,
          headingRowHeight: 46.h,
          horizontalMargin: 16.w,
          columnSpacing: 36.w,
          dividerThickness: 0,
          columns: labels
              .map((label) => DataColumn(
                    columnWidth:
                        fillIntrinsicColumnWidth, // Owner 21/10/2026: equal share of the free width
                    label: _headerCell(context, label),
                  ))
              .toList(),
          rows: List.generate(rows.length, (index) {
            final employee = rows[index];
            final values = [
              '${index + 1}',
              employee.id ?? '',
              employee.firstName ?? '',
              employee.middleName ?? '',
              employee.lastName ?? '',
              employee.firstNameInArabic ?? '',
              employee.middleNameInArabic ?? '',
              employee.lastNameInArabic ?? '',
              SalaryTableValueResolver.jobType(employee.jobType ?? ''),
              SalaryTableValueResolver.currency(employee.currency ?? ''),
              employee.salary ?? '',
              SalaryTableValueResolver.daysOff(employee.daysOff ?? ''),
              employee.startTime ?? '',
              employee.endTime ?? '',
            ];
            return DataRow(
              color: WidgetStatePropertyAll(
                index.isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
              ),
              cells: values
                  .asMap()
                  .entries
                  .map(
                    (entry) => DataCell(
                      Text(
                        HrTableDisplayValue.format(
                          entry.value,
                          capitalize: entry.key != 0 && entry.key != 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight600,
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        )),
      ),
    );
  }

  /// Method Name: [_headerCell]
  ///
  /// Purpose: Matches the Employees table header-label contrast in both themes.
  ///
  /// Parameters:
  /// - [context]: Resolves the active application brightness.
  /// - [value]: Localized table heading.
  ///
  /// Returns: A theme-contrast-aware header label.
  Widget _headerCell(BuildContext context, String value) => Text(
        value,
        style: StyleText.fontSize14Weight600.copyWith(
          color: AppColors.white, // header row is dark in both themes
        ),
      );

  bool _matchesQuery(HrEmployeeEntity employee) {
    if (_query.isEmpty) return true;
    final values = [
      employee.id,
      employee.firstName,
      employee.middleName,
      employee.lastName,
      employee.firstNameInArabic,
      employee.middleNameInArabic,
      employee.lastNameInArabic,
      employee.jobType,
      employee.currency,
      employee.salary,
      employee.daysOff,
      employee.startTime,
      employee.endTime
    ];
    return values
        .any((value) => value?.toLowerCase().contains(_query) ?? false);
  }

  List<HrEmployeeEntity> _employeesFor(HrModuleDataState state) =>
      switch (state) {
        HrModuleDataInitial() => const [],
        HrModuleDataLoading() => state.employees,
        HrModuleDataLoaded() => state.employees,
        HrModuleDataError() => state.employees
      };
}
