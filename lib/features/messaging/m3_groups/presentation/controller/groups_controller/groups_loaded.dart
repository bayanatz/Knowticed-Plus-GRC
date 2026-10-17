/// Module: messaging/m3_groups
///
///*************************** FILE INFO ****************************///
/// File Name: groups_loaded.dart
/// Description: `GroupsLoaded` — split out of `groups_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../groups_controller.dart';

// Split from groups_controller.dart to keep every file under 700 lines.

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
