/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: create_form_data_state.dart
/// Description: `CreateFormDataState` state, `CreateFormDataInitial` state, `CreateFormDataLoading` state and 2 more.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/presentation/controller/fields/page_controller_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/department_entity.dart';

abstract class CreateFormDataState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateFormDataInitial extends CreateFormDataState {}

class CreateFormDataLoading extends CreateFormDataState {}

class CreateFormDataLoaded extends CreateFormDataState {
  final List<PageControllerModel> pages;
  final int? expandedPageIndex;
  final List<DepartmentEntity> departmentsShown;
  final List<PersonEntity> personList;
  final List<PersonEntity> shownPersonList;
  final List<PersonEntity> selectedPersonList;
  final DateTime? timeBegin;
  final DateTime? timeEnd;
  final bool isEdit;
  final List<Color> savedColors;
  final String? selectedDepartment;
  final String? currentPersonDepartment;
  final String? textSearch;
  final int version;
  final String? existingFormId;
  final DateTime? existingCreateDate;

  /// Bumped each time a structure change is refused because the form
  /// already has answers; the editor page shows the message.
  final int structureLockedNotice;

  CreateFormDataLoaded({
    required this.pages,
    this.expandedPageIndex,
    required this.departmentsShown,
    required this.personList,
    required this.shownPersonList,
    required this.selectedPersonList,
    this.timeBegin,
    this.timeEnd,
    required this.isEdit,
    required this.savedColors,
    this.selectedDepartment,
    this.currentPersonDepartment,
    this.textSearch,
    this.version = 0,
    this.existingFormId,
    this.existingCreateDate,
    this.structureLockedNotice = 0,
  });

  /// Method Name: [copyWith]
  ///
  /// Purpose: a copy with the given values changed.
  ///
  /// Parameters:
  /// - [pages]: the new value (null keeps the current one).
  /// - [expandedPageIndex]: expandedPage index.
  /// - [departmentsShown]: the new value (null keeps the current one).
  /// - [personList]: the new value (null keeps the current one).
  /// - [shownPersonList]: the new value (null keeps the current one).
  /// - [selectedPersonList]: the new value (null keeps the current one).
  /// - [timeBegin]: the new value (null keeps the current one).
  /// - [timeEnd]: the new value (null keeps the current one).
  /// - [isEdit]: the new value (null keeps the current one).
  /// - [savedColors]: the new value (null keeps the current one).
  /// - [selectedDepartment]: the new value (null keeps the current one).
  /// - [currentPersonDepartment]: the new value (null keeps the current one).
  /// - [textSearch]: the new value (null keeps the current one).
  /// - [incrementVersion]: bump the version so the state is new.
  /// - [existingFormId]: the new value (null keeps the current one).
  /// - [existingCreateDate]: the new value (null keeps the current one).
  /// - [structureLockedNotice]: the new value (null keeps the current one).
  ///
  /// Returns: the copy.
  CreateFormDataLoaded copyWith({
    List<PageControllerModel>? pages,
    int? expandedPageIndex,
    List<DepartmentEntity>? departmentsShown,
    List<PersonEntity>? personList,
    List<PersonEntity>? shownPersonList,
    List<PersonEntity>? selectedPersonList,
    DateTime? timeBegin,
    DateTime? timeEnd,
    bool? isEdit,
    List<Color>? savedColors,
    String? selectedDepartment,
    String? currentPersonDepartment,
    String? textSearch,
    bool incrementVersion = true,
    String? existingFormId,
    DateTime? existingCreateDate,
    int? structureLockedNotice,
  }) {
    return CreateFormDataLoaded(
      pages: pages ?? this.pages,
      expandedPageIndex: expandedPageIndex ?? this.expandedPageIndex,
      departmentsShown: departmentsShown ?? this.departmentsShown,
      personList: personList ?? this.personList,
      shownPersonList: shownPersonList ?? this.shownPersonList,
      selectedPersonList: selectedPersonList ?? this.selectedPersonList,
      timeBegin: timeBegin ?? this.timeBegin,
      timeEnd: timeEnd ?? this.timeEnd,
      isEdit: isEdit ?? this.isEdit,
      savedColors: savedColors ?? this.savedColors,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      currentPersonDepartment:
          currentPersonDepartment ?? this.currentPersonDepartment,
      textSearch: textSearch ?? this.textSearch,
      version: incrementVersion ? version + 1 : version,
      existingFormId: existingFormId ?? this.existingFormId,
      existingCreateDate: existingCreateDate ?? this.existingCreateDate,
      structureLockedNotice:
          structureLockedNotice ?? this.structureLockedNotice,
    );
  }

  @override
  List<Object?> get props => [
    pages,
    expandedPageIndex,
    departmentsShown,
    personList,
    shownPersonList,
    selectedPersonList,
    timeBegin,
    timeEnd,
    isEdit,
    savedColors,
    selectedDepartment,
    currentPersonDepartment,
    textSearch,
    version,
    existingFormId,
    existingCreateDate,
    structureLockedNotice,
  ];
}

class CreateFormDataError extends CreateFormDataState {
  final String message;

  CreateFormDataError(this.message);

  @override
  List<Object?> get props => [message];
}
