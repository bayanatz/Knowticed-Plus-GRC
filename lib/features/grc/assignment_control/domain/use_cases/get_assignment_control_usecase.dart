import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';
import 'package:demo_app/features/grc/assignment_control/domain/repository/assignment_control_repository.dart';

class GetAssignmentControlUseCase {
  const GetAssignmentControlUseCase(this._repository);

  final AssignmentControlRepository _repository;

  Future<Either<Failure, AssignmentControlEntity?>> call({
    required String moduleId,
    required String controlId,
    required String championEmail,
  }) {
    return _repository.getAssignmentControl(
      moduleId: moduleId,
      controlId: controlId,
      championEmail: championEmail,
    );
  }
}
