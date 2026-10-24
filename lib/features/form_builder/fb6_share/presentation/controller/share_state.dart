/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: share_state.dart
/// Description: `ShareState` state, `ShareInitial` state, `ShareLoading` state and 2 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:equatable/equatable.dart';

import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';

abstract class ShareState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShareInitial extends ShareState {}

class ShareLoading extends ShareState {}

class ShareLoaded extends ShareState {
  final List<PersonEntity> persons;
  final List<PersonEntity> filteredPersons;
  final bool isEditPermission;
  final DateTime? timeBegin;
  final DateTime? timeEnd;
  final FormEntity? selectedForm;

  /// The emails already on the form's access list.
  final List<String> sharedEmails;

  /// FB-SHARE-11: true once the access list has been read. Share stays
  /// disabled until then, so people who already have access are never
  /// re-shared with reset dates.
  final bool isAccessListLoaded;

  /// FB-SHARE-11: the translated message shown (with Retry) when the access
  /// list could not be read, or null.
  final String? accessListError;
  final List<PersonEntity> previousSelectedPersons;
  final List<PersonEntity> filteredPreviousSelectedPersons;
  final List<PersonEntity> newSelectedPersons;
  final List<PersonEntity> filteredNewSelectedPersons;
  final String? department;

  /// Multi-select Department filter on the Share screen:
  /// the selected department IDs. Empty = all departments.
  final List<String> departments;

  /// The text in the people search field (the field owns its controller).
  final String searchText;

  ShareLoaded({
    required this.persons,
    required this.filteredPersons,
    required this.isEditPermission,
    this.timeBegin,
    this.timeEnd,
    this.selectedForm,
    this.sharedEmails = const [],
    this.isAccessListLoaded = false,
    this.accessListError,
    required this.previousSelectedPersons,
    required this.filteredPreviousSelectedPersons,
    required this.newSelectedPersons,
    required this.filteredNewSelectedPersons,
    this.department,
    this.departments = const [],
    this.searchText = '',
  });

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given values changed.
  ///
  /// Parameters:
  /// - [persons]: the new value (null keeps the current one).
  /// - [filteredPersons]: the new value (null keeps the current one).
  /// - [isEditPermission]: the new value (null keeps the current one).
  /// - [timeBegin]: the new value (null keeps the current one).
  /// - [timeEnd]: the new value (null keeps the current one).
  /// - [selectedForm]: the new value (null keeps the current one).
  /// - [sharedEmails]: the new value (null keeps the current one).
  /// - [isAccessListLoaded]: the new value (null keeps the current one).
  /// - [accessListError]: the new value (null keeps the current one).
  /// - [previousSelectedPersons]: the new value (null keeps the current one).
  /// - [filteredPreviousSelectedPersons]: the new value (null keeps the current one).
  /// - [newSelectedPersons]: the new value (null keeps the current one).
  /// - [filteredNewSelectedPersons]: the new value (null keeps the current one).
  /// - [department]: the new value (null keeps the current one).
  /// - [departments]: the new value (null keeps the current one).
  /// - [searchText]: the new value (null keeps the current one).
  /// - [clearTimeBegin]: true sets the value to null.
  /// - [clearTimeEnd]: true sets the value to null.
  /// - [clearSelectedForm]: true sets the value to null.
  /// - [clearAccessListError]: true sets the value to null.
  /// - [clearDepartment]: true sets the value to null.
  ///
  /// Returns: the copy.
  ShareLoaded copyWith({
    List<PersonEntity>? persons,
    List<PersonEntity>? filteredPersons,
    bool? isEditPermission,
    DateTime? timeBegin,
    DateTime? timeEnd,
    FormEntity? selectedForm,
    List<String>? sharedEmails,
    bool? isAccessListLoaded,
    String? accessListError,
    List<PersonEntity>? previousSelectedPersons,
    List<PersonEntity>? filteredPreviousSelectedPersons,
    List<PersonEntity>? newSelectedPersons,
    List<PersonEntity>? filteredNewSelectedPersons,
    String? department,
    List<String>? departments,
    String? searchText,
    bool clearTimeBegin = false,
    bool clearTimeEnd = false,
    bool clearSelectedForm = false,
    bool clearAccessListError = false,
    bool clearDepartment = false,
  }) {
    return ShareLoaded(
      persons: persons ?? this.persons,
      filteredPersons: filteredPersons ?? this.filteredPersons,
      isEditPermission: isEditPermission ?? this.isEditPermission,
      timeBegin: clearTimeBegin ? null : (timeBegin ?? this.timeBegin),
      timeEnd: clearTimeEnd ? null : (timeEnd ?? this.timeEnd),
      selectedForm: clearSelectedForm
          ? null
          : (selectedForm ?? this.selectedForm),
      sharedEmails: sharedEmails ?? this.sharedEmails,
      isAccessListLoaded: isAccessListLoaded ?? this.isAccessListLoaded,
      accessListError: clearAccessListError
          ? null
          : (accessListError ?? this.accessListError),
      previousSelectedPersons:
          previousSelectedPersons ?? this.previousSelectedPersons,
      filteredPreviousSelectedPersons:
          filteredPreviousSelectedPersons ??
          this.filteredPreviousSelectedPersons,
      newSelectedPersons: newSelectedPersons ?? this.newSelectedPersons,
      filteredNewSelectedPersons:
          filteredNewSelectedPersons ?? this.filteredNewSelectedPersons,
      department: clearDepartment ? null : (department ?? this.department),
      departments: departments ?? this.departments,
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [
    persons,
    filteredPersons,
    isEditPermission,
    timeBegin,
    timeEnd,
    selectedForm,
    sharedEmails,
    isAccessListLoaded,
    accessListError,
    previousSelectedPersons,
    filteredPreviousSelectedPersons,
    newSelectedPersons,
    filteredNewSelectedPersons,
    department,
    departments,
    searchText,
  ];
}

class ShareError extends ShareState {
  final String message;

  ShareError(this.message);

  @override
  List<Object?> get props => [message];
}
