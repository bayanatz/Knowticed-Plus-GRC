import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/control_firestore.dart';

abstract class ControlRepo {
  Future<Either<Failure, void>> createControl(ControlFirestore control);
  Future<Either<Failure, void>> editControl(ControlFirestore control);
  Future<Either<Failure, void>> deleteControl(ControlFirestore control);
  Future<Either<Failure, List<ControlFirestore>>> readALLControls();
}
