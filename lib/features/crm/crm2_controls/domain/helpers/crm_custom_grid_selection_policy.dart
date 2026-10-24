// ****************** FILE INFO ******************
// File Name: crm_custom_grid_selection_policy.dart
// Purpose: Validates the persisted custom grid field selection limit.
// Author: Mohand Adel
// Created At: 06/10/2026

/// Shared guard for the Custom Grid configuration.
///
/// UI controls use this policy for immediate feedback, while the data source
/// uses it again before persisting an update.
abstract final class CrmCustomGridSelectionPolicy {
  static const int maximumFields = 4;

  static String? validationError(List<String> fieldIds) {
    if (fieldIds.length > maximumFields) {
      return 'Maximum $maximumFields custom grid fields can be selected.';
    }

    final Set<String> uniqueIds = <String>{};
    for (final String fieldId in fieldIds) {
      final String normalizedId = fieldId.trim();
      if (normalizedId.isEmpty) {
        return 'Custom grid field ids cannot be empty.';
      }
      if (!uniqueIds.add(normalizedId)) {
        return 'Custom grid fields cannot be duplicated.';
      }
    }
    return null;
  }

  static String? availabilityError({
    required List<String> fieldIds,
    required Set<String> availableFieldIds,
  }) {
    if (fieldIds
        .any((String fieldId) => !availableFieldIds.contains(fieldId))) {
      return 'Selected custom grid fields are no longer available.';
    }
    return null;
  }
}
