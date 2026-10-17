/// Module: roles / r4_active_directory / presentation / ui / widgets / tabs
///
///*************************** FILE INFO ****************************///
/// File Name: wrong_data_tab.dart
/// Description: Declares `WrongData`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

//Youssef Ashraf — refactored by Amr Mesbah
/// WrongData tab — renders invalid employees table.
/// When [controller.isEditMode] is true, a dedicated actions column appears
/// as the FIRST column (before all data), showing per-row:
///   • pencil icon  → toggles that row into edit mode
///   • red-circle minus → (while NOT editing) delete/remove row
///   • restore/undo icon → (while editing) replaces minus, discards row edits
import 'package:grc_module/core/custom/dialogs/custom_dialog_manager.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_colors.dart';

import 'package:grc_module/core/helper/format_title.dart';
import 'package:grc_module/features/roles/helpers/constants/active_directory_constants.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/enums/employee_data.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/controller/active_directory_controller.dart';
import 'package:grc_module/features/roles/r4_active_directory/presentation/ui/widgets/wrong_data_widgets/editable_text_widget.dart';

import 'package:grc_module/features/roles/r4_active_directory/presentation/ui/widgets/table/default_data_table.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/di/app_controllers.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

/// Was `extends GetView<ActiveDirectoryController>`, whose inherited
/// `controller` getter is a GetX service-locator lookup. Now a plain
/// StatelessWidget resolving the same instance through the DI seam.
class WrongData extends StatelessWidget {
  /// The shared active-directory controller.
  ActiveDirectoryController get controller => AppControllers.activeDirectory;

  final bool isVertical;

  const WrongData(this.isVertical, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
      bloc: AppControllers.activeDirectory,
      builder: (context, state) {
        final controller = AppControllers.activeDirectory;
        // ── Build columns ────────────────────────────────────────────────
        // Skip the last enum value (was previously the actions slot)
        final dataColumnNames = EmployeeDataItems.values
            .take(EmployeeDataItems.values.length - 1)
            .map((e) => e.name)
            .toList();

        final List<DataColumn> columns = [
          // Actions column — first, only when edit mode is active
          if (controller.isEditMode)
            DataColumn(
              label: SizedBox(width: 56.w), // blank header
            ),
          ...dataColumnNames.map(
            (name) => DataColumn(
              label: Text(
                name,
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: isVertical ? 10.sp : 10.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.colorWhite,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ];

        // ── Build rows ───────────────────────────────────────────────────
        final List<DataRow> rows = List.generate(controller.rowInvalid.length, (
          row,
        ) {
          final List<DataCell> cells = [];

          // ── Actions cell — first cell, only in edit mode ─────────────
          if (controller.isEditMode) {
            cells.add(
              DataCell(
                BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
                  bloc: AppControllers.activeDirectory,
                  builder: (context, state) {
                    final controller = AppControllers.activeDirectory;
                    final bool isRowEditing = controller.isInvalidEditable[row];

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // ── Pencil / X icon ──────────────────────────
                        GestureDetector(
                          onTapDown: (_) => HapticController.medium(),
                          onTap: () {
                            if (isRowEditing &&
                                controller.isInvalidChanged[row]) {
                              controller.saveInvalidChanges(rowIndex: row);
                            }
                            controller.toggleRowEditInvalid(row);
                          },
                          child: CustomSvgImage.natural(
                            assetPath: isRowEditing
                                ? 'assets/icons_assets/main_icons_assets/ic_action_cancel.svg'
                                : 'assets/icons_assets/main_icons_assets/ic_action_edit.svg',
                            width: 16.w,
                            height: 16.h,
                            colorFilter: ColorFilter.mode(
                              AppColors.text,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // ── Minus (delete) OR Restore icon ───────────
                        // Not editing → red minus circle → remove row
                        // Editing     → restore/undo → discard row edits
                        GestureDetector(
                          onTapDown: (_) => HapticController.high(),
                          onTap: () {
                            if (isRowEditing) {
                              // Restore: discard this single row's changes
                              controller.invalidChangedFields[row] = List.from(
                                controller.rowInvalid[row],
                              );
                              controller.isInvalidChanged[row] = false;
                              controller.isInvalidEditable[row] = false;
                              controller.refresh();
                            } else {
                              // Remove row: shared Are You Sure → Removed
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
                                onConfirm: () async {
                                  await controller.removeInvalidEmployee(row);
                                  return true;
                                },
                                successLottie:
                                    'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
                                successTitle: S.of(context).employeeRemoved,
                                successSubtitle: S
                                    .of(context)
                                    .youSuccessfullyRemovedEmployee,
                              );
                            }
                          },
                          child: isRowEditing
                              // ── Restore icon (orange) ──────────────
                              ? SizedBox(width: 16.w, height: 16.h)
                              // ── Red minus circle ───────────────────
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

          // ── Data cells ───────────────────────────────────────────────
          final dataColumnCount = EmployeeDataItems.values.length - 1;
          for (int column = 0; column < dataColumnCount; column++) {
            cells.add(
              DataCell(
                BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
                  bloc: AppControllers.activeDirectory,
                  builder: (context, state) {
                    final controller = AppControllers.activeDirectory;
                    return EditableTextWidget(
                      text: FormatHelper.capitalize(
                        controller.invalidChangedFields[row][column] ?? '',
                      ),
                      isEditable: controller.isInvalidEditable[row],
                      isOptional: ActiveDirectoryConstants.optionalItems
                          .contains(EmployeeDataItems.values[column]),
                      onChanged: (value) {
                        controller.isInvalidChanged[row] = true;
                        controller.isInvalidSaved[row] = false;
                        controller.invalidChangedFields[row][column] =
                            value.toLowerCase();

                        if (column == 13 || column == 15 || column == 17) {
                          controller.refresh();
                        }
                      },
                      titleValidator: (v) {
                        return column == 14 || column == 16 || column == 18
                            ? EmployeeDataItems.values[column].validateTitle
                                ?.call(
                                '${controller.invalidChangedFields[row][column - 1].toString()}-$v',
                              )
                            : EmployeeDataItems.values[column].validateTitle
                                ?.call(v);
                      },
                      validator: (v) {
                        return column == 14 || column == 16 || column == 18
                            ? EmployeeDataItems.values[column].validate.call(
                                '${controller.invalidChangedFields[row][column - 1].toString()}-$v',
                              )
                            : EmployeeDataItems.values[column].validate.call(v);
                      },
                    );
                  },
                ),
              ),
            );
          }

          return DataRow(
            color: WidgetStatePropertyAll(
              row % 2 == 0
                  ? !AppTheme.isDark
                      ? AppColors.evenRowColor
                      : AppColors.darkBackGround
                  : !AppTheme.isDark
                      ? AppColors.colorWhite
                      : AppColors.oddRowColor,
            ),
            cells: cells,
          );
        });

        return Expanded(
          child: DefaultDataTable(columns: columns, rows: rows),
        );
      },
    );
  }
}
