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

import 'package:demo_app/features/grc/data/data_source/grc_module_firebase_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/grc_module_storage_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/policy_firebase_data_source.dart';
import 'package:demo_app/features/grc/data/data_source/policy_storage_data_source.dart';
import 'package:demo_app/features/grc/data/repository/grc_module_repository_impl.dart';
import 'package:demo_app/features/grc/data/repository/policy_repository_impl.dart';
import 'package:demo_app/features/grc/domain/repository/grc_module_repository.dart';
import 'package:demo_app/features/grc/domain/repository/policy_repository.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_policy_usecase.dart';
import 'package:demo_app/features/grc/domain/use_cases/delete_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_all_grc_modules_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_grc_module_owner_history_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/get_policy_usecases.dart';
import 'package:demo_app/features/grc/domain/use_cases/restore_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/update_grc_module_use_case.dart';
import 'package:demo_app/features/grc/domain/use_cases/update_policy_usecase.dart';
import 'package:demo_app/features/grc/presentation/controller/grc_module_cubit.dart';
import 'package:demo_app/features/grc/presentation/controller/grc_previous_owners_cubit.dart';
import 'package:demo_app/features/grc/presentation/controller/policy_cubit.dart';
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
  /// purpose: presentation-layer state manager for all Policy operations.
  /// Registered as a factory so each page gets an independent cubit instance.
  sl.registerFactory<PolicyCubit>(
    () => PolicyCubit(
      createPolicyUseCase: sl<CreatePolicyUseCase>(),
      getPolicyUseCase: sl<GetPolicyUseCase>(),
      getAllPoliciesUseCase: sl<GetAllPoliciesUseCase>(),
      updatePolicyUseCase: sl<UpdatePolicyUseCase>(),
      deletePolicyUseCase: sl<DeletePolicyUseCase>(),
      restorePolicyUseCase: sl<RestorePolicyUseCase>(),
    ),
  );
}
