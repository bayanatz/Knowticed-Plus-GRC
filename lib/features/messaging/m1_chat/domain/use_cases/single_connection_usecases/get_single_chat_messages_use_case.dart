/// Module: messaging / chat / domain/use_cases/single_connection_usecases/get_single_chat_messages_use_case.dart
import 'dart:io';

import 'package:dartz/dartz.dart';

import 'package:grc_module/core/network/message_module/services/error_handler.dart';
import 'package:grc_module/core/enums/message_module/message_types.dart';
import 'package:grc_module/core/helper/message_module/main_helper/file_handler.dart';
import '../../../data/models/message/video_message_model.dart';
import '../../entity/message_entity.dart';
import '../../repository/chat_repository/base_chat_repository.dart';

class GetSingleChatMessages {
  final BaseChatRepository repository;
  GetSingleChatMessages({required this.repository});

  // ✅ FIX: added currentUserId parameter
  execute(String chatId, {required String currentUserId}) async* {
    Stream<Either<Failure, dynamic>> chatMessages =
    repository.getChatMessages(chatId);
    await for (final chatMessage in chatMessages) {
      Either<Failure, List<MessageEntity>> messages;
      if (chatMessage.isLeft()) {
        Failure? failure = chatMessage.fold((l) => l, (r) => null);
        messages = Left(failure!);
        yield messages;
        return;
      }
      yield* _getMessageEntities(
        fetchedMessages: chatMessage.getOrElse(() => []),
        chatId: chatId,
        currentUserId: currentUserId, // ✅ pass through
      );
    }
  }

  _getMessageEntities({
    required fetchedMessages,
    required String chatId,
    required String currentUserId, // ✅ added
  }) async* {
    Either<Failure, List<MessageEntity>> result;
    List<MessageEntity> messageEntities = [];
    Map<String, MessageEntity> messages = {};
    for (var message in fetchedMessages) {
      // ✅ FIX: pass currentUserId as third argument
      messages[message.messageId] =
          message.toMessageEntity(chatId, messages, currentUserId);
      await handleMediaMessage(message: messages[message.messageId]!);
      messageEntities.add(messages[message.messageId]!);
    }
    result = Right(messageEntities);
    yield result;
  }

  handleMediaMessage({required MessageEntity message}) async {
    if (message.messageType == MessageTypes.audio) {
      File file = await FileHandler().downloadFile(
          message.audio!.audioPath,
          message.time.toString() +
              '.' +
              message.audio!.audioPath.split('.').last.split('?').first);
      message.audio!.audioPath = file.path;
      message.mediaLink = message.audio!.audioPath;
    }
    if (message.messageType == MessageTypes.doc) {
      File file = await FileHandler().downloadFile(
          message.docMessageModel!.docPath,
          message.time.toString() + message.docMessageModel!.fileName!);

      message.docMessageModel!.docPath = file.path;
      message.mediaLink = message.docMessageModel!.docPath;
    }
    if (message.messageType == MessageTypes.video) {
      File file = await FileHandler().downloadFile(
          message.videoMessageModel!.videoFilePath,
          message.time.toString() +
              '.' +
              message.videoMessageModel!.videoFilePath
                  .split('.')
                  .last
                  .split('?')
                  .first);
      message.videoMessageModel!.videoFilePath = file.path;
      VideoMessageModel videoMessageModel = VideoMessageModel(
          videoFilePath: message.videoMessageModel!.videoFilePath);
      message.mediaLink = message.videoMessageModel!.videoFilePath;
      message.videoMessageModel = videoMessageModel;
    }
  }
}