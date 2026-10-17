/// Module: messaging / chat / data/data_source/single_chat_remote_data_source.dart
library;

import 'package:dartz/dartz.dart';
import 'package:grc_module/core/network/failure_model.dart';
import 'package:grc_module/features/messaging/helpers/constants/messaging_api_constants.dart';
import 'package:grc_module/features/messaging/helpers/enums/message_types.dart';
import 'package:grc_module/core/app_services/firebase/models/query_data_model.dart';
import 'package:grc_module/features/messaging/helpers/services/firebase/repository/firebase_repository.dart';
import 'package:grc_module/features/messaging/m2_connections/data/models/user_connection_last_message_info_model.dart';
import 'package:grc_module/features/messaging/m1_chat/data/models/single_chat_message_model.dart';

class SingleChatRemoteDataSource {
  Future<Either<Failure, void>> sendSingleChatMessage({
    required String chatId,
    required String messageId,
    required SingleChatMessageModel messageData,
    required UserConnectionLastMessageInfoModel currentUserConnectionModel,
    required UserConnectionLastMessageInfoModel otherUserConnectionModel,
  }) async {
    QueryDataModel messageQueryDataModel = createMessageQuery(
        chatId: chatId, messageId: messageId, messageData: messageData);
    QueryDataModel currentUserConnectionLastMessageInfoModel =
        createSenderConnectionLastMessageInfoQuery(
            senderId: messageData.senderId,
            receiverId: messageData.receiverId,
            senderConnectionLastMessageInfo: currentUserConnectionModel);
    QueryDataModel otherUserConnectionLastMessageInfoModel =
        createReceiverConnectionLastMessageInfoQuery(
            senderId: messageData.senderId,
            receiverId: messageData.receiverId,
            receiverConnectionLastMessageInfo: otherUserConnectionModel);

    return await FirebaseRepository.setMultipleDocuments(queryDataModels: [
      messageQueryDataModel,
      currentUserConnectionLastMessageInfoModel,
      otherUserConnectionLastMessageInfoModel
    ]);
  }

  QueryDataModel createMessageQuery(
      {required String chatId,
      required String messageId,
      required SingleChatMessageModel messageData}) {
    return QueryDataModel(
        collectionPath:
            '${ApiConstants.singleChatMessages}/$chatId/${ApiConstants.messages}',
        queryData: messageData.toMap(),
        documentId: messageId);
  }

  QueryDataModel createSenderConnectionLastMessageInfoQuery(
      {required String senderId,
      required String receiverId,
      required UserConnectionLastMessageInfoModel
          senderConnectionLastMessageInfo}) {
    return QueryDataModel(
        collectionPath:
            "${ApiConstants.usersConnections}/$senderId/${ApiConstants.lastMessage}",
        queryData: senderConnectionLastMessageInfo.toMap(),
        documentId: receiverId);
  }

  QueryDataModel createReceiverConnectionLastMessageInfoQuery(
      {required String senderId,
      required String receiverId,
      required UserConnectionLastMessageInfoModel
          receiverConnectionLastMessageInfo}) {
    return QueryDataModel(
        collectionPath:
            "${ApiConstants.usersConnections}/$receiverId/${ApiConstants.lastMessage}",
        queryData: receiverConnectionLastMessageInfo.toMap(),
        documentId: senderId);
  }

  Stream<Either<Failure, List<Map<String, dynamic>>>> getChatMessages(
      {required String chatId}) async* {
    yield* FirebaseRepository.getStreamOfCollectionSorted(
      collectionPath:
          '${ApiConstants.singleChatMessages}/$chatId/${ApiConstants.messages}',
      sortedBy: SingleChatMessageModel.kSendTime,
    );
  }

  Future<Either<FirebaseFailure, void>> updateMyNumOfUnreadMessages(
      {required String currentUserId,
      required String otherUserId,
      required int newValue}) async {
    QueryDataModel currentUserConnection = QueryDataModel(
        collectionPath:
            "${ApiConstants.usersConnections}/$currentUserId/${ApiConstants.lastMessage}",
        documentId: otherUserId,
        queryData: {
          UserConnectionLastMessageInfoModel.kMyUnreadMessagesCount: newValue
        });

    QueryDataModel otherUserConnection = QueryDataModel(
        collectionPath:
            "${ApiConstants.usersConnections}/$otherUserId/${ApiConstants.lastMessage}",
        documentId: currentUserId,
        queryData: {
          UserConnectionLastMessageInfoModel.kOtherUnreadMessagesCount: newValue
        });
    return await FirebaseRepository.setMultipleDocuments(
        queryDataModels: [currentUserConnection, otherUserConnection]);
  }

