import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:demo_app/core/network/failure_model.dart';
import 'package:demo_app/features/grc/assignment_control/domain/entities/assignment_control_entity.dart';

abstract class AssignmentControlRepository {
  /// Returns Right(null) — not an error — when no submission has ever been
  /// made for this control+champion pair yet (the Pending/Overdue state).
  Future<Either<Failure, AssignmentControlEntity?>> getAssignmentControl({
    required String moduleId,
    required String controlId,
    required String championEmail,
  });

  Future<Either<Failure, AssignmentControlEntity>> submitEvidence({
    required String moduleId,
    required String policyId,
    required String controlId,
    required String championEmail,
    required String? controlOwnerEmail,
    required File documentFile,
    required String note,
    required String editorEmail,
  });
}
