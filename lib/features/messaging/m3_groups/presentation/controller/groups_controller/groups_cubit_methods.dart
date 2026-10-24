/// Module: messaging/m3_groups
///
///*************************** FILE INFO ****************************///
/// File Name: groups_cubit_methods.dart
/// Description: Methods of `GroupsCubit` — split out of `groups_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../groups_controller.dart';

// Split from groups_controller.dart to keep every file under 700 lines.

extension GroupsCubitMethods on GroupsCubit {
  /// Rebuild [_members] from the current connections, KEEPING whatever was
  /// already ticked.
  ///
  /// FIXED 2/9/2026 — this used to start with `_selectedMembers = []`, and
  /// [searchMembersToAddToGroup] calls it on every department change and every
  /// search keystroke. So picking someone from Finance and then switching to
  /// Marketing silently threw the Finance pick away.
  ///
  /// Two things have to be carried across the rebuild, not one:
  ///
  ///  1. `isSelected` on the NEW entities — `fromSingleConnectionEntity`
  ///     always constructs them false, so the tick would vanish from the card
  ///     even if the id survived somewhere.
  ///  2. `_selectedMembers` must hold those SAME new instances. MemberEntity
  ///     does not override `==`, so `toggleSelection`'s
  ///     `_selectedMembers.remove(member)` is an identity check — leaving the
  ///     old objects in there would make un-ticking silently do nothing.
  ///
  /// Selection is matched by [MemberEntity.memberId] and deliberately survives
  /// the department filter: `searchMembersToAddToGroup` narrows `_members`
  /// afterwards, so a person picked under one department is no longer in the
  /// grid under another — but they are still selected, and the chip row above
  /// the grid still shows them.
  ///
  /// A genuine reset is the job of [initialize] / [resetCreateGroupControllers],
  /// which clear the list explicitly.
  void getMembers({required ConnectionsCubit connectionsCubit}) {
    _categories = connectionsCubit.categories;

    final Set<String> previouslySelectedIds =
        _selectedMembers.map((m) => m.memberId).toSet();

    _members = [];
    final List<MemberEntity> reselected = [];

    for (var connection in connectionsCubit.connections) {
      log('👤 [getMembers] ${connection.primaryLanguageName} | userCategory: ${connection.userCategory?.primaryLanguageName ?? "NULL"} | categoryId: ${connection.userCategory?.categoryId ?? "NULL"}');
      final member = MemberEntity.fromSingleConnectionEntity(connection);
      if (previouslySelectedIds.contains(member.memberId)) {
        member.isSelected = true;
        reselected.add(member);
      }
      _members.add(member);
    }

    _selectedMembers = reselected;
    _isMemberSelected = _selectedMembers.isNotEmpty;

    log("getMembers called - members count: ${_members.length}, "
        "kept ${_selectedMembers.length} selected");
    _emitLoadedState();
  }

  // ✅ Updated to support comma-separated multi-select category ids
  void searchMembersToAddToGroup(String value,
      ConnectionsCubit connectionsCubit, MessagingHomeCubit homeCubit) {
    getMembers(connectionsCubit: connectionsCubit);
    try {
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

  /// Create the group. Returns whether it was actually written.
  ///
  /// CHANGED 2/9/2026 — was `Future<void>` that popped the page itself. The
  /// Create button now runs through `CustomDialogManager.showDialogFlow`,
  /// whose `onConfirm` is a `Future<bool>`: it only shows the success step if
  /// the work really succeeded. Returning void meant every outcome — a
  /// permission denial, a failed validation, a repository error — looked
  /// identical to a success.
  ///
  /// [popOnSuccess] keeps the old behaviour for any caller that is not
  /// driving its own dialog; the dialog flow passes false and pops from
  /// `onSuccessComplete`, so the page does not disappear out from under the
  /// success dialog.
  Future<bool> createGroup(
    BuildContext context, {
    bool popOnSuccess = true,
  }) async {
    // GATED 2/9/2026 — Figma "Adding New Role" → Messages → Create Group.
    //
    // Guarded HERE rather than only on the button that opens the form. This is
    // the method that actually writes the group, so a stale form, a deep link
    // or a widget built before a role change all hit the same check. Hiding
    // the entry point as well is right, but it is not enforcement — the same
    // lesson the Knowledge Hub permissions pass produced.
    //
    // Silent return: the form's own validation failure path is also silent, so
    // an error dialog here would be the only one in the method.
    if (!MessagesAccess.canCreateGroup) {
      log(
          '⛔ createGroup denied: section on=${MessagesAccess.canUseMessagesPermissions}, '
          'stored=${MessagesAccess.storedForDebug}',
          name: 'MessagesPermissions');
      return false;
    }

    if (newGroupFormKey.currentState!.validate() && _isMemberSelected) {
      GroupAdminModel admin = GroupAdminModel(
          adminId: currentUser.userId,
          isAdmin: [true],
          timestamps: [Timestamp.now()]);
      // 18/10/2026: the creator is added to a COPY — adding to
      // _selectedMembers itself listed them twice after a failed try.
      final List<MemberEntity> members = <MemberEntity>[
        ..._selectedMembers.where((m) => m.memberId != currentUser.userId),
        MemberEntity(
            memberId: currentUser.userId,
            isAdmin: true,
            primaryLanguageName: currentUser.primaryLanguageName,
            secondaryLanguageName: currentUser.secondaryLanguageName,
            primaryLanguageSubInfo: currentUser.primaryLanguageSubInfo,
            secondaryLanguageSubInfo: currentUser.secondaryLanguageSubInfo,
            memberPhone: currentUser.phone,
            numOfUnreadMessages: 0,
            memberImage: currentUser.imageUri,
            addedTime: null),
      ];

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
        groupMembers: members,
        // Two more role switches applied at the point of WRITING rather than
        // at the toggle that sets them. A role without
        // `Disappearing_Messages` cannot create a group with them on even if
        // the toggle was somehow left enabled — the stored value is the thing
        // that matters, and this is the last place before it is stored.
        isDisappearingMessages: MessagesAccess.canUseDisappearingMessages &&
            _isDisappearingMessagesEnabled,
        isOnlyAdminsCanSend: _isAdminEnabled,
        isPublic: !_isMakePrivateEnabled,
        // `isUnMuted` is the INVERSE of muted, so denying the mute permission
        // means forcing this true, not false. Reading it the other way round
        // would silently mute every group a restricted role creates.
        isUnMuted: MessagesAccess.canMuteNotifications ? !_isMuteEnabled : true,
        createdBy: currentUser.userId,
        groupAdmins: [admin],
      );
      if (response.isRight()) {
        if (popOnSuccess && context.mounted) {
          Navigator.of(context).pop();
        }
        return true;
        // GetDialogHelper.generalDialog(
        //   context: context,
        //   child: DefaultDialog(
        //     title: "Creating New Group",
        //     subTitle: "You Successfully Created New Group",
        //     autoClose: true,
        //     lottieAsset: "assets/lottie_assets/main_lottie_assets/lot_status_success.json",
        //     showButtons: false,
        //   ),
        // );
      }
    }
    return false;
  }

  void _emitLoadedState(
      {String? updateId,
      bool clearGroupImage = false,
      bool clearSelectedGroup = false}) {
    if (state is GroupsLoaded) {
      emitState((state as GroupsLoaded).copyWith(
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
      emitState(GroupsLoaded(
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
}
