/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: home_cubit_methods_2.dart
/// Description: Save methods of `HomeCubit` (publish, edit, draft, delete,
///              restore, duplicate, tab change). Each returns the result;
///              the UI shows the dialogs.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
/// Updated: 19/10/2026 - Dialogs and navigation moved to HomeFormActions /
///                       HomePublishActions.
/// Updated: 23/10/2026 - Access lists built as FormAccessGrant (Home rule 9).

part of '../home_cubit.dart';

/// Save methods of [HomeCubit].
extension HomeCubitMethods2 on HomeCubit {
  /// Method Name: [editFormModel]
  ///
  /// Purpose: saves an edited form under the original id and reloads.
  ///
  /// Parameters:
  /// - [oldFormModel]: the form before the edit.
  /// - [newFormModel]: the edited form.
  ///
  /// Returns: the failure, or null when the save worked (FB-HOME-04).
  Future<Failure?> editFormModel(
    FormEntity oldFormModel,
    FormEntity newFormModel,
  ) async {
    newFormModel.id = oldFormModel.id;
    final result = await formRepo.updateForm(newFormModel);
    final Failure? failure = result.fold((failure) => failure, (_) {
      FormBuilderLogService.log(FormBuilderLogService.actionUpdateForm);
      // Section 2.3 "Form Content Updated".
      FormBuilderNotificationService.notifyFormContentUpdated(
        formId: newFormModel.id,
        formNameEn: newFormModel.formHeadModel.title,
        formNameAr: newFormModel.formHeadModel.arTitle,
      );
      return null;
    });
    await getForms();
    return failure;
  }

  /// Method Name: [editFormWithAccess]
  ///
  /// Purpose: bug report #13: saves an edit that switched the form to Open
  /// or Restricted Access, then its new access list.
  ///
  /// Parameters:
  /// - [oldFormModel]: the form before the edit.
  /// - [model]: the edited form, holding the picked departments / people.
  ///
  /// Returns: the failure, or null when BOTH saves worked.
  Future<Failure?> editFormWithAccess(
    FormEntity oldFormModel,
    FormEntity model,
  ) async {
    final Failure? failure = await editFormModel(oldFormModel, model);
    if (failure != null) return failure;
    final FormAccessGrant? grant = _accessGrantFor(model);
    if (grant == null) return null;
    return saveFormAccess(grant, model);
  }

  /// Method Name: [publishForm]
  ///
  /// Purpose: saves a new form and, for Open / Restricted Access, its
  /// access list. FB-HOME-02: re-checks the Create New Form permission.
  ///
  /// Parameters:
  /// - [model]: the form, holding the picked departments / people.
  ///
  /// Returns: null on success, otherwise the translated message to show.
  Future<String?> publishForm(FormEntity model) async {
    if (!FormBuilderAccess.canCreateForm) {
      return S.current.noPermissionCreateForm;
    }
    final AccessManagement? access = AccessManagementExtension.fromStored(
      model.formHeadModel.accessManagement,
    );
    if (access == null) return S.current.chooseAccessManagement;
    if (access == AccessManagement.openAccess &&
        (model.openAccessModel?.selectedDepartments?.isEmpty ?? true)) {
      return S.current.selectAtLeastOneDepartment;
    }

    final Failure? formFailure = await createForm(model);
    if (formFailure != null) return S.current.formSaveFailed;

    final FormAccessGrant? grant = _accessGrantFor(model);
    if (grant != null) {
      final Failure? accessFailure = await saveFormAccess(grant, model);
      if (accessFailure != null) return S.current.formAccessSaveFailed;
    }
    FormBuilderLogService.log(FormBuilderLogService.actionPublishForm);
    return null;
  }

  /// Method Name: [saveDraft]
  ///
  /// Purpose: saves a new form as a draft and reloads the lists.
  ///
  /// Parameters:
  /// - [model]: the form.
  ///
  /// Returns: the failure, or null when the save worked (FB-HOME-04).
  Future<Failure?> saveDraft(FormEntity model) async {
    model.status = FormStatus.drafts;
    final response = await formRepo.createForm(model);
    final Failure? failure = response.fold((f) => f, (_) => null);
    if (failure != null) return failure;
    FormBuilderLogService.log(FormBuilderLogService.actionCreateForm);
    await getForms(showLoading: false);
    return null;
  }

  /// Method Name: [deleteFormModel]
  ///
  /// Purpose: deletes the form. FB-HOME-09: it is removed by id from every
  /// list it can be in.
  ///
  /// Parameters:
  /// - [formEntity]: the form.
  ///
  /// Returns: true when the delete worked.
  Future<bool> deleteFormModel(FormEntity formEntity) async {
    final response = await formRepo.deleteForm(formEntity.id);
    final bool deleted = response.fold((failure) => false, (r) {
      publishFormModels.removeWhere((f) => f.id == formEntity.id);
      draftFormModels.removeWhere((f) => f.id == formEntity.id);
      shownFormModels.removeWhere((f) => f.id == formEntity.id);
      formEntity.status = FormStatus.deleted;
      deleteFormModels.add(formEntity);
      FormBuilderLogService.log(FormBuilderLogService.actionDeleteForm);
      return true;
    });
    if (deleted) _emitLoadedState();
    return deleted;
  }