  Future<Either<FirebaseFailure, void>> updateMessagesAsSeen(
      {required String chatId, required List<String> unSeenMessagesIds}) async {
    List<QueryDataModel> queryDataModels = [];
    for (String messageId in unSeenMessagesIds) {
      QueryDataModel queryDataModel = QueryDataModel(
          collectionPath:
              '${ApiConstants.singleChatMessages}/$chatId/${ApiConstants.messages}',
          documentId: messageId,
          queryData: {SingleChatMessageModel.kIsSeen: true});
      queryDataModels.add(queryDataModel);
    }
    return await FirebaseRepository.setMultipleDocuments(
        queryDataModels: queryDataModels);
  }

  Future<Either<FirebaseFailure, void>> editTextMessage(
      {required String newMessageText,
      required String messageId,
      required String chatId,
      required String otherId,
      required String currentUserId}) async {
    QueryDataModel queryDataModel = QueryDataModel(
        collectionPath:
            '${ApiConstants.singleChatMessages}/$chatId/${ApiConstants.messages}',
        documentId: messageId,
        queryData: {
          SingleChatMessageModel.kMessageContent: newMessageText,
          SingleChatMessageModel.kIsEdited: true
        });
    QueryDataModel currentUserConnection = QueryDataModel(
        collectionPath:
            "${ApiConstants.usersConnections}/$currentUserId/${ApiConstants.lastMessage}",
        documentId: otherId,
        equalFieldsValues: {
          UserConnectionLastMessageInfoModel.kMessageId: messageId
        },
        queryData: {
          UserConnectionLastMessageInfoModel.kTextMessage: newMessageText
        });

    QueryDataModel otherUserConnection = QueryDataModel(
        collectionPath:
            "${ApiConstants.usersConnections}/$otherId/${ApiConstants.lastMessage}",
        documentId: currentUserId,
        equalFieldsValues: {
          UserConnectionLastMessageInfoModel.kMessageId: messageId
        },
        queryData: {
          UserConnectionLastMessageInfoModel.kTextMessage: newMessageText
        });

    return await FirebaseRepository.setMultipleDocuments(queryDataModels: [
      queryDataModel,
      currentUserConnection,
      otherUserConnection
    ]);
  }

  Future<Either<FirebaseFailure, void>> deleteMessage(
      {required String messageId,
      required String chatId,
      required String otherId,
      required String currentUserId}) async {
    QueryDataModel queryDataModel = QueryDataModel(
        collectionPath:
            '${ApiConstants.singleChatMessages}/$chatId/${ApiConstants.messages}',
        documentId: messageId,
        queryData: {SingleChatMessageModel.kIsDeleted: true});

    QueryDataModel currentUserConnection = QueryDataModel(
        collectionPath:
            "${ApiConstants.usersConnections}/$currentUserId/${ApiConstants.lastMessage}",
        documentId: otherId,
        equalFieldsValues: {
          UserConnectionLastMessageInfoModel.kMessageId: messageId
        },
        queryData: {
          UserConnectionLastMessageInfoModel.kMessageType:
              MessageTypes.deleted.index
        });

    QueryDataModel otherUserConnection = QueryDataModel(
        collectionPath:
            "${ApiConstants.usersConnections}/$otherId/${ApiConstants.lastMessage}",
        documentId: currentUserId,
        equalFieldsValues: {
          UserConnectionLastMessageInfoModel.kMessageId: messageId
        },
        queryData: {
          UserConnectionLastMessageInfoModel.kMessageType:
              MessageTypes.deleted.index
        });

    return await FirebaseRepository.setMultipleDocuments(queryDataModels: [
      queryDataModel,
      currentUserConnection,
      otherUserConnection
    ]);
  }

  Future<Either<FirebaseFailure, String>> uploadImage(
      {required String documentName, required String filePath}) async {
    return await FirebaseRepository.uploadFile(
        collectionName:
            "${ApiConstants.singleChatMessages}/${ApiConstants.images}",
        documentName: documentName,
        filePath: filePath);
  }

  Future<Either<FirebaseFailure, String>> uploadMedia(
      {required String filePath}) async {
    return await FirebaseRepository.uploadFile(
        collectionName: ApiConstants.singleChatMessages,
        documentName: filePath.split("/").last,
        filePath: filePath);
  }

  /// Function Name : [getMessage]
  ///
  /// Purpose: function to get message from single chat
  ///
  /// Parameters:
  ///             [messageId]: [String] - message id
  ///             [chatId]: [String] - chat id
  Future<Either<FirebaseFailure, dynamic>> getMessage(
      String messageId, chatId) async {
    return await FirebaseRepository.getDocumentWithId(
        collection:
            "${ApiConstants.singleChatMessages}/$chatId/${ApiConstants.messages}",
        documentId: messageId);
  }

  Future<void> updateMessage(
      String messageId, chatId, SingleChatMessageModel messageModel) async {
    await FirebaseRepository.setDocumentWithId(
        collection:
            "${ApiConstants.singleChatMessages}/$chatId/${ApiConstants.messages}",
        data: messageModel.toMap(),
        documentId: messageId);
  }
}
