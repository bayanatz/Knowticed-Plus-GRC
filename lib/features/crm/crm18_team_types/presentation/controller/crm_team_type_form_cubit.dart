// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_type_form_cubit.dart
// Purpose: Validates and persists CRM team types
// Author: Mohand Adel
// Created At: 08/10/2026

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/interfaces/crm_team_types_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/presentation/controller/crm_team_type_form_state.dart';

/// Owns Team Type validation, duplicate protection, and persistence.
class CrmTeamTypeFormCubit extends Cubit<CrmTeamTypeFormState> {
  final CrmTeamTypesBaseRepository _repository;
  final CrmTeamType? _existingTeamType;
  StreamSubscription<List<CrmTeamType>>? _subscription;

  CrmTeamTypeFormCubit({
    required CrmTeamTypesBaseRepository repository,
    CrmTeamType? teamType,
  })  : _repository = repository,
        _existingTeamType = teamType,
        super(CrmTeamTypeFormState(
          teamType: teamType ?? CrmTeamType(updatedAt: DateTime.now()),
        ));

  bool get isEditing => _existingTeamType != null;

  /// Starts duplicate-name tracking for the form.
  void init() {
    _subscription = _repository.watchTeamTypes().listen(
      (List<CrmTeamType> items) {
        if (!isClosed) {
          emit(state.copyWith(existingTypes: items));
        }
      },
      onError: (Object error) {
        if (!isClosed) {
          emit(state.copyWith(errorMessage: error.toString()));
        }
      },
    );
  }

  /// Updates the English name and refreshes its inline validation message.
  void updateNameEn(String value) => _updateName(isArabic: false, value: value);

  /// Updates the Arabic name and refreshes its inline validation message.
  void updateNameAr(String value) => _updateName(isArabic: true, value: value);

  /// Updates the optional English note.
  void updateNoteEn(String value) => _update(noteEn: value);

  /// Updates the optional Arabic note.
  void updateNoteAr(String value) => _update(noteAr: value);

  /// Updates whether the type is selectable for new teams.
  void updateIsActive(bool value) => _update(isActive: value);

  /// Validates and persists the current type.
  Future<bool> save() async {
    if (!_validate()) {
      return false;
    }
    emit(state.copyWith(isSaving: true, clearError: true));
    final CrmTeamType teamType = state.teamType.copyWith(
      updatedAt: DateTime.now(),
      updatedBy: _currentUserEmail,
    );
    try {
      if (isEditing) {
        await _repository.updateTeamType(teamType);
      } else {
        await _repository.createTeamType(teamType);
      }
      if (!isClosed) {
        emit(state.copyWith(teamType: teamType, isSaving: false));
      }
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      }
      return false;
    }
  }

  /// Soft deletes the opened type.
  Future<bool> delete() async {
    if (_existingTeamType == null) {
      return false;
    }
    try {
      await _repository.deleteTeamType(
        state.teamType.copyWith(updatedAt: DateTime.now(), isDeleted: true),
      );
      return true;
    } catch (error) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: error.toString()));
      }
      return false;
    }
  }

  /// Removes the transient error after the page displays it.
  void clearError() => emit(state.copyWith(clearError: true));

  void _updateName({required bool isArabic, required String value}) {
    _update(
      nameEn: isArabic ? null : value,
      nameAr: isArabic ? value : null,
    );
    final String? error = _nameError(value, isArabic: isArabic);
    emit(state.copyWith(
      nameEnError: isArabic ? null : error,
      nameArError: isArabic ? error : null,
      clearNameEnError: isArabic,
      clearNameArError: !isArabic,
    ));
  }

  void _update({
    String? nameEn,
    String? nameAr,
    String? noteEn,
    String? noteAr,
    bool? isActive,
  }) {
    emit(state.copyWith(
      teamType: state.teamType.copyWith(
        nameEn: nameEn,
        nameAr: nameAr,
        noteEn: noteEn,
        noteAr: noteAr,
        isActive: isActive,
      ),
    ));
  }

  bool _validate() {
    final String? nameEnError = _nameError(state.teamType.nameEn);
    final String? nameArError =
        _nameError(state.teamType.nameAr, isArabic: true);
    emit(state.copyWith(
      nameEnError: nameEnError,
      nameArError: nameArError,
      clearNameEnError: nameEnError == null,
      clearNameArError: nameArError == null,
    ));
    return nameEnError == null && nameArError == null;
  }

  String? _nameError(String value, {bool isArabic = false}) {
    if (value.trim().isEmpty) {
      return isArabic ? 'الحقل مطلوب' : 'Field Required';
    }
    final bool exists = state.existingTypes.any((CrmTeamType item) {
      final String other = isArabic ? item.nameAr : item.nameEn;
      return item.id != state.teamType.id &&
          other.trim().toLowerCase() == value.trim().toLowerCase();
    });
    if (exists) {
      return isArabic ? 'هذا الاسم موجود من قبل' : 'This Name Exist Before';
    }
    return null;
  }

  String get _currentUserEmail {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final String? email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    return 'system';
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
