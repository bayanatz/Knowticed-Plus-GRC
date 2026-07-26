/// Module: Control Champion Management
/// Description: BLoC Cubit that manages Control Champion state for the
///              presentation layer, mirroring PolicyCubit's shape.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, use cases, ChampionEntity, AssigningControlEntity

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/create_champion_usecase.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/get_champion_usecases.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/update_champion_usecase.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_request_resolver.dart';
import 'package:demo_app/features/grc/control_champion/domain/use_cases/apply_champion_reassignment_usecase.dart';
import 'package:demo_app/features/grc/grc_request/domain/use_cases/get_grc_requests_usecase.dart';
import 'package:get/get.dart';

part 'champion_state.dart';

class ChampionCubit extends Cubit<ChampionState> {
  ChampionCubit({
    required CreateChampionUseCase createChampionUseCase,
    required GetChampionUseCase getChampionUseCase,
    required GetAllChampionsUseCase getAllChampionsUseCase,
    required UpdateChampionUseCase updateChampionUseCase,
    required GetGrcRequestsUseCase getGrcRequestsUseCase,
    required ApplyChampionReassignmentUseCase applyChampionReassignmentUseCase,
  })  : _createUseCase = createChampionUseCase,
        _getUseCase = getChampionUseCase,
        _getAllUseCase = getAllChampionsUseCase,
        _updateUseCase = updateChampionUseCase,
        _getGrcRequestsUseCase = getGrcRequestsUseCase,
        _applyReassignmentUseCase = applyChampionReassignmentUseCase,
        super(ChampionInitial());

  final CreateChampionUseCase _createUseCase;
  final GetChampionUseCase _getUseCase;
  final GetAllChampionsUseCase _getAllUseCase;
  final UpdateChampionUseCase _updateUseCase;
  final GetGrcRequestsUseCase _getGrcRequestsUseCase;
  final ApplyChampionReassignmentUseCase _applyReassignmentUseCase;

  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  Future<void> getAllChampions({
    required String moduleId,
    bool includeRemoved = false,
  }) async {
    emit(ChampionLoading());
    await _applyDueReassignments(moduleId);
    await _stripExpiredControls(moduleId, includeRemoved: includeRemoved);
    final result = await _getAllUseCase.call(
      moduleId: moduleId,
      includeRemoved: includeRemoved,
    );
    result.fold(
      (failure) => emit(ChampionFailure(failure.message)),
      (champions) => emit(ChampionListLoaded(champions)),
    );
  }

  Future<void> _applyDueReassignments(String moduleId) async {
    final requestsResult = await _getGrcRequestsUseCase.call(moduleId);
    await requestsResult.fold(
      (_) async {}, // no requests fetched — nothing to apply, champion list still loads
      (requests) async {
        final due = findDueReassignmentRequests(requests);
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
      (champions) async {
        for (final champion in champions) {
          final expired = findExpiredControls(champion.assigningControls);
          if (expired.isEmpty) continue;
          final remaining = champion.assigningControls.where((ac) {
            return !expired.any(
              (ex) => ex.policyId == ac.policyId && ex.controlId == ac.controlId,
            );
          }).toList();
          await _updateUseCase.call(
            UpdateChampionParams(
              championEmail: champion.championEmail,
              moduleId: moduleId,
              editorId: _currentUserEmail,
              assigningControls: remaining,
              status: remaining.isEmpty ? ChampionStatus.removed : null,
            ),
          );
        }
      },
    );
  }

  Future<void> getChampion(String championEmail, {required String moduleId}) async {
    emit(ChampionLoading());
    final result = await _getUseCase.call(championEmail, moduleId: moduleId);
    result.fold(
      (failure) => emit(ChampionFailure(failure.message)),
      (champion) => emit(ChampionActionSuccess(champion)),
    );
  }

  Future<void> createChampion({
    required String moduleId,
    required String championEmail,
    required List<AssigningControlEntity> assigningControls,
  }) async {
    emit(ChampionLoading());
    final result = await _createUseCase.call(
      CreateChampionParams(
        moduleId: moduleId,
        championEmail: championEmail,
        assigningControls: assigningControls,
        editorId: _currentUserEmail,
      ),
    );
    result.fold(
      (failure) => emit(ChampionFailure(failure.message)),
      (champion) => emit(ChampionActionSuccess(champion)),
    );
  }

  Future<void> updateChampion({
    required String championEmail,
    required String moduleId,
    List<AssigningControlEntity>? assigningControls,
    ChampionStatus? status,
  }) async {
    emit(ChampionLoading());
    final result = await _updateUseCase.call(
      UpdateChampionParams(
        championEmail: championEmail,
        moduleId: moduleId,
        editorId: _currentUserEmail,
        assigningControls: assigningControls,
        status: status,
      ),
    );
    result.fold(
      (failure) => emit(ChampionFailure(failure.message)),
      (champion) => emit(ChampionActionSuccess(champion)),
    );
  }
}
