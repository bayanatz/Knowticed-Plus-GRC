/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: home_cubit_methods.dart
/// Description: Loading and sorting methods of `HomeCubit`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../home_cubit.dart';

/// Loading and sorting methods of [HomeCubit].
extension HomeCubitMethods on HomeCubit {
  /// Method Name: [getForms]
  ///
  /// Purpose: loads every list on the home screen (created, requested and
  /// submitted forms).
  ///
  /// Parameters:
  /// - [showLoading]: emit [HomeLoading] first (initial load only).
  /// - [live]: a refresh triggered by [_watchForms]: no loader, the tab and
  ///   sort the user chose are kept, and the old lists stay on screen if the
  ///   read fails (no error page for a background refresh).
  ///
  /// Returns: [Future<void>]; emits [HomeLoaded], or [HomeError] with a
  /// translated message when the forms cannot be read, so the page can
  /// offer a retry instead of showing an empty home screen.
  Future<void> getForms({bool showLoading = true, bool live = false}) async {
    final previousPublish = publishFormModels;
    final previousDrafts = draftFormModels;
    final previousDeleted = deleteFormModels;
    final previousRequested = requestedFormModels;
    final previousSubmissions = submissionsFormModels;
    formsEntity = [];

    if (showLoading) {
      isLoading = true;
      emit(HomeLoading());
    }

    bool failed = false;
    try {
      final Either<Failure, List<FormEntity>> response = await formRepo
          .getCreatedForms(mainCoreEmployeeController.employeeEntity!.email!);
      if (response.isLeft()) {
        failed = true;
      } else {
        await filterUserCreatedForms(response.getOrElse(() => []));
        await getAccessedForms();
      }
    } catch (e, stackTrace) {
      fbFailure(e, stackTrace);
      failed = true;
    }

    isLoading = false;
    if (isClosed) return;
    if (failed) {
      if (live) {
        publishFormModels = previousPublish;
        draftFormModels = previousDrafts;
        deleteFormModels = previousDeleted;
        requestedFormModels = previousRequested;
        submissionsFormModels = previousSubmissions;
        return;
      }
      emit(HomeError(S.current.formsLoadFailed));
      return;
    }
    // FB-HOME-28: show the list of the tab that is open (with its search,
    // filter and sort), not always the Published list, so the cards always
    // match the selected tab chip.
    onSearch(searchQuery);
    _watchForms();
  }

  /// Keeps every tab (forms, counts, access, submissions) live.
  void _watchForms() => _live.watchPaths([
        getBaseUrl(FormApiConstants.forms),
        getBaseUrl(FormApiConstants.formPrivacy),
        FormApiConstants.userResponses,
      ], () => getForms(showLoading: false, live: true));

