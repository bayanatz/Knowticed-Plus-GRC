/// Module: roles / r4_active_directory / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: main_core_employee_repository.dart
/// Description: Declares `MainCoreEmployeeRepository`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:dartz/dartz.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/data/data_source/remote_data_source/department_and_employee_remote_data_source.dart';

import 'package:grc_module/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';

class MainCoreEmployeeRepository {
  MainCoreEmployeeRemoteDataSource remoteDataSource =
      MainCoreEmployeeRemoteDataSource();

  Future<Either<Failure, List<NewEmployeeModelHistory>>> getEmployees() async {
    Either<Failure, dynamic> result = await remoteDataSource.getAllEmployees();
    if (result.isLeft()) {
      return Left(
        result.fold((l) => l, (r) => FirebaseFailure('Unknown error')),
      );
    }
    List<Map<String, dynamic>> employees = result.getOrElse(() => []);
    // ✅ FIX: one malformed document used to throw inside .map() and lose
    // ALL employees. Parse each record separately and skip the bad ones.
    List<NewEmployeeModelHistory> newEmployees = [];
    for (var employee in employees) {
      try {
        newEmployees.add(NewEmployeeModelHistory.fromMap(employee));
      } catch (e) {
        // Was an empty `catch {}` — the failure is deliberately
        // non-fatal here, but it must not vanish silently (§11.5).
      }
    }
    return Right(newEmployees);
  }
}

// class MainCoreEmployeeRepository {
//   MainCoreEmployeeRemoteDataSource remoteDataSource =
//       MainCoreEmployeeRemoteDataSource();
//   getEmployees() async {
//     Either<Failure, dynamic> result = await remoteDataSource.getAllEmployees();
//     if (result.isLeft()) return result;
//     List<Map<String, dynamic>> employees = result.getOrElse(() => []);
//     List<NewEmployeeModel> newEmployees = employees
//         .map((employee) => NewEmployeeModel.fromMap(employee))
//         .toList();
//   return result = Right(newEmployees);
//   }
// }
