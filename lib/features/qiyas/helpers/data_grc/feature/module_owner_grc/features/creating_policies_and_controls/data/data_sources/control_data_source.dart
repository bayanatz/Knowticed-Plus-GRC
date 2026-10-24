// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/firebase_helper.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/control_firestore.dart';

abstract class ControlDataSource {
  Future<void> createControl(ControlFirestore control);
  Future<void> editControl(ControlFirestore control);
  Future<void> deleteControl(ControlFirestore control);
  Future<List<ControlFirestore>> readALLControls();
}

class ControlDataSourceImpl extends ControlDataSource {
  final FireBaseHelper<ControlFirestore> helper;
  ControlDataSourceImpl({
    required this.helper,
  });
  @override
  Future<void> createControl(ControlFirestore control) async {
    try {
      return await helper.addItem(control.toMap());
    } on ServerFailure {
      rethrow;
    }
  }

  @override
  Future<void> deleteControl(ControlFirestore control) {
    // TODO: implement deleteModule
    throw UnimplementedError();
  }

  @override
  Future<void> editControl(ControlFirestore control) async {
    try {
      return await helper.editItem("name", control.name.last, control.toMap());
    } on ServerFailure {
      rethrow;
    }
  }

  @override
  Future<List<ControlFirestore>> readALLControls() async {
    try {
      return await helper.getItems();
    } on ServerFailure {
      rethrow;
    }
  }
}
