/// Module: messaging / connections / data/repository/connections_repository.dart
/// ************************* FILE INFO *************************** ///
/// File Name: connections_repository.dart
/// Purpose: Connections repository — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:grc_module/core/network/message_module/services/error_handler.dart';
import '../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../domain/base_repository/base_connections_repository.dart';
import '../../domain/entities/single_connection_entity.dart';
import '../data_source/remote_data_source/connections_remote_data_source.dart';
import '../models/users_connection_model.dart';

// created by Mohamed Elrashidy
// created at 30/9/2024
// description: this class is a repository class that will be used to handle user connections
class ConnectionsRepository extends ConnectionsRepositoryInterface {
  ConnectionsRemoteDataSource remoteDataSource = ConnectionsRemoteDataSource();

  @override
  Future<Either<Failure, void>> createNewConnection({
    required BaseMessagingInterfaceParameters currentUser,
    required BaseMessagingInterfaceParameters newConnectionUser,
  }) async {
    log('creating new connection repository');
    Timestamp timestamp = Timestamp.now();
    String connectionId = "${currentUser.userId}.${newConnectionUser.userId}";
    UsersConnectionModel currentUserConnectionModel = _createConnectionModel(
      user: newConnectionUser,
      timestamp: timestamp,
      connectionId: connectionId,
    );
    UsersConnectionModel newConnectionUserConnectionModel =
    _createConnectionModel(
      user: currentUser,
      timestamp: timestamp,
      connectionId: connectionId,
    );
    return await remoteDataSource.createNewConnection(
      currentUserConnectionModel: currentUserConnectionModel,
      otherUserConnectionModel: newConnectionUserConnectionModel,
    );
  }

  UsersConnectionModel _createConnectionModel({
    required BaseMessagingInterfaceParameters user,
    required Timestamp timestamp,
    required String connectionId,
  }) {
    return UsersConnectionModel(
      connectionId: connectionId,
      userPrimaryLanguageName: user.primaryLanguageName,
      userSecondaryLanguageName: user.secondaryLanguageName,
      userPrimaryLanguageSubInfo: user.primaryLanguageSubInfo,
      userSecondaryLanguageSubInfo: user.secondaryLanguageSubInfo,
      userPhone: user.phone,
      userCategoryId: user.userCategory?.categoryId,
      userId: user.userId,
      userImageUri: user.imageUri,
      startedConnectionTime: timestamp,
    );
  }

  // ✅ FIX: categories parameter added so toSingleConnectionEntity()
  //         can resolve UserCategory without GetX
  @override
  Stream<Either<Failure, dynamic>> getCurrentUserConnections({
    required String currentUserId,
    required List<UserCategory> categories,
  }) async* {
    await for (final futureResult in remoteDataSource.getCurrentUserConnection(
        currentUserId: currentUserId)) {
      final result = futureResult;
      if (result.isRight()) {
        List<Map<String, dynamic>> connections = result.getOrElse(() => []);

        for (var connection in connections) {
          log('Connection: ${connection.toString()}');
        }

        List<SingleConnectionEntity> existedConnections =
        connections.map((connection) {
          return UsersConnectionModel.fromMap(connection)
              .toSingleConnectionEntity(categories: categories); // ✅ pass categories
        }).toList();

        yield Right(existedConnections);
      } else if (result.isLeft()) {
        yield result;
      }
    }
  }
}