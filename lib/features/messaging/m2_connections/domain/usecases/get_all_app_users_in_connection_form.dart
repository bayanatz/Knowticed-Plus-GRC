/// Module: messaging / connections / domain/use_cases/get_all_app_users_in_connection_form.dart
/// ************************* FILE INFO *************************** ///
/// File Name: get_all_app_users_in_connection_form.dart
/// Purpose: Get all app users in connection form — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:dartz/dartz.dart';

import 'package:grc_module/core/network/message_module/services/error_handler.dart';
import '../../../../../core/helper/message_module/interface/entity/user_category.dart';
import '../../../../../core/helper/message_module/interface/entity/user_connection_interface_parameters.dart';
import '../base_repository/base_connections_repository.dart';
import '../entities/single_connection_entity.dart';

/// created by Mohamed Elrashidy
/// created at 30/9/2024
/// description: this class will get all app users and connections and then
/// return single connection entity of all of this entities sorted by the
/// last message time

class GetAllAppUsersInConnectionFormUseCase {
  final ConnectionsRepositoryInterface connectionRepository;

  GetAllAppUsersInConnectionFormUseCase({required this.connectionRepository});

  Stream<Either<Failure, List<SingleConnectionEntity>>> execute({
    required String currentUserId,
    required Future<List<UserConnectionInterfaceParameters>> Function() getAllUsers,
    required List<UserCategory> categories, // ✅ added
  }) async* {
    // Domain stays pure — no try/catch here (§11.2). Any failure from the
    // injected data source propagates to the caller (cubit), which handles it
    // via the stream's onError.
    final List<UserConnectionInterfaceParameters> allUsers = await getAllUsers();

    List<SingleConnectionEntity> connectionLessUsers = mapConnectionLessUsers(
      allUsers: allUsers,
      currentUserId: currentUserId,
    );

    yield* startStreamOfConnections(
      currentUserId,
      connectionLessUsers,
      categories, // ✅ pass through
    );
  }

  Stream<Either<Failure, List<SingleConnectionEntity>>> startStreamOfConnections(
      String currentUserId,
      List<SingleConnectionEntity> allUsers,
      List<UserCategory> categories, // ✅ added
      ) async* {
    await for (final connections in connectionRepository
        .getCurrentUserConnections(
      currentUserId: currentUserId,
      categories: categories, // ✅ pass through
    )) {
      if (connections.isLeft()) {
        yield Left(connections.fold(
              (l) => l,
              (r) => FirebaseFailure(""),
        ));
      } else if (connections.isRight()) {
        List<SingleConnectionEntity> existedConnections =
        connections.getOrElse(() => [] as List<SingleConnectionEntity>)
        as List<SingleConnectionEntity>;

        List<SingleConnectionEntity> allUsersInConnectionForm =
        getAllDataInSingleConnectionForm(
          allUsers,
          existedConnections,
          currentUserId,
        );

        yield Right(allUsersInConnectionForm);
      }
    }
  }

  List<SingleConnectionEntity> getAllDataInSingleConnectionForm(
      List<SingleConnectionEntity> allUsers,
      List<SingleConnectionEntity> existedConnections,
      String currentUserId,
      ) {
    List<SingleConnectionEntity> allUsersInConnectionForm = [];
    Set<String> ids = {};

    for (SingleConnectionEntity connection in existedConnections) {
      ids.add(connection.userId);
      allUsersInConnectionForm.add(connection);
    }

    for (SingleConnectionEntity user in allUsers) {
      if (ids.contains(user.userId)) continue;
      if (user.userId == currentUserId) continue;
      allUsersInConnectionForm.add(user);
    }

    allUsersInConnectionForm
        .sort((a, b) => b.lastMessageTime!.compareTo(a.lastMessageTime!));

    return allUsersInConnectionForm;
  }

  List<SingleConnectionEntity> mapConnectionLessUsers({
    required List<UserConnectionInterfaceParameters> allUsers,
    required String currentUserId,
  }) {
    List<SingleConnectionEntity> connectionLessUsers = [];
    for (UserConnectionInterfaceParameters user in allUsers) {
      connectionLessUsers.add(
        SingleConnectionEntity.fromBaseMessagingInterface(user, currentUserId),
      );
    }
    return connectionLessUsers;
  }
}