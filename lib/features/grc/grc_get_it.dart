/// Module: GRC Module Management
/// Description: Dependency injection setup for the GRC feature using get_it.
///              Registers all data sources, repository, use cases, and the
///              cubit as lazy singletons so they are only created on first use.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: get_it, GRCModuleFirebaseDataSource,
///               GRCModuleStorageDataSource, GRCModuleRepositoryImpl,
///               use cases, GRCModuleCubit
/// Revision History: 2026-06-30 - Initial creation
library;

import 'package:demo_app/features/grc/control/data/data_source/control_firebase_data_source.dart';
import 'package:demo_app/features/grc/control_champion/data/data_source/champion_firebase_data_source.dart';
import 'package:demo_app/features/grc/control_owner/data/data_source/owner_firebase_data_source.dart';
import 'package:demo_app/features/grc/module/data/data_source/grc_module_firebase_data_source.dart';
import 'package:demo_app/features/grc/module/data/data_source/grc_module_storage_data_source.dart';
import 'package:demo_app/features/grc/policy/data/data_source/policy_firebase_data_source.dart';
import 'package:demo_app/features/grc/policy/data/data_source/policy_storage_data_source.dart';
import 'package:demo_app/features/grc/control/data/repository/control_repository_impl.dart';
import 'package:demo_app/features/grc/control_champion/data/repository/champion_repository_impl.dart';
import 'package:demo_app/features/grc/control_owner/data/repository/owner_repository_impl.dart';
import 'package:demo_app/features/grc/module/data/repository/grc_module_repository_impl.dart';
import 'package:demo_app/features/grc/policy/data/repository/policy_repository_impl.dart';
import 'package:demo_app/features/grc/control/domain/repository/control_repository.dart';
import 'package:demo_app/features/grc/control_champion/domain/repository/champion_repository.dart';
import 'package:demo_app/features/grc/control_owner/domain/repository/owner_repository.dart';
import 'package:demo_app/features/grc/module/domain/repository/grc_module_repository.dart';
import 'package:demo_app/features/grc/policy/domain/repository/policy_repository.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/create_champion_usecase.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/create_owner_usecase.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/create_grc_module_use_case.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/create_policy_usecase.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/delete_grc_module_use_case.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/get_all_grc_modules_use_case.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_usecases.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/get_control_weight_history_use_case.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/get_grc_module_use_case.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/get_grc_module_owner_history_use_case.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/get_policy_weight_history_use_case.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/restore_grc_module_use_case.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/update_control_usecase.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/update_champion_usecase.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/update_owner_usecase.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/update_grc_module_use_case.dart';
import 'package:demo_app/features/grc/policy/domain/use_cases/update_policy_usecase.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_module_cubit.dart';
import 'package:demo_app/features/grc/module/presentation/controller/cubit/grc_previous_owners_cubit.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_cubit.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_history_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_weight_issue/policy_weight_issue_cubit.dart';
import 'package:get_it/get_it.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_get_it.dart
/// Purpose: Contains the setupGRCDependencies() function that registers
///          every GRC-feature dependency into the global [GetIt] service
///          locator. Call this once from main() before the app runs.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// function name: [setupGRCDependencies]
///
/// purpose: register all GRC feature dependencies into [sl] (the global
///          [GetIt] instance) in the correct order:
///            1. Data sources
///            2. Repository (implementation)
///            3. Use cases
///            4. Cubit (presentation layer)
///          All registrations use [registerLazySingleton] so instances are
///          created on first access and reused afterwards.
///
/// parameters:
///            [GetIt] sl: the global service locator instance
///
/// return type: [void]
void setupGRCDependencies(GetIt sl) {
  // ─── 1. Data Sources ────────────────────────────────────────────────────────

  /// class name: [GRCModuleFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for GRC Module documents.
  sl.registerLazySingleton<GRCModuleFirebaseDataSource>(
    () => GRCModuleFirebaseDataSource(),
  );

  /// class name: [GRCModuleStorageDataSource]
  /// purpose: Firebase Storage upload/delete for GRC Module images.
  sl.registerLazySingleton<GRCModuleStorageDataSource>(
    () => GRCModuleStorageDataSource(),
  );

  /// class name: [PolicyFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Policy documents.
  sl.registerLazySingleton<PolicyFirebaseDataSource>(
    () => PolicyFirebaseDataSource(),
  );

  /// class name: [PolicyStorageDataSource]
  /// purpose: Firebase Storage upload/delete for Policy images and documents.
  sl.registerLazySingleton<PolicyStorageDataSource>(
    () => PolicyStorageDataSource(),
  );

  /// class name: [ControlFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Control documents (the
  /// Controls subcollection nested under each Policy).
  sl.registerLazySingleton<ControlFirebaseDataSource>(
    () => ControlFirebaseDataSource(),
  );

  /// class name: [ChampionFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Control Champion documents.
  sl.registerLazySingleton<ChampionFirebaseDataSource>(
    () => ChampionFirebaseDataSource(),
  );

  /// class name: [OwnerFirebaseDataSource]
  /// purpose: Cloud Firestore CRUD operations for Control Owner documents.
  sl.registerLazySingleton<OwnerFirebaseDataSource>(
    () => OwnerFirebaseDataSource(),
  );

  // ─── 2. Repository ──────────────────────────────────────────────────────────

  /// class name: [GRCModuleRepositoryImpl] registered as [GRCModuleRepository]
  /// purpose: orchestrates the data sources and maps models to entities.
  sl.registerLazySingleton<GRCModuleRepository>(
    () => GRCModuleRepositoryImpl(
      firebaseDataSource: sl<GRCModuleFirebaseDataSource>(),
      storageDataSource: sl<GRCModuleStorageDataSource>(),
    ),
  );

  /// class name: [PolicyRepositoryImpl] registered as [PolicyRepository]
  /// purpose: orchestrates the data sources and maps models to entities.
  sl.registerLazySingleton<PolicyRepository>(
    () => PolicyRepositoryImpl(
      firebaseDataSource: sl<PolicyFirebaseDataSource>(),
      storageDataSource: sl<PolicyStorageDataSource>(),
    ),
  );

  /// class name: [ControlRepositoryImpl] registered as [ControlRepository]
  /// purpose: orchestrates the Controls subcollection data source and Storage
  /// uploads, and maps models to entities.
  sl.registerLazySingleton<ControlRepository>(
    () => ControlRepositoryImpl(
      firebaseDataSource: sl<ControlFirebaseDataSource>(),
      storageDataSource: sl<PolicyStorageDataSource>(),
    ),
  );

  /// class name: [ChampionRepositoryImpl] registered as [ChampionRepository]
  /// purpose: orchestrates the Champion data source and maps models to entities.
  sl.registerLazySingleton<ChampionRepository>(
    () => ChampionRepositoryImpl(
      firebaseDataSource: sl<ChampionFirebaseDataSource>(),
    ),
  );

  /// class name: [OwnerRepositoryImpl] registered as [OwnerRepository]
  /// purpose: orchestrates the Owner data source and maps models to entities.
  sl.registerLazySingleton<OwnerRepository>(
    () => OwnerRepositoryImpl(
      firebaseDataSource: sl<OwnerFirebaseDataSource>(),
    ),
  );

  // ─── 3. Use Cases ───────────────────────────────────────────────────────────

  /// class name: [CreateGRCModuleUseCase]
  /// purpose: business logic for creating a new GRC Module.
  sl.registerLazySingleton<CreateGRCModuleUseCase>(
    () => CreateGRCModuleUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [GetGRCModuleUseCase]
  /// purpose: business logic for fetching a single GRC Module by id.
  sl.registerLazySingleton<GetGRCModuleUseCase>(
    () => GetGRCModuleUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [GetAllGRCModulesUseCase]
  /// purpose: business logic for fetching all GRC Module records.
  sl.registerLazySingleton<GetAllGRCModulesUseCase>(
    () => GetAllGRCModulesUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [UpdateGRCModuleUseCase]
  /// purpose: business logic for updating an existing GRC Module.
  sl.registerLazySingleton<UpdateGRCModuleUseCase>(
    () => UpdateGRCModuleUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [DeleteGRCModuleUseCase]
  /// purpose: business logic for soft-deleting a GRC Module.
  sl.registerLazySingleton<DeleteGRCModuleUseCase>(
    () => DeleteGRCModuleUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [RestoreGRCModuleUseCase]
  /// purpose: business logic for restoring a soft-deleted GRC Module.
  sl.registerLazySingleton<RestoreGRCModuleUseCase>(
    () => RestoreGRCModuleUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [GetGRCModuleOwnerHistoryUseCase]
  /// purpose: business logic for fetching a module's previous owner history.
  sl.registerLazySingleton<GetGRCModuleOwnerHistoryUseCase>(
    () => GetGRCModuleOwnerHistoryUseCase(sl<GRCModuleRepository>()),
  );

  /// class name: [GetPolicyWeightHistoryUseCase]
  /// purpose: business logic for fetching a module's Policy weight history.
  sl.registerLazySingleton<GetPolicyWeightHistoryUseCase>(
    () => GetPolicyWeightHistoryUseCase(sl<PolicyRepository>()),
  );

  /// class name: [CreatePolicyUseCase]
  /// purpose: business logic for creating a new Policy (with its Controls).
  sl.registerLazySingleton<CreatePolicyUseCase>(
    () => CreatePolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [GetPolicyUseCase]
  /// purpose: business logic for fetching a single Policy by id.
  sl.registerLazySingleton<GetPolicyUseCase>(
    () => GetPolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [GetAllPoliciesUseCase]
  /// purpose: business logic for fetching all Policy records.
  sl.registerLazySingleton<GetAllPoliciesUseCase>(
    () => GetAllPoliciesUseCase(sl<PolicyRepository>()),
  );

  /// class name: [UpdatePolicyUseCase]
  /// purpose: business logic for updating an existing Policy.
  sl.registerLazySingleton<UpdatePolicyUseCase>(
    () => UpdatePolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [DeletePolicyUseCase]
  /// purpose: business logic for soft-deleting a Policy.
  sl.registerLazySingleton<DeletePolicyUseCase>(
    () => DeletePolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [RestorePolicyUseCase]
  /// purpose: business logic for restoring a soft-deleted Policy.
  sl.registerLazySingleton<RestorePolicyUseCase>(
    () => RestorePolicyUseCase(sl<PolicyRepository>()),
  );

  /// class name: [CreateControlUseCase]
  /// purpose: business logic for creating a new Control.
  sl.registerLazySingleton<CreateControlUseCase>(
    () => CreateControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [GetControlUseCase]
  /// purpose: business logic for fetching a single Control by id.
  sl.registerLazySingleton<GetControlUseCase>(
    () => GetControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [GetAllControlsUseCase]
  /// purpose: business logic for fetching all Controls under a Policy.
  sl.registerLazySingleton<GetAllControlsUseCase>(
    () => GetAllControlsUseCase(sl<ControlRepository>()),
  );

  /// class name: [UpdateControlUseCase]
  /// purpose: business logic for updating an existing Control.
  sl.registerLazySingleton<UpdateControlUseCase>(
    () => UpdateControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [DeleteControlUseCase]
  /// purpose: business logic for hard-deleting a Control.
  sl.registerLazySingleton<DeleteControlUseCase>(
    () => DeleteControlUseCase(sl<ControlRepository>()),
  );

  /// class name: [GetControlWeightHistoryUseCase]
  /// purpose: business logic for fetching a policy's Control weight history.
  sl.registerLazySingleton<GetControlWeightHistoryUseCase>(
    () => GetControlWeightHistoryUseCase(sl<ControlRepository>()),
  );

  /// class name: [CreateChampionUseCase]
  /// purpose: business logic for creating a new Control Champion.
  sl.registerLazySingleton<CreateChampionUseCase>(
    () => CreateChampionUseCase(sl<ChampionRepository>()),
  );

  /// class name: [GetChampionUseCase]
  /// purpose: business logic for fetching a single Control Champion by email.
  sl.registerLazySingleton<GetChampionUseCase>(
    () => GetChampionUseCase(sl<ChampionRepository>()),
  );

  /// class name: [GetAllChampionsUseCase]
  /// purpose: business logic for fetching all Control Champion records.
  sl.registerLazySingleton<GetAllChampionsUseCase>(
    () => GetAllChampionsUseCase(sl<ChampionRepository>()),
  );

  /// class name: [UpdateChampionUseCase]
  /// purpose: business logic for updating (or soft-deleting/restoring) a Control Champion.
  sl.registerLazySingleton<UpdateChampionUseCase>(
    () => UpdateChampionUseCase(sl<ChampionRepository>()),
  );

  /// class name: [CreateOwnerUseCase]
  /// purpose: business logic for creating a new Control Owner.
  sl.registerLazySingleton<CreateOwnerUseCase>(
    () => CreateOwnerUseCase(sl<OwnerRepository>()),
  );

  /// class name: [GetOwnerUseCase]
  /// purpose: business logic for fetching a single Control Owner by email.
  sl.registerLazySingleton<GetOwnerUseCase>(
    () => GetOwnerUseCase(sl<OwnerRepository>()),
  );

  /// class name: [GetAllOwnersUseCase]
  /// purpose: business logic for fetching all Control Owner records.
  sl.registerLazySingleton<GetAllOwnersUseCase>(
    () => GetAllOwnersUseCase(sl<OwnerRepository>()),
  );

  /// class name: [UpdateOwnerUseCase]
  /// purpose: business logic for updating (or soft-deleting/restoring) a Control Owner.
  sl.registerLazySingleton<UpdateOwnerUseCase>(
    () => UpdateOwnerUseCase(sl<OwnerRepository>()),
  );

  // ─── 4. Cubit (Presentation) ────────────────────────────────────────────────

  /// class name: [GRCModuleCubit]
  /// purpose: presentation-layer state manager for all GRC Module operations.
  /// Registered as a factory so each page gets an independent cubit instance,
  /// preventing state leaking between the list page and the details page.
  sl.registerFactory<GRCModuleCubit>(
    () => GRCModuleCubit(
      createGRCModuleUseCase: sl<CreateGRCModuleUseCase>(),
      getGRCModuleUseCase: sl<GetGRCModuleUseCase>(),
      getAllGRCModulesUseCase: sl<GetAllGRCModulesUseCase>(),
      updateGRCModuleUseCase: sl<UpdateGRCModuleUseCase>(),
      deleteGRCModuleUseCase: sl<DeleteGRCModuleUseCase>(),
      restoreGRCModuleUseCase: sl<RestoreGRCModuleUseCase>(),
    ),
  );

  /// class name: [GrcPreviousOwnersCubit]
  /// purpose: presentation-layer state manager for the previous module owners page.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<GrcPreviousOwnersCubit>(
    () => GrcPreviousOwnersCubit(
      getOwnerHistoryUseCase: sl<GetGRCModuleOwnerHistoryUseCase>(),
    ),
  );

  /// class name: [PolicyCubit]
  /// purpose: presentation-layer state manager for all Policy and Control
  /// operations. Registered as a factory so each page gets an independent
  /// cubit instance.
  sl.registerFactory<PolicyCubit>(
    () => PolicyCubit(
      createPolicyUseCase: sl<CreatePolicyUseCase>(),
      getPolicyUseCase: sl<GetPolicyUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
      deletePolicyUseCase: sl<DeletePolicyUseCase>(),
      restorePolicyUseCase: sl<RestorePolicyUseCase>(),
      createControlUseCase: sl<CreateControlUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
      deleteControlUseCase: sl<DeleteControlUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );

  /// class name: [PolicyWeightIssueCubit]
  /// purpose: presentation-layer state manager for the Policy Weight Issue
  /// page's editable table. Registered as a factory so each page gets an
  /// independent cubit instance.
  sl.registerFactory<PolicyWeightIssueCubit>(
    () => PolicyWeightIssueCubit(
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
    ),
  );

  /// class name: [PolicyWeightHistoryCubit]
  /// purpose: presentation-layer state manager for the Policy Weight
  /// Issue page's History tab. Registered as a factory so each page gets
  /// an independent cubit instance.
  sl.registerFactory<PolicyWeightHistoryCubit>(
    () => PolicyWeightHistoryCubit(
      getPolicyWeightHistoryUseCase: sl<GetPolicyWeightHistoryUseCase>(),
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
    ),
  );

  /// class name: [ControlWeightIssueCubit]
  /// purpose: presentation-layer state manager for the Control Weight
  /// Issue page's editable table. Registered as a factory so each page
  /// gets an independent cubit instance.
  sl.registerFactory<ControlWeightIssueCubit>(
    () => ControlWeightIssueCubit(
      getAllControlsUseCase: sl<GetAllControlsUseCase>(),
      updateControlUseCase: sl<UpdateControlUseCase>(),
    ),
  );

  /// class name: [ChampionCubit]
  /// purpose: presentation-layer state manager for Control Champion operations.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<ChampionCubit>(
    () => ChampionCubit(
      createChampionUseCase: sl<CreateChampionUseCase>(),
      getChampionUseCase: sl<GetChampionUseCase>(),
      getAllChampionsUseCase: sl<GetAllChampionsUseCase>(),
      updateChampionUseCase: sl<UpdateChampionUseCase>(),
    ),
  );

  /// class name: [OwnerCubit]
  /// purpose: presentation-layer state manager for Control Owner operations.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<OwnerCubit>(
    () => OwnerCubit(
      createOwnerUseCase: sl<CreateOwnerUseCase>(),
      getOwnerUseCase: sl<GetOwnerUseCase>(),
      getAllOwnersUseCase: sl<GetAllOwnersUseCase>(),
      updateOwnerUseCase: sl<UpdateOwnerUseCase>(),
    ),
  );
}
