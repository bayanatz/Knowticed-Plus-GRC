import 'package:dartz/dartz.dart';
import 'package:grc_module/features/roles/r3_user_access/data/repository/user_access_repository.dart';
import 'package:grc_module/features/roles/r3_user_access/domain/entity/user_access_entity.dart';
import 'package:grc_module/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';

import 'package:grc_module/core/network/failure_model.dart';

class GetUserAccessEntitiesUseCase {
  UserAccessRepository repository;

  GetUserAccessEntitiesUseCase(this.repository);

  /// Method Name: [execute]
  ///
  /// Purpose: get all employees account status categorized according to status.
  /// ✅ FIXED: Prevent double-counting users with scheduled dates
  ///
  /// return: [Either<Failure, dynamic>]
  ///                                - Failure: if there is an error in the process or  [Map< EmployeeStatusEnum,UserAccessEntity>] data.
  Future<Either<Failure, dynamic>> execute() async {
    Either<Failure, dynamic> result =
    await repository.getAccountsStatusEntities();
    if (result.isLeft()) result;
    List<UserAccessEntity> entities = result.getOrElse(() => []);
    Map<EmployeeStatusEnum, List<UserAccessEntity>> map = {};

    for (EmployeeStatusEnum status in EmployeeStatusEnum.values) {
      map[status] = [];
    }


    for (UserAccessEntity entity in entities) {
      // ✅ FIXED: Determine the PRIMARY status category
      EmployeeStatusEnum primaryCategory;

      // Priority order: willBeActivated > willBeDeactivated > actual status
      if (entity.willBeActivated) {
        primaryCategory = EmployeeStatusEnum.willBeActivated;
      } else if (entity.willBeDeactivated) {
        primaryCategory = EmployeeStatusEnum.willBeDeactivated;
      } else {
        primaryCategory = entity.status;
      }

      // ✅ Add to PRIMARY category only (never double-add)
      map[primaryCategory]!.add(entity);

      // ✅ ALWAYS add to "All" category
      map[EmployeeStatusEnum.all]!.add(entity);
    }

    map.forEach((status, list) {
      if (list.isNotEmpty) {
      }
    });

    int totalExcludingAll = map.entries
        .where((entry) => entry.key != EmployeeStatusEnum.all)
        .fold<int>(0, (sum, entry) => sum + entry.value.length);

    int allCount = map[EmployeeStatusEnum.all]?.length ?? 0;


    if (totalExcludingAll == allCount) {
    } else {
    }

    result = Right(map);
    return result;
  }
}