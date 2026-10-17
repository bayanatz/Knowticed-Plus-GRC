/// Module: messaging / chat / data/models/single_chat_message_model.dart
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:grc_module/features/messaging/helpers/enums/message_types.dart';
import 'package:grc_module/features/messaging/m1_chat/domain/entity/message_entity.dart';
import 'package:grc_module/features/messaging/m1_chat/domain/enum/reacts.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/message/audio_message_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/message/doc_message_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/message/video_message_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/sub_models/pin_model.dart';

class SingleChatMessageModel {
  /// **********************  MESSAGE INFO ****************************
  // §10 — pure data model: all fields final; edits go through copyWith.
  final String chatId;
  final String messageId;
  final Timestamp sendTime;
  final String senderId;
  final String receiverId;
  final bool isSeen;
  final bool isDeleted;
  final bool isEdited;
  final bool isForwarded;
  final String? forwardFrom;
  final String? repliedMessageId;
  final PinModel? pinModel;
  final List<Reacts> reacts;

  /// **********************  MESSAGE CONTENT ****************************

  final MessageTypes messageType;
  final String? messageContent;
  final String? mediaLink;
  final DocMessageModel? docMessageModel;
  final VideoMessageModel? videoMessageModel;
  final AudioMessageModel? audioMessageModel;

  /// *************************** CONSTRUCTOR ***************************

  SingleChatMessageModel({
    required this.chatId,
    required this.messageId,
    required this.sendTime,
    required this.senderId,
    required this.receiverId,
    required this.isSeen,
    required this.isDeleted,
    required this.isEdited,
    required this.isForwarded,
    this.forwardFrom,
    required this.messageType,
    required this.messageContent,
    this.docMessageModel,
    this.repliedMessageId,
    this.mediaLink,
    this.audioMessageModel,
    this.videoMessageModel,
    this.pinModel,
    this.reacts = const [],
  });

  SingleChatMessageModel copyWith({
    String? chatId,
    String? messageId,
    Timestamp? sendTime,
    String? senderId,
    String? receiverId,
    bool? isSeen,
    bool? isDeleted,
    bool? isEdited,
    bool? isForwarded,
    String? forwardFrom,
    String? repliedMessageId,
    PinModel? pinModel,
    List<Reacts>? reacts,
    MessageTypes? messageType,
    String? messageContent,
    String? mediaLink,
    DocMessageModel? docMessageModel,
    VideoMessageModel? videoMessageModel,
    AudioMessageModel? audioMessageModel,
  }) {
    return SingleChatMessageModel(
      chatId: chatId ?? this.chatId,
      messageId: messageId ?? this.messageId,
      sendTime: sendTime ?? this.sendTime,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      isSeen: isSeen ?? this.isSeen,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      isForwarded: isForwarded ?? this.isForwarded,
      forwardFrom: forwardFrom ?? this.forwardFrom,
      repliedMessageId: repliedMessageId ?? this.repliedMessageId,
      pinModel: pinModel ?? this.pinModel,
      reacts: reacts ?? this.reacts,
      messageType: messageType ?? this.messageType,
      messageContent: messageContent ?? this.messageContent,
      mediaLink: mediaLink ?? this.mediaLink,
      docMessageModel: docMessageModel ?? this.docMessageModel,
      videoMessageModel: videoMessageModel ?? this.videoMessageModel,
      audioMessageModel: audioMessageModel ?? this.audioMessageModel,
    );
  }

  /// *************************** FIELDS KEY ****************************
  static const String kChatId = 'Chat_Id';
  static const String kMessageId = 'Message_Id';
  static const String kSendTime = 'Send_Time';
  static const String kSenderId = 'Sender_Id';
  static const String kRecieverId = 'Reciever_Id';
  static const String kIsSeen = 'Is_Seen';
  static const String kIsDeleted = 'Is_Deleted';
  static const String kIsEdited = 'Is_Edited';
  static const String kIsForwarded = 'Is_Forwarded';
  static const String kForwardFrom = 'Forward_From';
  static const String kMessageType = 'Message_Type';
  static const String kMessageContent = 'Message_Content';
  static const String kRepliedMessageId = 'Replied_Message_Id';
  static const String kMediaLink = 'Media_Link';
  static const String kPinModel = 'Pin_Model';
  static const String kReacts = 'reacts';

