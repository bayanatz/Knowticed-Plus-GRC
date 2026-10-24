/// Module: services / sv2_create_single_services / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: provider_selection_state.dart
/// Purpose: Provider selection state — declares ProviderSelectionState,
///          ProviderSelectionInitial, ProviderSelectionLoading,
///          ProviderSelectionLoaded.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/sv2_create_single_services/data/models/provider_selection_data.dart';

abstract class ProviderSelectionState {
  const ProviderSelectionState();
}

class ProviderSelectionInitial extends ProviderSelectionState {
  const ProviderSelectionInitial();
}

class ProviderSelectionLoading extends ProviderSelectionState {
  const ProviderSelectionLoading();
}

class ProviderSelectionLoaded extends ProviderSelectionState {
  final ProviderSelectionData data;
  final List<EmployeeEntityPro> allEmployees;
  final List<EmployeeEntityPro> filteredEmployees;
  final String searchQuery;

  /// SVC-CREATE-08 / SVC-HOME-12: true when the employee list or their role
  /// permissions could not be loaded; the grid shows an error with Retry
  /// instead of an empty list.
  final bool loadError;

  const ProviderSelectionLoaded({
    required this.data,
    required this.allEmployees,
    required this.filteredEmployees,
    this.searchQuery = '',
    this.loadError = false,
  });

  ProviderSelectionLoaded copyWith({
    ProviderSelectionData? data,
    List<EmployeeEntityPro>? allEmployees,
    List<EmployeeEntityPro>? filteredEmployees,
    String? searchQuery,
    bool? loadError,
  }) {
    return ProviderSelectionLoaded(
      data: data ?? this.data,
      allEmployees: allEmployees ?? this.allEmployees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      searchQuery: searchQuery ?? this.searchQuery,
      loadError: loadError ?? this.loadError,
    );
  }
}

/// What went wrong — the page shows the translated text for it (Create R3).
enum ProviderSelectionIssue {
  draftSaveFailed,
  providerUpdateFailed,
  unexpected,
}

class ProviderSelectionError extends ProviderSelectionState {
  final ProviderSelectionIssue issue;

  /// English detail for logs only — never shown to the user.
  final String message;
  const ProviderSelectionError(this.issue, [this.message = '']);
}

class ProviderSelectionSaved extends ProviderSelectionState {
  const ProviderSelectionSaved();
}

/// 🔥 NEW: State for when draft is being saved to Firebase
/// 🔥 NEW: State for when draft is being saved to Firebase
class ProviderSelectionSaving extends ProviderSelectionState {
  final ProviderSelectionData data;
  final List<EmployeeEntityPro> allEmployees;

  const ProviderSelectionSaving({
    required this.data,
    required this.allEmployees,
  });
}

/// 🔥 NEW: State for when draft is successfully saved to Firebase
class ProviderSelectionSavedToFirebase extends ProviderSelectionState {
  final String draftId;

  const ProviderSelectionSavedToFirebase({required this.draftId});
}

class ProviderSelectionNavigateToDetails extends ProviderSelectionState {
  final ServicesHistoryModel completeModel;
  final String? docId;

  const ProviderSelectionNavigateToDetails({
    required this.completeModel,
    this.docId,
  });
}

class ProviderSelectionNavigateBack extends ProviderSelectionState {
  const ProviderSelectionNavigateBack();
}

class ProviderSelectionShowWarning extends ProviderSelectionState {
  final String message;
  const ProviderSelectionShowWarning(this.message);
}

class ProviderSelectionProviderUpdated extends ProviderSelectionState {
  const ProviderSelectionProviderUpdated();
}
