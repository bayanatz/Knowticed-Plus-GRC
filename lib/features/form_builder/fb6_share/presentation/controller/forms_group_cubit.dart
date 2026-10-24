/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: forms_group_cubit.dart
/// Description: `FormsGroupCubit`, the user's form groups (list, search,
///              sort, create, edit, delete).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 19/10/2026 - Injected dependencies; no dialogs, controllers or
///                       Form key in the cubit.
library;

import 'package:get/get.dart';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder/helpers/department_display_name.dart';
import 'package:knowticed_plus/features/form_builder/helpers/form_builder_log_service.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/data/mappers/person_entity_factory.dart';
import 'package:knowticed_plus/features/form_builder/fb2_create/domain/entities/person_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/base_repository/group_base_repository.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/entities/group_entity.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/domain/use_cases/get_user_groups_use_case.dart';
import 'package:knowticed_plus/features/form_builder/fb6_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/features/notification/data/repository/form_builder_notification_service.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/features/form_builder/helpers/constants/fb_api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// What a group save ended with; the page shows the matching message.
enum GroupSaveResult {
  /// Saved.
  saved,

  /// Not saved: a group needs at least one member (FB-SHARE-01).
  needsMembers,

  /// Not saved: the write failed (FB-SHARE-04).
  failed,
}

/// The user's form groups: list, search, sort, create, edit and delete.
/// No dialogs, navigation, controllers or Form keys here: the pages own
/// them and show the messages.
class FormsGroupCubit extends Cubit<FormsGroupState> {
  /// Group reads and writes (injected).
  final GroupBaseRepository groupRepository;

  /// Reads the groups as entities (injected).
  final GetUserGroupsUseCase getUserGroupsUseCase;

  /// The signed-in employee and the employee list (injected).
  final MainCoreEmployeeController mainCoreEmployeeController;

  /// The company departments (injected).
  final MainCoreDepartmentCubit departmentCubit;

  FormsGroupCubit({
    required this.groupRepository,
    required this.getUserGroupsUseCase,
    required this.mainCoreEmployeeController,
    required this.departmentCubit,
  }) : super(
         FormsGroupLoaded(
           groups: const [],
           filteredGroups: const [],
           persons: const [],
           filteredPersons: const [],
           selectedPersons: const [],
           filteredSelectedPersons: const [],
           department: S.current.all,
         ),
       );

  /// Every emit is skipped once the cubit is closed (Share rule 4).
  @override
  void emit(FormsGroupState state) {
    if (isClosed) return;
    super.emit(state);
  }

  int _fieldsVersion = 0;

  String get _currentUserEmail =>
      mainCoreEmployeeController.employeeEntity!.email!;

  /// Method Name: [getDepartments]
  ///
  /// Purpose: the Department filter options ("All" first).
  ///
  /// Returns: the translated department names.
  List<String> getDepartments() {
    return [
      S.current.all.toLowerCase(),
      ...departmentCubit.departmentModels.map((e) => e.displayName()),
    ];
  }

  /// Method Name: [resetGroupController]
  ///
  /// Purpose: clears the search, the people lists and the group fields.
  void resetGroupController() {
    if (state is! FormsGroupLoaded) return;
    final currentState = state as FormsGroupLoaded;
    emit(
      FormsGroupLoaded(
        groups: currentState.groups,
        filteredGroups: currentState.filteredGroups,
        persons: const [],
        filteredPersons: const [],
        selectedPersons: const [],
        filteredSelectedPersons: const [],
        department: S.current.all.toLowerCase(),
        groupSort: currentState.groupSort,
        fieldsVersion: ++_fieldsVersion,
      ),
    );
  }

  /// Method Name: [updateGroupName]
  ///
  /// Purpose: stores the group name typed in its field.
  void updateGroupName(String value) {
    if (state is! FormsGroupLoaded) return;
    emit((state as FormsGroupLoaded).copyWith(groupName: value));
  }

  /// Method Name: [updateGroupDescription]
  ///
  /// Purpose: stores the group description typed in its field.
  void updateGroupDescription(String value) {
    if (state is! FormsGroupLoaded) return;
    emit((state as FormsGroupLoaded).copyWith(groupDescription: value));
  }

  /// Get all persons entities
  void getPersonsEntities() {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    final persons = <PersonEntity>[];

    mainCoreEmployeeController.allEmployeesEntities?.forEach((element) {
      persons.add(PersonEntityFactory.fromEmployeeEntity(element));
    });

    emit(
      currentState.copyWith(
        persons: persons,
        filteredPersons: List.from(persons),
      ),
    );
  }