  /// ***************************** FUNCTIONS ****************************

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      kChatId: chatId,
      kMessageId: messageId,
      kSendTime: sendTime,
      kSenderId: senderId,
      kRecieverId: receiverId,
      kIsSeen: isSeen,
      kIsDeleted: isDeleted,
      kIsEdited: isEdited,
      kIsForwarded: isForwarded,
      kForwardFrom: forwardFrom,
      kMessageType: messageType.index,
      kMessageContent: messageContent,
      kRepliedMessageId: repliedMessageId,
      kMediaLink: mediaLink,
      kPinModel: pinModel?.toMap(),
      kReacts: reacts.map((e) => e.name).toList(),
    };
    if (messageType == MessageTypes.doc) {
      map.addAll(docMessageModel!.toMap());
    }
    if (messageType == MessageTypes.video) {
      map.addAll(videoMessageModel!.toMap());
    }
    if (messageType == MessageTypes.audio) {
      map.addAll(audioMessageModel!.toMap());
    }
    return map;
  }

  /// Helper to convert a react name string back to Reacts enum
  static Reacts? _reactFromName(String name) {
    for (final r in Reacts.values) {
      if (r.name == name) return r;
    }
    return null;
  }

  factory SingleChatMessageModel.fromMap(Map<String, dynamic> map) {
    MessageTypes messageType = MessageTypes.values[map[kMessageType]];

    // ✅ Parse reacts from Firestore string list back to Reacts enum list
    List<Reacts> parsedReacts = [];
    if (map[kReacts] != null && map[kReacts] is List) {
      for (final reactName in map[kReacts]) {
        final r = _reactFromName(reactName.toString());
        if (r != null) parsedReacts.add(r);
      }
    }

    return SingleChatMessageModel(
      chatId: map[kChatId],
      messageId: map[kMessageId],
      sendTime: map[kSendTime],
      senderId: map[kSenderId],
      receiverId: map[kRecieverId],
      isSeen: map[kIsSeen],
      isDeleted: map[kIsDeleted],
      isEdited: map[kIsEdited],
      isForwarded: map[kIsForwarded],
      forwardFrom: map[kForwardFrom],
      messageType: MessageTypes.values[map[kMessageType]],
      messageContent: map[kMessageContent],
      mediaLink: map[kMediaLink],
      audioMessageModel: (messageType == MessageTypes.audio)
          ? AudioMessageModel.fromMap(map)
          : null,
      videoMessageModel: (messageType == MessageTypes.video)
          ? VideoMessageModel.fromMap(map)
          : null,
      docMessageModel: (messageType == MessageTypes.doc)
          ? DocMessageModel.fromMap(map)
          : null,
      repliedMessageId: map[kRepliedMessageId],
      pinModel:
          map[kPinModel] != null ? PinModel.fromMap(map[kPinModel]) : null,
      reacts: parsedReacts,
    );
  }

  // ✅ FIX: currentUserId passed as parameter — no more Get.find<ConnectionsCubit>()
  MessageEntity toMessageEntity(
    String connectionId,
    Map<String, MessageEntity> messages,
    String currentUserId,
  ) {
    MessageEntity? repliedMessage;
    if (repliedMessageId != null) {
      repliedMessage = messages[repliedMessageId];
    }
    return MessageEntity(
      isGroup: false,
      channelId: connectionId,
      messageId: messageId,
      time: sendTime,
      isMe: senderId == currentUserId,
      mediaLink: mediaLink,
      isSeen: isSeen,
      isDeleted: isDeleted,
      isEdited: isEdited,
      isPinned: pinModel != null ? pinModel!.isPinned.last : false,
      isForwarded: isForwarded,
      forwardFrom: forwardFrom,
      messageType: messageType,
      messageContent: messageContent,
      audio: audioMessageModel,
      docMessageModel: docMessageModel,
      videoMessageModel: videoMessageModel,
      repliedMessage: repliedMessage,
      index: (messages.containsKey(messageId))
          ? messages.length - 1
          : messages.length,
      reacts: reacts,
    );
  }
}
