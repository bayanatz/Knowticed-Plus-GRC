import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/helper/firebase_helper.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/data/data_sources/control_owner_data_source.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/data/models/control_owner_firestore.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/data/repositories/control_owner_repo_impl.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/domain/repositories/control_owner_repo.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/domain/usecases/read_all_control_owner_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/domain/repositories/crud_repo.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/domain/usecases/delete_module_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/domain/usecases/edit_module_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/domain/usecases/read_all_module_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/data/modules/champion_module.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/data/repositories/champion_repo_impl.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/domain/repositories/champion_repo.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/domain/usecases/add_champion_officer.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/domain/usecases/read_all_control_champion.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/control_firestore.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/models/policy_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/control_owner/features/home/domain/usecases/create_control_owner_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/data/data_sources/crud_data_sources.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/data/modules/module_firestore.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/data/repositories/crud_repo_impl.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/manager_grc/features/CUD_module/domain/usecases/create_module_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/add_champion_officer/data/data_sources/champion_data_sources.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/data_sources/control_data_source.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/data_sources/policy_data_source.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/repositories/control_repo_impl.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/data/repositories/policy_repo_impl.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/repositories/control_repo.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/repositories/policy_repo.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/usecases/create_control_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/usecases/create_policy_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/usecases/delete_control_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/usecases/delete_policy_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/usecases/edit_control_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/usecases/edit_policy_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/usecases/read_all_control_usecase.dart';
import 'package:knowticed_plus/features/qiyas/data/legacy_core/helper/qiyas/data_grc/feature/module_owner_grc/features/creating_policies_and_controls/domain/usecases/read_all_policy_usecase.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/data_source/vision_data_source.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/models/vision_firestore.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/data/repository/vision_repo_impl.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/base_repository/vision_repo.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/use_cases/create_vision_usecase.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/use_cases/delete_vision_usecase.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/use_cases/edit_vision_usecase.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/domain/use_cases/read_all_vision_usecase.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/data_source/qiyas_champion_data_sources.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/models/qiyas_champion_model.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/data/repository/qiyas_champion_repo_impl.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/base_repository/qiyas_champion_repo.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/use_cases/add_qiyas_champion_officer.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/create_control_champion/domain/use_cases/read_all_qiyas_control_champion.dart';

final sl = GetIt.instance;
const String kModuleNameCollection = "Modules";
const String kPolicyNameCollection = "Policies";
const String kChampionNameCollection = "Control_Champions";
const String kControlOwnerNameCollection = "Control_Owners";
const String kControlNameCollection = "Controls";
const String kVisionNameCollection = "Visions";
const String kQiyasChampionNameCollection = "Qiyas Control Champions";
const String kQiyasOwnerNameCollection = "Qiyas Control Owners";

void _reg<T extends Object>(String name, T Function() factory) {
  if (!sl.isRegistered<T>()) {
    try {
      sl.registerLazySingleton<T>(factory);
    } catch (e) {
      debugPrint("Error registering $name: $e");
    }
  }
}

