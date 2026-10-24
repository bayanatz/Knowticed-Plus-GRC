// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_form_state.dart
// Purpose: Immutable transient state for the conversion-stage form
// Author: Mohand Adel
// Created At: 07/10/2026

class CrmConvertChecklistInput {
  final int id;
  final String nameEn;
  final String nameAr;

  const CrmConvertChecklistInput({
    required this.id,
    this.nameEn = '',
    this.nameAr = '',
  });

  CrmConvertChecklistInput copyWith({String? nameEn, String? nameAr}) =>
      CrmConvertChecklistInput(
        id: id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
      );
}

class CrmConvertFormState {
  final int selectedOrder;
  final List<CrmConvertChecklistInput> checklist;
  final String? nameEnError;
  final String? nameArError;
  final bool isSubmitting;

  const CrmConvertFormState({
    this.selectedOrder = 1,
    this.checklist = const <CrmConvertChecklistInput>[],
    this.nameEnError,
    this.nameArError,
    this.isSubmitting = false,
  });

  CrmConvertFormState copyWith({
    int? selectedOrder,
    List<CrmConvertChecklistInput>? checklist,
    String? nameEnError,
    String? nameArError,
    bool clearNameEnError = false,
    bool clearNameArError = false,
    bool? isSubmitting,
  }) =>
      CrmConvertFormState(
        selectedOrder: selectedOrder ?? this.selectedOrder,
        checklist: checklist ?? this.checklist,
        nameEnError: clearNameEnError ? null : nameEnError ?? this.nameEnError,
        nameArError: clearNameArError ? null : nameArError ?? this.nameArError,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}
