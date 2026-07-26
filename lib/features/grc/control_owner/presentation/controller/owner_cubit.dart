/// Module: Control Owner Management
/// Description: BLoC Cubit that manages Control Owner state for the
///              presentation layer, mirroring ChampionCubit's shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, use cases, OwnerEntity, AssigningControlEntity

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_request_resolver.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_status.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/apply_owner_reassignment_usecase.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/create_owner_usecase.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/get_owner_usecases.dart';
import 'package:demo_app/features/grc/control_owner/domain/use_cases/update_owner_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart';
import 'package:get/get.dart';

part 'owner_state.dart';

class OwnerCubit extends Cubit<OwnerState> {
  OwnerCubit({
    required CreateOwnerUseCase createOwnerUseCase,
    required GetOwnerUseCase getOwnerUseCase,
    required GetAllOwnersUseCase getAllOwnersUseCase,
    required UpdateOwnerUseCase updateOwnerUseCase,
    required GetGrcRequestsUseCase getGrcRequestsUseCase,
    required ApplyOwnerReassignmentUseCase applyOwnerReassignmentUseCase,
  })  : _createUseCase = createOwnerUseCase,
        _getUseCase = getOwnerUseCase,
        _getAllUseCase = getAllOwnersUseCase,
        _updateUseCase = updateOwnerUseCase,
        _getGrcRequestsUseCase = getGrcRequestsUseCase,
        _applyReassignmentUseCase = applyOwnerReassignmentUseCase,
        super(OwnerInitial());

  final CreateOwnerUseCase _createUseCase;
  final GetOwnerUseCase _getUseCase;
  final GetAllOwnersUseCase _getAllUseCase;
  final UpdateOwnerUseCase _updateUseCase;
  final GetGrcRequestsUseCase _getGrcRequestsUseCase;
  final ApplyOwnerReassignmentUseCase _applyReassignmentUseCase;

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
    await _applyDueReassignments(moduleId);
    await _stripExpiredControls(moduleId, includeRemoved: includeRemoved);
    final result = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    result.fold(
      (failure) => emit(OwnerFailure(failure.message)),
      (owners) => emit(OwnerListLoaded(owners)),
    );
  }

  Future<void> _applyDueReassignments(String moduleId) async {
    final requestsResult = await _getGrcRequestsUseCase.call(moduleId);
    await requestsResult.fold(
      (_) async {}, // no requests fetched — nothing to apply, owner list still loads
      (requests) async {
        final due = findDueReassignmentRequests(
          requests,
          type: GrcRequestType.reassignOwner,
        );
        for (final request in due) {
          await _applyReassignmentUseCase.call(request);
        }
      },
    );
  }

  Future<void> _stripExpiredControls(
    String moduleId, {
    required bool includeRemoved,
  }) async {
    final currentResult = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    await currentResult.fold(
      (_) async {},
      (owners) async {
        for (final owner in owners) {
          final expired = findExpiredControls(owner.assigningControls);
          if (expired.isEmpty) continue;
          final remaining = owner.assigningControls.where((ac) {
            return !expired.any(
              (ex) => ex.policyId == ac.policyId && ex.controlId == ac.controlId,
            );
          }).toList();
          await _updateUseCase.call(
            UpdateOwnerParams(
              ownerEmail: owner.ownerEmail,
              moduleId: moduleId,
              editorId: _currentUserEmail,
              assigningControls: remaining,
              status: remaining.isEmpty ? OwnerStatus.removed : null,
            ),
          );
        }
      },
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
