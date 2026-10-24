/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: share_cubit.dart
/// Description: `ShareCubit`, sharing a form with people.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Injected dependencies; no dialogs, navigation or
///                       controllers in the cubit.
/// Updated: 23/10/2026 - FB-SHARE-11: access-list read errors are shown
///                       with Retry; no data model in the cubit.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/helpers/form_builder_log_service.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/form_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/mappers/person_entity_factory.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/base_repository/share_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/share_state.dart';
import 'package:knowticed_plus/features/notification/data/repository/form_builder_notification_service.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Sharing a form: the people list, the filters, the picked people and the
/// access dates. No dialogs, navigation or controllers here: the page shows
/// the messages.
class ShareCubit extends Cubit<ShareState> {
  /// Access-list reads and writes (injected).
  final ShareBaseRepository shareRepository;

  /// The employee list (injected).
  final MainCoreEmployeeController mainCoreEmployeeController;

  /// The company departments (injected).
  final MainCoreDepartmentCubit departmentCubit;

  /// The "All departments" value of [ShareLoaded.department].
  static const String allDepartments = 'All';

  ShareCubit({
    required this.shareRepository,
    required this.mainCoreEmployeeController,
    required this.departmentCubit,
  }) : super(
         ShareLoaded(
           persons: const [],
           filteredPersons: const [],
           isEditPermission: false,
           previousSelectedPersons: const [],
           filteredPreviousSelectedPersons: const [],
           newSelectedPersons: const [],
           filteredNewSelectedPersons: const [],
           department: allDepartments,
         ),
       );

