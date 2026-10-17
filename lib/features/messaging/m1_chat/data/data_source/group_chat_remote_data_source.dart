/// Module: messaging / chat / data/data_source/group_chat_remote_data_source.dart
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/messaging/helpers/constants/messaging_api_constants.dart';
import 'package:grc_module/features/messaging/helpers/enums/message_types.dart';
import 'package:grc_module/features/messaging/helpers/services/firebase/repository/firebase_repository.dart';
import 'package:grc_module/features/messaging/m3_groups/data/models/group_last_message_info.dart';
import 'package:grc_module/features/messaging/m3_groups/data/models/group_members.dart';
import 'package:grc_module/features/messaging/m3_groups/data/models/group_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/group_chat_message_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/group_member_seen_model.dart';

/// ******************************** FILE INFO *****************************
/// Class Name: GroupChatRemoteDataSource
/// Purpose: This file contains the class for group chat remote data source, to have functions that work repository need
/// Author: Mohamed Elrashidy

class GroupChatRemoteDataSource {
  WriteBatch _batch = FirebaseFirestore.instance.batch();

  Future<void> sendMessage({required GroupChatMessageModel messageModel}) async {
    FirebaseRepository.setDocumentWithIdWithBatch(
        collection:
            "${ApiConstants.groupsChat}/${messageModel.groupId}/${ApiConstants.messages}",
        data: messageModel.toMap(),
        documentId: messageModel.messageId,
        batch: _batch);
  }

  /// Function Name : startBatch
  /// Purpose: function to start batch to commit multiple operations at once
  void startBatch() {
    _batch = FirebaseFirestore.instance.batch();
  }

  /// Function Name : commitBatch
  /// Purpose: function to commit batch to commit multiple operations at once
  Future<Either<Failure, dynamic>> commitBatch() async {
    return await FirebaseRepository.commitBatch(batch: _batch);
  }

