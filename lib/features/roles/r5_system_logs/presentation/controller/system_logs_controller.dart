/// ************************* FILE INFO ******************** ///
/// FILE NAME: system_logs_controller.dart
/// PURPOSE: handle all the operations related to the system logs.
/// Author: Amr Mesbah
/// REFACTORED AT: 2/2/2025
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/controllers/users_access_controller.dart';

import 'package:grc_module/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:grc_module/features/roles/r5_system_logs/data/models/system_logs_model.dart';

import 'package:grc_module/core/helper/main_helper/csv_helper.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/core/services/gelocator/gelocator_repository.dart';
import 'package:grc_module/core/custom/loading.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:grc_module/features/roles/r5_system_logs/data/repository/system_logs_repository.dart';
import 'package:grc_module/features/roles/r5_system_logs/domain/system_logs_items.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:grc_module/core/custom/57_custom_dialog_manager.dart';

part './system_logs_state.dart';

/// Converted from GetxController to Cubit. Dependency lookup still goes
/// through GetX (`Get.put` in main.dart / `Get.find` at call sites) — only the
/// state-notification mechanism changed, so the widgets bind with
/// `BlocBuilder(bloc: Get.find<SystemLogsController>())`.
class SystemLogsController extends Cubit<SystemLogsState> {
  SystemLogsController() : super(SystemLogsInitial());

  SystemLogsRepository systemLogsRepository = SystemLogsRepository();
  List<SystemLogsModel> systemLogsData = [];
  List<SystemLogsModel> finalSystemLogsList = [];
  // Tracks whether the initial fetch has completed (success, failure, or empty)
  // so the UI can stop showing the loading spinner and render an empty state.
  bool logsLoaded = false;
  List<String> systemLogsUserNamesFilter = [];
  List<String> cities = [];
  List<String> countries = [];
  List<String> actions = [];
  List<String> actionsEnglish = [];
  List<String> accessNames = [];
  String? status;
  String? actionValue;
  String? countryValue;
  String? cityValue;
  String? roleValue;
  List<DateTime?> rangeDatePickerValueWithDefaultValue = [];
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  TextEditingController searchController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? endTime;
  TimeOfDay? startTime;
  bool isFilter = false;
  String sortValue = "Date";

  void updateCountryValue(v) {
    countryValue = v;
    emit(SystemLogsUpdated());
  }

  void updateCityValue(v) {
    cityValue = v;
    emit(SystemLogsUpdated());
  }

  void updateActionValue(v) {
    actionValue = v;
    emit(SystemLogsUpdated());
  }

  void updateRoleValue(v) {
    roleValue = v;
    emit(SystemLogsUpdated());
  }

  Position? currentPosition;

  /// Method Name: [getSystemLogs]
  ///
  /// Description: this method will get the system logs from the repository.
  ///
  Future<void> getSystemLogs() async {
    Either<Failure, dynamic> result =
        await systemLogsRepository.getSystemLogs();
    if (result.isLeft()) {
      // Fetch failed: stop the spinner and let the UI show an empty state
      // instead of hanging on the loading indicator forever.
      logsLoaded = true;
      emit(SystemLogsUpdated());
      return;
    }
    systemLogsData = result.getOrElse(() => []);
    systemLogsData.sort((a, b) {
      final aTime = a.timestamp;
      final bTime = b.timestamp;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });
    finalSystemLogsList = [];
    for (var element in systemLogsData) {
      finalSystemLogsList.add(element);
    }
    logsLoaded = true;
    emit(SystemLogsUpdated());
  }

  initFiltersLists() {
    _getLocationList();
    _getRolesList();
    _getActionsList();
  }

  void _getLocationList() {
    for (var element in Get.find<EmployeeController>().allEmployees!) {
      if (element.city?.lastOrNull != null) {
        if (!cities.contains(element.city!.last!.capitalize!)) {
          cities.add(element.city!.last!.capitalize!);
        }
      }
      if (element.country?.lastOrNull != null) {
        if (!countries.contains(element.country!.last!.capitalize!)) {
          countries.add(element.country!.last!.capitalize!);
        }
      }
    }
  }

  /// Method Name: [sortLogs]
  ///
  /// Description: this method will sort the system logs based on the selected criteria.
  ///
  /// Parameters:
  ///         [String] criteria: the criteria that the system logs will be sorted based on.
  void sortLogs(String criteria) {
    emit(SystemLogsUpdated());
    switch (criteria) {
      case 'First Name':
        finalSystemLogsList
            .sort((a, b) => a.firstName?.compareTo(b.firstName ?? '') ?? 0);
        break;
      case 'Last Name':
        finalSystemLogsList
            .sort((a, b) => a.lastName?.compareTo(b.lastName ?? '') ?? 0);
        break;
      case 'Date':
        finalSystemLogsList.sort((a, b) =>
            b.timestamp?.compareTo(a.timestamp ?? Timestamp.now()) ?? 0);

        break;
      case 'Country':
        finalSystemLogsList
            .sort((a, b) => a.country?.compareTo(b.country ?? '') ?? 0);
        break;
      case 'City':
        finalSystemLogsList
            .sort((a, b) => a.city?.compareTo(b.city ?? '') ?? 0);
        break;
      default:
        finalSystemLogsList.sort((a, b) =>
            b.timestamp?.compareTo(a.timestamp ?? Timestamp.now()) ?? 0);
        break;
    }

    emit(SystemLogsUpdated());
  }

