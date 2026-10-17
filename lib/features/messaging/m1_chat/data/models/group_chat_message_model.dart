/// Module: messaging / chat / data/models/group_chat_message_model.dart
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:grc_module/features/messaging/helpers/enums/message_types.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/group_member_seen_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/message/audio_message_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/message/doc_message_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/message/video_message_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/sub_models/pin_model.dart';

class GroupChatMessageModel {
  /// **********************  MESSAGE INFO ****************************
  // §10 — pure data model: all fields final; edits go through copyWith.

  final String groupId;
  final String messageId;
  final Timestamp sendTime;
  final String senderId;
  final List<GroupMemberSeenModel> seenBy;
  final bool isDeleted;
  final bool isEdited;
  final bool isForwarded;
  final String? forwardFrom;
  final String? repliedMessageId;
  final List<String>? mentionedMembers;
  final PinModel? pinModel;
  final List<String> reacts;

  /// **********************  MESSAGE CONTENT ****************************

  final MessageTypes messageType;
  final String? messageContent;
  final String? mediaLink;
  final VideoMessageModel? video;
  final DocMessageModel? docMessageModel;
  final AudioMessageModel? audio;

  /// *************************** CONSTRUCTOR ***************************

  GroupChatMessageModel(
      {required this.groupId,
      required this.messageId,
      required this.sendTime,
      required this.senderId,
      required this.seenBy,
      required this.isDeleted,
      required this.isEdited,
      required this.isForwarded,
      this.forwardFrom,
      required this.messageType,
      required this.messageContent,
      this.pinModel,
      this.mentionedMembers,
      this.repliedMessageId,
      this.docMessageModel,
      this.mediaLink,
      this.audio,
      this.video,
      this.reacts = const []});

  GroupChatMessageModel copyWith({
    String? groupId,
    String? messageId,
    Timestamp? sendTime,
    String? senderId,
    List<GroupMemberSeenModel>? seenBy,
    bool? isDeleted,
    bool? isEdited,
    bool? isForwarded,
    String? forwardFrom,
    String? repliedMessageId,
    List<String>? mentionedMembers,
    PinModel? pinModel,
    List<String>? reacts,
    MessageTypes? messageType,
    String? messageContent,
    String? mediaLink,
    VideoMessageModel? video,
    DocMessageModel? docMessageModel,
    AudioMessageModel? audio,
  }) {
    return GroupChatMessageModel(
      groupId: groupId ?? this.groupId,
      messageId: messageId ?? this.messageId,
      sendTime: sendTime ?? this.sendTime,
      senderId: senderId ?? this.senderId,
      seenBy: seenBy ?? this.seenBy,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      isForwarded: isForwarded ?? this.isForwarded,
      forwardFrom: forwardFrom ?? this.forwardFrom,
      repliedMessageId: repliedMessageId ?? this.repliedMessageId,
      mentionedMembers: mentionedMembers ?? this.mentionedMembers,
      pinModel: pinModel ?? this.pinModel,
      reacts: reacts ?? this.reacts,
      messageType: messageType ?? this.messageType,
      messageContent: messageContent ?? this.messageContent,
      mediaLink: mediaLink ?? this.mediaLink,
      video: video ?? this.video,
      docMessageModel: docMessageModel ?? this.docMessageModel,
      audio: audio ?? this.audio,
    );
  }

  /// *************************** FIELDS KEY ****************************

  static const String kGroupId = 'Group_Id';
  static const String kMessageId = 'Message_Id';
  static const String kSendTime = 'Send_Time';
  static const String kSenderId = 'Sender_Id';
  static const String kSeenBy = 'Seen_By';
  static const String kIsDeleted = 'Is_Deleted';
  static const String kIsEdited = 'Is_Edited';
  static const String kIsForwarded = 'Is_Forwarded';
  static const String kForwardFrom = 'Forward_From';
  static const String kMessageType = 'Message_Type';
  static const String kMessageContent = 'Message_Content';
  static const String kRepliedMessageId = 'Replied_Message_Id';
  static const String kMediaLink = 'Media_Link';
  static const String kMentionedMembers = 'Mentioned_Members';
  static const String kPinModel = 'Pin_Model';
  static const String kReacts = 'reacts';

  /// ***************************** FUNCTIONS ****************************

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      kGroupId: groupId,
      kMessageId: messageId,
      kSendTime: sendTime,
      kSenderId: senderId,
      kSeenBy: seenBy.map((e) => e.toMap()).toList(),
      kIsDeleted: isDeleted,
      kIsEdited: isEdited,
      kIsForwarded: isForwarded,
      kForwardFrom: forwardFrom,
      kMessageType: messageType.index,
      kMessageContent: messageContent,
      kRepliedMessageId: repliedMessageId,
      kMediaLink: mediaLink,
      kMentionedMembers: mentionedMembers,
      kPinModel: pinModel?.toMap(),
      kReacts: reacts,
    };

    if (docMessageModel != null) {
      map.addAll(docMessageModel!.toMap());
    }
    if (video != null) {
      map.addAll(video!.toMap());
    }
    if (audio != null) {
      map.addAll(audio!.toMap());
    }
    return map;
  }

  factory GroupChatMessageModel.fromMap(Map<String, dynamic> map) {
    MessageTypes messageType = MessageTypes.values[map[kMessageType]];

    // ✅ Parse reacts from Firestore
    List<String> parsedReacts = [];
    if (map[kReacts] != null && map[kReacts] is List) {
      parsedReacts = List<String>.from(map[kReacts]);
    }

    return GroupChatMessageModel(
      groupId: map[kGroupId],
      messageId: map[kMessageId],
      sendTime: map[kSendTime],
      senderId: map[kSenderId],
      seenBy: (map[kSeenBy] as List)
          .map((e) => GroupMemberSeenModel.fromMap(e))
          .toList(),
      isDeleted: map[kIsDeleted],
      mentionedMembers: map[kMentionedMembers] != null
          ? List<String>.from(map[kMentionedMembers])
          : null,
      isEdited: map[kIsEdited],
      isForwarded: map[kIsForwarded],
      forwardFrom: map[kForwardFrom],
      messageType: MessageTypes.values[map[kMessageType]],
      messageContent: map[kMessageContent],
      repliedMessageId: map[kRepliedMessageId],
      mediaLink: map[kMediaLink],
      pinModel:
          map[kPinModel] == null ? null : PinModel.fromMap(map[kPinModel]),
      video: (messageType == MessageTypes.video)
          ? VideoMessageModel.fromMap(map)
          : null,
      audio: (messageType == MessageTypes.audio)
          ? AudioMessageModel.fromMap(map)
          : null,
      docMessageModel: (messageType == MessageTypes.doc)
          ? DocMessageModel.fromMap(map)
          : null,
      reacts: parsedReacts,
    );
  }
}