  /// Update pinned message ID on the group document
  Future<Either<Failure, void>> updateGroupPinnedMessageId({
    required String groupId,
    required String? pinnedMessageId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection(ApiConstants.groups)
          .doc(groupId)
          .update({
        GroupModel.kPinnedMessageId: pinnedMessageId,
      });
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Function Name : updateGroupMessageData
  /// Purpose: function to add update group message data to batch
  /// Parameters:
  ///            data: Map`<String,dynamic>` - Map`<String, dynamic>` data
  ///            groupId: String - group id
  void updateGroupMessageData(
      {required Map<String, dynamic> data, required String groupId}) {
    FirebaseRepository.updateDocumentWithIdWithBatch(
        collection: ApiConstants.groups,
        data: data,
        documentId: groupId,
        batch: _batch);
  }

  Stream<Either<Failure, List<Map<String, dynamic>>>> getGroupChatMessages(
      {required String groupId}) async* {
    yield* FirebaseRepository.getStreamOfCollectionSorted(
        collectionPath:
            "${ApiConstants.groupsChat}/$groupId/${ApiConstants.messages}",
        sortedBy: GroupChatMessageModel.kSendTime);
  }

  /// Function Name : updateUserSeenMessages
  /// Purpose: function to add update in batch for user seen messages in message models that were not seen before
  /// Parameters:
  ///           chatId: String - chat id
  ///           messageId: List`<String>` - list of unseen message ids
  ///           userId: String - user id
  ///           seenTime: Timestamp - seen time
  Future<void> updateUserSeenMessages({
    required String chatId,
    required List<String> messageId,
    required String userId,
    required Timestamp seenTime,
  }) async {
    for (String id in messageId) {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection(ApiConstants.groupsChat)
          .doc(chatId)
          .collection(ApiConstants.messages)
          .doc(id);
      _batch.update(documentReference, {
        GroupChatMessageModel.kSeenBy: FieldValue.arrayUnion([
          {
            GroupMemberSeenModel.kMemberId: userId,
            GroupMemberSeenModel.kSeenTime: seenTime,
          }
        ])
      });
    }
  }

  /// Function Name : updateUserNumOfUnreadMessages
  /// Purpose: function to update user number of unread messages in group model
  /// Parameters:
  ///          groupId: String - group id
  ///          userId: String - user id
  ///          numOfUnreadMessages: int - number of unread messages

  void updateUserNumOfUnreadMessages(
      {required String groupId,
      required String userId,
      required int numOfUnreadMessages}) {
    FirebaseRepository.updateDocumentWithIdWithBatch(
        collection: ApiConstants.groups,
        data: {
          "${GroupMembers.membersKey}.${userId.replaceAll(".", "---")}.${GroupMember.numOfUnreadMessagesKey}":
              numOfUnreadMessages,
          GroupModel.kMentionedMembers: FieldValue.arrayRemove([userId])
        },
        documentId: groupId,
        batch: _batch);
  }

  Future<Either<FirebaseFailure, String>> uploadMedia({required String filePath}) async {
    return await FirebaseRepository.uploadFile(
        collectionName: ApiConstants.groupsChat,
        documentName: filePath.split("/").last,
        filePath: filePath);
  }

  /// Function Name : deleteMessage
  /// Purpose: function to delete message from group chat and update group last message info
  /// Parameters:
  ///          messageId: String - message id
  ///          groupId: String - group id
  ///          currentUserId: String - current user id
  ///          Return: Future`<Either<Failure, dynamic>`> - Future of either failure or dynamic
  ///
  Future<Either<Failure, dynamic>> deleteMessage(
      {required String messageId,
      required String groupId,
      required String currentUserId}) async {
    // start batch to commit multiple operations at once
    startBatch();
    // update message data to be deleted
    FirebaseRepository.updateDocumentWithIdWithBatch(
        collection:
            "${ApiConstants.groupsChat}/$groupId/${ApiConstants.messages}",
        data: {
          GroupChatMessageModel.kMessageType: MessageTypes.deleted.index,
          GroupChatMessageModel.kIsDeleted: true,
        },
        documentId: messageId,
        batch: _batch);
    // get group data to check if the message is the last message in the group
    await _updateGroupLastMessageInfoIfSame(messageId, groupId, {
      "${GroupModel.kGroupLastMessageInfo}.${GroupLastMessageInfo.kMessageType}":
          MessageTypes.deleted.index
    });
    // commit batch to commit multiple operations at once
    return await commitBatch();
  }

  Future<Either<FirebaseFailure, dynamic>> getMessage(String messageId, String groupId) async {
    return await FirebaseRepository.getDocumentWithId(
        collection:
            "${ApiConstants.groupsChat}/$groupId/${ApiConstants.messages}",
        documentId: messageId);
  }

  /// Function Name : _updateGroupLastMessageInfoIfSame
  /// Purpose: function to update group last message info if the message is the last message in the group
  /// Parameters:
  ///         messageId: String - message id to check if last message same as it
  ///         groupId: String - group id
  ///         updatedData: Map`<String, dynamic>` - updated data

  Future<void> _updateGroupLastMessageInfoIfSame(String messageId, String groupId,
      Map<String, dynamic> updatedData) async {
    var data = await FirebaseFirestore.instance
        .collection(ApiConstants.groups)
        .where(
            "${GroupModel.kGroupLastMessageInfo}.${GroupLastMessageInfo.kMessageId}",
            isEqualTo: messageId)
        .get();

    if (data.docs.isNotEmpty) {
      FirebaseRepository.updateDocumentWithIdWithBatch(
          collection: ApiConstants.groups,
          data: updatedData,
          documentId: groupId,
          batch: _batch);
    }
  }

  Future<Either<Failure, dynamic>> editTextMessage(
      {required String newMessageText,
      required String messageId,
      required String groupId,
      required String currentUserId}) async {
    startBatch();
    FirebaseRepository.updateDocumentWithIdWithBatch(
        collection:
            "${ApiConstants.groupsChat}/$groupId/${ApiConstants.messages}",
        data: {
          GroupChatMessageModel.kMessageContent: newMessageText,
          GroupChatMessageModel.kIsEdited: true
        },
        documentId: messageId,
        batch: _batch);

    await _updateGroupLastMessageInfoIfSame(messageId, groupId, {
      "${GroupModel.kGroupLastMessageInfo}.${GroupLastMessageInfo.kTextMessage}":
          newMessageText
    });

    return commitBatch();
  }

  void updateGroupMentionList(
      {required String groupId, required List<String> mentions}) {
    FirebaseRepository.updateDocumentWithIdWithBatch(
        collection: ApiConstants.groups,
        documentId: groupId,
        data: {GroupModel.kMentionedMembers: FieldValue.arrayUnion(mentions)},
        batch: _batch);
  }

  Future<Either<FirebaseFailure, void>> updateMessage(
      String messageId, String groupId, Map<String, dynamic> data) async {
    return await FirebaseRepository.setDocumentWithId(
      collection:
          "${ApiConstants.groupsChat}/$groupId/${ApiConstants.messages}",
      documentId: messageId,
      data: data,
    );
  }
}
