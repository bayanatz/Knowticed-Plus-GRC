// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reasons_state.dart
// Purpose: Immutable UI state for CRM Remove Clients reasons
// Author: Mohand Adel
// Created At: 07/10/2026

class CrmReasonInput {
  final int id;
  final String nameEn;
  final String nameAr;

  const CrmReasonInput({
    required this.id,
    this.nameEn = '',
    this.nameAr = '',
  });

  CrmReasonInput copyWith({String? nameEn, String? nameAr}) => CrmReasonInput(
        id: id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
      );
}

class CrmReasonsState {
  final List<CrmReasonInput> reasons;
  final bool isLoading;
  final bool isSaving;
  final bool hasStoredReasons;
  final String? errorMessage;

  const CrmReasonsState({
    this.reasons = const <CrmReasonInput>[],
    this.isLoading = false,
    this.isSaving = false,
    this.hasStoredReasons = false,
    this.errorMessage,
  });

  CrmReasonsState copyWith({
    List<CrmReasonInput>? reasons,
    bool? isLoading,
    bool? isSaving,
    bool? hasStoredReasons,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CrmReasonsState(
        reasons: reasons ?? this.reasons,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        hasStoredReasons: hasStoredReasons ?? this.hasStoredReasons,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
