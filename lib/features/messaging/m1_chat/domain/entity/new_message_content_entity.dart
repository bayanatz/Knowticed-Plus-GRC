/// Module: messaging / chat / domain/entity/new_message_content_entity.dart
import 'package:grc_module/core/enums/message_module/message_types.dart';
import '../../../m3_groups/domain/entities/member_entity.dart';
import '../../data/models/message/audio_message_model.dart';
import '../../data/models/message/doc_message_model.dart';
import '../../data/models/message/video_message_model.dart';

/// NewMessageContentEntity is an abstract class that is used to create new message content entities.
/// Purpose: this class is used to avoid creating many functions for each message type.
/// Example: if we have 10 message types, we will have to create 10 functions for each message type.
/// Instead, we can create a single function that takes NewMessageContentEntity as a parameter.
/// and make single part of the follow handle the message type.
/// Author: Mohamed Elrashidy
/// Created At: 24 oct 2024
sealed class NewMessageContentEntity {
  MessageTypes messageType;
  String? repliedMessageId;

  NewMessageContentEntity({required this.messageType, this.repliedMessageId});
}

class TextMessageContentEntity extends NewMessageContentEntity {
  String messageContent;
  Map<String, MemberEntity>? mentionedMembers;
  String? previewContent;
  TextMessageContentEntity(
      {required this.messageContent,
        super.repliedMessageId,
        this.mentionedMembers,
        this.previewContent})
      : super(messageType: MessageTypes.text);
}

class ImageMessageContentEntity extends NewMessageContentEntity {
  String filePath;
  String? caption;
  ImageMessageContentEntity(
      {required this.filePath, required this.caption, super.repliedMessageId})
      : super(messageType: MessageTypes.cameraImage);
}

class DocumentMessageContentEntity extends NewMessageContentEntity {
  DocMessageModel documentMessageModel;
  DocumentMessageContentEntity(
      {required this.documentMessageModel, super.repliedMessageId})
      : super(messageType: MessageTypes.doc);
}

class VideoMessageContentEntity extends NewMessageContentEntity {
  VideoMessageModel video;
  String? caption;
  VideoMessageContentEntity(
      {required this.video, required this.caption, super.repliedMessageId})
      : super(messageType: MessageTypes.video);
}

class AudioMessageContentEntity extends NewMessageContentEntity {
  AudioMessageModel audio;
  AudioMessageContentEntity({required this.audio, super.repliedMessageId})
      : super(messageType: MessageTypes.audio);
}