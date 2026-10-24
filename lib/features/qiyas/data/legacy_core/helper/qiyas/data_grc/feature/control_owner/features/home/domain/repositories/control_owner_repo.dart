import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/data/models/control_owner_firestore.dart';

abstract class ControlOwnerRepo {
  Future<Either<Failure, void>> createControlOwner(
      ControlOwnerFirestore controlOwner);
  Future<Either<Failure, List<ControlOwnerFirestore>>> readALLControlOwners();
}
