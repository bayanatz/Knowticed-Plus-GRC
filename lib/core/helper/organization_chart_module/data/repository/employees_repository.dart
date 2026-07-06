
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/api_constants.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/employee/data/models/emplyees_model/new_employee_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/data_source/remote_data_source/employees_remote_data_source.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/employee_model/employee_directory_model.dart';
import 'package:demo_app/core/helper/organization_chart_module/data/models/new_employee_model/emplyees_model/new_employee_model.dart';

/// ******************************** FILE INFO *****************************
/// Class Name: EmployeesRepository
/// Purpose: This file contains the class for employees repository
/// Author: Mohamed Elrashidy
/// Created At: 5/11/2024
class EmployeesRepository {
  final EmployeesRemoteDataSource _remoteDataSource =
      EmployeesRemoteDataSource();

  /// Function Name : getAllEmployees
  /// Purpose: function to get all employees in form of employee model and path to controller
  /// return: Future<Either<Failure, dynamic> - list of employee model or list of empty of map or failure
  Future<Either<Failure, List<NewEmployeeModelHistory>>> getAllEmployees() async {
    try {
      // ✅ Build the correct path using baseUri
      String collectionPath;

      if (ApiConstants.baseUri.isNotEmpty) {
        // Demo path: "Demo/84763782/Employees_Info"
        collectionPath = "${ApiConstants.baseUri}/${ApiConstants.employeeInfo}";
        // print("📍 Fetching employees from DEMO path: $collectionPath");
      } else {
        // Fallback to direct path if baseUri is empty
        collectionPath = ApiConstants.employeeInfo;
        // print("📍 Fetching employees from direct path: $collectionPath");
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .get();

      // print("📊 Found ${querySnapshot.docs.length} employee documents");

      List<NewEmployeeModelHistory> employees = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          NewEmployeeModelHistory employee = NewEmployeeModelHistory.fromMap(data);
          employees.add(employee);
        } catch (e) {
          // print("⚠️ Error parsing employee ${doc.id}: $e");
          continue;
        }
      }

      // print("✅ Successfully loaded ${employees.length} employees");
      return Right(employees);
    } catch (e) {
      // print("❌ Error in getAllEmployees: $e");
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Function Name : getAllEmployeesDirectory
  /// Purpose: function to get all employees directory in form of employee directory model and path to controller
  /// return: Future<Either<Failure, dynamic> - list of employee directory model or list of empty of map or failure
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
      return result= Right(false);
    }
    return result = Right(true);
  }

  Future<void> activateAccountOverview(String email, bool isDemoActivation) async {
    return await _remoteDataSource.activateAccountOverview(email, isDemoActivation);
  }
}


class EmployeesRepositoryPro {
  final EmployeesRemoteDataSource _remoteDataSource =
  EmployeesRemoteDataSource();

  /// Function Name : getAllEmployees
  /// Purpose: function to get all employees in form of employee model and path to controller
  /// return: Future<Either<Failure, dynamic> - list of employee model or list of empty of map or failure
  Future<Either<Failure, List<NewEmployeeModelHistory>>> getAllEmployees() async {
    try {
      // ✅ Build the correct path using baseUri
      String collectionPath;

      if (ApiConstants.baseUri.isNotEmpty) {
        // Demo path: "Demo/84763782/Employees_Info"
        collectionPath = "${ApiConstants.baseUri}/${ApiConstants.employeeInfo}";
        // print("📍 Fetching employees from DEMO path: $collectionPath");
      } else {
        // Fallback to direct path if baseUri is empty
        collectionPath = ApiConstants.employeeInfo;
        // print("📍 Fetching employees from direct path: $collectionPath");
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .get();

      // print("📊 Found ${querySnapshot.docs.length} employee documents");

      List<NewEmployeeModelHistory> employees = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          NewEmployeeModelHistory employee = NewEmployeeModelHistory.fromMap(data);
          employees.add(employee);
        } catch (e) {
          // print("⚠️ Error parsing employee ${doc.id}: $e");
          continue;
        }
      }

      // print("✅ Successfully loaded ${employees.length} employees");
      return Right(employees);
    } catch (e) {
      // print("❌ Error in getAllEmployees: $e");
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Function Name : getAllEmployeesDirectory
  /// Purpose: function to get all employees directory in form of employee directory model and path to controller
  /// return: Future<Either<Failure, dynamic> - list of employee directory model or list of empty of map or failure
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
      return result= Right(false);
    }
    return result = Right(true);
  }

  Future<void> activateAccountOverview(String email, bool isDemoActivation) async {
    return await _remoteDataSource.activateAccountOverview(email, isDemoActivation);
  }
}
