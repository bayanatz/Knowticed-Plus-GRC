import 'package:get/get.dart';
import 'package:dartz/dartz.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/controllers/notification_controller.dart';
import 'package:grc_module/features/roles/r2_user_management/data/repository/user_role_repository.dart';

import 'package:grc_module/core/custom/date_time_in_arabic.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/roles/r4_active_directory/domain/entities/employee_entity.dart';


class UpdateSelectedMembersUseCase {
  final UserManagementAccessRepository repository;

  UpdateSelectedMembersUseCase(this.repository);

  Future<Either<Failure, dynamic>> execute({
    required String currentUserEmail,
    required String accessName,
    required String startDate,
    required String endDate,
    required List<EmployeeEntityPro> selectedMembers,
  }) async {
    return await repository.updateSelectedMembersPermission(
      currentUserEmail: currentUserEmail,
      accessName: accessName,
      startDate: startDate,
      endDate: endDate,
      selectedMembers: selectedMembers,
    );
  }
}
