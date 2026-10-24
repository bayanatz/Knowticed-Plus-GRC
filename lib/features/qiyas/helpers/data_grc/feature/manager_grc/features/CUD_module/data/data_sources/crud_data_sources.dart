// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/manager_grc/features/CUD_module/data/modules/module_firestore.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/network/failure_model.dart';
import 'package:knowticed_plus/features/qiyas/helpers/helper/firebase_helper.dart';

abstract class CrudDataSources {
  Future<void> createModule(ModuleFirestore moduleEntity);
  Future<void> editModule(ModuleFirestore moduleEntity);
  Future<void> deleteModule(ModuleFirestore moduleEntity);
  Future<List<ModuleFirestore>> readALLModules();
}

class CrudDataSourcesImpl extends CrudDataSources {
  FireBaseHelper<ModuleFirestore> helper;
  CrudDataSourcesImpl({
    required this.helper,
  });
  @override
  Future<void> createModule(ModuleFirestore moduleEntity) async {
    try {
      return await helper.addItem(moduleEntity.toMap());
    } on ServerFailure {
      rethrow;
    }
  }

  @override
  Future<void> deleteModule(ModuleFirestore moduleEntity) async {
    try {
      // return await helper.deleteData(moduleEntity.name.last);
    } on ServerFailure {
      rethrow;
    }
  }

  @override
  Future<void> editModule(ModuleFirestore moduleEntity) async {
    try {
      return await helper.editItem(
          "name", moduleEntity.name.last, moduleEntity.toMap());
    } on ServerFailure {
      rethrow;
    }
  }

  @override
  Future<List<ModuleFirestore>> readALLModules() async {
    try {
      return await helper.getItems();
    } on ServerFailure {
      rethrow;
    }
  }
}
