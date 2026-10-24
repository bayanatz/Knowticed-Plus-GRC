/// Module: roles / r4_active_directory / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: active_directory_controller_export.dart
/// Description: Declares `ActiveDirectoryControllerExport`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of 'active_directory_controller.dart';

extension ActiveDirectoryControllerExport on ActiveDirectoryController {
  Future<void> saveChanges({required int rowIndex}) async {
    try {
      hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact,
      );

      if (isChanged[rowIndex]) {
        await CustomDialogManager.showDialogFlow(
          context: globalNavigatorKey.currentContext!,
          confirmLottie:
              "assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json",
          confirmTitle: S.current.saveChanges,
          confirmSubtitle: S.current.youHaveUnsavedChangesDoYouWantToSaveThem,
          confirmYesText: S.current.yes,
          confirmNoText: S.current.no,
          onNoPressed: () {
            // Owner 21/10/2026: "No" resets only this row — other rows keep their unsaved edits.
            changedFields[rowIndex] = List.from(usersData[rowIndex]);
            isEditable[rowIndex] = false;
            emitState(ActiveDirectoryUpdated());
          },
          onConfirm: () async {
            await saveEdits(
              rowIndex: rowIndex,
              context: globalNavigatorKey.currentContext!,
            );
            return true;
          },
          successLottie:
              "assets/lottie_assets/main_lottie_assets/lot_status_success.json",
          successTitle: S.current.Successful,
          successSubtitle: S.current.dataHasBeenSavedSuccessfully,
        );
        isSaved[rowIndex] = false;
        isChanged[rowIndex] = false;
      }
    } catch (e) {
      // Was an empty `catch {}` — the failure is deliberately
      // non-fatal here, but it must not vanish silently (§11.5).
    }
  }

  Future<void> saveInvalidChanges({required int rowIndex}) async {
    try {
      hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact,
      );

      if (isInvalidChanged[rowIndex]) {
        await CustomDialogManager.showDialogFlow(
          context: globalNavigatorKey.currentContext!,
          confirmLottie:
              "assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json",
          confirmTitle: S.current.saveChanges,
          confirmSubtitle: S.current.youHaveUnsavedChangesDoYouWantToSaveThem,
          confirmYesText: S.current.yes,
          confirmNoText: S.current.no,
          onNoPressed: () {
            isInvalidEditable[rowIndex] = false;
            // Owner 21/10/2026: "No" resets only this row — other rows keep their unsaved edits.
            invalidChangedFields[rowIndex] = List.from(rowInvalid[rowIndex]);
            emitState(ActiveDirectoryUpdated());
          },
          onConfirm: () async {
            await saveEdits(
              rowIndex: rowIndex,
              context: globalNavigatorKey.currentContext!,
            );
            return true;
          },
          successLottie:
              "assets/lottie_assets/main_lottie_assets/lot_status_success.json",
          successTitle: S.current.Successful,
          successSubtitle: S.current.dataHasBeenSavedSuccessfully,
        );
        isInvalidSaved[rowIndex] = false;
        isInvalidChanged[rowIndex] = false;
      }
    } catch (e) {
      // Was an empty `catch {}` — the failure is deliberately
      // non-fatal here, but it must not vanish silently (§11.5).
    }
  }

  /// Owner 21/10/2026: Invalid Data tab bottom-bar Save — uploads every changed invalid
  /// row through the same path as the per-row save (updateWrongRow), then reloads once.
  /// Returns null when nothing was changed, true when every row saved, false otherwise.
  Future<bool?> saveAllInvalidChanges() async {
    final List<int> changedRows = <int>[
      for (int i = 0; i < isInvalidChanged.length; i++)
        if (isInvalidChanged[i] && i < invalidChangedFields.length) i,
    ];
    if (changedRows.isEmpty) return null;
    bool allSaved = true;
    for (final int i in changedRows) {
      try {
        final List<dynamic> row = invalidChangedFields[i];
        final bool allValid = EmployeesCsvFileUploader().validateRowValues(row);
        final result = await uploadEmployeesData(
          companyId: ApiConstants.baseUri.split("/").last,
          validData: allValid ? [row] : [],
          invalidData: allValid ? [] : [row],
        );
        if (result.isLeft()) allSaved = false;
      } catch (_) {
        allSaved = false;
      }
    }
    await init();
    return allSaved;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EXPORT
  // ══════════════════════════════════════════════════════════════════════════

  void _getRowDataFromModel({
    required List<dynamic> row,
    required NewEmployeeModelHistory employee,
    required bool isWrongEmployee,
  }) {
    try {
      for (EmployeeDataItems item in EmployeeDataItems.values) {
        item.getRowDataFromModelItem(
          row: row,
          employee: employee,
          isWrongEmployee: isWrongEmployee,
          departmentName: (id, {required arabic}) =>
              (arabic
                  ? departmentCubit.getArabicDepartmentNameFromDepartmentId(
                      departmentId: id,
                    )
                  : departmentCubit.getEnglishDepartmentNameFromDepartmentId(
                      departmentId: id,
                    )) ??
              '',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Owner 21/10/2026: saves through CSVHelper.exportRowsForUser (like System Logs) and
  /// no longer pops a route — the File Name dialog has already closed itself.
  Future<void> exportToCSV(String fileName) async {
    showLoadingIndicator();
    try {
      final List<List> rows = _getExportData();
      final saved = await CSVHelper().exportRowsForUser(
        fileName: fileName,
        rows: rows,
      );
      hideLoadingIndicator();
      final String? error = saved.fold((l) => l, (_) => null);
      if (error != null) throw Exception(error);
      final String path = saved.fold((_) => '', (r) => r);
      // The user dismissed the system save sheet — nothing was written.
      if (path == CSVHelper.exportCancelled) return;
      // Owner 21/10/2026: truthful message — the file is where the user/OS put it; desktop shows the path.
      final bool isPhone = Platform.isAndroid || Platform.isIOS;
      await CustomDialogManager.showMessage(
        context: globalNavigatorKey.currentContext!,
        title: S.current.Successful,
        subtitle: isPhone
            ? S.current.fileSavedSuccessfully
            : '${S.current.fileSavedSuccessfully}\n$path',
        lottiePath:
            "assets/lottie_assets/main_lottie_assets/lot_status_success.json",
      );
    } catch (e) {
      hideLoadingIndicator();
      await CustomDialogManager.showMessage(
        context: globalNavigatorKey.currentContext!,
        title: S.current.error,
        subtitle: S.current.downloadFailed,
        lottiePath:
            "assets/lottie_assets/main_lottie_assets/lot_status_error.json",
      );
    }
  }

  // REMOVED 10/9/2026: `exportSelectedRowsToCSV`.
  //
  // Its only caller was the phone preview page, and it was the reason that
  // page's export never reached the user: it wrote through
  // `CSVHelper.exportToCSV`, a folder write that scoped storage refuses on
  // Android and that lands in the app's unreachable private Documents on iOS.
  // It also answered with a bool, so a save sheet the user dismissed and a
  // failed write were the same answer.
  //
  // The page now builds its own header row — the same `EmployeeDataItems` order
  // this file's `_getExportData` uses — and saves through
  // `CSVHelper.exportForUser`, which hands the file to the system save sheet.

  /// Owner 21/10/2026: exports what the table shows now (current filter + search) without
  /// reloading — the old getEmployeesTableData() call wiped in-progress edits.
  List<List> _getExportData() {
    final List<List> rows = [];
    rows.add(EmployeeDataItems.values.map((e) => e.name).toList());
    for (final dynamic row in filteredUsersData) {
      rows.add(List.from(row as List));
    }
    return rows;
  }
}
