// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_type_form_state.dart
// Purpose: Immutable editing state for a CRM team type
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';

/// Represents editable data, validation errors, and save status for one type.
class CrmTeamTypeFormState {
  final CrmTeamType teamType;
  final List<CrmTeamType> existingTypes;
  final bool isSaving;
  final String? nameEnError;
  final String? nameArError;
  final String? errorMessage;

  const CrmTeamTypeFormState({
    required this.teamType,
    this.existingTypes = const <CrmTeamType>[],
    this.isSaving = false,
    this.nameEnError,
    this.nameArError,
    this.errorMessage,
  });

  /// Returns a state copy while allowing validation fields to be cleared.
  CrmTeamTypeFormState copyWith({
    CrmTeamType? teamType,
    List<CrmTeamType>? existingTypes,
    bool? isSaving,
    String? nameEnError,
    String? nameArError,
    String? errorMessage,
    bool clearNameEnError = false,
    bool clearNameArError = false,
    bool clearError = false,
  }) =>
      CrmTeamTypeFormState(
        teamType: teamType ?? this.teamType,
        existingTypes: existingTypes ?? this.existingTypes,
        isSaving: isSaving ?? this.isSaving,
        nameEnError: clearNameEnError ? null : nameEnError ?? this.nameEnError,
        nameArError: clearNameArError ? null : nameArError ?? this.nameArError,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
