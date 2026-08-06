import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/notification/presentation/controller/app_notification_cubit.dart';
import 'package:grc_module/features/roles/r2_user_management/data/repository/user_role_repository.dart';
import 'package:grc_module/features/roles/r2_user_management/domain/entity/user_permission_entity.dart';


class DeleteUserPermissionUseCase {
  final UserManagementAccessRepository repository;

  DeleteUserPermissionUseCase(this.repository);

  Future<Either<Failure, dynamic>> execute({
    required UserPermissionEntity permission,
    required String employeeEmail,
    required String currentUserEmail,
  }) async {
    return await repository.deleteEmployeePermission(
      employeeId: permission.employeeId,
      currentUserEmail: currentUserEmail,
    );
  }
}
