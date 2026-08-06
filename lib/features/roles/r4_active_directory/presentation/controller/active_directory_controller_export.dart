part of './active_directory_controller.dart';
extension ActiveDirectoryControllerExport on ActiveDirectoryController {
  saveChanges({required int rowIndex}) async {

    try {
      hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact,
      );

      if (isChanged[rowIndex]) {
        await CustomDialogManager.showDialogFlow(
          context: Get.context!,
          confirmLottie:
              "assets/lottie_assets/main_lottie_assets/lottie_confirmation.json",
          confirmTitle: S.current.saveChanges,
          confirmSubtitle:
              S.current.youHaveUnsavedChangesDoYouWantToSaveThem,
          confirmYesText: S.current.yes,
          confirmNoText: S.current.no,
          onNoPressed: () {
            changedFields =
                usersData.map((subList) => List.from(subList)).toList();
            isEditable[rowIndex] = false;
            emitState(ActiveDirectoryUpdated());
          },
          onConfirm: () async {
            await saveEdits(rowIndex: rowIndex, context: Get.context!);
            return true;
          },
          successLottie:
              "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
          successTitle: S.current.Successful,
          successSubtitle: S.current.dataHasBeenSavedSuccessfully,
        );
        isSaved[rowIndex]   = false;
        isChanged[rowIndex] = false;
      } else {
      }
    } catch (e, stackTrace) {
    }
  }

  saveInvalidChanges({required int rowIndex}) async {

    try {
      hapticController.triggerHapticFeedback(
        vibration: VibrateType.mediumImpact,
        hapticFeedback: HapticFeedback.mediumImpact,
      );

      if (isInvalidChanged[rowIndex]) {
        await CustomDialogManager.showDialogFlow(
          context: Get.context!,
          confirmLottie:
              "assets/lottie_assets/main_lottie_assets/lottie_confirmation.json",
          confirmTitle: S.current.saveChanges,
          confirmSubtitle:
              S.current.youHaveUnsavedChangesDoYouWantToSaveThem,
          confirmYesText: S.current.yes,
          confirmNoText: S.current.no,
          onNoPressed: () {
            isInvalidEditable[rowIndex] = false;
            invalidChangedFields =
                rowInvalid.map((subList) => List.from(subList)).toList();
            emitState(ActiveDirectoryUpdated());
          },
          onConfirm: () async {
            await saveEdits(rowIndex: rowIndex, context: Get.context!);
            return true;
          },
          successLottie:
              "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
          successTitle: S.current.Successful,
          successSubtitle: S.current.dataHasBeenSavedSuccessfully,
        );
        isInvalidSaved[rowIndex]   = false;
        isInvalidChanged[rowIndex] = false;
      } else {
      }
    } catch (e, stackTrace) {
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EXPORT
  // ══════════════════════════════════════════════════════════════════════════

  _getRowDataFromModel({
    required List<dynamic> row,
    required NewEmployeeModelHistory employee,
    required bool isWrongEmployee,
  }) {
    try {
      for (EmployeeDataItems item in EmployeeDataItems.values) {
        item.getRowDataFromModelItem(
          departments: departmentCubit,
            row: row, employee: employee, isWrongEmployee: isWrongEmployee);
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  exportToCSV(String fileName) async {
    showLoadingIndicator();
    try {
      List<List> rows = await _getExportData();
      await CSVHelper().exportToCSV(rows, fileName);
      hideLoadingIndicator();
      Navigator.pop(Get.context!);
      await CustomDialogManager.showMessage(
        context: Get.context!,
        title: "SuccessFul",
        subtitle: "Your Data Has Been Saved To Download Folder",
        lottiePath: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
      );
    } catch (e, stackTrace) {
      hideLoadingIndicator();
      await CustomDialogManager.showMessage(
        context: Get.context!,
        title: "Error",
        subtitle: "Error At Saving The File",
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
      );
    }
  }

  _getExportData() async {
    try {
      List<List> rows = [];
      rows.add(EmployeeDataItems.values.map((e) => e.name).toList());
      await getEmployeesTableData();
      for (int i = 0; i < usersData.length; i++) {
        rows.add(usersData[i]);
      }
      return rows;
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}
