import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import '../data_source/main_core_employee_remote_data_source.dart';
import '../models/emplyees_model/new_employee_model.dart';

class MainCoreEmployeeRepository {
  MainCoreEmployeeRemoteDataSource remoteDataSource =
  MainCoreEmployeeRemoteDataSource();

  Future<Either<Failure, List<NewEmployeeModelHistory>>> getEmployees() async {
    Either<Failure, dynamic> result = await remoteDataSource.getAllEmployees();
    if (result.isLeft()) return Left(result.fold((l) => l, (r) => FirebaseFailure('Unknown error')));
    List<Map<String, dynamic>> employees = result.getOrElse(() => []);
    // ✅ FIX: one malformed document used to throw inside .map() and lose
    // ALL employees. Parse each record separately and skip the bad ones.
    List<NewEmployeeModelHistory> newEmployees = [];
    for (var employee in employees) {
      try {
        newEmployees.add(NewEmployeeModelHistory.fromMap(employee));
      } catch (e) {
        print("⚠️ MainCoreRepo: skipped malformed employee doc: $e");
      }
    }
    print("✅ MainCoreRepo: parsed ${newEmployees.length}/${employees.length} employees");
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
