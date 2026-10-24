// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_cubit.dart
// Purpose: Owns conversion-stage CRUD, validation, filtering, and sorting
// Author: Mohand Adel
// Created At: 07/10/2026

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/domain/entities/crm_convert_stage.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/domain/interfaces/crm_convert_base_repository.dart';

import 'package:knowticed_plus/features/crm/crm14_convert/presentation/controller/crm_convert_state.dart';

class CrmConvertCubit extends Cubit<CrmConvertState> {
  final CrmConvertBaseRepository _repository;
  StreamSubscription<List<CrmConvertStage>>? _subscription;

  CrmConvertCubit({
    required CrmConvertBaseRepository repository,
  })  : _repository = repository,
        super(const CrmConvertState());

  void init() {
    emit(state.copyWith(isLoading: true, clearError: true));
    _subscription = _repository.watchStages().listen(
      (List<CrmConvertStage> stages) {
        if (!isClosed) emit(state.copyWith(stages: stages, isLoading: false));
      },
      onError: (Object error) {
        if (!isClosed) {
          emit(
              state.copyWith(isLoading: false, errorMessage: error.toString()));
        }
      },
    );
  }

  void search(String value) => emit(state.copyWith(searchQuery: value.trim()));
  void setStatus(String value) => emit(state.copyWith(selectedStatus: value));
  void setSort(String? value) => emit(state.copyWith(selectedSort: value));
  void clearError() => emit(state.copyWith(clearError: true));

  Future<bool> saveStage({
    CrmConvertStage? existing,
    required String nameEn,
    required String nameAr,
    required int order,
    required List<CrmConvertChecklistItem> checklistItems,
    String? status,
  }) async {
    if (nameEn.trim().isEmpty || nameAr.trim().isEmpty) {
      emit(state.copyWith(
          errorMessage: nameEn.trim().isEmpty
              ? 'This field is required'
              : 'هذا الحقل مطلوب'));
      return false;
    }
    emit(state.copyWith(isSaving: true, clearError: true));
    final DateTime now = DateTime.now();
    final String stageStatus = status ?? existing?.status ?? 'active';
    final CrmConvertStage stage = existing == null
        ? CrmConvertStage(
            id: '',
            nameEn: nameEn.trim(),
            nameAr: nameAr.trim(),
            status: stageStatus,
            order: order,
            checklistItems: checklistItems,
            updatedAt: now,
            updatedBy: _currentUserName,
          )
        : existing.copyWith(
            nameEn: nameEn.trim(),
            nameAr: nameAr.trim(),
            status: stageStatus,
            order: order,
            checklistItems: checklistItems,
            updatedAt: now,
            updatedBy: _currentUserName,
          );
    try {
      if (existing == null) {
        await _repository.createStage(stage);
      } else {
        await _repository.updateStage(stage);
      }
      if (!isClosed) emit(state.copyWith(isSaving: false));
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      }
      return false;
    }
  }

  Future<bool> updateStatus(CrmConvertStage stage, String status) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.updateStage(
        stage.copyWith(
          status: status,
          updatedAt: DateTime.now(),
          updatedBy: _currentUserName,
        ),
      );
      if (!isClosed) emit(state.copyWith(isSaving: false));
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      }
      return false;
    }
  }

  Future<bool> deleteStage(CrmConvertStage stage) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.deleteStage(
        stage.copyWith(updatedAt: DateTime.now(), updatedBy: _currentUserName),
      );
      if (!isClosed) emit(state.copyWith(isSaving: false));
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      }
      return false;
    }
  }

  String get _currentUserName {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final employee = Get.find<MainCoreEmployeeController>().employeeEntity;
      final String fullName = <String?>[
        employee?.firstName,
        employee?.lastName,
      ].whereType<String>().where((String s) => s.trim().isNotEmpty).join(' ');
      if (fullName.isNotEmpty) {
        return fullName;
      }
      final String? email = employee?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    return 'Aya Ali';
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