  /// Method Name: [sortForms]
  ///
  /// Purpose: sorts the shown list by [selectedSortOption] in the order
  /// set by [isAscending], then emits the lists.
  ///
  /// Returns: void; emits [HomeLoaded].
  void sortForms() {
    // Still emit when the list is empty so the Sort button reflects the pick.
    if (shownFormModels.isEmpty) {
      _emitLoadedState();
      return;
    }

    // This switch used to carry one `case` per language
    // ('Published Date' / 'تاريخ النشر'), so sorting broke as soon as the
    // Arabic wording in the .arb changed. `SortDropdownMenu` now hands up a
    // FormSortOption constant and translates only for display.
    switch (selectedSortOption) {
      case FormSortOption.publishedDate:
        shownFormModels.sort((a, b) {
          final dateA = _getPublishedDate(a);
          final dateB = _getPublishedDate(b);
          return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
        break;

      case FormSortOption.submissionDate:
        shownFormModels.sort((a, b) {
          final dateA = a.submissionDate ?? _getPublishedDate(a);
          final dateB = b.submissionDate ?? _getPublishedDate(b);
          return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
        break;

      case FormSortOption.receivedDate:
        shownFormModels.sort((a, b) {
          final dateA = a.receivedDate ?? _getPublishedDate(a);
          final dateB = b.receivedDate ?? _getPublishedDate(b);
          return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
        break;

      case FormSortOption.lastUpdate:
        shownFormModels.sort((a, b) {
          final dateA = _getLastUpdate(a);
          final dateB = _getLastUpdate(b);
          return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
        break;

      default:
        // Default to Published Date if unknown option
        shownFormModels.sort((a, b) {
          final dateA = _getPublishedDate(a);
          final dateB = _getPublishedDate(b);
          return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
    }

    _emitLoadedState();
  }

  /// Method Name: [getAccessedForms]
  ///
  /// Purpose: adds the forms shared with the user to Requested (not yet
  /// answered) or Submissions (answered). A form that cannot be read is
  /// skipped and logged (FB-HOME-08); it no longer stops the whole load.
  ///
  /// Returns: [Future<void>]; fills [requestedFormModels],
  /// [submissionsFormModels] and [formsEntity].
  Future<void> getAccessedForms() async {
    final String email = mainCoreEmployeeController.employeeEntity!.email!;
    final Either<Failure, List<FormAccessRecord>> response =
        await formRepo.getMyAccessRecords(email);
    if (response.isLeft()) return;

    final List<FormAccessRecord> records = response.getOrElse(() => []);
    final UserSubmissions? userSubmissions =
        (await homeRepository.getUserSubmissions(email)).getOrElse(() => null);
    final Set<String> submittedFormIds = userSubmissions?.formIds.toSet() ?? {};

    // 24/10/2026: every shared form is read at once; the lists are filled
    // as each one arrives and sorted afterwards by [onSearch].
    await Future.wait(
      records.map((FormAccessRecord record) async {
        try {
          await _addAccessedForm(
            record,
            email,
            userSubmissions,
            submittedFormIds,
          );
        } catch (e, stackTrace) {
          fbFailure(e, stackTrace);
        }
      }),
    );
  }

  /// Adds one shared form to Requested or Submissions.
  Future<void> _addAccessedForm(
    FormAccessRecord record,
    String email,
    UserSubmissions? userSubmissions,
    Set<String> submittedFormIds,
  ) async {
    final bool isHasAccess = record.isOpenAt(DateTime.now());

    // Already listed (your own form, handled in filterCreatedForms) —
    // don't add it a second time.
    if (submissionsFormModels.any((f) => f.id == record.formId) ||
        requestedFormModels.any((f) => f.id == record.formId)) {
      return;
    }
    if (!record.isActive ||
        !(isHasAccess || submittedFormIds.contains(record.formId))) {
      return;
    }

    final Either<Failure, FormEntity?> formResult =
        await formRepo.getSharedForm(record, isHasAccess: isHasAccess);
    if (formResult.isLeft()) return;
    final FormEntity? formEntity = formResult.getOrElse(() => null);
    if (formEntity == null) return;

    if (!submittedFormIds.contains(formEntity.id)) {
      formEntity.status = FormStatus.requestedForms;
      formsEntity.add(formEntity);
      requestedFormModels.add(formEntity);
      return;
    }

    formEntity.status = FormStatus.submissions;
    final Either<Failure, FormResponse?> result = await homeRepository
        .getFormResponse(formId: formEntity.id, email: email);
    if (result.isLeft()) return;
    final FormResponse? formResponse = result.getOrElse(() => null);
    // FB-HOME-07: a response with no pages no longer crashes.
    if (formResponse?.pages == null) return;
    formEntity.submissionDate = userSubmissions?.submissionDateOf(
      formEntity.id,
    );
    formEntity.pages = List<PageEntity>.of(formResponse!.pages!);
    // FB-HOME-07: added once per form, not once per page.
    submissionsFormModels.add(formEntity);
    formsEntity.add(formEntity);
  }

  /// A Submissions-tab copy of one of your own forms, holding the answers
  /// you sent. Null when the response cannot be read.
  Future<FormEntity?> _ownSubmissionEntity(
    FormEntity form,
    UserSubmissions index,
  ) async {
    final Either<Failure, FormResponse?> result =
        await homeRepository.getFormResponse(
      formId: form.id,
      email: mainCoreEmployeeController.employeeEntity!.email!,
    );
    final FormResponse? response = result.getOrElse(() => null);
    if (response?.pages == null) return null;
    final FormEntity copy = form.duplicate(newId: form.id);
    copy.status = FormStatus.submissions;
    copy.submissionDate = index.submissionDateOf(form.id);
    copy.pages = List<PageEntity>.of(response!.pages!);
    return copy;
  }

  /// Method Name: [filterUserCreatedForms]
  ///
  /// Purpose: adds the user's own forms with their answer counts, then
  /// splits every form into its tab list ([filterCreatedForms]).
  ///
  /// Parameters:
  /// - [createdForms]: the forms the user created.
  ///
  /// Returns: [Future<void>]; fills [formsEntity] and the tab lists.
  Future<void> filterUserCreatedForms(List<FormEntity> createdForms) async {
    // 24/10/2026: the answer counts are read all at once, not one form after
    // the other (that made the Home lists take over a minute to appear).
    final List<Either<Failure, int>> usages = await Future.wait(
      createdForms.map(
        (FormEntity form) => homeRepository.getFormNumberOfUsage(form.id),
      ),
    );
    for (int i = 0; i < createdForms.length; i++) {
      final FormEntity form = createdForms[i];
      // FB-HOME-26: when the answer count cannot be read the form is
      // skipped (it appears on the next reload), so a form that already
      // has answers is never opened as unused with its structure unlocked.
      final Either<Failure, int> usage = usages[i];
      if (usage.isLeft()) continue;
      form.numberUsed = usage.getOrElse(() => 0);
      formsEntity.add(form);
    }
    // FB-HOME-10: awaited, so it can no longer reset the lists while
    // getAccessedForms is filling them.
    await filterCreatedForms();
  }

  /// Method Name: [filterCreatedForms]
  ///
  /// Purpose: splits [formsEntity] into the Publish, Drafts, Deleted,
  /// Requested and Submissions lists. A form you created and answered
  /// yourself also gets a Submissions copy with your answers.
  ///
  /// Returns: [Future<void>]; resets and fills the tab lists.
  Future<void> filterCreatedForms() async {
    publishFormModels = [];
    draftFormModels = [];
    deleteFormModels = [];
    requestedFormModels = [];
    submissionsFormModels = [];
    final UserSubmissions? userSubmissions =
        (await homeRepository.getUserSubmissions(
      mainCoreEmployeeController.employeeEntity!.email!,
    ))
            .getOrElse(() => null);
    for (FormEntity form in formsEntity) {
      if (form.status == FormStatus.publish) {
        publishFormModels.add(form);
      }
      if (form.status == FormStatus.drafts) {
        draftFormModels.add(form);
      }
      if (form.status == FormStatus.deleted) {
        deleteFormModels.add(form);
      }

      // A form YOU created and then filled out yourself
      // ("Fill Out Form" on its details page) now shows under Submissions
      // whatever its access type. It used to be listed only for Personal
      // Access, so answering your own Open / Restricted form saved the
      // response but never showed it. The Submissions card is a separate
      // copy carrying YOUR answers, so the Publish card is untouched.
      final bool answered =
          userSubmissions != null && userSubmissions.contains(form.id);
      if (answered &&
          form.status != FormStatus.deleted &&
          form.status != FormStatus.drafts) {
        final FormEntity? submitted = await _ownSubmissionEntity(
          form,
          userSubmissions,
        );
        if (submitted != null) submissionsFormModels.add(submitted);
      } else if (form.isHasAccess) {
        form.status = FormStatus.requestedForms;
        requestedFormModels.add(form);
      }
    }
  }

  /// Creates the form. Returns the failure, or null when it worked.
  ///
  /// FB-HOME-02: re-checks the Create New Form permission here, not only on
  /// the button. FB-HOME-04: the result is returned instead of ignored.
  /// FB-HOME-05 / FB-HOME-20: the cover and watermark are uploaded in ONE
  /// place only — `FormRepoImpl.createForm` — under the form id. The second
  /// upload here (file name only, failures ignored) is removed.
  Future<Failure?> createForm(FormEntity formEntity) async {
    if (!FormBuilderAccess.canCreateForm) {
      return FeatureFailure(S.current.noPermissionCreateForm);
    }

    final response = await formRepo.createForm(formEntity);
    final Failure? failure = response.fold((f) => f, (_) => null);

    // Reload, so every list shows the new form.
    if (failure == null) {
      FormBuilderLogService.log(FormBuilderLogService.actionCreateForm);
      await getForms(showLoading: false);
    }
    return failure;
  }

  /// Method Name: [restoreFormModel]
  ///
  /// Purpose: moves a restored form out of Deleted and back into the list
  /// it came from, in memory. [statusBeforeDelete] is read from the form's
  /// own status history, so a restored draft goes back to Drafts. Matches
  /// on `id`, so two forms with the same name are kept apart.
  ///
  /// Parameters:
  /// - [formModel]: the restored form.
  /// - [statusBeforeDelete]: the status it had before it was deleted.
  void restoreFormModel(FormEntity formModel, FormStatus statusBeforeDelete) {
    formModel.status = statusBeforeDelete;
    formModel.deleteDate = null;

    if (statusBeforeDelete == FormStatus.drafts) {
      draftFormModels.add(formModel);
    } else {
      publishFormModels.add(formModel);
    }

    deleteFormModels.removeWhere((element) => element.id == formModel.id);

    if (selectedTab == FormStatus.deleted) {
      shownFormModels = [];
      shownFormModels = deleteFormModels;
    }
    _emitLoadedState();
  }
}
