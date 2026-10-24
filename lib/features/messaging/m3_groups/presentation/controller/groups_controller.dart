/// Module: messaging / groups / presentation/controller/groups_controller.dart
/// ************************* FILE INFO *************************** ///
/// File Name: groups_controller.dart
/// Description: Groups controller — messaging Groups sub-feature.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'dart:developer';
// Date: 3/9/2024
// By:Mohamed Ashraf
// Last update: 3/9/2024
// Objectives: This file is responsible for providing the groups controller used in the community feature.

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/enums/group_member_status.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/user_category.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/group_chat_interface_parameters.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/user_connection_interface_parameters.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/domain/enums/sort_enum.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/data/models/group_admin_model.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/group_entity.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/member_entity.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/base_repository/base_group_repository.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/usecases/create_group_use_case.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/usecases/get_groups_use_case.dart';
// ADDED 2/9/2026 — spec section 2.4.
import 'package:knowticed_plus/features/messaging/helpers/notifications/messages_notification_service.dart';
// ADDED 2/9/2026 — the Messages role switches.
import 'package:knowticed_plus/features/messaging/helpers/main/messages_permissions.dart';

part 'groups_controller/groups_loaded.dart';
part 'groups_controller/groups_cubit_methods.dart';

// State classes
abstract class GroupsState {}

class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsError extends GroupsState {
  final String message;

  GroupsError(this.message);
}

// Cubit
class GroupsCubit extends Cubit<GroupsState> {
  /// Public [emit] for this cubit's extension / part files and widgets
  /// ([emit] itself is protected).
  void emitState(GroupsState state) => emit(state);

  final BaseGroupsRepository repository;
  late GroupChatInterfaceParameters currentUser;
  late Future<List<UserConnectionInterfaceParameters>> Function()
      getAllUsersDate;

  TextEditingController searchController = TextEditingController();
  final TextEditingController membersSearchTextField = TextEditingController();

  GroupsCubit({required this.repository}) : super(GroupsInitial());

  bool isCreateGroup = false;

  /// ********************** CREATE GROUP CONTROLLERS ***********************
  List<MemberEntity> _members = [];
  List<MemberEntity> get members => _members;

  List<MemberEntity> _selectedMembers = [];
  List<MemberEntity> get selectedMembers => _selectedMembers;

  String _searchText = '';
  String get searchText => _searchText;

  String _userCategoryId = '';
  String get userCategoryId => _userCategoryId;
  set userCategoryId(String value) {
    _userCategoryId = value;
    _emitLoadedState();
  }

  bool _isMemberSelected = false;
  bool get isMemberSelected => _isMemberSelected;

  void searchMembers(String value) {
    _searchText = value;
    _emitLoadedState();
  }

  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupNameArController = TextEditingController();
  TextEditingController groupDescriptionController = TextEditingController();
  TextEditingController groupDescriptionArController = TextEditingController();
  GlobalKey<FormState> newGroupFormKey = GlobalKey<FormState>();
  File? _groupImage;
  File? get groupImage => _groupImage;

  void initialize({required TextEditingController searchController}) {
    this.searchController = searchController;
    _selectedMembers = [];
    emit(GroupsLoaded(
      groups: [],
      members: [],
      selectedMembers: [],
      isMemberSelected: false,
      searchText: '',
      userCategoryId: '',
      isMakePrivateEnabled: true,
      isAdminEnabled: true,
      isDisappearingMessagesEnabled: true,
      isMuteEnabled: true,
      selectedRole: {},
    ));
  }

  /// Categories used to resolve member departments — supplied by ConnectionsCubit
  /// so the domain entity never reaches into presentation via GetX (§3).
  List<UserCategory>? _categories;

  void toggleSelection(MemberEntity member) {
    if (member.isSelected) {
      _selectedMembers.remove(member);
    } else {
      _selectedMembers.add(member);
    }
    member.isSelected = !member.isSelected;
    _isMemberSelected = _selectedMembers.isNotEmpty;
    _emitLoadedState();
  }