  /// Every emit is skipped once the cubit is closed (Share rule 4).
  @override
  void emit(ShareState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Get all persons entities
  void getPersonsEntities() {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    final persons = <PersonEntity>[];

    mainCoreEmployeeController.allEmployeesEntities?.forEach((element) {
      persons.add(PersonEntityFactory.fromEmployeeEntity(element));
    });

    emit(currentState.copyWith(persons: persons));
  }

  /// Toggle person selection
  void togglePersonSelection(int index, bool isPreviousSelected) {
    if (state is! ShareLoaded) return;
    if (isPreviousSelected) return;

    final currentState = state as ShareLoaded;
    final filteredPersons = List<PersonEntity>.from(
      currentState.filteredPersons,
    );
    final newSelectedPersons = List<PersonEntity>.from(
      currentState.newSelectedPersons,
    );

    filteredPersons[index].isSelected = !filteredPersons[index].isSelected;

    if (filteredPersons[index].isSelected) {
      newSelectedPersons.add(filteredPersons[index]);
    } else {
      newSelectedPersons.remove(filteredPersons[index]);
    }

    emit(
      currentState.copyWith(
        filteredPersons: filteredPersons,
        newSelectedPersons: newSelectedPersons,
      ),
    );
  }

  /// Select form and load privacy settings
  Future<void> selectForm(FormEntity form) async {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;

    // Reset state for new form
    emit(
      currentState.copyWith(
        searchText: '',
        isEditPermission: false,
        previousSelectedPersons: [],
        // A selection from an earlier visit (or an earlier
        // form) used to survive, so it showed up again in the next Review.
        newSelectedPersons: [],
        filteredNewSelectedPersons: [],
        filteredPersons: [],
        filteredPreviousSelectedPersons: [],
        departments: [],
        persons: [],
        clearTimeBegin: true,
        clearTimeEnd: true,
        clearDepartment: true,
        selectedForm: form,
        sharedEmails: [],
        isAccessListLoaded: false,
        clearAccessListError: true,
      ),
    );

    getPersonsEntities();
    await getFormPrivacy();
    search();
  }

  /// Method Name: [getFormPrivacy]
  ///
  /// Purpose: reads who already has access and marks those people.
  /// FB-SHARE-11: when the list cannot be read, a translated error is
  /// emitted (the page shows it with Retry) and Share stays disabled, so
  /// people who already have access are not re-shared with reset dates.
  ///
  /// Returns: [Future<void>]; emits [ShareLoaded].
  Future<void> getFormPrivacy() async {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    if (currentState.selectedForm == null) return;

    final Either<Failure, List<String>> result = await shareRepository
        .getSharedEmails(currentState.selectedForm!.id);
    if (isClosed || state is! ShareLoaded) return;
    if (result.isLeft()) {
      emit(
        (state as ShareLoaded).copyWith(
          isAccessListLoaded: false,
          accessListError: S.current.fbAccessListLoadFailed,
        ),
      );
      return;
    }
    final Set<String> sharedEmails = result.getOrElse(() => []).toSet();

    // Update persons with previous selections
    final persons = List<PersonEntity>.from(currentState.persons);
    final previousSelectedPersons = <PersonEntity>[];

    for (int i = 0; i < persons.length; i++) {
      if (sharedEmails.contains(persons[i].id)) {
        persons[i].isSelected = true;
        previousSelectedPersons.add(persons[i]);
      }
    }

    // Remove previously selected persons from main list
    for (var person in previousSelectedPersons) {
      persons.remove(person);
    }

    emit(
      currentState.copyWith(
        sharedEmails: sharedEmails.toList(),
        isAccessListLoaded: true,
        clearAccessListError: true,
        persons: persons,
        previousSelectedPersons: previousSelectedPersons,
      ),
    );
  }

  /// Method Name: [retryAccessList]
  ///
  /// Purpose: FB-SHARE-11 Retry: reads the access list again and rebuilds
  /// the people lists.
  ///
  /// Returns: [Future<void>].
  Future<void> retryAccessList() async {
    if (state is! ShareLoaded) return;
    final ShareLoaded currentState = state as ShareLoaded;
    emit(currentState.copyWith(clearAccessListError: true));
    await getFormPrivacy();
    search();
  }

  /// Method Name: [search]
  ///
  /// Purpose: filters the people by department and by [text] (or the last
  /// search text when null).
  ///
  /// Parameters:
  /// - [text]: the search text typed, or null to keep the current one.
  void search([String? text]) {
    if (state is! ShareLoaded) return;

    if (text != null) {
      emit((state as ShareLoaded).copyWith(searchText: text));
    }
    final currentState = state as ShareLoaded;
    final value = currentState.searchText;

    applyDepartmentFilter();

    if (state is! ShareLoaded) return;
    final updatedState = state as ShareLoaded;

    final filteredPersons =
        List<PersonEntity>.from(updatedState.filteredPersons)..removeWhere(
          (element) =>
              !element.name.toLowerCase().contains(value.toLowerCase()),
        );

    final filteredPreviousSelectedPersons =
        List<PersonEntity>.from(updatedState.filteredPreviousSelectedPersons)
          ..removeWhere(
            (element) =>
                !element.name.toLowerCase().contains(value.toLowerCase()),
          );

    emit(
      updatedState.copyWith(
        filteredPersons: filteredPersons,
        filteredPreviousSelectedPersons: filteredPreviousSelectedPersons,
      ),
    );
  }

  /// Apply department filter
  void applyDepartmentFilter() {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    List<PersonEntity> filteredPersons = [];
    List<PersonEntity> filteredPreviousSelectedPersons = [];

    // Multi-select: keep people from ANY picked department.
    if (currentState.departments.isNotEmpty) {
      final Set<String> names = _departmentNames(currentState.departments);
      bool inPicked(PersonEntity p) =>
          names.contains(p.departmentName.trim().toLowerCase());
      emit(
        currentState.copyWith(
          filteredPersons: currentState.persons.where(inPicked).toList(),
          filteredPreviousSelectedPersons: currentState.previousSelectedPersons
              .where(inPicked)
              .toList(),
        ),
      );
      return;
    }

    if (currentState.department == null ||
        currentState.department!.toLowerCase() ==
            allDepartments.toLowerCase()) {
      // Show all persons when no filter or "All" is selected
      filteredPersons = List.from(currentState.persons);
      filteredPreviousSelectedPersons = List.from(
        currentState.previousSelectedPersons,
      );
    } else {
      // Filter by department using case-insensitive comparison
      filteredPersons = currentState.persons
          .where(
            (element) =>
                element.departmentName.toLowerCase() ==
                currentState.department!.toLowerCase(),
          )
          .toList();

      filteredPreviousSelectedPersons = currentState.previousSelectedPersons
          .where(
            (element) =>
                element.departmentName.toLowerCase() ==
                currentState.department!.toLowerCase(),
          )
          .toList();
    }

    emit(
      currentState.copyWith(
        filteredPersons: filteredPersons,
        filteredPreviousSelectedPersons: filteredPreviousSelectedPersons,
      ),
    );
  }

  /// Multi-select Department filter. [departmentIds] are
  /// department IDs; an empty list shows everyone.
  void updateDepartments(List<String> departmentIds) {
    if (state is! ShareLoaded) return;
    final currentState = state as ShareLoaded;
    emit(
      currentState.copyWith(
        departments: List<String>.from(departmentIds),
        department: allDepartments,
      ),
    );
    search(); // re-applies the department filter, then the search text
  }

  /// English AND Arabic names (lower-case) of the given department IDs, so a
  /// person matches whichever language their department name was saved in.
  Set<String> _departmentNames(List<String> ids) {
    final Set<String> idSet = ids.toSet();
    final Set<String> names = {};
    for (final d in departmentCubit.departmentModels) {
      if (!idSet.contains(d.departmentID)) continue;
      final en = d.departmentName?.trim().toLowerCase();
      final ar = d.departmentNameInArabic?.trim().toLowerCase();
      if (en != null && en.isNotEmpty) names.add(en);
      if (ar != null && ar.isNotEmpty) names.add(ar);
    }
    return names;
  }

  /// Update department filter
  void updateDepartment(String? department) {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    emit(
      currentState.copyWith(
        department: department,
        clearDepartment: department == null,
      ),
    );
    applyDepartmentFilter();
  }

  /// Search new selected persons
  void newSelectedSearch(String query) {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;

    if (query.isEmpty) {
      // When search is empty, show ALL newSelectedPersons

      final newFiltered = List<PersonEntity>.from(
        currentState.newSelectedPersons,
      );

      emit(currentState.copyWith(filteredNewSelectedPersons: newFiltered));
    } else {
      // Filter based on search query
      final filtered = currentState.newSelectedPersons.where((person) {
        return person.name.toLowerCase().contains(query.toLowerCase()) ||
            person.departmentName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      emit(currentState.copyWith(filteredNewSelectedPersons: filtered));
    }
  }

  /// Update edit permission
  void updateEditPermission(bool value) {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    emit(currentState.copyWith(isEditPermission: value));
  }

  /// Update time begin
  void updateTimeBegin(DateTime? time) {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    emit(currentState.copyWith(timeBegin: time, clearTimeBegin: time == null));
  }

  /// Update time end
  void updateTimeEnd(DateTime? time) {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    emit(currentState.copyWith(timeEnd: time, clearTimeEnd: time == null));
  }

  /// Method Name: [grantAccess]
  ///
  /// Purpose: gives the picked people access to the form, logs the share
  /// and tells them (Section 2.3 "Form Shared With You"). FB-SHARE-04: every
  /// early exit says why. The people sent to move to "already has access"
  /// and the selection starts empty.
  ///
  /// Returns: null when shared, otherwise the translated message to show.
  Future<String?> grantAccess() async {
    if (state is! ShareLoaded) return S.current.shareFailed;
    final currentState = state as ShareLoaded;

    // Safety net only — ShareAccessDialog validates these first.
    if (currentState.newSelectedPersons.isEmpty ||
        currentState.timeBegin == null ||
        currentState.timeEnd == null) {
      return S.current.shareNeedsPeopleAndDates;
    }
    if (currentState.selectedForm == null) return S.current.shareFailed;
    // FB-SHARE-11: never share before the current access list is known.
    if (!currentState.isAccessListLoaded) {
      return S.current.fbAccessListLoadFailed;
    }

    final Either<Failure, List<String>> result = await shareRepository
        .grantAccess(
          formId: currentState.selectedForm!.id,
          persons: currentState.newSelectedPersons,
          timeBegin: currentState.timeBegin!,
          timeEnd: currentState.timeEnd!,
          isEditPermission: currentState.isEditPermission,
        );

    return result.fold(
      // The repository returns a translated message, never raw error text.
      (Failure failure) => failure.message,
      (List<String> saved) {
        // Keep the cubit's copy in step with what was saved (FB-SHARE-06).
        if (!isClosed && state is ShareLoaded) {
          emit((state as ShareLoaded).copyWith(sharedEmails: saved));
        }
        _moveSentToPrevious(currentState.newSelectedPersons);
        FormBuilderLogService.log(FormBuilderLogService.actionShareForm);
        FormBuilderNotificationService.notifyFormShared(
          formId: currentState.selectedForm!.id,
          recipients: currentState.newSelectedPersons.map((e) => e.id),
          formNameEn: currentState.selectedForm!.formHeadModel.title,
          formNameAr: currentState.selectedForm!.formHeadModel.arTitle,
          accessEnd: currentState.timeEnd,
        );
        return null;
      },
    );
  }

  /// After a successful share: [sent] leave the selectable list, join the
  /// "already has access" list, and the selection is cleared.
  void _moveSentToPrevious(List<PersonEntity> sent) {
    if (state is! ShareLoaded) return;
    final s = state as ShareLoaded;
    final Set<String> sentIds = sent.map((p) => p.id).toSet();

    final persons = s.persons.where((p) => !sentIds.contains(p.id)).toList();
    final previous = List<PersonEntity>.from(s.previousSelectedPersons);
    for (final p in sent) {
      if (!previous.any((e) => e.id == p.id)) {
        p.isSelected = true;
        previous.add(p);
      }
    }

    emit(
      s.copyWith(
        persons: persons,
        previousSelectedPersons: previous,
        newSelectedPersons: [],
        filteredNewSelectedPersons: [],
        // The next share starts clean — no dates or edit
        // permission carried over from the one just sent.
        clearTimeBegin: true,
        clearTimeEnd: true,
        isEditPermission: false,
      ),
    );
    search(); // rebuild the filtered lists the grid shows
  }

  /// Clear selected persons
  void clearSelectedPersons() {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;
    final newSelectedPersons = List<PersonEntity>.from(
      currentState.newSelectedPersons,
    );

    for (var person in newSelectedPersons) {
      person.isSelected = false;
    }

    emit(
      currentState.copyWith(
        newSelectedPersons: [],
        filteredNewSelectedPersons: [],
      ),
    );
  }

  /// Select a person programmatically (used by group selection)
  ///
  /// [includeExisting] — also select someone who already has access (group
  /// selection: a group's members are all listed in the summary, and sending
  /// renews the access of those who already had it).
  void selectPerson(PersonEntity person, {bool includeExisting = false}) {
    if (state is! ShareLoaded) return;

    final currentState = state as ShareLoaded;

    // Check if already selected
    final alreadyInNew = currentState.newSelectedPersons.any(
      (p) => p.id == person.id,
    );
    final alreadyInPrevious = currentState.previousSelectedPersons.any(
      (p) => p.id == person.id,
    );

    if (alreadyInNew) return;
    if (alreadyInPrevious && !includeExisting) return;

    person.isSelected = true;
    final newSelectedPersons = List<PersonEntity>.from(
      currentState.newSelectedPersons,
    )..add(person);
    final filteredNewSelectedPersons = List<PersonEntity>.from(
      currentState.filteredNewSelectedPersons,
    )..add(person);

    emit(
      currentState.copyWith(
        newSelectedPersons: newSelectedPersons,
        filteredNewSelectedPersons: filteredNewSelectedPersons,
      ),
    );
  }
}
