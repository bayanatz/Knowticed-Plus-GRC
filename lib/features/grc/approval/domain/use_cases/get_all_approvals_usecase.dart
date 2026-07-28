import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/approval/domain/entities/approval_entity.dart';
import 'package:demo_app/features/grc/approval/domain/repository/approval_repository.dart';

class GetAllApprovalsUseCase {
  const GetAllApprovalsUseCase(this._repository);

  final ApprovalRepository _repository;

  Future<Either<Failure, List<ApprovalEntity>>> call({
    required String moduleId,
  }) {
    return _repository.getAllApprovals(moduleId: moduleId);
  }
}
