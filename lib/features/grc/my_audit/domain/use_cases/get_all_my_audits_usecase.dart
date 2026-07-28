import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/my_audit/domain/entities/my_audit_entity.dart';
import 'package:demo_app/features/grc/my_audit/domain/repository/my_audit_repository.dart';

class GetAllMyAuditsUseCase {
  const GetAllMyAuditsUseCase(this._repository);

  final MyAuditRepository _repository;

  Future<Either<Failure, List<MyAuditEntity>>> call({required String moduleId}) {
    return _repository.getAllMyAudits(moduleId: moduleId);
  }
}
