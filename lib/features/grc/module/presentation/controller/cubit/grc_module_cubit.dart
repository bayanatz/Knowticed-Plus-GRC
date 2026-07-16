/// Module: GRC Module Management
/// Description: BLoC Cubit that manages GRC Module state for the presentation
///              layer. Delegates all operations to the corresponding use cases
///              and emits typed [GRCModuleState] subclasses.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: flutter_bloc, use cases, GRCModuleEntity
/// Revision History: 2026-06-30 - Initial creation
library;

import 'dart:io';

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/create_grc_module_use_case.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/delete_grc_module_use_case.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/get_all_grc_modules_use_case.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/get_grc_module_use_case.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/restore_grc_module_use_case.dart';
import 'package:demo_app/features/grc/module/domain/use_cases/update_grc_module_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'grc_module_state.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_cubit.dart
/// Purpose: Contains the GRCModuleCubit class, the presentation-layer state
///          manager for all GRC Module CRUD operations.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

/// class name: [GRCModuleCubit]
///
/// purpose: manage all GRC Module UI state. Each public method maps to one
///          use case and follows the pattern: emit [GRCModuleLoading] →
///          call use case → emit [GRCModuleActionSuccess] /
///          [GRCModuleListLoaded] / [GRCModuleSingleLoaded] on success, or
///          [GRCModuleFailure] on failure.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GRCModuleCubit extends Cubit<GRCModuleState> {
  GRCModuleCubit({
    required CreateGRCModuleUseCase createGRCModuleUseCase,
    required GetGRCModuleUseCase getGRCModuleUseCase,
    required GetAllGRCModulesUseCase getAllGRCModulesUseCase,
    required UpdateGRCModuleUseCase updateGRCModuleUseCase,
    required DeleteGRCModuleUseCase deleteGRCModuleUseCase,
    required RestoreGRCModuleUseCase restoreGRCModuleUseCase,
  })  : _createUseCase = createGRCModuleUseCase,
        _getUseCase = getGRCModuleUseCase,
        _getAllUseCase = getAllGRCModulesUseCase,
        _updateUseCase = updateGRCModuleUseCase,
        _deleteUseCase = deleteGRCModuleUseCase,
        _restoreUseCase = restoreGRCModuleUseCase,
        super(GRCModuleInitial());

  final CreateGRCModuleUseCase _createUseCase;
  final GetGRCModuleUseCase _getUseCase;
  final GetAllGRCModulesUseCase _getAllUseCase;
  final UpdateGRCModuleUseCase _updateUseCase;
  final DeleteGRCModuleUseCase _deleteUseCase;
  final RestoreGRCModuleUseCase _restoreUseCase;

  /// Resolves the currently logged-in user's email (every GRC Module
  /// revision is attributed to an email, not an id — see Modifiers on
  /// GRCModuleModel).
  /// Falls back to MainCoreEmployeeController if Constant.emailUser isn't set yet.
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  /// function name: [getAllModules]
  ///
  /// purpose: fetch all GRC Module records and emit [GRCModuleListLoaded]
  ///          on success or [GRCModuleFailure] on failure.
  ///
  /// parameters:
  ///            [bool] includeDeleted: when true, soft-deleted modules are
  ///            included in the result (default: false)
  ///
  /// return type: [Future<void>]
  Future<void> getAllModules({bool includeDeleted = false}) async {
    emit(GRCModuleLoading());
    final result = await _getAllUseCase.execute(includeDeleted: includeDeleted);
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (modules) => emit(GRCModuleListLoaded(modules)),
    );
  }

  /// function name: [getModule]
  ///
  /// purpose: fetch a single GRC Module by [id] and emit
  ///          [GRCModuleSingleLoaded] on success or [GRCModuleFailure] on
  ///          failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to fetch
  ///
  /// return type: [Future<void>]
  Future<void> getModule(String id) async {
    emit(GRCModuleLoading());
    final result = await _getUseCase.execute(id);
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (module) => emit(GRCModuleSingleLoaded(module)),
    );
  }

  /// function name: [createModule]
  ///
  /// purpose: create a new GRC Module and emit [GRCModuleActionSuccess] on
  ///          success or [GRCModuleFailure] on failure.
  ///
  /// parameters:
  ///            [String] grcModuleNameEnglish: English module name
  ///            [String] grcModuleNameArabic: Arabic module name
  ///            [String] descriptionEnglish: English description
  ///            [String] descriptionArabic: Arabic description
  ///            [String] owningDepartment: owning department
  ///            [DateTime] activationDate: activation date
  ///            [List<String>] owners: list of owner employee ids
  ///            [String] status: initial status
  ///            [File] imageFile: local image file to upload, if any
  ///            [String] imageUrl: an already-hosted image URL, if any
  ///
  /// return type: [Future<void>]
  Future<void> createModule({
    required String grcModuleNameEnglish,
    required String grcModuleNameArabic,
    required String descriptionEnglish,
    required String descriptionArabic,
    required String owningDepartment,
    required DateTime activationDate,
    required List<String> owners,
    required String status,
    File? imageFile,
    String? imageUrl,
  }) async {
    emit(GRCModuleLoading());
    final result = await _createUseCase.execute(
      grcModuleNameEnglish: grcModuleNameEnglish,
      grcModuleNameArabic: grcModuleNameArabic,
      descriptionEnglish: descriptionEnglish,
      descriptionArabic: descriptionArabic,
      owningDepartment: owningDepartment,
      activationDate: activationDate,
      owners: owners,
      status: status,
      editorId: _currentUserEmail,
      imageFile: imageFile,
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (module) => emit(GRCModuleActionSuccess(module)),
    );
  }

  /// function name: [updateModule]
  ///
  /// purpose: update an existing GRC Module and emit [GRCModuleActionSuccess]
  ///          on success or [GRCModuleFailure] on failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to update
  ///            [String] grcModuleNameEnglish: new English module name, if changed
  ///            [String] grcModuleNameArabic: new Arabic module name, if changed
  ///            [String] descriptionEnglish: new English description, if changed
  ///            [String] descriptionArabic: new Arabic description, if changed
  ///            [String] owningDepartment: new owning department, if changed
  ///            [DateTime] activationDate: new activation date, if changed
  ///            [List<String>] owners: new owners list, if changed
  ///            [String] status: new status, if changed
  ///            [File] imageFile: new local image file to upload, if changed
  ///            [String] imageUrl: a new already-hosted image URL, if changed
  ///
  /// return type: [Future<void>]
  Future<void> updateModule({
    required String id,
    String? grcModuleNameEnglish,
    String? grcModuleNameArabic,
    String? descriptionEnglish,
    String? descriptionArabic,
    String? owningDepartment,
    DateTime? activationDate,
    List<String>? owners,
    String? status,
    File? imageFile,
    String? imageUrl,
  }) async {
    emit(GRCModuleLoading());
    final result = await _updateUseCase.execute(
      id: id,
      editorId: _currentUserEmail,
      grcModuleNameEnglish: grcModuleNameEnglish,
      grcModuleNameArabic: grcModuleNameArabic,
      descriptionEnglish: descriptionEnglish,
      descriptionArabic: descriptionArabic,
      owningDepartment: owningDepartment,
      activationDate: activationDate,
      owners: owners,
      status: status,
      imageFile: imageFile,
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (module) => emit(GRCModuleActionSuccess(module)),
    );
  }

  /// function name: [deleteModule]
  ///
  /// purpose: soft-delete a GRC Module and emit [GRCModuleActionSuccess] on
  ///          success or [GRCModuleFailure] on failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to delete
  ///
  /// return type: [Future<void>]
  Future<void> deleteModule({required String id}) async {
    emit(GRCModuleLoading());
    final result = await _deleteUseCase.execute(
      id: id,
      editorId: _currentUserEmail,
    );
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (module) => emit(GRCModuleActionSuccess(module)),
    );
  }

  /// function name: [restoreModule]
  ///
  /// purpose: restore a soft-deleted GRC Module and emit
  ///          [GRCModuleActionSuccess] on success or [GRCModuleFailure] on
  ///          failure.
  ///
  /// parameters:
  ///            [String] id: unique identifier of the module to restore
  ///
  /// return type: [Future<void>]
  Future<void> restoreModule({required String id}) async {
    emit(GRCModuleLoading());
    final result = await _restoreUseCase.execute(
      id: id,
      editorId: _currentUserEmail,
    );
    result.fold(
      (failure) => emit(GRCModuleFailure(failure.message)),
      (module) => emit(GRCModuleActionSuccess(module)),
    );
  }
}
