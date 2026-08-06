import 'package:dartz/dartz.dart';
import 'package:grc_module/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/entity/new_permission_entity.dart';

import 'package:grc_module/core/network/failure_model.dart';


class UpdateUserPermissionUseCase {
  final UserManagementAccessRepository repository;

  UpdateUserPermissionUseCase(this.repository);

  Future<Either<Failure, dynamic>> execute({
    required String employeeId,
    required String currentUserEmail,
    String? accessName,
    String? accessBegin,
    String? accessEnd,
  }) async {
    return await repository.updateUserPermission(
      employeeId: employeeId,
      currentUserEmail: currentUserEmail,
      accessName: accessName,
      accessBegin: accessBegin,
      accessEnd: accessEnd,
    );
  }
}
