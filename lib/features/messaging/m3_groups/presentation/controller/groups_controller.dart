/// Module: messaging / groups / presentation/controller/groups_controller.dart
/// ************************* FILE INFO *************************** ///
/// File Name: groups_controller.dart
/// Purpose: Groups controller — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

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
import 'package:grc_module/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:grc_module/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';

import 'package:grc_module/core/network/message_module/services/error_handler.dart';
import 'package:grc_module/core/helper/main_helper/get_dialog_helper.dart';
import '../../../../../core/helper/message_module/interface/entity/group_chat_interface_parameters.dart';
import '../../../../../core/helper/message_module/interface/entity/user_connection_interface_parameters.dart';
import '../../../m4_messaging_home/domain/enums/sort_enum.dart';
import '../../data/models/group_admin_model.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/base_repository/base_group_repository.dart';
import '../../domain/usecases/create_group_use_case.dart';
import '../../domain/usecases/get_groups_use_case.dart';

// State classes
abstract class GroupsState {}

class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<GroupEntity> groups;
  final GroupEntity? selectedGroup;
  final List<MemberEntity> members;
  final List<MemberEntity> selectedMembers;
  final bool isMemberSelected;
  final File? groupImage;
  final String searchText;
  final String userCategoryId;
  final bool isMakePrivateEnabled;
  final bool isAdminEnabled;
  final bool isDisappearingMessagesEnabled;
  final bool isMuteEnabled;
  final Map<int, String> selectedRole;

  GroupsLoaded({
    required this.groups,
    this.selectedGroup,
    required this.members,
    required this.selectedMembers,
    required this.isMemberSelected,
    this.groupImage,
    required this.searchText,
    required this.userCategoryId,
    required this.isMakePrivateEnabled,
    required this.isAdminEnabled,
    required this.isDisappearingMessagesEnabled,
    required this.isMuteEnabled,
    required this.selectedRole,
  });

  GroupsLoaded copyWith({
    List<GroupEntity>? groups,
    GroupEntity? selectedGroup,
    List<MemberEntity>? members,
    List<MemberEntity>? selectedMembers,
    bool? isMemberSelected,
    File? groupImage,
    String? searchText,
    String? userCategoryId,
    bool? isMakePrivateEnabled,
    bool? isAdminEnabled,
    bool? isDisappearingMessagesEnabled,
    bool? isMuteEnabled,
    Map<int, String>? selectedRole,
    bool clearGroupImage = false,
    bool clearSelectedGroup = false,
  }) {
    return GroupsLoaded(
      groups: groups ?? this.groups,
      selectedGroup:
      clearSelectedGroup ? null : (selectedGroup ?? this.selectedGroup),
      members: members ?? this.members,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      isMemberSelected: isMemberSelected ?? this.isMemberSelected,
      groupImage: clearGroupImage ? null : (groupImage ?? this.groupImage),
      searchText: searchText ?? this.searchText,
      userCategoryId: userCategoryId ?? this.userCategoryId,
      isMakePrivateEnabled: isMakePrivateEnabled ?? this.isMakePrivateEnabled,
      isAdminEnabled: isAdminEnabled ?? this.isAdminEnabled,
      isDisappearingMessagesEnabled:
      isDisappearingMessagesEnabled ?? this.isDisappearingMessagesEnabled,
      isMuteEnabled: isMuteEnabled ?? this.isMuteEnabled,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}

class GroupsError extends GroupsState {
  final String message;

  GroupsError(this.message);
}

// Cubit
class GroupsCubit extends Cubit<GroupsState> {
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

  void getMembers({required ConnectionsCubit connectionsCubit}) {
    _categories = connectionsCubit.categories;
    _members = [];
    _selectedMembers = [];
    connectionsCubit.connections.forEach((connection) {
      log('👤 [getMembers] ${connection.primaryLanguageName} | userCategory: ${connection.userCategory?.primaryLanguageName ?? "NULL"} | categoryId: ${connection.userCategory?.categoryId ?? "NULL"}');
      _members.add(MemberEntity.fromSingleConnectionEntity(connection));
    });
    log("getMembers called - members count: ${_members.length}");
    _emitLoadedState();
  }

  void _enrichMembersWithCategories() {
    if (_selectedGroup == null) return;

    // Categories are stored on this cubit (set from ConnectionsCubit) — no GetX.
    final categories = _categories;

    log('🔧 [enrichMembers] categories available: ${categories?.length ?? "NULL"}');

    if (categories == null || categories.isEmpty) {
      log('❌ [enrichMembers] No categories to enrich with');
      return;
    }

    for (final member in _selectedGroup!.members) {
      if (member.category != null) continue; // already resolved

      // Try to match via categoryId stored on the member
      // Since categoryId may be null, try matching via departmentId from employee data
      log('🔧 [enrichMembers] member: ${member.primaryLanguageName} | categoryId: ${member.category?.categoryId ?? "NULL"}');
    }
  }




  // ✅ Updated to support comma-separated multi-select category ids
  void searchMembersToAddToGroup(
      String value,
      ConnectionsCubit connectionsCubit,
      MessagingHomeCubit homeCubit) {
    getMembers(connectionsCubit: connectionsCubit);
    try
    {
      log("selected category ids: $_userCategoryId");

      // ✅ Split comma-separated ids into a list
      final selectedIds = _userCategoryId.isEmpty
          ? <String>[]
          : _userCategoryId.split(',').where((id) => id.isNotEmpty).toList();

      _members = _members.where((member) {
        final matchesSearch = member.primaryLanguageName
            .toLowerCase()
            .contains(value.toLowerCase()) ||
            (member.secondaryLanguageName?.contains(value) ?? false);

        // ✅ If no categories selected → show all; else match any selected id
        final matchesCategory = selectedIds.isEmpty ||
            selectedIds.contains(member.category?.categoryId);

        bool result = matchesSearch && matchesCategory;
        log("member: ${member.category?.primaryLanguageName} - $result");
        return result;
      }).toList();
    } catch (e) {
      log("error in searchMembersToAddToGroup: $e");
    }

    // remove members already in the group
    if (state is GroupsLoaded &&
        (state as GroupsLoaded).selectedGroup != null) {
      for (var member in (state as GroupsLoaded).selectedGroup!.members) {
        _members.removeWhere((element) => element.memberId == member.memberId);
      }
    }
    _emitLoadedState(updateId: 'groupChatProfile');
  }

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

    if (_searchText.isEmpty && selectedIds.isEmpty) {
      return _members;
    }

    List<MemberEntity> result = [];
    for (var member in _members) {
      final matchesSearch = member.primaryLanguageName
          .toLowerCase()
          .contains(_searchText.trim().toLowerCase()) ||
          (member.secondaryLanguageName?.contains(_searchText.trim()) ?? false);

      final matchesCategory = selectedIds.isEmpty ||
          selectedIds.contains(member.category?.categoryId);

      if (matchesSearch && matchesCategory) {
        result.add(member);
      }
    }
    return result;
  }

  Future<void> createGroup(BuildContext context) async {
    if (newGroupFormKey.currentState!.validate() && _isMemberSelected) {
      GroupAdminModel admin = GroupAdminModel(
          adminId: currentUser.userId,
          isAdmin: [true],
          timestamps: [Timestamp.now()]);
      _selectedMembers.add(MemberEntity(
          memberId: currentUser.userId,
          isAdmin: true,
          primaryLanguageName: currentUser.primaryLanguageName,
          secondaryLanguageName: currentUser.secondaryLanguageName,
          primaryLanguageSubInfo: currentUser.primaryLanguageSubInfo,
          secondaryLanguageSubInfo: currentUser.secondaryLanguageSubInfo,
          memberPhone: currentUser.phone,
          numOfUnreadMessages: 0,
          memberImage: currentUser.imageUri,
          addedTime: null));

      var response =
      await CreateGroupUseCase(groupRepository: repository).execute(
        groupName: groupNameController.text,
        groupNameAr: groupNameArController.text.trim().isEmpty
            ? null
            : groupNameArController.text.trim(),
        groupDescription: groupDescriptionController.text,
        groupDescriptionAr: groupDescriptionArController.text.trim().isEmpty
            ? null
            : groupDescriptionArController.text.trim(),
        groupImage: _groupImage?.path,
        groupMembers: _selectedMembers,
        isDisappearingMessages: _isDisappearingMessagesEnabled,
        isOnlyAdminsCanSend: _isAdminEnabled,
        isPublic: !_isMakePrivateEnabled,
        isUnMuted: !_isMuteEnabled,
        createdBy: currentUser.userId,
        groupAdmins: [admin],
      );
      if (response.isRight()) {
        Navigator.of(context).pop();
        // GetDialogHelper.generalDialog(
        //   context: context,
        //   child: DefaultDialog(
        //     title: "Creating New Group",
        //     subTitle: "You Successfully Created New Group",
        //     autoClose: true,
        //     lottieAsset: "assets/lottie_assets/main_lottie_assets/assets_lottie_successful.json",
        //     showButtons: false,
        //   ),
        // );
      }
    }
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

  onChangedMakePrivate(bool value) {
    _isMakePrivateEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  bool _isAdminEnabled = true;
  bool get isAdminEnabled => _isAdminEnabled;

  onChangedAdmin(bool value) {
    _isAdminEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  bool _isDisappearingMessagesEnabled = true;
  bool get isDisappearingMessagesEnabled => _isDisappearingMessagesEnabled;

  onChangedDisappearingMessages(bool value) {
    _isDisappearingMessagesEnabled = value;
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  bool _isMuteEnabled = true;
  bool get isMuteEnabled => _isMuteEnabled;

  onChangMuteMessages(bool value) {
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

  getGroups() {
    closeGetGroupsSubscription();
    groupsSubscription = GetGroupsUseCase(groupRepository: repository)
        .execute(userId: currentUser.userId, categories: _categories)
        .listen((Either<Failure, dynamic> groupsEither) {
      if (groupsEither.isLeft()) groupsSubscription!.cancel();
      if (groupsEither.isRight()) {
        allGroups = groupsEither.getOrElse(() => []);
        log(" all groups: ${allGroups.length}");
        filterGroups();
        if (_selectedGroup != null) {
          _selectedGroup = _groups
              .where((group) => group.groupId == _selectedGroup!.groupId)
              .first;
          _selectedRole.clear();
        }
        _emitLoadedState();
      }
    });
  }

  void closeGetGroupsSubscription() {
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

  void selectGroup(GroupEntity groupEntity) {
    log('🟢 selectGroup called for: ${groupEntity.primaryLanguageName}');
    log('🟢 groupEntity.groupNameAr: "${groupEntity.groupNameAr}"');
    log('🟢 groupEntity.groupDescriptionAr: "${groupEntity.groupDescriptionAr}"');
    isCreateGroup = false;
    _selectedGroup = groupEntity;
    log("selected group: ${_selectedGroup!.primaryLanguageName}");
    groupNameController.text = _selectedGroup!.primaryLanguageName ?? '';
    groupNameArController.text = _selectedGroup!.groupNameAr ?? '';
    groupDescriptionController.text = _selectedGroup!.groupDescription ?? '';
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

  Map<int, String> _selectedRole = {};
  Map<int, String> get selectedRole => _selectedRole;

  void setRole(int index, String role) {
    _selectedRole[index] = role;
    _emitLoadedState();
  }

  updateGroupData() async {
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

  saveRemovedMembers() async {
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

  addGroupMember(MemberEntity member) async {
    await repository.addGroupMembers(
        groupId: _selectedGroup!.groupId, member: member);
    membersSearchTextField.clear();
    _emitLoadedState(updateId: 'groupChatProfile');
  }

  saveAddedAdmins() {
    List<String> addedAdmins = [];
    for (int key in _selectedRole.keys) {
      if (_selectedRole[key] == 'Admin' &&
          _selectedGroup!.members[key].isAdmin == false) {
        addedAdmins.add(_selectedGroup!.members[key].memberId);
      }
    }
    if (addedAdmins.isNotEmpty) {
      repository.addGroupAdmins(
          groupId: _selectedGroup!.groupId, admins: addedAdmins);
    }
  }

  removeAdmin() {
    List<String> removedAdmins = [];
    for (int key in _selectedRole.keys) {
      if (_selectedRole[key] == 'Member' &&
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
    groupNameController.text = _selectedGroup!.primaryLanguageName ?? '';
    groupNameArController.text = _selectedGroup!.groupNameAr ?? '';
    groupDescriptionController.text = _selectedGroup!.groupDescription ?? '';
    groupDescriptionArController.text = _selectedGroup!.groupDescriptionAr ?? '';

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

  filteredMentionsMembers(String memberName) {
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
      case SortEnum.ReadMessages:
        _groups.sort(
                (a, b) => b.myNumUnreadMessage.compareTo(a.myNumUnreadMessage));
        break;
      case SortEnum.UnRead:
        _groups.sort(
                (a, b) => a.myNumUnreadMessage.compareTo(b.myNumUnreadMessage));
        break;
    }
  }

  void deleteGroup() {
    repository.deleteGroup(groupId: _selectedGroup!.groupId);
    _selectedGroup = null;
    _emitLoadedState(clearSelectedGroup: true);
  }

  void _emitLoadedState(
      {String? updateId,
        bool clearGroupImage = false,
        bool clearSelectedGroup = false}) {
    if (state is GroupsLoaded) {
      emit((state as GroupsLoaded).copyWith(
        groups: _groups,
        selectedGroup: _selectedGroup,
        members: _members,
        selectedMembers: _selectedMembers,
        isMemberSelected: _isMemberSelected,
        groupImage: _groupImage,
        searchText: _searchText,
        userCategoryId: _userCategoryId,
        isMakePrivateEnabled: _isMakePrivateEnabled,
        isAdminEnabled: _isAdminEnabled,
        isDisappearingMessagesEnabled: _isDisappearingMessagesEnabled,
        isMuteEnabled: _isMuteEnabled,
        selectedRole: _selectedRole,
        clearGroupImage: clearGroupImage,
        clearSelectedGroup: clearSelectedGroup,
      ));
    } else {
      emit(GroupsLoaded(
        groups: _groups,
        selectedGroup: clearSelectedGroup ? null : _selectedGroup,
        members: _members,
        selectedMembers: _selectedMembers,
        isMemberSelected: _isMemberSelected,
        groupImage: clearGroupImage ? null : _groupImage,
        searchText: _searchText,
        userCategoryId: _userCategoryId,
        isMakePrivateEnabled: _isMakePrivateEnabled,
        isAdminEnabled: _isAdminEnabled,
        isDisappearingMessagesEnabled: _isDisappearingMessagesEnabled,
        isMuteEnabled: _isMuteEnabled,
        selectedRole: _selectedRole,
      ));
    }
  }

  @override
  Future<void> close() {
    closeGetGroupsSubscription();
    searchController.dispose();  // ← add this
    groupNameController.dispose();
    groupNameArController.dispose();
    groupDescriptionController.dispose();
    groupDescriptionArController.dispose();
    membersSearchTextField.dispose();
    return super.close();
  }
}