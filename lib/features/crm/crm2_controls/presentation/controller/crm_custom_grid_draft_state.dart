// ****************** FILE INFO ******************
// File Name: crm_custom_grid_draft_state.dart
// Purpose: Presentation state for mobile CRM Custom Grid view and edit modes
// Author: Mohand Adel
// Created At: 10/10/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';

/// Presentation mode of the Custom Grid screen.
enum CrmCustomGridMode {
  view,
  editing,
}

/// One-shot UI events emitted by the draft controller.
enum CrmCustomGridEvent {
  none,
  limitReached,
  saveFailed,
}

/// Titled group of active template fields.
class CrmCustomGridFieldGroup {
  final String titleEn;
  final String titleAr;
  final List<CrmTemplateFieldModel> fields;

  const CrmCustomGridFieldGroup({
    required this.titleEn,
    required this.titleAr,
    required this.fields,
  });
}

/// Transient presentation state for the Custom Grid mobile experience.
class CrmCustomGridDraftState {
  final CrmCustomGridMode mode;
  final List<String> persistedFieldIds;
  final List<String> draftFieldIds;
  final List<CrmCustomGridFieldGroup> groups;
  final bool isSaving;
  final CrmCustomGridEvent event;
  final String? errorMessage;

  const CrmCustomGridDraftState({
    this.mode = CrmCustomGridMode.view,
    this.persistedFieldIds = const <String>[],
    this.draftFieldIds = const <String>[],
    this.groups = const <CrmCustomGridFieldGroup>[],
    this.isSaving = false,
    this.event = CrmCustomGridEvent.none,
    this.errorMessage,
  });

  /// Function Name: isFieldSelected
  ///
  /// Purpose: Determines whether a field is currently selected based on active mode
  ///
  /// Parameters:
  /// - fieldId: The field identifier to check
  ///
  /// Returns: bool
  bool isFieldSelected(String fieldId) {
    if (mode == CrmCustomGridMode.view) {
      return persistedFieldIds.contains(fieldId);
    }
    return draftFieldIds.contains(fieldId);
  }

  /// Function Name: copyWith
  ///
  /// Purpose: Creates a copy of this state with the given fields replaced
  ///
  /// Parameters:
  /// - mode: The presentation mode
  /// - persistedFieldIds: The persisted custom grid field identifiers
  /// - draftFieldIds: The local draft custom grid field identifiers
  /// - groups: Derived field groups
  /// - isSaving: Whether a save operation is in flight
  /// - event: One-shot event notification
  /// - errorMessage: Optional error message string
  /// - clearError: Whether to clear the error message
  ///
  /// Returns: CrmCustomGridDraftState
  CrmCustomGridDraftState copyWith({
    CrmCustomGridMode? mode,
    List<String>? persistedFieldIds,
    List<String>? draftFieldIds,
    List<CrmCustomGridFieldGroup>? groups,
    bool? isSaving,
    CrmCustomGridEvent? event,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CrmCustomGridDraftState(
      mode: mode ?? this.mode,
      persistedFieldIds: persistedFieldIds ?? this.persistedFieldIds,
      draftFieldIds: draftFieldIds ?? this.draftFieldIds,
      groups: groups ?? this.groups,
      isSaving: isSaving ?? this.isSaving,
      event: event ?? this.event,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
