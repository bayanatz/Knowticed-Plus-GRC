// ***************************** FILE INFO ***************************** //
// File Name: hr_employee_search_row.dart
// Purpose: Renders the responsive HR employee search and action row.
// Author: Mohamed Elrashidy
// Created At: 2026-08-05
// ********************************************************************* //

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/hr/helpers/constants/hr_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_pop_up.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/hr/helpers/hr_routes.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/controller/controller/hr_employee_cubit.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/controller/controller/hr_employee_state.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/employee_table_value_resolver.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/employee_excel_exporter.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/enums/employee_upload_controllers/employee_info.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/utils/enums/ui_controllers/employee_operations.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/hr_employee_view_buttons.dart';
import 'package:knowticed_plus/features/hr/hr2_employees/presentation/ui/widgets/hr_employee_filter_dialog.dart';

class HrEmployeeSearchRow extends StatefulWidget {
  const HrEmployeeSearchRow({
    this.showViewButtons = true,
    super.key,
  });

  final bool showViewButtons;

  @override
  State<HrEmployeeSearchRow> createState() => _HrEmployeeSearchRowState();
}

class _HrEmployeeSearchRowState extends State<HrEmployeeSearchRow> {
  late final TextEditingController _controller;
  final EmployeeExcelExporter _excelExporter = EmployeeExcelExporter();
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HrEmployeeCubit, HrEmployeeState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final cubit = context.read<HrEmployeeCubit>();
            final searchField = AppSearchTextField(
              controller: _controller,
              onChanged: cubit.updateSearchQuery,
            );
            final actions = [
              CustomFilterIcon(
                title: S.of(context).filter,
                onTap: () {
                  final employeeCubit = context.read<HrEmployeeCubit>();
                  showAppDialog<void>(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: employeeCubit,
                      child: const HrEmployeeFilterDialog(),
                    ),
                  );
                },
                color: AppColors.card,
                svgColor: AppColors.secondaryBlack,
                // 22/10/2026 — Owner: dead textStyle removed — CustomFilterIcon draws its
                // label from ToolbarStyle (14 medium) since 18/10.
              ),
              customButtonWithSvg(
                title: S.of(context).export,
                function: () => _exportEmployees(context, state),
                // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.textButton,
                ),
                color: AppColors.primary,
                image: AppAssets.export,
                widthImage: 20.sp,
                heightImage: 20.sp,
                colorBorder: AppColors.transparent,
                svgColor: AppColors.textButton,
              ),
              CustomPopupMenuButton(
                title: S.of(context).employees,
                iconPath: HRAssets.hrEmployeeOperations,
                options: EmployeeOperation.values
                    .map(
                      (operation) => PopupOption(
                        value: operation.value,
                        label: operation.title,
                      ),
                    )
                    .toList(),
                onSelected: _handleEmployeeOperation,
                backgroundColor: AppColors.primary,
                iconColor: AppColors.textButton,
              ),
            ];

            final topRow = constraints.maxWidth < 720.w
                ? Column(
                    children: [
                      Row(children: [searchField]),
                      SizedBox(height: 12.h),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Wrap(
                          spacing: 12.w,
                          runSpacing: 12.h,
                          children: actions,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      searchField,
                      SizedBox(width: 16.w),
                      actions[0],
                      SizedBox(width: 12.w),
                      actions[1],
                      SizedBox(width: 12.w),
                      actions[2],
                    ],
                  );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                topRow,
                if (widget.showViewButtons) ...[
                  SizedBox(height: 12.h),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: HrEmployeeViewButtons(
                      selectedMode: state.viewMode,
                      onChanged: cubit.updateViewMode,
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  /// Method Name: [_exportEmployees]
  ///
  /// Purpose: Exports the currently filtered employee table to Excel.
  ///
  /// Parameters:
  /// - [context]: Provides localization and the department resolver.
  /// - [state]: Supplies the current filtered employee rows.
  ///
  /// Returns: Completes after the workbook is saved.
  Future<void> _exportEmployees(
    BuildContext context,
    HrEmployeeState state,
  ) async {
    if (_isExporting) return;
    final localization = S.of(context);
    setState(() => _isExporting = true);
    showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
          child: SizedBox(height: 96, child: CircleProgressMaster())),
    );
    await Future<void>.delayed(Duration.zero);
    final departmentCubit = Get.find<MainCoreDepartmentCubit>();
    final fields = EmployeeInfo.values;
    final headers = [localization.number, ...fields.map((field) => field.name)];
    final rows = state.employees.asMap().entries.map((entry) {
      final employee = entry.value;
      return [
        '${entry.key + 1}',
        ...fields.map(
          (field) => EmployeeTableValueResolver.valueFor(
            employee: employee,
            field: field,
            departmentCubit: departmentCubit,
          ),
        ),
      ];
    }).toList();

    try {
      await _excelExporter.export(
        headers: headers,
        rows: rows,
        fileName: 'employees',
      );
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      await CustomDialogManager.showSuccess(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
        title: localization.downloadSuccessTitle,
        subtitle: localization.successDownloadFile,
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
        title: localization.downloadFailed,
        subtitle: localization.failedToDownloadFile,
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  /// Method Name: [_handleEmployeeOperation]
  ///
  /// Purpose: Handles typed selections from the employee operations popup.
  ///
  /// Parameters:
  /// - [value]: Selected popup operation identifier.
  ///
  /// Returns: No state change until the employee operation flows are added.
  void _handleEmployeeOperation(String value) {
    final operation = EmployeeOperation.fromValue(value);
    if (operation == null) return;

    switch (operation) {
      case EmployeeOperation.addEmployee:
        Navigator.of(context).pushNamed(HRRoutes.hrModuleAddEmployeePage);
        return;
      case EmployeeOperation.bulkUpload:
        Navigator.of(context)
            .pushNamed(HRRoutes.hrModuleBulkUploadEmployeesPage);
        return;
    }
  }
}