  /// Method Name: [search]
  ///
  /// Purpose: filters the people by department and by [text] (or the last
  /// search text when null).
  ///
  /// Parameters:
  /// - [text]: the search text typed, or null to keep the current one.
  void search([String? text]) {
    if (state is! FormsGroupLoaded) return;

    if (text != null) {
      emit((state as FormsGroupLoaded).copyWith(searchText: text));
    }
    final currentState = state as FormsGroupLoaded;
    final value = currentState.searchText;

    applyDepartmentFilter();

    if (state is! FormsGroupLoaded) return;
    final updatedState = state as FormsGroupLoaded;

    final filteredPersons =
        List<PersonEntity>.from(updatedState.filteredPersons)..removeWhere(
          (element) =>
              !element.name.toLowerCase().contains(value.toLowerCase()),
        );

    final filteredSelectedPersons =
        List<PersonEntity>.from(updatedState.filteredSelectedPersons)
          ..removeWhere(
            (element) =>
                !element.name.toLowerCase().contains(value.toLowerCase()),
          );

    emit(
      updatedState.copyWith(
        filteredPersons: filteredPersons,
        filteredSelectedPersons: filteredSelectedPersons,
      ),
    );
  }

  /// Apply department filter
  void applyDepartmentFilter() {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    List<PersonEntity> filteredPersons = [];
    List<PersonEntity> filteredSelectedPersons = [];

    if (currentState.department.toLowerCase() == S.current.all.toLowerCase()) {
      filteredPersons = List.from(currentState.persons);
      filteredSelectedPersons = List.from(currentState.selectedPersons);
    } else {
      // (bug report p.51 — "when I choose a specific
      // department everything disappears"): only the selected side was
      // lower-cased, so "Finance" never matched and the list emptied. Both
      // sides are normalised now — same fix as the Results page (p.36).
      //
      // Large-screen bug report p.2 ("when I choose a department no
      // employees appear"): the person's name was looked up through
      // `Get.locale`, which can differ from the label language the dropdown
      // used, so the names never matched. The picked label is resolved to
      // department IDs and people are matched on their department ID.
      final String selected = currentState.department.trim().toLowerCase();
      final Set<String> selectedIds = <String>{
        for (final department in departmentCubit.departmentModels)
          if (department.displayName().trim().toLowerCase() == selected ||
              (department.departmentName ?? '').trim().toLowerCase() ==
                  selected ||
              (department.departmentNameInArabic ?? '').trim().toLowerCase() ==
                  selected)
            department.departmentID ?? '',
      }..remove('');
      bool inDepartment(PersonEntity element) =>
          selectedIds.contains(element.department) ||
          element.departmentName.trim().toLowerCase() == selected;
      filteredPersons = currentState.persons.where(inDepartment).toList();
      filteredSelectedPersons = currentState.selectedPersons
          .where(inDepartment)
          .toList();
    }

    emit(
      currentState.copyWith(
        filteredPersons: filteredPersons,
        filteredSelectedPersons: filteredSelectedPersons,
      ),
    );
  }

  /// Update department filter
  void updateDepartment(String department) {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    emit(currentState.copyWith(department: department));
    applyDepartmentFilter();
  }

  /// Initialize create group screen
  void initCreateGroup() {
    resetGroupController();
    getPersonsEntities();
  }

  /// Toggle person selection
  void togglePersonSelection(int index) {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    final filteredPersons = List<PersonEntity>.from(
      currentState.filteredPersons,
    );
    final selectedPersons = List<PersonEntity>.from(
      currentState.selectedPersons,
    );
    final filteredSelectedPersons = List<PersonEntity>.from(
      currentState.filteredSelectedPersons,
    );

    filteredPersons[index].isSelected = !filteredPersons[index].isSelected;

    if (filteredPersons[index].isSelected) {
      selectedPersons.add(filteredPersons[index]);
      filteredSelectedPersons.add(filteredPersons[index]);
    } else {
      selectedPersons.remove(filteredPersons[index]);
      filteredSelectedPersons.remove(filteredPersons[index]);
    }

    emit(
      currentState.copyWith(
        filteredPersons: filteredPersons,
        selectedPersons: selectedPersons,
        filteredSelectedPersons: filteredSelectedPersons,
      ),
    );
  }