void setUp() {
  _reg(
      'FireBaseHelper<ModuleFirestore>',
      () => FireBaseHelper<ModuleFirestore>(
            collectionName: getBaseUrl(kModuleNameCollection),
            fromMap: (map) => ModuleFirestore.fromMap(map),
          ));
  _reg(
      'FireBaseHelper<VisionModel>',
      () => FireBaseHelper<VisionModel>(
            collectionName: getBaseUrl(kVisionNameCollection),
            fromMap: (map) => VisionModel.fromMap(map),
          ));
  _reg(
      'FireBaseHelper<PolicyFirestore>',
      () => FireBaseHelper<PolicyFirestore>(
            collectionName: getBaseUrl(kPolicyNameCollection),
            fromMap: (map) => PolicyFirestore.fromMap(map),
          ));
  _reg(
      'FireBaseHelper<ChampionFirestore>',
      () => FireBaseHelper<ChampionFirestore>(
            collectionName: getBaseUrl(kChampionNameCollection),
            fromMap: (map) => ChampionFirestore.fromMap(map),
          ));
  _reg(
      'FireBaseHelper<QiyasChampionModel>',
      () => FireBaseHelper<QiyasChampionModel>(
            collectionName: getBaseUrl(kQiyasChampionNameCollection),
            fromMap: (map) => QiyasChampionModel.fromMap(map),
          ));
  _reg(
      'FireBaseHelper<ControlFirestore>',
      () => FireBaseHelper<ControlFirestore>(
            collectionName: getBaseUrl(kControlNameCollection),
            fromMap: (map) => ControlFirestore.fromMap(map),
          ));
  _reg(
      'FireBaseHelper<ControlOwnerFirestore>',
      () => FireBaseHelper<ControlOwnerFirestore>(
            collectionName: getBaseUrl(kControlOwnerNameCollection),
            fromMap: (map) => ControlOwnerFirestore.fromMap(map),
          ));

  _reg<CrudDataSources>(
      'CrudDataSources', () => CrudDataSourcesImpl(helper: sl()));
  _reg<CrudRepo>('CrudRepo', () => CrudRepoImpl(sl()));
  _reg<PolicyDataSource>(
      'PolicyDataSource', () => PolicyDataSourceImpl(helper: sl()));
  _reg<PolicyRepo>('PolicyRepo', () => PolicyRepoImpl(sl()));
  _reg<VisionDataSource>(
      'VisionDataSource', () => VisionDataSource(helper: sl()));
  _reg<VisionRepo>('VisionRepo', () => VisionRepoImpl(sl()));
  _reg<ControlDataSource>(
      'ControlDataSource', () => ControlDataSourceImpl(helper: sl()));
  _reg<ControlRepo>('ControlRepo', () => ControlRepoImpl(sl()));
  _reg<ChampionDataSources>(
      'ChampionDataSources', () => ChampionDataSourcesImpl(helper: sl()));
  _reg<ChampionRepo>('ChampionRepo', () => ChampionRepoImpl(sl()));
  _reg<QiyasChampionDataSources>(
      'QiyasChampionDataSources', () => QiyasChampionDataSources(helper: sl()));
  _reg<QiyasChampionRepo>(
      'QiyasChampionRepo', () => QiyasChampionRepoImpl(sl()));
  _reg<ControlOwnerDataSource>(
      'ControlOwnerDataSource', () => ControlOwnerDataSourceImpl(helper: sl()));
  _reg<ControlOwnerRepo>('ControlOwnerRepo', () => ControlOwnerRepoImpl(sl()));

  _reg<CreateModuleUsecase>(
      'CreateModuleUsecase', () => CreateModuleUsecase(sl()));
  _reg<EditModuleUsecase>('EditModuleUsecase', () => EditModuleUsecase(sl()));
  _reg<DeleteModuleUsecase>(
      'DeleteModuleUsecase', () => DeleteModuleUsecase(sl()));
  _reg<ReadAllModuleUsecase>(
      'ReadAllModuleUsecase', () => ReadAllModuleUsecase(sl()));
  _reg<CreatePolicyUsecase>(
      'CreatePolicyUsecase', () => CreatePolicyUsecase(sl()));
  _reg<EditPolicyUsecase>('EditPolicyUsecase', () => EditPolicyUsecase(sl()));
  _reg<DeletePolicyUsecase>(
      'DeletePolicyUsecase', () => DeletePolicyUsecase(sl()));
  _reg<ReadAllPolicyUsecase>(
      'ReadAllPolicyUsecase', () => ReadAllPolicyUsecase(sl()));
  _reg<AddChampionOfficersUsecase>(
      'AddChampionOfficersUsecase', () => AddChampionOfficersUsecase(sl()));
  _reg<ReadAllControlChampionUsecase>('ReadAllControlChampionUsecase',
      () => ReadAllControlChampionUsecase(sl()));
  _reg<AddQiyasChampionOfficersUsecase>('AddQiyasChampionOfficersUsecase',
      () => AddQiyasChampionOfficersUsecase(sl()));
  _reg<ReadAllQiyasControlChampionUsecase>('ReadAllQiyasControlChampionUsecase',
      () => ReadAllQiyasControlChampionUsecase(sl()));
  _reg<CreateControlOwnerUsecase>(
      'CreateControlOwnerUsecase', () => CreateControlOwnerUsecase(sl()));
  _reg<ReadAllControlOwnerUsecase>(
      'ReadAllControlOwnerUsecase', () => ReadAllControlOwnerUsecase(sl()));
  _reg<CreateControlUsecase>(
      'CreateControlUsecase', () => CreateControlUsecase(sl()));
  _reg<EditControlUsecase>(
      'EditControlUsecase', () => EditControlUsecase(sl()));
  _reg<DeleteControlUsecase>(
      'DeleteControlUsecase', () => DeleteControlUsecase(sl()));
  _reg<ReadAllControlUsecase>(
      'ReadAllControlUsecase', () => ReadAllControlUsecase(sl()));
  _reg<CreateVisionUsecase>(
      'CreateVisionUsecase', () => CreateVisionUsecase(sl()));
  _reg<EditVisionUsecase>('EditVisionUsecase', () => EditVisionUsecase(sl()));
  _reg<DeleteVisionUsecase>(
      'DeleteVisionUsecase', () => DeleteVisionUsecase(sl()));
  _reg<ReadAllVisionUsecase>(
      'ReadAllVisionUsecase', () => ReadAllVisionUsecase(sl()));
}

/// Backwards-compatible alias.
///
/// [setUpQiyas] used to register only the Vision + QiyasChampion subset from a
/// separate service locator. Every one of those registrations already exists in
/// [setUp] above (which is idempotent via `_reg`), so the two were merged and
/// this now simply delegates.
void setUpQiyas() => setUp();
