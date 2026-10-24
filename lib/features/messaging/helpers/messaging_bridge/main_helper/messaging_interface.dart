/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: messaging_interface.dart
/// Purpose: Declares `MessagingInterface`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/domain/entities/group_entity.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/base_messaging_interface_parameters.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/group_chat_interface_parameters.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/messaging_configurations.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/single_chat_interface_parameters.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/user_category.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/user_connection_interface_parameters.dart';

// all interface
abstract class MessagingInterface {
  MessagingInterface(
      {required MessagingConfigurations messagingConfigurations});

  //
  void useSingleMessagingOnly(
      {required SingleChatInterfaceParameters singleChatParameters});
  void useGroupAndSingleMessaging(
      {required GroupChatInterfaceParameters groupChatParameters,
      required Future<List<UserConnectionInterfaceParameters>> Function()
          getAllUsersDate,
      required UserCategory defaultCategory,
      required BuildContext context});
  Future<void> showSpecificSingleChat(
      {required String otherUserId, required BuildContext context});

  Future<void> showSpecificGroupChat(
      {required String groupId, required BuildContext context});

  void updateMyInfoWithConnections(
      {required BaseMessagingInterfaceParameters userParameters});

  Future<Either<Failure, void>> createNewConnection(
      {required BaseMessagingInterfaceParameters currentUser,
      required BaseMessagingInterfaceParameters newConnectionUser});

  bool isConnected(
      {required BaseMessagingInterfaceParameters currentUser,
      required BaseMessagingInterfaceParameters otherUser});
  bool isThereAnyUnreadMessages({required String currentUserId});

  void deleteConnection({required String otherUserId});

  void blockConnection({required String otherUserId});

  List<GroupEntity> getUserGroups();
}
