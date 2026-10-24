/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: forms_group_state.dart
/// Description: `FormsGroupState` state, `FormsGroupInitial` state, `FormsGroupLoading` state and 2 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/entities/group_entity.dart';

abstract class FormsGroupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FormsGroupInitial extends FormsGroupState {}

class FormsGroupLoading extends FormsGroupState {}

class FormsGroupLoaded extends FormsGroupState {
  final List<GroupEntity> groups;
  final List<GroupEntity> filteredGroups;
  final List<PersonEntity> persons;
  final List<PersonEntity> filteredPersons;
  final List<PersonEntity> selectedPersons;
  final List<PersonEntity> filteredSelectedPersons;

  /// The text in the people search field (the field owns its controller).
  final String searchText;
  final String department;
  final GroupEntity? selectedGroup;

  /// The group name and description typed (the fields own their
  /// controllers).
  final String groupName;
  final String groupDescription;

  /// Bumped when the cubit replaces the texts itself (new group, open a
  /// group), so the fields copy the new values in.
  final int fieldsVersion;
  final File? groupImage;

  /// True after a Save / Create attempt — the required group name and
  /// description then show their "required" error when empty.
  final bool submitted;

  /// The active group-list sort option id (null = none). Part of the state
  /// so picking / un-picking it always emits — see FormsGroupCubit.sortGroups.
  final String? groupSort;

  FormsGroupLoaded({
    required this.groups,
    required this.filteredGroups,
    required this.persons,
    required this.filteredPersons,
    required this.selectedPersons,
    required this.filteredSelectedPersons,
    this.searchText = '',
    required this.department,
    this.selectedGroup,
    this.groupName = '',
    this.groupDescription = '',
    this.fieldsVersion = 0,
    this.groupImage,
    this.submitted = false,
    this.groupSort,
  });

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given values changed.
  ///
  /// Parameters:
  /// - [groups]: the new value (null keeps the current one).
  /// - [filteredGroups]: the new value (null keeps the current one).
  /// - [persons]: the new value (null keeps the current one).
  /// - [filteredPersons]: the new value (null keeps the current one).
  /// - [selectedPersons]: the new value (null keeps the current one).
  /// - [filteredSelectedPersons]: the new value (null keeps the current one).
  /// - [searchText]: the new value (null keeps the current one).
  /// - [department]: the new value (null keeps the current one).
  /// - [selectedGroup]: the new value (null keeps the current one).
  /// - [groupName]: the new value (null keeps the current one).
  /// - [groupDescription]: the new value (null keeps the current one).
  /// - [fieldsVersion]: the new value (null keeps the current one).
  /// - [groupImage]: the new value (null keeps the current one).
  /// - [clearGroupImage]: true sets the value to null.
  /// - [clearSelectedGroup]: true sets the value to null.
  /// - [submitted]: the new value (null keeps the current one).
  /// - [groupSort]: the new value (null keeps the current one).
  /// - [clearGroupSort]: true sets the value to null.
  ///
  /// Returns: the copy.
  FormsGroupLoaded copyWith({
    List<GroupEntity>? groups,
    List<GroupEntity>? filteredGroups,
    List<PersonEntity>? persons,
    List<PersonEntity>? filteredPersons,
    List<PersonEntity>? selectedPersons,
    List<PersonEntity>? filteredSelectedPersons,
    String? searchText,
    String? department,
    GroupEntity? selectedGroup,
    String? groupName,
    String? groupDescription,
    int? fieldsVersion,
    File? groupImage,
    bool clearGroupImage = false,
    bool clearSelectedGroup = false,
    bool? submitted,
    String? groupSort,
    bool clearGroupSort = false,
  }) {
    return FormsGroupLoaded(
      groups: groups ?? this.groups,
      filteredGroups: filteredGroups ?? this.filteredGroups,
      persons: persons ?? this.persons,
      filteredPersons: filteredPersons ?? this.filteredPersons,
      selectedPersons: selectedPersons ?? this.selectedPersons,
      filteredSelectedPersons:
          filteredSelectedPersons ?? this.filteredSelectedPersons,
      searchText: searchText ?? this.searchText,
      department: department ?? this.department,
      selectedGroup: clearSelectedGroup
          ? null
          : (selectedGroup ?? this.selectedGroup),
      groupName: groupName ?? this.groupName,
      groupDescription: groupDescription ?? this.groupDescription,
      fieldsVersion: fieldsVersion ?? this.fieldsVersion,
      groupImage: clearGroupImage ? null : (groupImage ?? this.groupImage),
      submitted: submitted ?? this.submitted,
      groupSort: clearGroupSort ? null : (groupSort ?? this.groupSort),
    );
  }

  @override
  List<Object?> get props => [
    groups,
    filteredGroups,
    persons,
    filteredPersons,
    selectedPersons,
    filteredSelectedPersons,
    searchText,
    department,
    selectedGroup,
    groupName,
    groupDescription,
    fieldsVersion,
    groupImage,
    submitted,
    groupSort,
  ];
}

class FormsGroupError extends FormsGroupState {
  final String message;

  FormsGroupError(this.message);

  @override
  List<Object?> get props => [message];
}
