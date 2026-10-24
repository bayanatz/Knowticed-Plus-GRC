// ***************************** FILE INFO ***************************** //
// File Name: certifications_tab_page.dart
// Purpose: Displays searchable employee certification histories.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
// ********************************************************************* //

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/layout/fill_width_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/hr/helpers/constants/hr_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/hr/helpers/hr_date_time_helper.dart';
import 'package:knowticed_plus/features/hr/helpers/hr_routes.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/hr/presentation/controller/hr_module_data_cubit.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/enums/employee_upload_controllers/employee_info.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/hr_table_display_value.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/controller/controller/certifications_cubit.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/certifications_filter_dialog.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/hr_table_excel_export_action.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/hr_table_viewport.dart';

/// Renders employee certification information in a searchable table.
class CertificationsTabPage extends StatefulWidget {
  const CertificationsTabPage({super.key});

  @override
  State<CertificationsTabPage> createState() => _CertificationsTabPageState();
}

class _CertificationsTabPageState extends State<CertificationsTabPage> {
  late final CertificationsCubit _cubit;
  late final TextEditingController _searchController;
  final HrTableExcelExportAction _exportAction = HrTableExcelExportAction();

  @override
  void initState() {
    super.initState();
    _cubit = CertificationsCubit(dataCubit: context.read<HrModuleDataCubit>());
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _cubit,
        child: BlocBuilder<CertificationsCubit, CertificationsState>(
          builder: (context, state) => Column(children: [
            _buildToolbar(context, state),
            SizedBox(height: 16.h),
            Expanded(child: _buildTable(context, state)),
          ]),
        ),
      );

  /// Method Name: [_buildToolbar]
  ///
  /// Purpose: Builds the Health Insurance-style certification toolbar.
  Widget _buildToolbar(BuildContext context, CertificationsState state) {
    final actions = [
      CustomFilterIcon(
        title: S.of(context).filter,
        onTap: () => showAppDialog<void>(
          context: context,
          builder: (_) => BlocProvider.value(
            value: _cubit,
            child: const CertificationsFilterDialog(),
          ),
        ),
        color: AppColors.card,
        svgColor: AppColors.secondaryBlack,
        // 22/10/2026 — Owner: dead textStyle removed — CustomFilterIcon draws its
        // label from ToolbarStyle (14 medium) since 18/10.
      ),
      customButtonWithSvg(
        title: S.of(context).export,
        function: () => _exportCertifications(context, state),
        // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
        textStyle:
            StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
        color: AppColors.primary,
        image: AppAssets.export,
        widthImage: 20.sp,
        heightImage: 20.sp,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
      ),
      customButtonWithSvg(
        title: S.of(context).bulkUpload,
        function: () async {
          final updated = await Navigator.of(context).pushNamed(
            HRRoutes.hrModuleBulkUploadCertificationsPage,
          );
          if (updated == true && mounted) {
            await _cubit.refreshCertifications();
          }
        },
        // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
        textStyle:
            StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
        color: AppColors.primary,
        image: HRAssets.hrEmployeeOperations,
        widthImage: 20.sp,
        heightImage: 20.sp,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
      ),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final search = AppSearchTextField(
        controller: _searchController,
        onChanged: _cubit.updateSearchQuery,
      );
      if (constraints.maxWidth < 720.w) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              SizedBox(height: 12.h),
              Wrap(spacing: 12.w, runSpacing: 12.h, children: actions),
            ]);
      }
      return Row(children: [
        search,
        SizedBox(width: 16.w),
        actions[0],
        SizedBox(width: 12.w),
        actions[1],
        SizedBox(width: 12.w),
        actions[2],
      ]);
    });
  }

  /// Method Name: [_exportCertifications]
  ///
  /// Purpose: Exports the current certification search and filter results.
  ///
  /// Parameters:
  /// - [context]: Provides localized spreadsheet labels and date formatting.
  /// - [state]: Supplies the displayed certification rows.
  ///
  /// Returns: Completes after the export action finishes.
  Future<void> _exportCertifications(
    BuildContext context,
    CertificationsState state,
  ) {
    final localization = S.of(context);
    return _exportAction.export(
      context: context,
      fileName: 'certifications',
      headers: [
        localization.number,
        localization.employeeId,
        EmployeeInfo.firstName.name,
        EmployeeInfo.middleName.name,
        EmployeeInfo.lastName.name,
        EmployeeInfo.firstNameArabic.name,
        EmployeeInfo.middleNameArabic.name,
        EmployeeInfo.lastNameArabic.name,
        localization.institutionName,
        localization.degreeOrCertification,
        localization.fieldOfStudy,
        localization.startDate,
        localization.endDate,
        localization.gradeOrScore,
        localization.certificateId,
        localization.issuingAuthority,
        localization.documentUrl,
        localization.notes,
        localization.createdAt,
        localization.updatedAt,
      ],
      rows: state.rows.indexed.map((entry) {
        final row = entry.$2;
        return <String>[
          '${entry.$1 + 1}',
          ...row.employeeIdentityValues,
          ...row.certificationValues,
          HrDateTimeHelper.formatTimestamp(context, row.createdTimestamp),
          HrDateTimeHelper.formatTimestamp(context, row.updatedTimestamp),
        ];
      }).toList(growable: false),
    );
  }

  /// Method Name: [_buildTable]
  ///
  /// Purpose: Displays current joined certification values for all employees.
  Widget _buildTable(BuildContext context, CertificationsState state) {
    if (state is CertificationsInitial ||
        state is CertificationsLoading && state.rows.isEmpty) {
      return const CircleProgressMaster();
    }
    if (state is CertificationsError && state.rows.isEmpty) {
      return Center(child: Text(state.message));
    }
    final localization = S.of(context);
    final labels = [
      localization.number,
      localization.employeeId,
      EmployeeInfo.firstName.name,
      EmployeeInfo.middleName.name,
      EmployeeInfo.lastName.name,
      EmployeeInfo.firstNameArabic.name,
      EmployeeInfo.middleNameArabic.name,
      EmployeeInfo.lastNameArabic.name,
      localization.institutionName,
      localization.degreeOrCertification,
      localization.fieldOfStudy,
      localization.startDate,
      localization.endDate,
      localization.gradeOrScore,
      localization.certificateId,
      localization.issuingAuthority,
      localization.documentUrl,
      localization.notes,
      localization.createdAt,
      localization.updatedAt,
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
                  columnWidth: fillIntrinsicColumnWidth,
                  label: _headerCell(context,
                      label)) /* Owner 21/10/2026: equal share of the free width */)
              .toList(),
          rows: List.generate(state.rows.length, (index) {
            final row = state.rows[index];
            final values = [
              '${index + 1}',
              ...row.employeeIdentityValues,
              ...row.certificationValues,
              HrDateTimeHelper.formatTimestamp(
                context,
                row.createdTimestamp,
              ),
              HrDateTimeHelper.formatTimestamp(
                context,
                row.updatedTimestamp,
              ),
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
                      _valueCell(
                        entry.value,
                        capitalize:
                            !_certificationPreservedColumns.contains(entry.key),
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

  Widget _valueCell(String value, {bool capitalize = true}) => Text(
        HrTableDisplayValue.format(value, capitalize: capitalize),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize14Weight600,
      );
// Preserved columns are those that should not be capitalized in the table display.
  static const _certificationPreservedColumns = {0, 1, 11, 12, 14, 16, 18, 19};
}
