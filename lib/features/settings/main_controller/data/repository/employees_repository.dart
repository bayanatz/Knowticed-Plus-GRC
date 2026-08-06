import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:grc_module/core/network/api_constants.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/features/settings/main_controller/data/data_source/employees_remote_data_source.dart';
import 'package:grc_module/features/settings/main_controller/data/models/employee_directory_model.dart';

/// ******************************** FILE INFO *****************************
/// Class Name: EmployeesRepository
/// Purpose: This file contains the class for employees repository
/// Author: Amr Mesbah
/// Created At: 5/11/2024
/// Ported into services_app under features/settings (source: services_app
/// features/employees/data/repository/employees_repository.dart).
class EmployeesRepository {
  final EmployeesRemoteDataSource _remoteDataSource =
      EmployeesRemoteDataSource();

  /// Function Name : getAllEmployees
  /// Purpose: get all employees as NewEmployeeModelHistory and pass to controller
  /// return: Future<Either<Failure, List<NewEmployeeModelHistory>>>
  Future<Either<Failure, List<NewEmployeeModelHistory>>>
      getAllEmployees() async {
    try {
      // Build the correct path using baseUri
      String collectionPath;

      if (ApiConstants.baseUri.isNotEmpty) {
        // Demo path: "Demo/84763782/Employees_Info"
        collectionPath = "${ApiConstants.baseUri}/${ApiConstants.employeeInfo}";
      } else {
        // Fallback to direct path if baseUri is empty
        collectionPath = ApiConstants.employeeInfo;
      }

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      List<NewEmployeeModelHistory> employees = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          NewEmployeeModelHistory employee =
              NewEmployeeModelHistory.fromMap(data);
          employees.add(employee);
        } catch (e) {
          continue;
        }
      }

      return Right(employees);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Function Name : getAllEmployeesDirectory
  /// Purpose: get all employees directory entries and pass to controller
  /// return: Future<Either<Failure, dynamic>>
  Future<Either<Failure, dynamic>> getAllEmployeesDirectory() async {
    Either<Failure, dynamic> result;
    result = await _remoteDataSource.getAllEmployeesDirectory();
    if (result.isLeft()) return result;
    List<EmployeeDirectoryModel> directories = [];
    List<Map<String, dynamic>> data = result.getOrElse(() => []);
    for (var element in data) {
      directories.add(EmployeeDirectoryModel.fromMap(element));
    }
    result = Right(directories);
    return result;
  }

  Future<Either<Failure, dynamic>> isEmployeeExist(
      {required String employeeId}) async {
    Either<Failure, dynamic> result =
        await _remoteDataSource.getEmployee(employeeId: employeeId);
    if (result.isLeft()) return result;
    if (result.getOrElse(() => null) == null) {
      return result = Right(false);
    }
    return result = Right(true);
  }

  Future<void> activateAccountOverview(
      String email, bool isDemoActivation) async {
    return await _remoteDataSource.activateAccountOverview(
        email, isDemoActivation);
  }
}
