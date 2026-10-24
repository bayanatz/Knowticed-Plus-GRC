// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_form_cubit.dart
// Purpose: Manages conversion-stage form validation and checklist input state
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/domain/entities/crm_convert_stage.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/presentation/controller/crm_convert_cubit.dart';

import 'package:knowticed_plus/features/crm/crm14_convert/presentation/controller/crm_convert_form_state.dart';

class CrmConvertFormCubit extends Cubit<CrmConvertFormState> {
  final CrmConvertCubit _convertCubit;
  int _nextChecklistId = 0;

  CrmConvertFormCubit(this._convertCubit) : super(const CrmConvertFormState());

  void prepare(CrmConvertStage? stage) {
    final List<CrmConvertChecklistInput> checklist =
        stage?.checklistItems.isNotEmpty == true
            ? stage!.checklistItems
                .map((CrmConvertChecklistItem item) => CrmConvertChecklistInput(
                      id: _nextChecklistId++,
                      nameEn: item.nameEn,
                      nameAr: item.nameAr,
                    ))
                .toList()
            : <CrmConvertChecklistInput>[
                CrmConvertChecklistInput(id: _nextChecklistId++)
              ];
    emit(CrmConvertFormState(
      selectedOrder: stage?.order ?? _convertCubit.state.stages.length + 1,
      checklist: checklist,
    ));
  }

  void selectOrder(int value) => emit(state.copyWith(selectedOrder: value));
  void addChecklistItem() => emit(state.copyWith(
        checklist: <CrmConvertChecklistInput>[
          ...state.checklist,
          CrmConvertChecklistInput(id: _nextChecklistId++),
        ],
      ));
  void removeChecklistItem(int id) {
    if (state.checklist.length <= 1) return;
    emit(state.copyWith(
      checklist: state.checklist
          .where((CrmConvertChecklistInput item) => item.id != id)
          .toList(),
    ));
  }

  void updateChecklistNameEn(int id, String value) =>
      _updateItem(id, nameEn: value);
  void updateChecklistNameAr(int id, String value) =>
      _updateItem(id, nameAr: value);
  void clearNameEnError() => emit(state.copyWith(clearNameEnError: true));
  void clearNameArError() => emit(state.copyWith(clearNameArError: true));

  Future<bool> submit({
    required CrmConvertStage? existing,
    required String nameEn,
    required String nameAr,
    String? status,
  }) async {
    final String? nameEnError =
        nameEn.trim().isEmpty ? 'This field is required' : null;
    final String? nameArError =
        nameAr.trim().isEmpty ? 'هذا الحقل مطلوب' : null;
    if (nameEnError != null || nameArError != null) {
      emit(state.copyWith(
        nameEnError: nameEnError,
        nameArError: nameArError,
        clearNameEnError: nameEnError == null,
        clearNameArError: nameArError == null,
      ));
      return false;
    }
    emit(state.copyWith(isSubmitting: true));
    final List<CrmConvertChecklistItem> checklist = state.checklist
        .where((CrmConvertChecklistInput item) =>
            item.nameEn.trim().isNotEmpty || item.nameAr.trim().isNotEmpty)
        .map((CrmConvertChecklistInput item) => CrmConvertChecklistItem(
              nameEn: item.nameEn.trim(),
              nameAr: item.nameAr.trim(),
            ))
        .toList();
    final bool saved = await _convertCubit.saveStage(
      existing: existing,
      nameEn: nameEn,
      nameAr: nameAr,
      order: state.selectedOrder,
      checklistItems: checklist,
      status: status,
    );
    if (!isClosed) emit(state.copyWith(isSubmitting: false));
    return saved;
  }

  void _updateItem(int id, {String? nameEn, String? nameAr}) {
    emit(state.copyWith(
      checklist: state.checklist
          .map((CrmConvertChecklistInput item) => item.id == id
              ? item.copyWith(nameEn: nameEn, nameAr: nameAr)
              : item)
          .toList(),
    ));
  }
}
