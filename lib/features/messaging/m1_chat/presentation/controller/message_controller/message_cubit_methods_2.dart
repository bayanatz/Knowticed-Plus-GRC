/// Module: messaging/m1_chat
///
///*************************** FILE INFO ****************************///
/// File Name: message_cubit_methods_2.dart
/// Description: Methods of `MessageCubit` — split out of `message_controller.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../message_controller.dart';

// Split from message_controller.dart to keep every file under 700 lines.

extension MessageCubitMethods2 on MessageCubit {
  void shareMessage(MessageModel messageModel) {
    if (messageModel.videoModel != null) {
      // ShareHelper.shareFile
    } else if (messageModel.image != null) {
      ShareHelper.shareFile(
        messageModel.image!,
        text: messageModel.message,
      );
    } else if (messageModel.audioModel != null) {
      ShareHelper.shareFile(
        File(messageModel.audioModel!.audioPath),
      );
    } else if (messageModel.docModel != null) {
      // ShareHelper.shareFile
    } else if (messageModel.locationModel != null) {
      ShareHelper.shareText(
        'https://www.openstreetmap.org/?mlat=${messageModel.locationModel!.latitude}&mlon=${messageModel.locationModel!.longitude}#map=15/${messageModel.locationModel!.latitude}/${messageModel.locationModel!.longitude}',
      );
    } else {
      ShareHelper.shareText(messageModel.message!);
    }
  }

  /// Set — not append — the reaction on a message.
  ///
  /// FIXED 2/9/2026. This was `reacts: [...reactMsg.reacts, react]`, a plain
  /// append, so reacting a second time stacked a second emoji on the bubble
  /// and a third tap a third. One person holds ONE reaction, so:
  ///
  ///   - tapping the reaction that is already there removes it (toggle off);
  ///   - tapping a different one replaces whatever was there.
  ///
  /// Replacing the whole list is safe here because [MessageEntity.reacts] is
  /// local, single-user state: nothing in data/ reads or writes it (no model
  /// maps a `reacts` field, and it defaults to `const []`), so the list only
  /// ever holds what this device added. If reactions are later persisted per
  /// member, this must key off the current user's id instead of clearing the
  /// list, or one person's tap will wipe everyone else's.
  void reactToMessage({required Reacts react, required int messageIndex}) {
    if (_chatModel == null) return;
    if (messageIndex < 0 || messageIndex >= _chatModel!.messages.length) return;

    // §10 — reacts field is final; rebuild the list and reassign via copyWith.
    final reactMsg = _chatModel!.messages[messageIndex];
    final bool isSameReact = reactMsg.reacts.contains(react);

    _chatModel!.messages[messageIndex] = reactMsg.copyWith(
      reacts: isSameReact ? const <Reacts>[] : <Reacts>[react],
    );
    _emitLoadedState();
  }

  void _emitLoadedState() {
    if (state is MessageLoaded) {
      emitState((state as MessageLoaded).copyWith(
        chatModel: _chatModel,
        firstUnreadIndex: _firstUnreadIndex,
        isEmojiPickerVisible: _isEmojiPickerVisible,
        isRecording: _isRecording,
        ellapsedSeconds: _ellapsedSeconds,
        ellapsedMinutes: _ellapsedMinutes,
        currentlyPlayingAudioModel: _currentlyPlayingAudioModel,
        duration: _duration,
        clearOption: _clearOption,
        reportContact: _reportContact,
        blockContact: _blockContact,
        multibleChoices: _multibleChoices,
        pollOptions: _pollOptions,
        captionControllers: _captionControllers,
        swiperIndex: _swiperIndex,
        bufferedVideo: _bufferedVideo,
        isPlaying: _isPlaying,
        videoDuration: _videoDuration,
        progressShown: _progressShown,
        slideChanging: _slideChanging,
        editMessageModel: _editMessageModel,
        replyMessageModel: _replyMessageModel,
        replyScrollIndex: _replyScrollIndex,
        reactVisible: _reactVisible,
        forwardCheckBoxes: _forwardCheckBoxes,
        selectedForwardMessages: _selectedForwardMessages,
        selectMessages: _selectMessages,
        pickedLocation: _pickedLocation,
        selectedAllTab: _selectedAllTab,
        selectedRole: _selectedRole,
      ));
    } else {
      emitState(MessageLoaded(
        chatModel: _chatModel,
        firstUnreadIndex: _firstUnreadIndex,
        isEmojiPickerVisible: _isEmojiPickerVisible,
        isRecording: _isRecording,
        ellapsedSeconds: _ellapsedSeconds,
        ellapsedMinutes: _ellapsedMinutes,
        currentlyPlayingAudioModel: _currentlyPlayingAudioModel,
        duration: _duration,
        clearOption: _clearOption,
        reportContact: _reportContact,
        blockContact: _blockContact,
        multibleChoices: _multibleChoices,
        pollOptions: _pollOptions,
        captionControllers: _captionControllers,
        swiperIndex: _swiperIndex,
        bufferedVideo: _bufferedVideo,
        isPlaying: _isPlaying,
        videoDuration: _videoDuration,
        progressShown: _progressShown,
        slideChanging: _slideChanging,
        editMessageModel: _editMessageModel,
        replyMessageModel: _replyMessageModel,
        replyScrollIndex: _replyScrollIndex,
        reactVisible: _reactVisible,
        forwardCheckBoxes: _forwardCheckBoxes,
        selectedForwardMessages: _selectedForwardMessages,
        selectMessages: _selectMessages,
        pickedLocation: _pickedLocation,
        selectedAllTab: _selectedAllTab,
        selectedRole: _selectedRole,
      ));
    }
  }
}