  /// Method Name: [createGroup]
  ///
  /// Purpose: saves a new group with the picked people, logs it and tells
  /// the members (Section 2.3 "Added to Group"), then reloads the groups.
  ///
  /// Returns: what the save ended with; the page shows the message.
  Future<GroupSaveResult> createGroup() async {
    if (state is! FormsGroupLoaded) return GroupSaveResult.failed;
    final currentState = state as FormsGroupLoaded;

    // FB-SHARE-01: a group with no members is not saved.
    if (currentState.selectedPersons.isEmpty) {
      return GroupSaveResult.needsMembers;
    }

    final Either<Failure, void> result = await groupRepository.createGroup(
      groupName: currentState.groupName.trim(),
      description: currentState.groupDescription.trim(),
      selectedPersons: currentState.selectedPersons,
      image: currentState.groupImage?.path,
      currentUserId: _currentUserEmail,
    );
    if (result.isLeft()) return GroupSaveResult.failed;

    FormBuilderLogService.log(FormBuilderLogService.actionCreateGroup);
    FormBuilderNotificationService.notifyAddedToGroup(
      members: currentState.selectedPersons.map((PersonEntity p) => p.id),
      groupName: currentState.groupName.trim(),
    );
    await getGroups();
    return GroupSaveResult.saved;
  }

  /// Pick group image
  /// Function Name: [setGroupImage]
  ///
  /// Purpose: Keeps the image the user picked for the group (the page's
  /// picker does the picking; the cubit only holds the result).
  ///
  /// Parameters:
  /// - [image]: the picked file.
  void setGroupImage(File image) {
    if (state is! FormsGroupLoaded) return;
    emit((state as FormsGroupLoaded).copyWith(groupImage: image));
  }

  /// People who already have access to the form being shared. Passed in by
  /// the page that owns the ShareCubit (FB-SHARE-03: the old lookup used
  /// `Get.find<ShareCubit>()`, which is not registered with GetX, so it
  /// always failed silently).
  List<PersonEntity> _previousSelectedPersons = [];

  /// Get all groups
  ///
  /// [previousSelectedPersons] — people who already have access (optional;
  /// the last value passed is kept for reloads after create/edit/delete).
  Future<void> getGroups({List<PersonEntity>? previousSelectedPersons}) async {
    if (previousSelectedPersons != null) {
      _previousSelectedPersons = previousSelectedPersons;
    }

    // FB-SHARE-03: keep the loaded state on reload and replace only the
    // group lists (the screen used to be rebuilt from scratch with new text
    // controllers and cleared people lists after every create/edit/delete).
    final FormsGroupState previousState = state;
    if (previousState is! FormsGroupLoaded) {
      emit(FormsGroupLoading());
    }

    // Get ALL available persons from MainCoreEmployeeController.
    // FB-SHARE-03: the mapping is null-safe now, so one employee with a
    // missing job title or Arabic name no longer empties every group.
    final List<PersonEntity> availablePersons =
        (mainCoreEmployeeController.allEmployeesEntities ?? [])
            .map<PersonEntity>((e) => PersonEntityFactory.fromEmployeeEntity(e))
            .toList();

    final Either<Failure, List<GroupEntity>> result = await getUserGroupsUseCase
        .execute(
          currentUserId: _currentUserEmail,
          availablePersons: availablePersons,
          previousSelectedPersons: _previousSelectedPersons,
        );

    if (isClosed) return;
    if (result.isRight()) {
      final List<GroupEntity> groups = result.getOrElse(() => <GroupEntity>[]);

      if (state is FormsGroupLoaded) {
        final currentState = state as FormsGroupLoaded;
        emit(
          currentState.copyWith(
            groups: groups,
            filteredGroups: List.from(groups),
          ),
        );
        // Keep the active search / sort after a reload.
        _applyGroupView();
      } else {
        // If we're coming from Loading state, create a new Loaded state
        emit(
          FormsGroupLoaded(
            groups: groups,
            filteredGroups: List.from(groups),
            persons: const [],
            filteredPersons: const [],
            selectedPersons: const [],
            filteredSelectedPersons: const [],
            department: S.current.all,
          ),
        );
      }
      // Keep the group list live (create / edit / delete from anywhere).
      _live.watchPaths([
        '${getBaseUrl(FormApiConstants.formGroups)}/'
            '${Get.find<MainCoreEmployeeController>().employeeEntity!.email!}/'
            '${FormApiConstants.groups}',
      ], getGroups);
    } else {
      emit(FormsGroupError(S.current.groupsLoadFailed));
    }
  }

  final LiveRefresh _live = LiveRefresh();

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  // ── Group list search + sort (form bug report #36) ─────────────────────
  // Stable ids of the sort options; the user reads [groupSortLabel].
  static const String sortNameAsc = 'nameAsc';
  static const String sortNameDesc = 'nameDesc';
  static const String sortMembers = 'mostMembers';
  static const List<String> groupSortOptions = [
    sortNameAsc,
    sortNameDesc,
    sortMembers,
  ];

