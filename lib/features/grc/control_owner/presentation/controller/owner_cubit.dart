/// Module: Control Owner Management
/// Description: BLoC Cubit that manages Control Owner state for the
///              presentation layer, mirroring ChampionCubit's shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, use cases, OwnerEntity, AssigningControlEntity

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_status.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/create_owner_usecase.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/update_owner_usecase.dart';
import 'package:get/get.dart';

part 'owner_state.dart';

class OwnerCubit extends Cubit<OwnerState> {
  OwnerCubit({
    required CreateOwnerUseCase createOwnerUseCase,
    required GetOwnerUseCase getOwnerUseCase,
    required GetAllOwnersUseCase getAllOwnersUseCase,
    required UpdateOwnerUseCase updateOwnerUseCase,
  })  : _createUseCase = createOwnerUseCase,
        _getUseCase = getOwnerUseCase,
        _getAllUseCase = getAllOwnersUseCase,
        _updateUseCase = updateOwnerUseCase,
        super(OwnerInitial());

  final CreateOwnerUseCase _createUseCase;
  final GetOwnerUseCase _getUseCase;
  final GetAllOwnersUseCase _getAllUseCase;
  final UpdateOwnerUseCase _updateUseCase;

  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  Future<void> getAllOwners({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    emit(OwnerLoading());
    final result = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    result.fold(
      (failure) => emit(OwnerFailure(failure.message)),
      (owners) => emit(OwnerListLoaded(owners)),
    );
  }

  Future<void> getOwner(String ownerEmail, {required String moduleId}) async {
    emit(OwnerLoading());
    final result = await _getUseCase.call(ownerEmail, moduleId: moduleId);
    result.fold(
      (failure) => emit(OwnerFailure(failure.message)),
      (owner) => emit(OwnerActionSuccess(owner)),
    );
  }

  Future<void> createOwner({
    required String moduleId,
    required String ownerEmail,
    required List<AssigningControlEntity> assigningControls,
  }) async {
    emit(OwnerLoading());
    final result = await _createUseCase.call(
      CreateOwnerParams(
        moduleId: moduleId,
        ownerEmail: ownerEmail,
        assigningControls: assigningControls,
        editorId: _currentUserEmail,
      ),
    );
    result.fold(
      (failure) => emit(OwnerFailure(failure.message)),
      (owner) => emit(OwnerActionSuccess(owner)),
    );
  }

  Future<void> updateOwner({
    required String ownerEmail,
    required String moduleId,
    List<AssigningControlEntity>? assigningControls,
    List<List<String>>? controlOwnerPermissions,
    OwnerStatus? status,
  }) async {
    emit(OwnerLoading());
    final result = await _updateUseCase.call(
      UpdateOwnerParams(
        ownerEmail: ownerEmail,
        moduleId: moduleId,
        editorId: _currentUserEmail,
        assigningControls: assigningControls,
        controlOwnerPermissions: controlOwnerPermissions,
        status: status,
      ),
    );
    result.fold(
      (failure) => emit(OwnerFailure(failure.message)),
      (owner) => emit(OwnerActionSuccess(owner)),
    );
  }
}
