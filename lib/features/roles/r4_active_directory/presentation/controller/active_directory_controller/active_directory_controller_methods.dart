/// Module: roles/r4_active_directory
///
///*************************** FILE INFO ****************************///
/// File Name: active_directory_controller_methods.dart
/// Description: Methods of `ActiveDirectoryController` — split out of `active_directory_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../active_directory_controller.dart';

// Split from active_directory_controller.dart to keep every file under 700 lines.

extension ActiveDirectoryControllerMethods on ActiveDirectoryController {
  /// Remove a valid employee from Firebase and update local lists.
  Future<bool> removeValidEmployee(int rowIndex) async {
    try {
      if (rowIndex >= usersData.length) {
        return false;
      }

      final String employeeId =
          usersData[rowIndex][EmployeeDataItems.id.index]?.toString() ?? '';

      if (employeeId.isEmpty) {
        return false;
      }

      showLoadingIndicator();

      final result = await activeDirectoryRepository.removeValidEmployee(
        employeeId: employeeId,
      );

      hideLoadingIndicator();

      return await result.fold(
        (failure) {
          CustomDialogManager.showMessage(
            context: globalNavigatorKey.currentContext!,
            // Owner 21/10/2026: localised title.
            title: S.current.error,
            subtitle: failure.message,
            lottiePath:
                "assets/lottie_assets/main_lottie_assets/lot_status_error.json",
          );
          return false;
        },
        (_) {
          usersData.removeAt(rowIndex);
          changedFields.removeAt(rowIndex);
          isEditable = List.generate(usersData.length, (_) => false);
          isChanged = List.generate(usersData.length, (_) => false);
          isSaved = List.generate(usersData.length, (_) => false);
          emitSafely(ActiveDirectoryUpdated());
          return true;
        },
      );
    } catch (e) {
      hideLoadingIndicator();
      return false;
    }
  }

  Future<void> getEmployeesTableData() async {
    try {
      usersData = [];

      if (employeeController.employeesWithoutFilter == null) {
        changedFields = [];
        resetVariables(0, rowInvalid.length);
        return;
      }

      // Load departments
      try {
        final departmentController = departmentCubit;
        await departmentController.getAllDepartments();
      } catch (e) {
        // Was an empty `catch {}` — the failure is deliberately
        // non-fatal here, but it must not vanish silently (§11.5).
      }

      for (int i = 0;
          i < employeeController.employeesWithoutFilter!.length;
          i++) {
        try {
          NewEmployeeModelHistory employee =
              employeeController.employeesWithoutFilter![i];
          List<String> row = List.filled(EmployeeDataItems.values.length, '');
          _getRowDataFromModel(
              row: row, employee: employee, isWrongEmployee: false);
          usersData.add(row);
        } catch (e) {
          // Was an empty `catch {}` — the failure is deliberately
          // non-fatal here, but it must not vanish silently (§11.5).
        }
      }

      changedFields = usersData.map((subList) => List.from(subList)).toList();
      resetVariables(usersData.length, rowInvalid.length);
    } catch (e) {
      rethrow;
    }
  }

  void getEmployeesTableWrongData() {
    try {
      rowInvalid = [];

      if (addWrongEmployeeController.allWrongEmployees == null) {
        invalidChangedFields = [];
        invalidFieldsCount = 0;
        resetVariables(usersData.length, 0);
        return;
      }

      for (int i = 0;
          i < addWrongEmployeeController.allWrongEmployees!.length;
          i++) {
        try {
          WrongEmployeeModel employee =
              addWrongEmployeeController.allWrongEmployees![i];
          List<String?> row = List.filled(EmployeeDataItems.values.length, '');
          _getRowDataFromModel(
              row: row, employee: employee, isWrongEmployee: true);
          rowInvalid.add(row);
        } catch (e) {
          // Was an empty `catch {}` — the failure is deliberately
          // non-fatal here, but it must not vanish silently (§11.5).
        }
      }

      invalidChangedFields =
          rowInvalid.map((subList) => List.from(subList)).toList();

      invalidFieldsCount = 0;
      for (int i = 0; i < rowInvalid.length; i++) {
        validateWrongRowFields(rowInvalid[i]);
      }

      emitSafely(ActiveDirectoryUpdated());
      resetVariables(usersData.length, rowInvalid.length);
    } catch (e) {
      rethrow;
    }
  }

