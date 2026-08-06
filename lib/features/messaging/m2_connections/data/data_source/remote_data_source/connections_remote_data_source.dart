/// Module: messaging / connections / data/data_source/remote_data_source/connections_remote_data_source.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connections_remote_data_source.dart
/// Purpose: Connections remote data source — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:dartz/dartz.dart';

import 'package:grc_module/core/network/message_module/services/error_handler.dart';
import 'package:grc_module/core/constants/message_module/api_constants.dart';
import 'package:grc_module/core/services/firebase/models/query_data_model.dart';
import 'package:grc_module/core/services/message_module/firebase/repository/firebase_repository.dart';
import '../../models/user_connection_last_message_info_model.dart';
import '../../models/users_connection_model.dart';

class ConnectionsRemoteDataSource {
  Future<Either<Failure, void>> createNewConnection(
      {required UsersConnectionModel currentUserConnectionModel,
      required UsersConnectionModel otherUserConnectionModel}) async {
    // user id for each document come from other as each user has information about the other user
    return await FirebaseRepository.setMultipleDocuments(queryDataModels: [
      QueryDataModel(
          collectionPath:
              '${ApiConstants.usersConnections}/${otherUserConnectionModel.userId}/${ApiConstants.lastMessage}',
          documentId: currentUserConnectionModel.userId,
          queryData: currentUserConnectionModel.toMap()),
      QueryDataModel(
          collectionPath:
              '${ApiConstants.usersConnections}/${currentUserConnectionModel.userId}/${ApiConstants.lastMessage}',
          documentId: otherUserConnectionModel.userId,
          queryData: otherUserConnectionModel.toMap())
    ]);
  }

  Stream<Either<Failure, List<Map<String, dynamic>>>> getCurrentUserConnection(
      {required String currentUserId}) async* {
    log(
        "collection path: ${ApiConstants.usersConnections}/$currentUserId/${ApiConstants.lastMessage}");
    yield* FirebaseRepository.getStreamOfCollectionSorted(
        collectionPath:
            '${ApiConstants.usersConnections}/$currentUserId/${ApiConstants.lastMessage}',
        sortedBy: UserConnectionLastMessageInfoModel.LAST_MESSAGE_TIME);
  }
}
