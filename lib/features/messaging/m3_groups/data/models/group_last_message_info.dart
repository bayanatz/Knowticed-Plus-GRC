/// Module: messaging / groups / data/models/group_last_message_info.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_last_message_info.dart
/// Purpose: Group last message info — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/messaging/helpers/enums/message_types.dart';

class GroupLastMessageInfo {
  MessageTypes messageType;
  String? textMessage;
  Timestamp? lastMessageTime;
  String? messageId;
  String? senderId;

  GroupLastMessageInfo(
      {required this.messageType,
      this.textMessage,
      this.lastMessageTime,
      this.messageId,
      this.senderId});

  static const String kMessageType = 'Message_Type';
  static const String kTextMessage = 'Text_Message';
  static const String kLastMessageTime = 'Last_Message_Time';
  static const String kMessageId = 'Message_Id';
  static const String kSenderId = 'Sender_Id';

  Map<String, dynamic> toMap() {
    return {
      kMessageType: messageType.index,
      kTextMessage: textMessage,
      kLastMessageTime: lastMessageTime,
      kMessageId: messageId,
      kSenderId: senderId
    };
  }

  factory GroupLastMessageInfo.fromMap(Map<String, dynamic> map) {
    return GroupLastMessageInfo(
        // Tolerates a number stored as text ("0") — that threw and hid
        // every group (18/10/2026).
        messageType: MessageTypes.values[
            (int.tryParse('${map[kMessageType]}') ?? 0)
                .clamp(0, MessageTypes.values.length - 1)],
        textMessage: map[kTextMessage],
        lastMessageTime: map[kLastMessageTime],
        messageId: map[kMessageId],
        senderId: map[kSenderId]);
  }
}
