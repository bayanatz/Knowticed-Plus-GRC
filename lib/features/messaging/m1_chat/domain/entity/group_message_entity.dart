/// Module: messaging / chat / domain/entity/group_message_entity.dart
library;

import 'package:grc_module/features/messaging/m1_chat/domain/entity/message_entity.dart';

class GroupMessageEntity extends MessageEntity {
  Set<String> messageSeenBy;
  String senderImage;
  GroupMessageEntity(
      {required super.messageId,
      required super.time,
      required super.isMe,
      required super.isSeen,
      required super.isDeleted,
      required super.isEdited,
      required super.isForwarded,
      required super.messageType,
      required super.messageContent,
      required super.channelId,
      required super.isGroup,
      required super.index,
      required super.isPinned,
      required this.senderImage,
      super.audio,
      super.mediaLink,
      super.docMessageModel,
      super.repliedMessage,
      super.indexOfRepliedMessage,
      required super.videoMessageModel,
      required this.messageSeenBy,
      super.reacts});
}
