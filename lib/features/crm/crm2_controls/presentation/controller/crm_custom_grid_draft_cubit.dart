// ****************** FILE INFO ******************
// File Name: crm_custom_grid_draft_cubit.dart
// Purpose: Presentation controller for mobile Custom Grid view, draft editing, and persistence lifecycle
// Author: Mohand Adel
// Created At: 10/10/2026

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/helpers/crm_custom_grid_selection_policy.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_custom_grid_draft_state.dart';

class CrmCustomGridDraftCubit extends Cubit<CrmCustomGridDraftState> {
  final Future<bool> Function(List<String> fieldIds) saveCallback;

  CrmCustomGridDraftCubit({
    required this.saveCallback,
    CrmCustomGridDraftState? initialState,
  }) : super(initialState ?? const CrmCustomGridDraftState());

  /// Function Name: syncTemplateData
  ///
  /// Purpose: Synchronizes template data, builds field groups, and updates persisted selections
  ///
  /// Parameters:
  /// - template: The active template model
  /// - fields: The list of template fields
  /// - sections: The list of template sections
  ///
  /// Returns: void
  void syncTemplateData({
    required CrmTemplateModel? template,
    required List<CrmTemplateFieldModel> fields,
    required List<CrmTemplateSectionModel> sections,
  }) {
    if (template == null) return;

    final List<CrmCustomGridFieldGroup> groups = _buildFieldGroups(
      templateId: template.id,
      fields: fields,
      sections: sections,
    );

    final List<String> persisted = List<String>.unmodifiable(
      template.customGridFieldIds,
    );

    final bool isEditing = state.mode == CrmCustomGridMode.editing;
    emit(
      state.copyWith(
        groups: groups,
        persistedFieldIds: persisted,
        draftFieldIds: isEditing ? state.draftFieldIds : persisted,
      ),
    );
  }

  /// Function Name: enterEditMode
  ///
  /// Purpose: Enters edit mode, initializing the local draft from persisted identifiers
  ///
  /// Returns: void
  void enterEditMode() {
    if (state.mode == CrmCustomGridMode.editing) return;
    emit(
      state.copyWith(
        mode: CrmCustomGridMode.editing,
        draftFieldIds: List<String>.from(state.persistedFieldIds),
        event: CrmCustomGridEvent.none,
        clearError: true,
      ),
    );
  }

  /// Function Name: discardChanges
  ///
  /// Purpose: Resets local draft to persisted selection and returns to view mode
  ///
  /// Returns: void
  void discardChanges() {
    emit(
      state.copyWith(
        mode: CrmCustomGridMode.view,
        draftFieldIds: List<String>.from(state.persistedFieldIds),
        event: CrmCustomGridEvent.none,
        clearError: true,
      ),
    );
  }

  /// Function Name: toggleField
  ///
  /// Purpose: Toggles a field selection in edit mode, enforcing maximum limit
  ///
  /// Parameters:
  /// - fieldId: The field identifier being toggled
  /// - enabled: Target selection state
  ///
  /// Returns: void
  void toggleField(String fieldId, bool enabled) {
    if (state.mode != CrmCustomGridMode.editing || state.isSaving) return;

    if (enabled) {
      _enableField(fieldId);
    } else {
      _disableField(fieldId);
    }
  }

  /// Function Name: _enableField
  ///
  /// Purpose: Adds a field identifier if limit allows; emits limitReached otherwise
  ///
  /// Parameters:
  /// - fieldId: The field identifier to add
  ///
  /// Returns: void
  void _enableField(String fieldId) {
    if (state.draftFieldIds.contains(fieldId)) return;

    if (state.draftFieldIds.length >=
        CrmCustomGridSelectionPolicy.maximumFields) {
      emit(state.copyWith(event: CrmCustomGridEvent.limitReached));
      return;
    }

    final List<String> updatedDraft = <String>[
      ...state.draftFieldIds,
      fieldId,
    ];
    emit(
      state.copyWith(
        draftFieldIds: updatedDraft,
        event: CrmCustomGridEvent.none,
      ),
    );
  }

