/// Module: messaging / groups / data/models/group_model.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_model.dart
/// Purpose: Group model — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grc_module/core/helper/single_value_tracking_model.dart';
import 'package:grc_module/features/messaging/m3_groups/data/models/group_admin_model.dart';
import 'package:grc_module/features/messaging/m3_groups/data/models/group_last_message_info.dart';
import 'package:grc_module/features/messaging/m3_groups/data/models/group_members.dart';

class GroupModel {
  String groupId;
  String createdBy;
  SingleValueTrackingModel<String> groupName;
  SingleValueTrackingModel<String>? groupNameAr;
  SingleValueTrackingModel<String> groupDescription;
  SingleValueTrackingModel<String>? groupDescriptionAr;
  SingleValueTrackingModel<String> groupImage;
  Timestamp creationTime;
  SingleValueTrackingModel<bool> isPublic;
  SingleValueTrackingModel<bool> isOnlyAdminsCanSend;
  SingleValueTrackingModel<bool> isDisappearingMessages;
  List<String> currentExistingMembers = [];
  bool isDeleted;
  Timestamp? deletedTime;
  SingleValueTrackingModel<bool> isUnMuted;
  GroupMembers groupMembers;
  GroupAdminsModel groupAdmins;
  GroupLastMessageInfo? groupLastMessageInfo;
  List<String>? mentionedMembers;
  String? pinnedMessageId; // ✅ Pinned message ID

  GroupModel({
    required this.groupId,
    required this.createdBy,
    required this.groupName,
    this.groupNameAr,
    required this.groupDescription,
    this.groupDescriptionAr,
    required this.groupImage,
    required this.creationTime,
    required this.isPublic,
    required this.isOnlyAdminsCanSend,
    required this.isDeleted,
    required this.deletedTime,
    required this.isUnMuted,
    required this.groupMembers,
    required this.groupAdmins,
    required this.isDisappearingMessages,
    required this.currentExistingMembers,
    this.mentionedMembers,
    this.groupLastMessageInfo,
    this.pinnedMessageId, // ✅
  });

  static const String kGroupId = 'Group_Id';
  static const String kCreatedBy = 'Created_By';
  static const String kGroupName = 'Group_Name';
  static const String kGroupNameAr = 'Group_Name_Ar';
  static const String kGroupDescription = 'Group_Description';
  static const String kGroupDescriptionAr = 'Group_Description_Ar';
  static const String kGroupImage = 'Group_Image';
  static const String kCreationTime = 'Creation_Time';
  static const String kIsPublic = 'Is_Public';
  static const String kIsOnlyAdminsCanSend = 'Is_Only_Admins_Can_Send';
  static const String kIsDeleted = 'Is_Deleted';
  static const String kDeletedTime = 'Deleted_Time';
  static const String kIsUnMuted = 'Is_Un_Muted';
  static const String kIsDisappearingMessages = 'Is_Disappearing_Messages';
  static const String kGroupAdmins = 'Group_Admins';
  static const String kGroupLastMessageInfo = 'Group_Last_Message_Info';
  static const String kCurrentExistingMembers = 'Current_Existing_Members';
  static const String kMentionedMembers = 'Mentioned_Members';
  static const String kPinnedMessageId = 'Pinned_Message_Id'; // ✅

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      kGroupId: groupId,
      kCreatedBy: createdBy,
      kCurrentExistingMembers: currentExistingMembers,
      kGroupName: groupName.toMap(),
      if (groupNameAr != null) kGroupNameAr: groupNameAr!.toMap(),
      kGroupDescription: groupDescription.toMap(),
      if (groupDescriptionAr != null)
        kGroupDescriptionAr: groupDescriptionAr!.toMap(),
      kGroupImage: groupImage.toMap(),
      kCreationTime: creationTime,
      kIsPublic: isPublic.toMap(),
      kIsOnlyAdminsCanSend: isOnlyAdminsCanSend.toMap(),
      kIsDeleted: isDeleted,
      kDeletedTime: deletedTime,
      kIsUnMuted: isUnMuted.toMap(),
      kGroupAdmins: groupAdmins.toMap(),
      kIsDisappearingMessages: isDisappearingMessages.toMap(),
      kGroupLastMessageInfo: groupLastMessageInfo?.toMap(),
      kMentionedMembers: mentionedMembers,
      if (pinnedMessageId != null) kPinnedMessageId: pinnedMessageId, // ✅
    };
    map.addAll(groupMembers.toMap());
    return map;
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map[kGroupId] as String,
      currentExistingMembers: List<String>.from(map[kCurrentExistingMembers]),
      createdBy: map[kCreatedBy] as String,
      groupName: SingleValueTrackingModel<String>.fromMap(
          map[kGroupName] as Map<String, dynamic>),
      groupNameAr: map[kGroupNameAr] != null
          ? SingleValueTrackingModel<String>.fromMap(
              map[kGroupNameAr] as Map<String, dynamic>)
          : null,
      groupDescription: SingleValueTrackingModel<String>.fromMap(
          map[kGroupDescription] as Map<String, dynamic>),
      groupDescriptionAr: map[kGroupDescriptionAr] != null
          ? SingleValueTrackingModel<String>.fromMap(
              map[kGroupDescriptionAr] as Map<String, dynamic>)
          : null,
      groupImage: SingleValueTrackingModel<String>.fromMap(
          map[kGroupImage] as Map<String, dynamic>),
      creationTime: map[kCreationTime] as Timestamp,
      isPublic: SingleValueTrackingModel<bool>.fromMap(
          map[kIsPublic] as Map<String, dynamic>),
      isOnlyAdminsCanSend: SingleValueTrackingModel<bool>.fromMap(
          map[kIsOnlyAdminsCanSend] as Map<String, dynamic>),
      isDeleted: map[kIsDeleted] as bool,
      deletedTime: map[kDeletedTime] as Timestamp?,
      isUnMuted: SingleValueTrackingModel<bool>.fromMap(
          map[kIsUnMuted] as Map<String, dynamic>),
      groupMembers: GroupMembers.fromMap(map),
      groupAdmins:
          GroupAdminsModel.fromMap(map[kGroupAdmins] as Map<String, dynamic>),
      groupLastMessageInfo: map[kGroupLastMessageInfo] == null
          ? null
          : GroupLastMessageInfo.fromMap(
              map[kGroupLastMessageInfo] as Map<String, dynamic>),
      isDisappearingMessages: SingleValueTrackingModel<bool>.fromMap(
          map[kIsDisappearingMessages] as Map<String, dynamic>),
      mentionedMembers: map[kMentionedMembers] == null
          ? null
          : List<String>.from(map[kMentionedMembers]),
      pinnedMessageId: map[kPinnedMessageId] as String?, // ✅
    );
  }
}