  /// The translated label of a sort option id.
  static String groupSortLabel(String option) {
    switch (option) {
      case sortNameAsc:
        return S.current.fbSortNameAsc;
      case sortNameDesc:
        return S.current.fbSortNameDesc;
      case sortMembers:
        return S.current.fbSortMostMembers;
    }
    return option;
  }

  String groupQuery = '';

  /// The active sort option id (null = none).
  String? get groupSort =>
      state is FormsGroupLoaded ? (state as FormsGroupLoaded).groupSort : null;

  /// Method Name: [searchGroups]
  ///
  /// Purpose: filters the group list by name or description.
  ///
  /// Parameters:
  /// - [query]: the search text.
  void searchGroups(String query) {
    groupQuery = query.trim().toLowerCase();
    _applyGroupView();
  }

  /// Large-screen bug report p.7 ("pressing the option a second time must
  /// unselect it" / "clickable issue in the sort"): the sort lived in a plain
  /// field and only `filteredGroups` was emitted. When the sorted list came
  /// out in the same order (two groups, same member count…) the new state was
  /// equal to the old one, nothing was emitted, the Sort button never rebuilt
  /// — so it stayed yellow after un-picking, or stayed grey after picking,
  /// and the next tap toggled from the stale value. The option is part of
  /// the state now, so every pick / un-pick emits and the button follows.
  void sortGroups(String? option) {
    if (state is! FormsGroupLoaded) return;
    final currentState = state as FormsGroupLoaded;
    emit(
      option == null
          ? currentState.copyWith(clearGroupSort: true)
          : currentState.copyWith(groupSort: option),
    );
    _applyGroupView();
  }