  /// Method Name: [filterLogs]
  ///
  /// Description: this method will filter the system logs based on the selected filters.
  void filterLogs() {
    if (fromDate == null &&
        toDate == null &&
        startTime == null &&
        endTime == null &&
        roleValue == null &&
        countryValue == null &&
        cityValue == null &&
        actionValue == null) {
      isFilter = false;
      CustomDialogManager.showMessage(
        context: Get.context!,
        title: "Warning",
        subtitle: "please select the filters",
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
      );
    } else {
      _applyFilter();
    }
    emit(SystemLogsUpdated());
  }

  /// Method Name: [_applyFilter]
  ///
  /// Description: this method will apply the selected filters on the system logs.
  ///
  /// Return Value: [void]
  void _applyFilter() {
    {
      isFilter = true;
      emit(SystemLogsUpdated());
      finalSystemLogsList = finalSystemLogsList.where((log) {
        bool isValid = true;

        isValid &= _isValidSingleFilter(roleValue, log.role);
        isValid &= _isValidSingleFilter(countryValue, log.country);
        isValid &= _isValidSingleFilter(cityValue, log.city);
        isValid &= _isValidSingleFilter(actionValue, log.action);
        isValid &= isValidDateRange(log);
        isValid &= _isValidStartTimeFilter(log);
        isValid &= _isValidEndTimeFilter(log);

        return isValid;
      }).toList();
    }
  }

  /// Method Name: [isValidDateRange]
  ///
  /// Description: this method will check if the log date is in the selected date range or not.
  ///
  /// Parameters:
  ///       [SystemLogsModel] log: the log that will be checked.
  ///
  /// Return Value: [bool] true if the log date is in the selected date range, false otherwise.
  bool isValidDateRange(SystemLogsModel log) {
    bool isValid = true;
    if (fromDate != null) {
      DateTime logDate = DateTime(log.timestamp!.toDate().year,
          log.timestamp!.toDate().month, log.timestamp!.toDate().day);
      isValid &=
          logDate.isAtSameMomentAs(fromDate!) || logDate.isAfter(fromDate!);
    }
    if (toDate != null) {
      DateTime logDate = DateTime(log.timestamp!.toDate().year,
          log.timestamp!.toDate().month, log.timestamp!.toDate().day);
      isValid &=
          (logDate.isAtSameMomentAs(toDate!) || logDate.isBefore(toDate!));
    }

    return isValid;
  }

  /// Method Name: [_isValidEndTimeFilter]
  ///
  /// Description: this method will check if the log time is before the end time or not.
  ///
  /// Parameters:
  ///       [SystemLogsModel] log: the log that will be checked.
  ///
  /// Return Value: [bool] true if the log time is before the end time, false otherwise.
  bool _isValidEndTimeFilter(SystemLogsModel log) {
    bool isValid = true;
    DateTime? timeToDateTime = endTime == null
        ? null
        : DateTime(0, 1, 1, endTime!.hour, endTime!.minute);

    if (timeToDateTime != null) {
      DateTime logTime = DateTime(0, 1, 1, log.timestamp!.toDate().hour,
          log.timestamp!.toDate().minute);
      isValid &= (logTime.isBefore(timeToDateTime) ||
          logTime.isAtSameMomentAs(timeToDateTime));
    }
    return isValid;
  }

  /// Method Name: [_isValidStartTimeFilter]
  ///
  /// Description: this method will check if the log time is after the start time or not.
  ///
  /// Parameters:
  ///        [SystemLogsModel] log: the log that will be checked.
  ///
  /// Return Value: [bool] true if the log time is after the start time, false otherwise.
  bool _isValidStartTimeFilter(SystemLogsModel log) {
    bool isValid = true;
    DateTime? timeFromDateTime = startTime == null
        ? null
        : DateTime(0, 1, 1, startTime!.hour, startTime!.minute);
    if (timeFromDateTime != null) {
      DateTime logTime = DateTime(0, 1, 1, log.timestamp!.toDate().hour,
          log.timestamp!.toDate().minute);
      isValid &= logTime.isAfter(timeFromDateTime) ||
          logTime.isAtSameMomentAs(timeFromDateTime);
    }
    return isValid;
  }

  bool _isValidSingleFilter(String? filter, String? value) {
    return filter == null || value!.toLowerCase() == filter.toLowerCase();
  }