  /// Function Name: _disableField
  ///
  /// Purpose: Removes a field identifier from the draft selection
  ///
  /// Parameters:
  /// - fieldId: The field identifier to remove
  ///
  /// Returns: void
  void _disableField(String fieldId) {
    final List<String> updatedDraft =
        state.draftFieldIds.where((String id) => id != fieldId).toList();
    emit(
      state.copyWith(
        draftFieldIds: updatedDraft,
        event: CrmCustomGridEvent.none,
      ),
    );
  }

  /// Function Name: submitDraft
  ///
  /// Purpose: Validates and persists the local draft via the save callback
  ///
  /// Returns: `Future<bool>`
  Future<bool> submitDraft() async {
    if (state.isSaving || state.mode != CrmCustomGridMode.editing) {
      return false;
    }

    emit(
      state.copyWith(
        isSaving: true,
        event: CrmCustomGridEvent.none,
        clearError: true,
      ),
    );

    final bool success = await saveCallback(state.draftFieldIds);
    if (isClosed) return success;

    if (success) {
      emit(
        state.copyWith(
          mode: CrmCustomGridMode.view,
          persistedFieldIds: List<String>.from(state.draftFieldIds),
          isSaving: false,
          event: CrmCustomGridEvent.none,
        ),
      );
      return true;
    }

    emit(
      state.copyWith(
        isSaving: false,
        event: CrmCustomGridEvent.saveFailed,
      ),
    );
    return false;
  }

  /// Function Name: clearEvent
  ///
  /// Purpose: Clears any one-shot UI event flag
  ///
  /// Returns: void
  void clearEvent() {
    if (state.event != CrmCustomGridEvent.none) {
      emit(state.copyWith(event: CrmCustomGridEvent.none));
    }
  }

  /// Function Name: _buildFieldGroups
  ///
  /// Purpose: Constructs ordered field groups from active template fields and sections
  ///
  /// Parameters:
  /// - templateId: Active template identifier
  /// - fields: All template fields
  /// - sections: All template sections
  ///
  /// Returns: `List<CrmCustomGridFieldGroup>`
  List<CrmCustomGridFieldGroup> _buildFieldGroups({
    required String templateId,
    required List<CrmTemplateFieldModel> fields,
    required List<CrmTemplateSectionModel> sections,
  }) {
    final List<CrmTemplateFieldModel> activeFields = fields
        .where((CrmTemplateFieldModel f) =>
            !f.isDeleted &&
            f.status.toLowerCase() != 'deleted' &&
            f.templateId == templateId)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final List<CrmCustomGridFieldGroup> groups = <CrmCustomGridFieldGroup>[];

    final List<CrmTemplateFieldModel> standalone = activeFields
        .where((CrmTemplateFieldModel f) =>
            f.sectionId == null || f.sectionId!.isEmpty)
        .toList();

    if (standalone.isNotEmpty) {
      groups.add(
        CrmCustomGridFieldGroup(
          titleEn: 'Fields',
          titleAr: 'حقول',
          fields: standalone,
        ),
      );
    }

    final List<CrmTemplateSectionModel> activeSections = sections
        .where((CrmTemplateSectionModel s) =>
            !s.isDeleted && s.status.toLowerCase() != 'deleted')
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    for (final CrmTemplateSectionModel section in activeSections) {
      final List<CrmTemplateFieldModel> sectionFields = activeFields
          .where((CrmTemplateFieldModel f) => f.sectionId == section.id)
          .toList();

      if (sectionFields.isNotEmpty) {
        groups.add(
          CrmCustomGridFieldGroup(
            titleEn: section.nameEn,
            titleAr: section.nameAr,
            fields: sectionFields,
          ),
        );
      }
    }

    return groups;
  }
}