  /// Function Name: [getBackupTableData]
  ///
  /// Purpose: Read one backup collection and shape it exactly like
  ///          [usersData], so the restore dialog can render it with the same
  ///          columns as the Users Data table.
  ///
  /// Parameters:
  /// - [backupVersion]: [backupVersionOne] or [backupVersionSecond].
  ///
  /// Returns: [Future<List<List<dynamic>>>] one row per employee, each row
  ///          `EmployeeDataItems.values.length` cells wide. Empty when the
  ///          backup has never been written.
  Future<List<List<dynamic>>> getBackupTableData(String backupVersion) async {
    try {
      // Department ids are resolved to names while building each row; on a
      // cold open of the dialog the lookup table may not be loaded yet.
      try {
        await departmentCubit.getAllDepartments();
      } catch (_) {
        // Best effort: this failure must not stop the action.
      }

      final List<NewEmployeeModelHistory> employees =
          await employeeController.getBackupEmployees(backupVersion);

      final List<List<dynamic>> rows = <List<dynamic>>[];
      for (final NewEmployeeModelHistory employee in employees) {
        try {
          final List<String> row =
              List<String>.filled(EmployeeDataItems.values.length, '');
          _getRowDataFromModel(
              row: row, employee: employee, isWrongEmployee: false);
          rows.add(row);
        } catch (e) {
          // One unreadable backup document must not empty the preview.
        }
      }
      return rows;
    } catch (e) {
      return <List<dynamic>>[];
    }
  }

  /// Function Name: [restoreBackup]
  ///
  /// Purpose: Replace `Employees_Info` with the chosen backup, then reload the
  ///          page from the restored collection.
  ///
  /// **Destructive.** Every current employee document is deleted first — call
  /// this only behind an explicit confirmation. The data source refuses to
  /// restore an empty backup, which is why the dialog also hides the action
  /// for a backup with no rows.
  ///
  /// Parameters:
  /// - [backupVersion]: [backupVersionOne] or [backupVersionSecond].
  ///
  /// Returns: [Future<bool>] `true` when the collection was replaced.
  Future<bool> restoreBackup(String backupVersion) async {
    showLoadingIndicator();
    try {
      await employeeController.restoreFromBackup(
        backupVersion,
        confirmDestructiveRestore: true,
      );
      // Re-read Employees_Info so the table behind the dialog shows the
      // restored rows rather than the ones that were just deleted.
      await init();
      hideLoadingIndicator();
      emitSafely(ActiveDirectoryUpdated());
      return true;
    } catch (e) {
      hideLoadingIndicator();
      await CustomDialogManager.showMessage(
        context: globalNavigatorKey.currentContext!,
        title: S.current.error,
        subtitle: '$e',
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      );
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UPLOAD
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> uploadExcelFile({required int length}) async {
    try {
      showLoadingIndicator();

      Either<Failure, dynamic> result =
          await activeDirectoryRepository.getDemoNumberOfUsers(
              currentUserEmail: AppControllers.settings.employee!.email.last);

      if (result.isLeft()) {
        hideLoadingIndicator();
        return;
      }

      int demoUsers = result.getOrElse(() => 0);

      Map<String, List<dynamic>> data = await EmployeesCsvFileUploader()
          .extractExcelFileData(length: demoUsers);

      if (data[ActiveDirectoryConstants.validEmployeesData]!.isEmpty &&
          data[ActiveDirectoryConstants.invalidEmployeesData]!.isEmpty) {
        emitSafely(ActiveDirectoryUpdated());
        hideLoadingIndicator();
        return;
      }

      bool isDataConsistent = await EmployeesCsvFileDataConsistency(
              departmentCubit: departmentCubit)
          .validateDepartmentsConsistency(
              data[ActiveDirectoryConstants.validEmployeesData]!
                  as List<List<dynamic>>);

      if (!isDataConsistent) {
        hideLoadingIndicator();
        return;
      }

      await uploadEmployeesData(
          companyId: ApiConstants.baseUri.split("/").last,
          validData: data[ActiveDirectoryConstants.validEmployeesData]!,
          invalidData: data[ActiveDirectoryConstants.invalidEmployeesData]!);

      if (data[ActiveDirectoryConstants.validEmployeesData]!.isNotEmpty) {
        await employeeController.getAllEmployees();
        int employeeCount = employeeController.allEmployees?.length ?? 0;
        if (employeeCount > 0) {
          await employeeController.backupCollections();
        }
      }

      hideLoadingIndicator();
      emitSafely(ActiveDirectoryUpdated());
      init();
    } catch (e) {
      hideLoadingIndicator();
    }
  }
}
