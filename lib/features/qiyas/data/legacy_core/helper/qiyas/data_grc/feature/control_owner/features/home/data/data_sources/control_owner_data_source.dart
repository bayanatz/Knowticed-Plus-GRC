// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/helper/firebase_helper.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/data/models/control_owner_firestore.dart';

abstract class ControlOwnerDataSource {
  Future<void> createControlOwner(ControlOwnerFirestore controlOwner);

  Future<List<ControlOwnerFirestore>> readALLControlOwners();
}

class ControlOwnerDataSourceImpl extends ControlOwnerDataSource {
  FireBaseHelper<ControlOwnerFirestore> helper;
  ControlOwnerDataSourceImpl({
    required this.helper,
  });
  @override
  Future<void> createControlOwner(ControlOwnerFirestore controlOwner) async {
    try {
      return await helper.addItem(controlOwner.toMap());
    } on ServerFailure {
      rethrow;
    }
  }

  @override
  Future<List<ControlOwnerFirestore>> readALLControlOwners() async {
    try {
      return await helper.getItems();
    } on ServerFailure {
      rethrow;
    }
  }
}