  void removeSelectedMember(MemberEntity member) {
    member.isSelected = false;
    _selectedMembers.remove(member);
    _isMemberSelected = _selectedMembers.isNotEmpty;
    _emitLoadedState();
  }

  /// Sets the picked group image. Picking itself happens in the page via
  /// MediaPickerService — the cubit no longer touches the picker (§16/§20).
  void setGroupImage(File? image) {
    _groupImage = image;
    _emitLoadedState();
  }

  // ✅ Updated filteredMembers to support multi-select comma-separated ids
  List<MemberEntity> get filteredMembers {
    final selectedIds = _userCategoryId.isEmpty
        ? <String>[]
        : _userCategoryId.split(',').where((id) => id.isNotEmpty).toList();

    final List<MemberEntity> matched;

    if (_searchText.isEmpty && selectedIds.isEmpty) {
      matched = _members;
    } else {
      final List<MemberEntity> result = [];
      for (var member in _members) {
        final matchesSearch = member.primaryLanguageName
                .toLowerCase()
                .contains(_searchText.trim().toLowerCase()) ||
            (member.secondaryLanguageName?.contains(_searchText.trim()) ??
                false);

        final matchesCategory = selectedIds.isEmpty ||
            selectedIds.contains(member.category?.categoryId);

        if (matchesSearch && matchesCategory) {
          result.add(member);
        }
      }
      matched = result;
    }

    return _selectedFirst(matched);
  }

  /// Ticked members float to the top of the grid, everything else keeps the
  /// order it already had.
  ///
  /// ADDED 2/9/2026. On a long employee list the person you just ticked
  /// scrolled away and there was no way to see what was selected without
  /// hunting for it. A STABLE partition, not a sort — a sort with a boolean
  /// comparator would also reshuffle the members that share a value.
  ///
  /// Returns a NEW list, so [_members] itself is never reordered.
  List<MemberEntity> _selectedFirst(List<MemberEntity> members) {
    final List<MemberEntity> selected = [];
    final List<MemberEntity> rest = [];
    for (final member in members) {
      (member.isSelected ? selected : rest).add(member);
    }
    return [...selected, ...rest];
  }

  void clearGroupData() {
    groupNameController.clear();
    groupNameArController.clear();
    groupDescriptionController.clear();
    groupDescriptionArController.clear();
    _groupImage = null;
    for (var member in _selectedMembers) {
      member.isSelected = false;
    }
    _selectedMembers = [];
    newGroupFormKey.currentState?.reset();
    _isMemberSelected = false;
    _emitLoadedState();
  }

  ///********************** SWITCHES CONTROLLERS ***********************
  bool _isMakePrivateEnabled = true;
  bool get isMakePrivateEnabled => _isMakePrivateEnabled;

