/// Module: messaging / chat / domain/repository/chat_repository/base_chat_repository.dart
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/domain/enum/reacts.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/interface/entity/base_messaging_interface_parameters.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/data/models/user_connection_last_message_info_model.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/domain/entities/chat_type_entity.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/single_chat_message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/domain/entity/new_message_content_entity.dart';

abstract interface class BaseChatRepository {
  Future<Either<Failure, void>> sendMessage({
    required SingleChatMessageModel messageModel,
    required UserConnectionLastMessageInfoModel currentUserConnectionModel,
    required UserConnectionLastMessageInfoModel otherUserConnectionModel,
  });

  Stream<Either<Failure, dynamic>> getChatMessages(String chatId);

  Future<Either<Failure, void>> updateMyNumOfUnreadMessages({
    required String currentUserId,
    required String otherUserId,
    required int newValue,
  });

  Future<Either<Failure, dynamic>> updateMessagesAsSeen({
    required List<String> unSeenMessagesIds,
    required String chatId,
    String? currentUserId,
  });

  Future<Either<Failure, void>?> editTextMessage({
    required String newMessageText,
    required String messageId,
    required String chatId,
    required String otherId,
    required String currentUserId,
  });

  Future<Either<Failure, void>?> deleteMessage({
    required String messageId,
    required String chatId,
    required String otherId,
    required String currentUserId,
  });

  Future<Either<Failure, dynamic>> sendNewMessage({
    required BaseMessagingInterfaceParameters currentUser,
    required ChatTypeEntity otherConnectionSide,
    required NewMessageContentEntity messageContent,
  });

  Future<Either<Failure, void>?> updateMessagePinState({
    required String messageId,
    required chatId,
    required currentUserId,
    required bool state,
  });

  // ✅ Add or toggle a reaction on a message
  Future<Either<Failure, void>> addReact({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required Reacts react,
  });
}