  /// Method Name: [restoreForm]
  ///
  /// Purpose: restores a deleted form and moves it back to the tab it was
  /// in before the delete (the repository reads that status from the
  /// form's own history).
  ///
  /// Parameters:
  /// - [model]: the deleted form.
  ///
  /// Returns: true when the restore worked.
  Future<bool> restoreForm(FormEntity model) async {
    final Either<Failure, FormStatus> result = await formRepo.restoreForm(
      model.id,
    );
    return result.fold((failure) => false, (FormStatus statusBeforeDelete) {
      restoreFormModel(model, statusBeforeDelete);
      return true;
    });
  }

  /// Method Name: [duplicateFormModel]
  ///
  /// Purpose: copies a form under new names. FB-HOME-06: the copy's access
  /// list is built like a publish (only people whose access is active).
  /// FB-HOME-09: the copy goes to the list that matches its status.
  ///
  /// Parameters:
  /// - [formEntity]: the form to copy.
  /// - [newEnglishName]: the copy's English title.
  /// - [newArabicName]: the copy's Arabic title.
  ///
  /// Returns: the failure, or null when it worked (FB-HOME-04).
  Future<Failure?> duplicateFormModel(
    FormEntity formEntity,
    String newEnglishName,
    String newArabicName,
  ) async {
    final FormEntity newFormModel = formEntity.duplicate(
      newId: '${FormBuilderDirectory.currentUserId}_${DateTime.now()}',
    );
    newFormModel.formHeadModel.title = newEnglishName;
    newFormModel.formHeadModel.arTitle = newArabicName;

    final response = await formRepo.createForm(newFormModel);
    final Failure? failure = response.fold((f) => f, (_) => null);
    if (failure != null) return failure;

    if (newFormModel.status == FormStatus.drafts) {
      draftFormModels.add(newFormModel);
    } else {
      publishFormModels.add(newFormModel);
    }

    final FormAccessGrant? grant = _accessGrantFor(
      newFormModel,
      activeOnly: true,
    );
    if (grant == null) {
      _emitLoadedState();
      return null;
    }
    final Failure? accessFailure = await saveFormAccess(grant, newFormModel);
    _emitLoadedState();
    return accessFailure;
  }

  /// The access list to save for [model], or null for Personal Access.
  FormAccessGrant? _accessGrantFor(
    FormEntity model, {
    bool activeOnly = false,
  }) {
    switch (AccessManagementExtension.fromStored(
      model.formHeadModel.accessManagement,
    )) {
      case AccessManagement.openAccess:
        return _openAccessGrant(model);
      case AccessManagement.restrictedAccess:
        return _restrictedAccessGrant(model, activeOnly: activeOnly);
      case AccessManagement.personalAccess:
      case null:
        return null;
    }
  }

  /// Access list for an Open Access form: every employee of the selected
  /// departments.
  FormAccessGrant _openAccessGrant(FormEntity model) {
    final List<String> departmentIds =
        model.openAccessModel?.selectedDepartments?.map((e) => e.id).toList() ??
            <String>[];
    final List<EmployeeEntityPro> employees =
        (mainCoreEmployeeController.allEmployeesEntities ??
                <EmployeeEntityPro>[])
            .where((e) => departmentIds.contains(e.departmentId))
            .toList();
    return FormAccessGrant(
      emails: employees.map((e) => e.email ?? '').toList(),
      accessBegin: model.openAccessModel?.timeBegin,
      accessEnd: model.openAccessModel?.timeEnd,
      editPermission: model.openAccessModel?.isEdit ?? false,
    );
  }

  /// Access list for a Restricted Access form: the picked people.
  /// [activeOnly] keeps only people whose access is active (used by
  /// duplicate, so people removed from the original are not re-added).
  FormAccessGrant _restrictedAccessGrant(
    FormEntity model, {
    bool activeOnly = false,
  }) {
    return FormAccessGrant(
      emails: (model.restrictedAccessModel?.selectedPersons ?? const [])
          .where((person) => !activeOnly || person.isSelected)
          .map((person) => person.id)
          .toList(),
      accessBegin: model.restrictedAccessModel?.timeBegin,
      accessEnd: model.restrictedAccessModel?.timeEnd,
      editPermission: model.restrictedAccessModel?.isEdit ?? false,
    );
  }

  /// Method Name: [onChangeTab]
  ///
  /// Purpose: shows the list of tab [value] and clears the filter. Each tab
  /// has its own sort options (bug report #24).
  ///
  /// Parameters:
  /// - [value]: the tab index (0 Publish … 4 Deleted).
  void onChangeTab(int value) {
    selectedTabIndex = value;
    switch (value) {
      case 0:
        selectedTab = FormStatus.publish;
        shownFormModels = publishFormModels;
        break;
      case 1:
        selectedTab = FormStatus.drafts;
        shownFormModels = draftFormModels;
        break;
      case 2:
        selectedTab = FormStatus.requestedForms;
        shownFormModels = requestedFormModels;
        break;
      case 3:
        selectedTab = FormStatus.submissions;
        shownFormModels = submissionsFormModels;
        break;
      case 4:
        selectedTab = FormStatus.deleted;
        shownFormModels = deleteFormModels;
        break;
    }
    currentDateValue = null;
    currentDropDownValue = null;

    final List<String> tabOptions =
        value == 3 ? FormSortOption.submissionValues : FormSortOption.values;
    if (!tabOptions.contains(selectedSortOption)) {
      activeSortOption = null;
      selectedSortOption = _defaultSortForTab();
    }
    sortForms();
  }
}
