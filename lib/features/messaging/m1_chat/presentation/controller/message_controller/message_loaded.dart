/// Module: messaging/m1_chat
///
///*************************** FILE INFO ****************************///
/// File Name: message_loaded.dart
/// Description: `MessageLoaded` — split out of `message_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../message_controller.dart';

// Split from message_controller.dart to keep every file under 700 lines.

class MessageLoaded extends MessageState {
  final ChatModel? chatModel;
  final int? firstUnreadIndex;
  final bool isEmojiPickerVisible;
  final bool isRecording;
  final int ellapsedSeconds;
  final int ellapsedMinutes;
  final AudioMessageModel? currentlyPlayingAudioModel;
  final DurationValues? duration;
  final List<bool> clearOption;
  final bool? reportContact;
  final bool? blockContact;
  final bool multibleChoices;
  final List<TextEditingController> pollOptions;
  final List<TextEditingController> captionControllers;
  final int swiperIndex;
  final double bufferedVideo;
  final bool isPlaying;
  final String videoDuration;
  final bool progressShown;
  final bool slideChanging;
  final MessageEntity? editMessageModel;
  final MessageModel? replyMessageModel;
  final int? replyScrollIndex;
  final bool reactVisible;
  final List<bool> forwardCheckBoxes;
  final List<MessageModel> selectedForwardMessages;
  final bool selectMessages;
  final LocationMessageModel? pickedLocation;
  final String selectedAllTab;
  final Map<int, String> selectedRole;

  MessageLoaded({
    this.chatModel,
    this.firstUnreadIndex,
    required this.isEmojiPickerVisible,
    required this.isRecording,
    required this.ellapsedSeconds,
    required this.ellapsedMinutes,
    this.currentlyPlayingAudioModel,
    this.duration,
    required this.clearOption,
    this.reportContact,
    this.blockContact,
    required this.multibleChoices,
    required this.pollOptions,
    required this.captionControllers,
    required this.swiperIndex,
    required this.bufferedVideo,
    required this.isPlaying,
    required this.videoDuration,
    required this.progressShown,
    required this.slideChanging,
    this.editMessageModel,
    this.replyMessageModel,
    this.replyScrollIndex,
    required this.reactVisible,
    required this.forwardCheckBoxes,
    required this.selectedForwardMessages,
    required this.selectMessages,
    this.pickedLocation,
    required this.selectedAllTab,
    required this.selectedRole,
  });

  MessageLoaded copyWith({
    ChatModel? chatModel,
    int? firstUnreadIndex,
    bool? isEmojiPickerVisible,
    bool? isRecording,
    int? ellapsedSeconds,
    int? ellapsedMinutes,
    AudioMessageModel? currentlyPlayingAudioModel,
    DurationValues? duration,
    List<bool>? clearOption,
    bool? reportContact,
    bool? blockContact,
    bool? multibleChoices,
    List<TextEditingController>? pollOptions,
    List<TextEditingController>? captionControllers,
    int? swiperIndex,
    double? bufferedVideo,
    bool? isPlaying,
    String? videoDuration,
    bool? progressShown,
    bool? slideChanging,
    MessageEntity? editMessageModel,
    MessageModel? replyMessageModel,
    int? replyScrollIndex,
    bool? reactVisible,
    List<bool>? forwardCheckBoxes,
    List<MessageModel>? selectedForwardMessages,
    bool? selectMessages,
    LocationMessageModel? pickedLocation,
    String? selectedAllTab,
    Map<int, String>? selectedRole,
    bool clearFirstUnreadIndex = false,
    bool clearCurrentlyPlayingAudioModel = false,
    bool clearDuration = false,
    bool clearReportContact = false,
    bool clearBlockContact = false,
    bool clearEditMessageModel = false,
    bool clearReplyMessageModel = false,
    bool clearReplyScrollIndex = false,
    bool clearPickedLocation = false,
  }) {
    return MessageLoaded(
      chatModel: chatModel ?? this.chatModel,
      firstUnreadIndex: clearFirstUnreadIndex
          ? null
          : (firstUnreadIndex ?? this.firstUnreadIndex),
      isEmojiPickerVisible: isEmojiPickerVisible ?? this.isEmojiPickerVisible,
      isRecording: isRecording ?? this.isRecording,
      ellapsedSeconds: ellapsedSeconds ?? this.ellapsedSeconds,
      ellapsedMinutes: ellapsedMinutes ?? this.ellapsedMinutes,
      currentlyPlayingAudioModel: clearCurrentlyPlayingAudioModel
          ? null
          : (currentlyPlayingAudioModel ?? this.currentlyPlayingAudioModel),
      duration: clearDuration ? null : (duration ?? this.duration),
      clearOption: clearOption ?? this.clearOption,
      reportContact:
          clearReportContact ? null : (reportContact ?? this.reportContact),
      blockContact:
          clearBlockContact ? null : (blockContact ?? this.blockContact),
      multibleChoices: multibleChoices ?? this.multibleChoices,
      pollOptions: pollOptions ?? this.pollOptions,
      captionControllers: captionControllers ?? this.captionControllers,
      swiperIndex: swiperIndex ?? this.swiperIndex,
      bufferedVideo: bufferedVideo ?? this.bufferedVideo,
      isPlaying: isPlaying ?? this.isPlaying,
      videoDuration: videoDuration ?? this.videoDuration,
      progressShown: progressShown ?? this.progressShown,
      slideChanging: slideChanging ?? this.slideChanging,
      editMessageModel: clearEditMessageModel
          ? null
          : (editMessageModel ?? this.editMessageModel),
      replyMessageModel: clearReplyMessageModel
          ? null
          : (replyMessageModel ?? this.replyMessageModel),
      replyScrollIndex: clearReplyScrollIndex
          ? null
          : (replyScrollIndex ?? this.replyScrollIndex),
      reactVisible: reactVisible ?? this.reactVisible,
      forwardCheckBoxes: forwardCheckBoxes ?? this.forwardCheckBoxes,
      selectedForwardMessages:
          selectedForwardMessages ?? this.selectedForwardMessages,
      selectMessages: selectMessages ?? this.selectMessages,
      pickedLocation:
          clearPickedLocation ? null : (pickedLocation ?? this.pickedLocation),
      selectedAllTab: selectedAllTab ?? this.selectedAllTab,
      selectedRole: selectedRole ?? this.selectedRole,
    );
  }
}