  /// Method Name: [resetFilter]
  ///
  /// Description: this method will reset the filters.
  resetFilter() {
    isFilter = false;
    status = null;
    countryValue = null;
    cityValue = null;
    actionValue = null;
    roleValue = null;
    startTime = null;
    endTime = null;
    selectedDate = null;
    fromDate = null;
    toDate = null;
    rangeDatePickerValueWithDefaultValue = [];
    startDate = TextEditingController();
    endDate = TextEditingController();

    finalSystemLogsList = [];
    systemLogsData.forEach((element) {
      finalSystemLogsList.add(element);
    });
    searchAndFilterLogs();
    emit(SystemLogsUpdated());
  }

  /// Method Name: [searchLogs]
  ///
  /// Description: this method will search the system logs.
  void searchLogs() {
    String query = searchController.text;
    finalSystemLogsList = [];
    final lowerCaseQuery = query.toLowerCase();
    finalSystemLogsList = systemLogsData.where((log) {
      return Get.locale.toString().contains('en')
          ? "${log.firstName} ${log.middleName} ${log.lastName}"
              .toLowerCase()
              .contains(lowerCaseQuery)
          : "${log.firstNameInArabic} ${log.middleNameInArabic} ${log.lastNameInArabic}"
              .contains(lowerCaseQuery);
    }).toList();
    emit(SystemLogsUpdated());
  }

  // UsersAccessController removed (module not available in knowticed)

  /// Method Name: [systemLogsAction]
  ///
  /// Description: this method will add the activity log to the system logs.
  ///
  /// Parameters:
  ///        [String] action: the activity that will be added to the system logs.
  void systemLogsAction(String action, {Modules module = Modules.more}) async {
    currentPosition = await GelocatorRepository.getCurrentLocation();
    systemLogsRepository.addActivityLog(
        module: module,
        activity: action,
        currentEmployee: employee!,
        currentPosition: currentPosition);
  }

  /// Method Name: [searchAndFilterLogs]
  ///
  /// Description: this method will search and then filter the system logs.
  ///
  /// Return Value: [void]
  searchAndFilterLogs() {
    searchLogs();
    if (isFilter) filterLogs();
  }

  /// Method Name: [_getRolesList]
  ///
  /// Description: this method will get all the roles_module from the system logs.
  void _getRolesList() {
    accessNames = roleCubit.roles.map((e) => e.currentRoleName).toList();
  }

  /// Method Name: [_getActionsList]
  ///
  /// Description: this method will get all the actions from the system logs.
  void _getActionsList() {
    for (var element in systemLogsData) {
      if (!actions.contains(FormatHelper.capitalize(element.action!))) {
        actions.add(FormatHelper.capitalize(element.action!));
      }
    }
  }

  /// Method Name: [exportSystemLogs]
  ///
  /// Description: this method will export the system logs to a CSV file.
  ///
  /// Parameters:
  ///        [String] fileName: the name of the file that the system logs will be saved to.
  exportSystemLogs(String fileName) async {
    showLoadingIndicator();
    List<List<dynamic>> rows = [];
    _fillHeaders(rows);
    _fillData(rows);
    try {
      await CSVHelper().exportToCSV(rows, fileName);
      hideLoadingIndicator();
      Navigator.pop(Get.context!);
      await CustomDialogManager.showMessage(
        context: Get.context!,
        title: "SuccessFul",
        subtitle: "Your Data Has Been Saved To Download Folder",
        lottiePath: "assets/lottie_assets/main_lottie_assets/correct.json",
      );
    } catch (e) {
      hideLoadingIndicator();
      await CustomDialogManager.showMessage(
        context: Get.context!,
        title: "Error",
        subtitle: "Error At Saving The File",
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
      );
    }
  }

  /// Method Name: [_fillHeaders]
  ///
  /// Description: this method will fill the headers of the CSV file.
  ///
  /// Parameters:
  ///       [List<List>] rows: the rows of the CSV file.
  void _fillHeaders(List<List> rows) {
    rows.add([]);
    for (SystemLogsItems item in SystemLogsItems.values) {
      rows[0].add(item.name);
    }
  }

  /// Method Name: [_fillData]
  ///
  /// Description: this method will fill the data of the CSV file.
  ///
  /// Parameters:
  ///      [List<List>] rows: the rows of the CSV file.
  _fillData(List<List> rows) {
    for (var log in finalSystemLogsList) {
      List<dynamic> row = [];
      for (SystemLogsItems item in SystemLogsItems.values) {
        row.add(item.itemValue(log));
      }
      rows.add(row);
    }
  }

  bool isThereFilter() {
    bool isThereFilter = false;
    if (fromDate != null ||
        toDate != null ||
        startTime != null ||
        endTime != null ||
        roleValue != null ||
        countryValue != null ||
        cityValue != null ||
        actionValue != null) {
      isThereFilter = true;
    }
    return isThereFilter;
  }
}
