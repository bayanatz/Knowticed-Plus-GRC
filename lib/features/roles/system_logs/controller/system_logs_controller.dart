/// ************************* FILE INFO ******************** ///
/// FILE NAME: system_logs_controller.dart
/// PURPOSE: handle all the operations related to the system logs.
/// AUTHOR: Mohamed Elrashidy
/// REFACTORED AT: 2/2/2025
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/helper/employees/presentation/controller/employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/roles/core_widgets/dialogs/response_dialog.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/controllers/users_access_controller.dart';

import 'package:demo_app/features/settings/presentation/ui/pages/settings_screen.dart';
import 'package:demo_app/features/roles/system_logs/data/models/system_logs_model.dart';

import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/csv_helper.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/core/services/gelocator/gelocator_repository.dart';
import 'package:demo_app/core/custom/loading.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/ui/pages/role_responsive_page.dart';
import 'package:demo_app/features/roles/system_logs/data/repository/system_logs_repository.dart';
import 'package:demo_app/features/roles/system_logs/domain/system_logs_items.dart';

class SystemLogsController extends GetxController {
  SystemLogsRepository systemLogsRepository = SystemLogsRepository();
  List<SystemLogsModel> systemLogsData = [];
  List<SystemLogsModel> finalSystemLogsList = [];
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
    update();
  }

  void updateCityValue(v) {
    cityValue = v;
    update();
  }

  void updateActionValue(v) {
    actionValue = v;
    update();
  }

  void updateRoleValue(v) {
    roleValue = v;
    update();
  }

  Position? currentPosition;

  /// Method Name: [getSystemLogs]
  ///
  /// Description: this method will get the system logs from the repository.
  ///
  Future<void> getSystemLogs() async {
    Either<Failure, dynamic> result =
        await systemLogsRepository.getSystemLogs();
    if (result.isLeft()) return;
    systemLogsData = result.getOrElse(() => []);
    systemLogsData.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    finalSystemLogsList = [];
    for (var element in systemLogsData) {
      finalSystemLogsList.add(element);
    }
    update();
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
    update();
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

    update();
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
      showDialog(
          context: Get.context!,
          builder: (context) {
            return const ResponseDialog(
              title: "Warning",
              subtitle: "please select the filters",
              lottieAsset: "assets/images/error.json",
            );
          });
    } else {
      _applyFilter();
    }
    update();
  }

  /// Method Name: [_applyFilter]
  ///
  /// Description: this method will apply the selected filters on the system logs.
  ///
  /// Return Value: [void]
  void _applyFilter() {
    {
      isFilter = true;
      update();
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
    update();
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
    update();
  }

  // UsersAccessController removed (module not available in demo_app)

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
      if (!actions.contains(capitalize(element.action!))) {
        actions.add(capitalize(element.action!));
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
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return const ResponseDialog(
            title: "SuccessFul",
            subtitle: "Your Data Has Been Saved To Download Folder",
            lottieAsset: "assets/images/correct.json",
          );
        },
      );
    } catch (e) {
      hideLoadingIndicator();
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return const ResponseDialog(
            title: "Error",
            subtitle: "Error At Saving The File",
            lottieAsset: "assets/images/error.json",
          );
        },
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
