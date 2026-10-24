/// Module: messaging / connections / data/models/user_connection_last_message_info_model.dart
/// ************************* FILE INFO *************************** ///
/// File Name: user_connection_last_message_info_model.dart
/// Purpose: User connection last message info model — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/messaging/helpers/enums/message_types.dart';

class UserConnectionLastMessageInfoModel {
  MessageTypes messageType;
  bool? isLastMessageSenderCurrentUser;
  String? textMessage;
  int? myUnreadMessagesCount;
  int otherUnreadMessagesCount;
  Timestamp? lastMessageTime;
  String? messageId;

  UserConnectionLastMessageInfoModel({
    required this.messageType,
    this.isLastMessageSenderCurrentUser,
    this.textMessage,
    required this.myUnreadMessagesCount,
    required this.otherUnreadMessagesCount,
    this.lastMessageTime,
    this.messageId,
  });

  static const String kMessageType = 'Message_Type';
  static const String kIsLastMessageSenderCurrentUser =
      'Is_Last_Message_Sender_Current_User';
  static const String kTextMessage = 'Text_Message';
  static const String kMyUnreadMessagesCount = 'My_Unread_Messages_Count';
  static const String kOtherUnreadMessagesCount = 'Other_Unread_Messages_Count';
  static const String kLastMessageTime = 'Last_Message_Time';
  static const String kMessageId = 'Message_Id';

  Map<String, dynamic> toMap() {
    return {
      kMessageType: messageType.index,
      kIsLastMessageSenderCurrentUser: isLastMessageSenderCurrentUser,
      kTextMessage: textMessage,
      kMyUnreadMessagesCount: myUnreadMessagesCount,
      kLastMessageTime: lastMessageTime,
      kOtherUnreadMessagesCount: otherUnreadMessagesCount,
      kMessageId: messageId,
    };
  }

  factory UserConnectionLastMessageInfoModel.fromMap(Map<String, dynamic> map) {
    return UserConnectionLastMessageInfoModel(
      messageType: MessageTypes.values[map[kMessageType]],
      isLastMessageSenderCurrentUser: map[kIsLastMessageSenderCurrentUser],
      textMessage: map[kTextMessage],
      myUnreadMessagesCount: map[kMyUnreadMessagesCount],
      otherUnreadMessagesCount: map[kOtherUnreadMessagesCount],
      lastMessageTime: map[kLastMessageTime],
      messageId: map[kMessageId],
    );
  }
}
