// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reasons_cubit.dart
// Purpose: Owns CRM reason-set stream, validation, and save mutations
// Author: Mohand Adel
// Created At: 07/10/2026

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/domain/entities/crm_reason.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/domain/interfaces/crm_reasons_base_repository.dart';

import 'package:knowticed_plus/features/crm/crm15_reasons/presentation/controller/crm_reasons_state.dart';

class CrmReasonsCubit extends Cubit<CrmReasonsState> {
  final CrmReasonsBaseRepository _repository;
  final String _reasonSetId;
  StreamSubscription<List<CrmReason>>? _subscription;
  int _nextId = 0;
  List<CrmReason> _storedReasons = <CrmReason>[];

  CrmReasonsCubit({
    required CrmReasonsBaseRepository repository,
    required String reasonSetId,
  })  : _repository = repository,
        _reasonSetId = reasonSetId,
        super(const CrmReasonsState());

  void init() {
    emit(state.copyWith(isLoading: true, clearError: true));
    _subscription = _repository.watchReasons(_reasonSetId).listen(
      (List<CrmReason> reasons) {
        if (!isClosed) {
          _storedReasons = reasons;
          emit(state.copyWith(
            reasons: _toInputs(reasons),
            hasStoredReasons: reasons.isNotEmpty,
            isLoading: false,
          ));
        }
      },
      onError: (Object error) {
        if (!isClosed) {
          emit(
              state.copyWith(isLoading: false, errorMessage: error.toString()));
        }
      },
    );
  }

  void addReason() => emit(state.copyWith(
        reasons: <CrmReasonInput>[
          ...state.reasons,
          CrmReasonInput(id: _nextId++),
        ],
      ));

  void removeReason(int id) {
    if (state.reasons.length <= 1) return;
    emit(state.copyWith(
      reasons:
          state.reasons.where((CrmReasonInput item) => item.id != id).toList(),
    ));
  }

  void updateReasonEn(int id, String value) => _updateReason(id, nameEn: value);
  void updateReasonAr(int id, String value) => _updateReason(id, nameAr: value);
  void clearError() => emit(state.copyWith(clearError: true));
  void discardEdits() =>
      emit(state.copyWith(reasons: _toInputs(_storedReasons)));

  Future<bool> save() async {
    final List<CrmReason> reasons = state.reasons
        .where((CrmReasonInput item) =>
            item.nameEn.trim().isNotEmpty || item.nameAr.trim().isNotEmpty)
        .map((CrmReasonInput item) => CrmReason(
              nameEn: item.nameEn.trim(),
              nameAr: item.nameAr.trim(),
            ))
        .toList();
    if (reasons.isEmpty ||
        reasons.any(
            (CrmReason item) => item.nameEn.isEmpty || item.nameAr.isEmpty)) {
      emit(state.copyWith(
          errorMessage: 'Each reason requires English and Arabic text.'));
      return false;
    }
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.saveReasons(
        reasonSetId: _reasonSetId,
        reasons: reasons,
        updatedBy: _currentUserEmail,
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

  void _updateReason(int id, {String? nameEn, String? nameAr}) {
    emit(state.copyWith(
      reasons: state.reasons
          .map((CrmReasonInput item) => item.id == id
              ? item.copyWith(nameEn: nameEn, nameAr: nameAr)
              : item)
          .toList(),
    ));
  }

  List<CrmReasonInput> _toInputs(List<CrmReason> reasons) {
    final List<CrmReason> source = reasons.isEmpty
        ? List<CrmReason>.generate(
            1,
            (int _) => const CrmReason(nameEn: '', nameAr: ''),
          )
        : reasons;
    return source
        .map((CrmReason item) => CrmReasonInput(
              id: _nextId++,
              nameEn: item.nameEn,
              nameAr: item.nameAr,
            ))
        .toList();
  }

  String get _currentUserEmail {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final String? email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    return 'system';
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
