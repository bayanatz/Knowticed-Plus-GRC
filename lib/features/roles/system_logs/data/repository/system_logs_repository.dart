/// *********************** FILE INFO ******************** ///
/// FILE NAME: system_logs_repository.dart
/// PURPOSE: handle all the operations related to the system logs.
/// AUTHOR: Mohamed Elrashidy
/// CREATED AT: 2/2/2025

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:demo_app/features/employee/data/models/emplyees_model/new_employee_model.dart';

import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/core/helper/employees/data/models/new_employee_model/emplyees_model/new_employee_model.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/system_logs/data/data/system_logs_remote_data_source.dart';
import 'package:demo_app/features/roles/system_logs/data/models/system_logs_model.dart';

class SystemLogsRepository {
  SystemLogsRemoteDataSource systemLogsRemoteDataSource =
      SystemLogsRemoteDataSource();

  /// Method Name: [addActivityLog]
  ///
  /// Description: this method will add the activity log to the system logs.
  ///
  /// Parameters:
  ///          [String] activity: the activity that will be added to the system logs.
  ///          [NewEmployeeModelHistory] currentEmployee: the current employee that will be added to the system logs.
  ///          [Position] currentPosition: the current position of the employee.
  ///
  /// Return Value: [Future<Either<Failure,dynamic>>] the result of the operation.
  addActivityLog(
      {required String activity,
      required Modules module,
      required NewEmployeeModelHistory currentEmployee,
      required Position? currentPosition}) async {
    SystemLogsModel systemLogsModel = SystemLogsModel(
      module: module,
      userEmail: currentEmployee.email?.lastOrNull,
      firstName: currentEmployee.firstName?.lastOrNull ?? '',
      lastName: currentEmployee.lastName?.lastOrNull ?? '',
      middleName: currentEmployee.middleName?.lastOrNull ?? '',
      firstNameInArabic:
          currentEmployee.firstNameInArabic?.lastOrNull ??
              '',
      middleNameInArabic:
          currentEmployee.middleNameInArabic?.lastOrNull ??
              '',
      lastNameInArabic:
          currentEmployee.lastNameInArabic?.lastOrNull ?? '',
      role: currentEmployee.role?.lastOrNull ?? "",
      country: currentEmployee.country?.lastOrNull ?? '',
      city: currentEmployee.city?.lastOrNull ?? '',
      // ✅ FIX: currentPosition is null on macOS (location is skipped);
      // the old `currentPosition!` crashed with a null-check error.
      lat: currentPosition?.latitude.toString() ?? '',
      long: currentPosition?.longitude.toString() ?? '',
      action: activity,
      timestamp: Timestamp.now(),
    );
    return await systemLogsRemoteDataSource.addActivityLog(systemLogsModel);
  }

  /// Method Name: [getSystemLogs]
  ///
  /// Description: this method will get the system logs from the remote data source.
  ///
  /// Return Value: [Future<Either<Failure,dynamic>>] the result of the operation.
  getSystemLogs() async {
    Either<Failure, dynamic> result =
        await systemLogsRemoteDataSource.getSystemLogs();
    if (result.isLeft()) return result;
    List<SystemLogsModel> systemLogs = [];
    result.fold((l) => null, (r) {
      r.forEach((element) {
        systemLogs.add(SystemLogsModel.fromMap(element));
      });
    });
    return result = Right(systemLogs);
  }
}