  void onChangedMakePrivate(bool value) {
    _isMakePrivateEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  bool _isAdminEnabled = true;
  bool get isAdminEnabled => _isAdminEnabled;

  void onChangedAdmin(bool value) {
    _isAdminEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  bool _isDisappearingMessagesEnabled = true;
  bool get isDisappearingMessagesEnabled => _isDisappearingMessagesEnabled;

  void onChangedDisappearingMessages(bool value) {
    _isDisappearingMessagesEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  bool _isMuteEnabled = true;
  bool get isMuteEnabled => _isMuteEnabled;

  void onChangMuteMessages(bool value) {
    _isMuteEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  /// ********************** GROUPS LIST CONTROLLERS ***********************
  List<GroupEntity> allGroups = [];
  List<GroupEntity> _groups = [];
  List<GroupEntity> get groups => _groups;

  /// Groups where both [otherUserId] and [currentUserId] are members.
  /// Error handling lives here (C1) so the UI never wraps this in try/catch
  /// (§11.2).
  List<GroupEntity> commonGroupsWith(String otherUserId, String currentUserId) {
    if (otherUserId.isEmpty || currentUserId.isEmpty) return [];
    try {
      return _groups.where((group) {
        final memberIds = group.members.map((m) => m.memberId).toSet();
        return memberIds.contains(otherUserId) &&
            memberIds.contains(currentUserId);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  GroupEntity? _selectedGroup;
  GroupEntity? get selectedGroup => _selectedGroup;

  StreamSubscription? groupsSubscription;

  // FIXED 24/9/2026 — realtime groups list: a Left used to cancel the
  // subscription for good (groups froze until restart). It now reconnects.
  Timer? _groupsRetryTimer;
  int _groupsRetryAttempt = 0;

  void _scheduleGroupsResubscribe() {
    if (isClosed) return;
    _groupsRetryTimer?.cancel();
    final int seconds =
        1 << (_groupsRetryAttempt < 4 ? _groupsRetryAttempt : 4);
    _groupsRetryAttempt++;
    _groupsRetryTimer = Timer(Duration(seconds: seconds), () {
      if (!isClosed) getGroups();
    });
  }

  void getGroups() {
    closeGetGroupsSubscription();
    groupsSubscription = GetGroupsUseCase(groupRepository: repository)
        .execute(userId: currentUser.userId, categories: _categories)
        .listen((Either<Failure, dynamic> groupsEither) {
      if (isClosed) return;
      if (groupsEither.isLeft()) {
        _scheduleGroupsResubscribe();
        return;
      }
      if (groupsEither.isRight()) {
        _groupsRetryAttempt = 0;
        allGroups = groupsEither.getOrElse(() => []);
        log(" all groups: ${allGroups.length}");
        filterGroups();
        if (_selectedGroup != null) {
          // `.first` threw (and killed the stream) when the selected group
          // was no longer in the filtered list.
          final match = _groups
              .where((group) => group.groupId == _selectedGroup!.groupId);
          if (match.isNotEmpty) _selectedGroup = match.first;
          _selectedRole.clear();
        }
        _emitLoadedState();
      }
    },
            onError: (Object _, StackTrace __) => _scheduleGroupsResubscribe(),
            onDone: _scheduleGroupsResubscribe,
            cancelOnError: false);
  }

  void closeGetGroupsSubscription() {
    _groupsRetryTimer?.cancel();
    groupsSubscription?.cancel();
  }

  void resetCreateGroupControllers() {
    isCreateGroup = true;
    groupNameController.clear();
    groupNameArController.clear();
    groupDescriptionController.clear();
    groupDescriptionArController.clear();
    _groupImage = null;
    _isMakePrivateEnabled = true;
    _isAdminEnabled = true;
    _isDisappearingMessagesEnabled = true;
    _isMuteEnabled = true;
    _selectedMembers = [];
    membersSearchTextField.clear();
    newGroupFormKey.currentState?.reset();
    _isMemberSelected = false;
    _emitLoadedState();
  }

  /// Called when a direct message is opened, so the group is no longer
  /// treated as the active chat.
  void clearSelectedGroup() {
    if (_selectedGroup == null) return;
    _selectedGroup = null;
    _emitLoadedState(clearSelectedGroup: true);
  }

  void selectGroup(GroupEntity groupEntity) {
    log('🟢 selectGroup called for: ${groupEntity.primaryLanguageName}');
    log('🟢 groupEntity.groupNameAr: "${groupEntity.groupNameAr}"');
    log('🟢 groupEntity.groupDescriptionAr: "${groupEntity.groupDescriptionAr}"');
    isCreateGroup = false;
    _selectedGroup = groupEntity;
    log("selected group: ${_selectedGroup!.primaryLanguageName}");
    groupNameController.text = _selectedGroup!.primaryLanguageName;
    groupNameArController.text = _selectedGroup!.groupNameAr ?? '';
    groupDescriptionController.text = _selectedGroup!.groupDescription;
    groupDescriptionArController.text =
        _selectedGroup!.groupDescriptionAr ?? '';
    _isMakePrivateEnabled = !_selectedGroup!.isPublic;
    _isAdminEnabled = _selectedGroup!.isOnlyAdminsCanSend;
    _isDisappearingMessagesEnabled = _selectedGroup!.isDisappearingMessages;
    _isMuteEnabled = !_selectedGroup!.isUnMuted;
    _isMakePrivateEnabled = !_selectedGroup!.isPublic;
    _groupImage = null;
    _selectedRole.clear();
    _emitLoadedState();
  }

  void filterGroups() {
    _groups = allGroups;
    if (searchController.text.isNotEmpty) {
      _groups = _groups
          .where((group) => group.primaryLanguageName
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }
    sortGroups();
    _emitLoadedState();
  }

  final Map<int, String> _selectedRole = {};
  Map<int, String> get selectedRole => _selectedRole;

  void setRole(int index, String role) {
    _selectedRole[index] = role;
    _emitLoadedState();
  }

  Future<void> updateGroupData() async {
    await repository.updateGroupData(
      image: _groupImage?.path,
      groupName: groupNameController.text.trim() !=
              (_selectedGroup!.primaryLanguageName)
          ? groupNameController.text.trim()
          : null,
      groupNameAr: groupNameArController.text.trim() !=
              (_selectedGroup!.groupNameAr ?? '')
          ? groupNameArController.text.trim()
          : null,
      groupDescription: groupDescriptionController.text.trim() !=
              (_selectedGroup!.groupDescription)
          ? groupDescriptionController.text.trim()
          : null,
      groupDescriptionAr: groupDescriptionArController.text.trim() !=
              (_selectedGroup!.groupDescriptionAr ?? '')
          ? groupDescriptionArController.text.trim()
          : null,
      isPublic: (!_isMakePrivateEnabled != (_selectedGroup!.isPublic))
          ? !_isMakePrivateEnabled
          : null,
      isOnlyAdminsCanSend:
          (_isAdminEnabled != (_selectedGroup!.isOnlyAdminsCanSend))
              ? _isAdminEnabled
              : null,
      isDisappearingMessages: (_isDisappearingMessagesEnabled !=
              (_selectedGroup!.isDisappearingMessages))
          ? _isDisappearingMessagesEnabled
          : null,
      isUnMuted: (!_isMuteEnabled != (_selectedGroup!.isUnMuted))
          ? !_isMuteEnabled
          : null,
      groupEntity: _selectedGroup!,
    );
    await saveMembersState();
  }

  Future<void> saveMembersState() async {
    await saveRemovedMembers();
    await saveAddedAdmins();
    await removeAdmin();
  }

  Future<void> saveRemovedMembers() async {
    List<String> removedMembers = [];
    for (int key in _selectedRole.keys) {
      if (_selectedRole[key] == 'Remove') {
        removedMembers.add(_selectedGroup!.members[key].memberId);
      }
    }
    if (removedMembers.isNotEmpty) {
      await repository.removeGroupMembers(
          groupId: _selectedGroup!.groupId, members: removedMembers);
    }
  }

  Future<void> addGroupMember(MemberEntity member) async {
    await repository.addGroupMembers(
        groupId: _selectedGroup!.groupId, member: member);
    membersSearchTextField.clear();
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  Future<void> saveAddedAdmins() async {
    List<String> addedAdmins = [];
    for (int key in _selectedRole.keys) {
      if (_selectedRole[key] == GroupMemberStatus.admin.name &&
          _selectedGroup!.members[key].isAdmin == false) {
        addedAdmins.add(_selectedGroup!.members[key].memberId);
      }
    }
    if (addedAdmins.isNotEmpty) {
      repository.addGroupAdmins(
          groupId: _selectedGroup!.groupId, admins: addedAdmins);
    }
  }

  Future<void> removeAdmin() async {
    List<String> removedAdmins = [];
    for (int key in _selectedRole.keys) {
      if (_selectedRole[key] == GroupMemberStatus.member.name &&
          _selectedGroup!.members[key].isAdmin == true) {
        removedAdmins.add(_selectedGroup!.members[key].memberId);
      }
    }
    if (removedAdmins.isNotEmpty) {
      repository.removeGroupAdmins(
          groupId: _selectedGroup!.groupId, admins: removedAdmins);
    }
  }

  void initGroupProfileController() {
    log('🟡 initGroupProfileController called');

    if (_selectedGroup == null) {
      log('🔴 selectedGroup is null — skipping');
      return;
    }

    // ── Populate controllers from selectedGroup ──
    groupNameController.text = _selectedGroup!.primaryLanguageName;
    groupNameArController.text = _selectedGroup!.groupNameAr ?? '';
    groupDescriptionController.text = _selectedGroup!.groupDescription;
    groupDescriptionArController.text =
        _selectedGroup!.groupDescriptionAr ?? '';

    // ── Populate switches ──
    _isMakePrivateEnabled = !_selectedGroup!.isPublic;
    _isAdminEnabled = _selectedGroup!.isOnlyAdminsCanSend;
    _isDisappearingMessagesEnabled = _selectedGroup!.isDisappearingMessages;
    _isMuteEnabled = !_selectedGroup!.isUnMuted;
    _groupImage = null;
    _selectedRole.clear();

    log('🟢 Controllers populated:');
    log('🟢 name EN: "${groupNameController.text}"');
    log('🟢 name AR: "${groupNameArController.text}"');
    log('🟢 desc EN: "${groupDescriptionController.text}"');
    log('🟢 desc AR: "${groupDescriptionArController.text}"');

    _emitLoadedState();
  }

  List<MemberEntity> filteredMentionsMembers(String memberName) {
    return _selectedGroup!.members
        .where((member) =>
            member.primaryLanguageName
                .toLowerCase()
                .contains(memberName.toLowerCase()) ||
            (member.secondaryLanguageName?.contains(memberName) ?? false))
        .toList();
  }

  void sortGroups({SortEnum? sortType}) {
    if (sortType == null) return;
    switch (sortType) {
      case SortEnum.readMessages:
        _groups.sort(
            (a, b) => b.myNumUnreadMessage.compareTo(a.myNumUnreadMessage));
        break;
      case SortEnum.unRead:
        _groups.sort(
            (a, b) => a.myNumUnreadMessage.compareTo(b.myNumUnreadMessage));
        break;
    }
  }

  void deleteGroup() {
    // ADDED 2/9/2026 — spec section 2.4, "Group Deleted".
    //
    // ⚠️ RAISED BEFORE THE DELETE, and that ordering is the whole point: the
    // recipients ARE the group's members, and once the document is gone there
    // is no membership list left to read. Every other trigger fires after its
    // write; this one cannot.
    //
    // Not awaited, and it cannot throw — the delete must not be held up by,
    // or fail because of, a notification.
    final GroupEntity deleted = _selectedGroup!;
    unawaited(
      MessagesNotificationService.notifyGroupDeleted(
        memberUserIds:
            deleted.members.map((MemberEntity m) => m.memberId).toList(),
        groupName: deleted.primaryLanguageName,
        deletedByName: MessagesNotificationService.currentUserName,
      ),
    );

    repository.deleteGroup(groupId: deleted.groupId);
    _selectedGroup = null;
    _emitLoadedState(clearSelectedGroup: true);
  }

  @override
  Future<void> close() {
    closeGetGroupsSubscription();
    searchController.dispose(); // ← add this
    groupNameController.dispose();
    groupNameArController.dispose();
    groupDescriptionController.dispose();
    groupDescriptionArController.dispose();
    membersSearchTextField.dispose();
    return super.close();
  }
}
