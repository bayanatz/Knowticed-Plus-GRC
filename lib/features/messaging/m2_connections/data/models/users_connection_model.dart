/// Module: messaging / connections / data/models/users_connection_model.dart
/// ************************* FILE INFO *************************** ///
/// File Name: users_connection_model.dart
/// Purpose: Users connection model — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/messaging/helpers/enums/message_types.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/user_category.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/domain/entities/single_connection_entity.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/data/models/user_connection_last_message_info_model.dart';

class UsersConnectionModel {
  /// ************************** USER INFO ****************************
  String userPrimaryLanguageName;
  String? userSecondaryLanguageName;
  String? userPrimaryLanguageSubInfo;
  String? userSecondaryLanguageSubInfo;
  String userImageUri;
  String userId;
  String? userPhone;
  String? userCategoryId;

  /// ************************** CONNECTION INFO ****************************
  Timestamp startedConnectionTime;
  bool isDeletedConnection;
  bool isBlockedConnection;
  String connectionId;

  /// ************************** MESSAGE INFO ****************************
  late UserConnectionLastMessageInfoModel lastMessageInfo;

  UsersConnectionModel({
    required this.connectionId,
    required this.userPrimaryLanguageName,
    required this.userSecondaryLanguageName,
    required this.userPrimaryLanguageSubInfo,
    required this.userSecondaryLanguageSubInfo,
    required this.userImageUri,
    required this.userId,
    required this.userPhone,
    required this.userCategoryId,
    required this.startedConnectionTime,
    this.isDeletedConnection = false,
    this.isBlockedConnection = false,
    MessageTypes messageType = MessageTypes.none,
    String? messageText,
    int myUnreadMessagesCount = 0,
    int otherUnreadMessagesCount = 0,
    Timestamp? lastMessageTime,
  }) {
    lastMessageInfo = UserConnectionLastMessageInfoModel(
      messageType: messageType,
      isLastMessageSenderCurrentUser: false,
      textMessage: messageText,
      myUnreadMessagesCount: myUnreadMessagesCount,
      otherUnreadMessagesCount: otherUnreadMessagesCount,
      lastMessageTime: lastMessageTime ?? startedConnectionTime,
    );
  }

  /// ************************** Fields Key Constants ****************************
  static const String kUserPrimaryLanguageName = 'User_Primary_Language_Name';
  static const String kUserSecondaryLanguageName =
      'User_Secondary_Language_Name';
  static const String kUserPrimaryLanguageSubInfo =
      'User_Primary_Language_Sub_Info';
  static const String kUserSecondaryLanguageSubInfo =
      'User_Secondary_Language_Sub_Info';
  static const String kUserImageUri = 'User_Image_Uri';
  static const String kUserId = 'User_ID';
  static const String kUserPhone = 'User_Phone';
  static const String kUserCategoryId = 'User_Category_ID';
  static const String kStartedConnectionTime = 'Started_Connection_Time';
  static const String kIsDeletedConnection = 'Is_Deleted_Connection';
  static const String kIsBlockedConnection = 'Is_Blocked_Connection';
  static const String kConnectionId = 'Connection_ID';

  /// ************************** Methods ****************************
  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      kUserPrimaryLanguageName: userPrimaryLanguageName,
      kUserSecondaryLanguageName: userSecondaryLanguageName,
      kUserPrimaryLanguageSubInfo: userPrimaryLanguageSubInfo,
      kUserSecondaryLanguageSubInfo: userSecondaryLanguageSubInfo,
      kUserImageUri: userImageUri,
      kUserId: userId,
      kUserPhone: userPhone,
      kUserCategoryId: userCategoryId,
      kStartedConnectionTime: startedConnectionTime,
      kIsDeletedConnection: isDeletedConnection,
      kIsBlockedConnection: isBlockedConnection,
      kConnectionId: connectionId,
    };
    data.addAll(lastMessageInfo.toMap());
    return data;
  }

  UsersConnectionModel.fromMap(Map<String, dynamic> map)
      : userPrimaryLanguageName = map[kUserPrimaryLanguageName],
        userSecondaryLanguageName = map[kUserSecondaryLanguageName],
        userPrimaryLanguageSubInfo = map[kUserPrimaryLanguageSubInfo],
        userSecondaryLanguageSubInfo = map[kUserSecondaryLanguageSubInfo],
        userImageUri = map[kUserImageUri],
        userId = map[kUserId],
        userPhone = map[kUserPhone],
        userCategoryId = map[kUserCategoryId] is int
            ? (map[kUserCategoryId] as int).toString()
            : map[kUserCategoryId],
        startedConnectionTime = map[kStartedConnectionTime],
        isDeletedConnection = map[kIsDeletedConnection],
        isBlockedConnection = map[kIsBlockedConnection],
        connectionId = map[kConnectionId],
        lastMessageInfo = UserConnectionLastMessageInfoModel.fromMap(map);

  // ✅ FIX: categories passed in directly — no more Get.find<ConnectionsCubit>()
  SingleConnectionEntity toSingleConnectionEntity({
    required List<UserCategory> categories,
  }) {
    UserCategory? userCategory;
    if (userCategoryId != null) {
      for (var element in categories) {
        if (element.categoryId == userCategoryId.toString()) {
          userCategory = element;
          break;
        }
      }
    }

    bool isRead = (lastMessageInfo.otherUnreadMessagesCount == 0 &&
        lastMessageInfo.isLastMessageSenderCurrentUser == true);

    return SingleConnectionEntity(
      connectionId: connectionId,
      primaryLanguageName: userPrimaryLanguageName,
      secondaryLanguageName: userSecondaryLanguageName,
      primaryLanguageSubInfo: userPrimaryLanguageSubInfo,
      secondaryLanguageSubInfo: userSecondaryLanguageSubInfo,
      imageUri: userImageUri,
      userId: userId,
      phone: userPhone,
      userCategory: userCategory,
      myNumUnreadMessage: lastMessageInfo.myUnreadMessagesCount ?? 0,
      lastMessageTime: lastMessageInfo.lastMessageTime,
      messageType: lastMessageInfo.messageType,
      messageContent: lastMessageInfo.textMessage,
      otherSideId: userId,
      isLastMessageSenderIsCurrentUser:
          lastMessageInfo.isLastMessageSenderCurrentUser ?? true,
      otherNumUnreadMessage: lastMessageInfo.otherUnreadMessagesCount,
      isSeen: isRead,
    );
  }
}
