/// Module: roles / r4_active_directory / presentation / ui / widgets / tabs
///
///*************************** FILE INFO ****************************///
/// File Name: user_data_tab.dart
/// Description: Declares `UserData`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/active_directory_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/user_data_widgets/text_widget.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/table/default_data_table.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Was `extends GetView<ActiveDirectoryController>`, whose inherited
/// `controller` getter is a GetX service-locator lookup. Now a plain
/// StatelessWidget resolving the same instance through the DI seam.
class UserData extends StatelessWidget {
  /// The shared active-directory controller.
  ActiveDirectoryController get controller => AppControllers.activeDirectory;

  final bool isVertical;

  /// Optional filtered/searched subset of [ActiveDirectoryController.usersData].
  /// When null the widget falls back to the full [controller.usersData] list
  /// (original behaviour — no breaking change).
  final List<dynamic>? data;

  const UserData(this.isVertical, {super.key, this.data});

  TextStyle get _headerStyle {
    // Owner 21/10/2026: Attendance table header — Medium 14 white.
    return StyleText.fontSize14Weight500.copyWith(color: AppColors.white);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightMode = Theme.of(context).brightness == Brightness.light;

    return BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
      bloc: AppControllers.activeDirectory,
      builder: (context, state) {
        final controller = AppControllers.activeDirectory;
        // Use the injected filtered list when provided, otherwise use raw data
        final List<dynamic> displayData = data ?? controller.usersData;

        final dataColumnNames = EmployeeDataItems.values
            .take(EmployeeDataItems.values.length - 1)
            .map((e) => e.name)
            .toList();

        final List<DataColumn> columns = [
          if (controller.isEditMode)
            DataColumn(
              // Owner 21/10/2026: no extra padding — the Attendance header band pads.
              label: Text(S.of(context).Edit, style: _headerStyle),
            ),
          ...dataColumnNames.map(
            (name) => DataColumn(
              label: Text(name, style: _headerStyle),
            ),
          ),
        ];

        final List<DataRow> rows = List.generate(
          displayData.length,
          (rowIndex) => _buildRow(
            displayIndex: rowIndex,
            displayData: displayData,
            controller: controller,
            isLightMode: isLightMode,
            context: context,
          ),
        );

        return Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            // Owner 21/10/2026: the Time Tracker Attendance table look, full width.
            child: DefaultDataTable(
                attendanceStyle: true,
                // Owner 21/10/2026: 30 columns scroll anyway; 90 keeps the values and the edit icons readable (titles still never cut).
                minColumnWidth: 90.w,
                columns: columns,
                rows: rows),
          ),
        );
      },
    );
  }

  DataRow _buildRow({
    required int displayIndex,
    required List<dynamic> displayData,
    required ActiveDirectoryController controller,
    required bool isLightMode,
    required BuildContext context,
  }) {
    // Find the real index in the original usersData so edits/deletes
    // still target the correct row in the controller lists.
    final rowData = displayData[displayIndex];
    final int realIndex = controller.usersData.indexOf(rowData);

    return DataRow(
      color: WidgetStatePropertyAll(
        displayIndex % 2 == 0
            ? (isLightMode ? AppColors.evenRowColor : AppColors.oddRowColor)
            : (isLightMode ? AppColors.white : AppColors.black),
      ),
      cells: _buildCells(
        displayIndex: displayIndex,
        realIndex: realIndex,
        displayData: displayData,
        controller: controller,
        context: context,
      ),
    );
  }

  List<DataCell> _buildCells({
    required int displayIndex,
    required int realIndex,
    required List<dynamic> displayData,
    required ActiveDirectoryController controller,
    required BuildContext context,
  }) {
    final cells = <DataCell>[];

    // ── Actions cell ────────────────────────────────────────────────────────
    if (controller.isEditMode) {
      cells.add(
        DataCell(
          BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
            bloc: AppControllers.activeDirectory,
            builder: (context, state) {
              final ctrl = AppControllers.activeDirectory;
              // Guard: real row may have been removed
              if (realIndex < 0 || realIndex >= ctrl.usersData.length) {
                return const SizedBox.shrink();
              }

              final bool rowEditing = realIndex < ctrl.isEditable.length &&
                  ctrl.isEditable[realIndex];

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Pencil (edit / save) ─────────────────────────────────
                  GestureDetector(
                    onTapDown: (_) => HapticController.medium(),
                    onTap: () {
                      if (rowEditing && ctrl.isChanged[realIndex]) {
                        ctrl.saveChanges(rowIndex: realIndex);
                      }
                      ctrl.toggleRowEdit(realIndex);
                    },
                    child: CustomSvgImage.natural(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/ic_action_edit.svg',
                      width: 16.w,
                      height: 16.h,
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // ── Restore (while editing) OR Delete (while not editing) ─
                  GestureDetector(
                    onTapDown: (_) => HapticController.high(),
                    onTap: () {
                      if (rowEditing) {
                        // Restore: discard this row's unsaved changes
                        ctrl.changedFields[realIndex] = List.from(
                          ctrl.usersData[realIndex],
                        );
                        ctrl.isChanged[realIndex] = false;
                        ctrl.isEditable[realIndex] = false;
                        ctrl.refresh();
                      } else {
                        // Delete: shared Are You Sure → Removed flow
                        CustomDialogManager.showDialogFlow(
                          context: context,
                          destructive: true,
                          confirmLottie:
                              'assets/lottie_assets/main_lottie_assets/lot_action_delete.json',
                          confirmTitle: S.of(context).removingEmployee,
                          confirmSubtitle: S
                              .of(context)
                              .areYouSureYouWantToRemoveThisEmployee,
                          confirmYesText: S.of(context).yes,
                          confirmNoText: S.of(context).no,
                          onConfirm: () => ctrl.removeValidEmployee(realIndex),
                          successLottie:
                              'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
                          successTitle: S.of(context).employeeRemoved,
                          successSubtitle:
                              S.of(context).youSuccessfullyRemovedEmployee,
                        );
                      }
                    },
                    child: rowEditing
                        ? Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            padding: EdgeInsets.all(6.w),
                            child: CustomSvgImage.natural(
                              assetPath:
                                  'assets/icons_assets/main_icons_assets/ic_time_clock.svg',
                              width: 10.sp,
                              height: 10.sp,
                              color: AppColors.textButton,
                            ),
                          )
                        : Container(
                            width: 18.w,
                            height: 18.w,
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.remove,
                              color: AppColors.white,
                              size: 12.w,
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    // ── Data cells ──────────────────────────────────────────────────────────
    final dataColumnCount = EmployeeDataItems.values.length - 1;

    for (int column = 0; column < dataColumnCount; column++) {
      final int col = column;

      final bool isProtectedColumn = col == EmployeeDataItems.id.index ||
          col == EmployeeDataItems.email.index;

      cells.add(
        DataCell(
          BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
            bloc: AppControllers.activeDirectory,
            builder: (context, state) {
              final ctrl = AppControllers.activeDirectory;
              // Guard: real row may have been removed
              if (realIndex < 0 || realIndex >= ctrl.usersData.length) {
                return const SizedBox.shrink();
              }

              final String displayText = col != 12 && col != 29
                  ? FormatHelper.capitalize(
                      ctrl.usersData[realIndex][col] ?? '',
                    )
                  : (ctrl.usersData[realIndex][col] ?? '');

              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: UserText(
                  key: ValueKey('cell_${realIndex}_$col'),
                  text: displayText,
                  compact: true,
                  // Owner 21/10/2026: table values 12 regular (Attendance table).
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.text),
                  isEditable:
                      isProtectedColumn ? false : ctrl.isEditable[realIndex],
                  titleValidator: EmployeeDataItems.values[col].validateTitle,
                  onChanged: (value) {
                    ctrl.isChanged[realIndex] = true;
                    ctrl.isSaved[realIndex] = false;
                    ctrl.changedFields[realIndex][col] = value.toLowerCase();
                  },
                  validator: EmployeeDataItems.values[col].validate,
                ),
              );
            },
          ),
        ),
      );
    }

    return cells;
  }
}