  /// Rebuilds `filteredGroups` from `groups` using the current query + sort.
  void _applyGroupView() {
    if (state is! FormsGroupLoaded) return;
    final currentState = state as FormsGroupLoaded;
    final String? groupSort = currentState.groupSort;
    final List<GroupEntity> view = currentState.groups
        .where(
          (g) =>
              groupQuery.isEmpty ||
              g.groupName.toLowerCase().contains(groupQuery) ||
              g.groupDescription.toLowerCase().contains(groupQuery),
        )
        .toList();
    switch (groupSort) {
      case sortNameAsc:
        view.sort(
          (a, b) =>
              a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase()),
        );
        break;
      case sortNameDesc:
        view.sort(
          (a, b) =>
              b.groupName.toLowerCase().compareTo(a.groupName.toLowerCase()),
        );
        break;
      case sortMembers:
        view.sort((a, b) => b.members.length.compareTo(a.members.length));
        break;
    }
    emit(currentState.copyWith(filteredGroups: view));
  }

  /// Method Name: [selectGroup]
  ///
  /// Purpose: picks or un-picks a group for sharing.
  ///
  /// Parameters:
  /// - [group]: the group.
  void selectGroup(GroupEntity group) {
    if (state is! FormsGroupLoaded) {
      return;
    }

    final currentState = state as FormsGroupLoaded;

    // Calculate new value once
    final newIsSelected = !group.isSelected;

    // Create new lists with updated entities
    final groups = currentState.groups.map((g) {
      if (g.groupId == group.groupId) {
        return g.copyWith(isSelected: newIsSelected);
      }
      return g;
    }).toList();

    final filteredGroups = currentState.filteredGroups.map((g) {
      if (g.groupId == group.groupId) {
        return g.copyWith(isSelected: newIsSelected);
      }
      return g;
    }).toList();

    emit(currentState.copyWith(groups: groups, filteredGroups: filteredGroups));
  }

  /// Method Name: [selectedGroupMembers]
  ///
  /// Purpose: every member of the picked groups, for the Share summary.
  /// Large-screen bug report p.10: members who already have access are
  /// included; sending renews their access.
  ///
  /// Returns: the members, in group order.
  List<PersonEntity> selectedGroupMembers() {
    if (state is! FormsGroupLoaded) return const [];
    final currentState = state as FormsGroupLoaded;
    return [
      for (final GroupEntity group in currentState.groups)
        if (group.isSelected) ...group.members,
    ];
  }

  /// Function Name: [validateGroupInfo]
  ///
  /// Purpose: Large-screen bug report p.11 — the group name and description
  /// are required. Marks the form as submitted (so the empty fields show
  /// their error) and returns whether both are filled.
  bool validateGroupInfo() {
    if (state is! FormsGroupLoaded) return false;
    final currentState = state as FormsGroupLoaded;
    emit(currentState.copyWith(submitted: true));
    return currentState.groupName.trim().isNotEmpty &&
        currentState.groupDescription.trim().isNotEmpty;
  }

  /// Check if group name exists
  bool isGroupNameExist(String groupName) {
    if (state is! FormsGroupLoaded) return false;

    final currentState = state as FormsGroupLoaded;
    for (GroupEntity group in currentState.groups) {
      if (groupName.toLowerCase() == group.groupName.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  /// Initialize group details screen
  void initGroupDetails(GroupEntity group) {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;

    // Large-screen bug report p.1: a member could be listed twice — kept
    // once per id here as well as in GetUserGroupsUseCase.
    final Set<String> seenIds = <String>{};
    final List<PersonEntity> members = group.members
        .where((PersonEntity p) => seenIds.add(p.id))
        .toList();

    emit(
      currentState.copyWith(
        selectedGroup: group,
        persons: List.from(members),
        filteredPersons: List.from(members),
        department: S.current.all.toLowerCase(),
        searchText: '',
        groupName: group.groupName,
        groupDescription: group.groupDescription,
        fieldsVersion: ++_fieldsVersion,
        clearGroupImage: true,
        submitted: false,
      ),
    );
  }

  /// Method Name: [deleteGroup]
  ///
  /// Purpose: deletes the open group and reloads the groups.
  ///
  /// Returns: true when deleted; false when the delete failed
  /// (FB-SHARE-04: the result is no longer ignored).
  Future<bool> deleteGroup() async {
    if (state is! FormsGroupLoaded) return false;
    final currentState = state as FormsGroupLoaded;
    if (currentState.selectedGroup == null) return false;

    final Either<Failure, void> result = await groupRepository.deleteGroup(
      userId: _currentUserEmail,
      groupId: currentState.selectedGroup!.groupId,
    );
    if (result.isLeft()) return false;
    FormBuilderLogService.log(FormBuilderLogService.actionDeleteGroup);
    await getGroups();
    return true;
  }

  /// Remove person from group
  void dropPerson(PersonEntity person) {
    if (state is! FormsGroupLoaded) return;

    final currentState = state as FormsGroupLoaded;
    final filteredPersons = List<PersonEntity>.from(
      currentState.filteredPersons,
    )..remove(person);
    final persons = List<PersonEntity>.from(currentState.persons)
      ..remove(person);

    emit(
      currentState.copyWith(filteredPersons: filteredPersons, persons: persons),
    );
  }

  /// Method Name: [editGroup]
  ///
  /// Purpose: saves the open group (name, description, image, removed
  /// members), sends the Section 2.3 notices and reloads the groups.
  /// Bug report p.60: removed members are matched by id.
  ///
  /// Returns: what the save ended with; the page shows the message.
  Future<GroupSaveResult> editGroup() async {
    if (state is! FormsGroupLoaded) return GroupSaveResult.failed;
    final currentState = state as FormsGroupLoaded;
    if (currentState.selectedGroup == null) return GroupSaveResult.failed;

    final Set<String> keptIds = currentState.persons
        .map((PersonEntity p) => p.id)
        .toSet();
    final List<String> removedPersons = <String>[
      for (final PersonEntity person in currentState.selectedGroup!.members)
        if (!keptIds.contains(person.id)) person.id,
    ];

    // FB-SHARE-01: a group cannot be saved with no members.
    if (keptIds.isEmpty) return GroupSaveResult.needsMembers;

    final Either<Failure, void> result = await groupRepository.editGroup(
      groupImage: currentState.groupImage?.path,
      groupName: currentState.groupName.trim(),
      description: currentState.groupDescription.trim(),
      groupId: currentState.selectedGroup!.groupId,
      removedPersons: removedPersons,
      currentUserId: _currentUserEmail,
    );
    if (result.isLeft()) return GroupSaveResult.failed;

    // Section 2.3 "Removed from Group" and "Group Name Updated". The rename
    // goes to the members who are still in the group.
    final String oldName = currentState.selectedGroup!.groupName.trim();
    final String newName = currentState.groupName.trim();
    if (removedPersons.isNotEmpty) {
      FormBuilderLogService.log(FormBuilderLogService.actionRemoveGroupMembers);
      FormBuilderNotificationService.notifyRemovedFromGroup(
        members: removedPersons,
        groupName: oldName,
      );
    }
    if (newName.isNotEmpty && newName != oldName) {
      FormBuilderLogService.log(FormBuilderLogService.actionRenameGroup);
      FormBuilderNotificationService.notifyGroupRenamed(
        members: keptIds.where((String id) => !removedPersons.contains(id)),
        oldGroupName: oldName,
        newGroupName: newName,
      );
    }
    await getGroups();
    return GroupSaveResult.saved;
  }
}
