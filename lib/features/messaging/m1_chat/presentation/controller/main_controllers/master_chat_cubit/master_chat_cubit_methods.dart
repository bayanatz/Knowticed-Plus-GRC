/// Module: messaging/m1_chat
///
///*************************** FILE INFO ****************************///
/// File Name: master_chat_cubit_methods.dart
/// Description: Methods of `MasterChatCubit` — split out of `master_chat_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../master_chat_cubit.dart';

// Split from master_chat_cubit.dart to keep every file under 700 lines.

extension MasterChatCubitMethods on MasterChatCubit {
  // ─────────────────────────────────────────────────────────────────────────
  // Async initialization
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initialize() async {
    try {
      await AudioRecordService.initializeController();
    } catch (e) {
      debugPrint('Ignored error: $e');
    }

    replyMessageCubit = ReplyMessageCubit(
      chatRepository: chatRepository,
      masterChatCubit: this,
    );

    imageMessageCubit = ImageMessageCubit(
      masterChatCubit: this,
      chatRepository: chatRepository,
    );

    editAndDeleteMessageCubit = EditAndDeleteMessageCubit(
      chatRepository: chatRepository,
      masterChatCubit: this,
    );

    recordAndAudioCubit = RecordAndAudioCubit(
      chatRepository: chatRepository,
      masterChatCubit: this,
    );

    textMessageCubit = TextMessageCubit(chatRepository: chatRepository);

    documentMessageCubit = DocumentMessageCubit(
      masterChatCubit: this,
      chatRepository: chatRepository,
    );

    try {
      resetResources();
    } catch (e) {
      debugPrint('Ignored error: $e');
    }
  }

  /// Drops messages that have disappeared and re-numbers the rest, so
  /// `index` / `indexOfRepliedMessage` still point at list positions.
  List<MessageEntity> applyDisappearing(List<MessageEntity> messages) {
    final since = _disappearingSince;
    if (since == null) return messages;
    final int hours = _disappearingHours;

    final Map<int, int> newIndexOf = <int, int>{};
    final List<MessageEntity> kept = <MessageEntity>[];
    for (final m in messages) {
      // "Always": a seen message goes when the chat is next opened, so it
      // never vanishes while the user is reading it.
      final bool seenEarlier =
          m.isSeen && m.time.toDate().isBefore(_chatOpenedAt);
      if (ChatSettingsService.hasDisappeared(m.time.toDate(), since,
          hours: hours, isSeen: seenEarlier)) {
        continue;
      }
      newIndexOf[m.index] = kept.length;
      kept.add(m);
    }
    if (kept.length == messages.length) return messages;

    return <MessageEntity>[
      for (int i = 0; i < kept.length; i++)
        kept[i].copyWith(
          index: i,
          indexOfRepliedMessage: () => kept[i].indexOfRepliedMessage == null
              ? null
              : newIndexOf[kept[i].indexOfRepliedMessage!],
        ),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Forward
  // ─────────────────────────────────────────────────────────────────────────

  /// Re-send [message] into each of [targets] as a new text message.
  ///
  /// ADDED 2/9/2026, for the "Forward" item in the long-press menu.
  ///
  /// TEXT ONLY — see the note on that menu item. The non-text
  /// NewMessageContentEntity variants all take a local file path to upload, and
  /// a received message only has a remote `mediaLink`, so media cannot be
  /// forwarded until a download-and-re-upload step exists.
  ///
  /// Sends are sequential rather than a Future.wait: each one writes the
  /// recipient's own "last message" document, and firing them together made
  /// those writes race in the connections list.
  Future<void> forwardTextMessage({
    required MessageEntity message,
    required List<SingleConnectionEntity> targets,
  }) async {
    final currentUser = state.currentUser;
    final String text = message.messageContent ?? '';

    if (currentUser == null || targets.isEmpty || text.isEmpty) return;

    setSending(true);
    try {
      for (final target in targets) {
        await chatRepository.sendNewMessage(
          currentUser: currentUser,
          otherConnectionSide: target,
          messageContent: TextMessageContentEntity(messageContent: text),
        );
      }
    } finally {
      setSending(false);
    }
  }

  void selectMessageToMakeAction({
    required MessageEntity? message,
    required MessageActionTypes actionType,
    required MessageTypes? newMessageType,
    required BuildContext context,
  }) {
    emitState(state.copyWith(
      newMessageType: newMessageType ?? MessageTypes.text,
      messageActionType: actionType,
      selectedMessage: () => message,
    ));

    if (actionType == MessageActionTypes.editMessage) {
      final raw = message?.messageContent ?? '';
      textMessageEditingController.text = decryptMessage(raw);
      editAndDeleteMessageCubit.setEditMessage();
      messageFocusNode.requestFocus();
      return;
    } else if (actionType == MessageActionTypes.replyMessage) {
      replyMessageCubit.setReplyMessage();
      return;
    } else if (actionType == MessageActionTypes.newMessage) {
      final msgType = state.newMessageType;
      if (msgType == MessageTypes.cameraImage) {
        imageMessageCubit.getImageCamera();
      } else if (msgType == MessageTypes.galleryImage) {
        imageMessageCubit.getImageGallery();
      } else if (msgType == MessageTypes.doc) {
        documentMessageCubit.pickDoc(context: context);
      } else if (msgType == MessageTypes.audio) {
        recordAndAudioCubit.pickAudio(context: context);
      }
    }
  }

  Future<void> applySelectedMessageAction(BuildContext context) async {
    if (state.messageActionType == MessageActionTypes.newMessage) {
      final hasMedia = state.selectedMediaPaths.isNotEmpty;
      final hasDocs = state.selectedDocPaths.isNotEmpty;

      if (hasMedia || hasDocs) {
        // Bug report p.14: the picked-file preview stayed above the input
        // (with its remove badge) after the message was already in the chat.
        // Take a copy and clear the preview as soon as sending starts; the
        // spinner on Send still shows until the upload finishes.
        final List<String> mediaPaths =
            List<String>.of(state.selectedMediaPaths);
        final List<String> docPaths = List<String>.of(state.selectedDocPaths);
        clearAllSelectedFiles();
        setSending(true);
        try {
          if (hasMedia) {
            await imageMessageCubit.sendMultipleMedia(mediaPaths);
          }
          if (hasDocs) {
            await documentMessageCubit.sendMultipleDocumentsFromPaths(docPaths);
          }
        } catch (e) {
          debugPrint('Ignored error: $e');
        } finally {
          setSending(false);
        }
      } else {
        await sendNewMessage();
      }
    }

    if (state.messageActionType == MessageActionTypes.editMessage) {
      if (!context.mounted) return;
      await editAndDeleteMessageCubit.submitEditMessage(context);
    }

    if (state.messageActionType == MessageActionTypes.deleteMessage) {
      await editAndDeleteMessageCubit.deleteMessage();
    }

    if (state.messageActionType == MessageActionTypes.replyMessage) {
      if (!context.mounted) return;
      await replyMessageCubit.submitMessageReply(context);
    }

    emitState(state.copyWith(
      messageActionType: MessageActionTypes.newMessage,
      newMessageType: MessageTypes.text,
    ));
    textMessageEditingController.clear();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reactions
  // ─────────────────────────────────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Share location / contact (bug report #23)
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _sendContent(NewMessageContentEntity content) async {
    final me = state.currentUser;
    final side = state.otherConnectionSide;
    if (me == null || side == null) {
      return false;
    }
    try {
      final result = await chatRepository.sendNewMessage(
        currentUser: me,
        otherConnectionSide: side,
        messageContent: content,
      );
      final bool ok = result is! Left;
      return ok;
    } catch (e) {
      return false;
    }
  }

  /// Schedule Message dialog (Figma 6799:16821) and scheduled polls.
  Future<bool> scheduleMessage({
    String? text,
    String? attachmentPath,
    PollPayload? poll,
    required DateTime sendAt,
  }) async {
    final me = state.currentUser;
    final side = state.otherConnectionSide;
    final key = chatSettingsKey;
    if (me == null || side == null || key.isEmpty) return false;
    final bool isGroup = side is GroupEntity;
    final String targetId = side is GroupEntity
        ? side.groupId
        : side is SingleConnectionEntity
            ? side.userId
            : side.otherSideId;
    final String targetName = side is GroupEntity
        ? side.primaryLanguageName
        : side is SingleConnectionEntity
            ? side.name
            : side.primaryLanguageName;
    return ScheduledMessagesService.schedule(
      senderId: me.userId,
      chatKey: key,
      isGroup: isGroup,
      targetId: targetId,
      targetName: targetName,
      sendAt: sendAt,
      text: text,
      attachmentPath: attachmentPath,
      poll: poll,
    );
  }

  void reactToMessage({
    required int messageIndex,
    required Reacts react,
  }) {
    final messages = List<MessageEntity>.from(state.messages);

    if (messageIndex < 0 || messageIndex >= messages.length) {
      return;
    }

    final message = messages[messageIndex];

    // §10 — reacts field is final; rebuild the list and reassign via copyWith.
    //
    // Bug report #24: ONE reaction per user. Changing it replaces the old
    // one instead of adding a second; the same one again removes it. The
    // server does the same (ReactWriter) and its snapshot then confirms
    // this optimistic view.
    final newReacts = List<Reacts>.from(message.reacts);
    final Reacts? previous = _myReacts[message.messageId];
    if (previous != null) newReacts.remove(previous);
    if (previous == react) {
      _myReacts.remove(message.messageId);
    } else {
      newReacts.add(react);
      _myReacts[message.messageId] = react;
    }
    messages[messageIndex] = message.copyWith(reacts: newReacts);

    emitState(state.copyWith(messages: messages));

    final chatId = _resolveChatId();
    final currentUserId = state.currentUser?.userId ?? '';

    if (chatId.isNotEmpty && currentUserId.isNotEmpty) {
      chatRepository
          .addReact(
            chatId: chatId,
            messageId: message.messageId,
            currentUserId: currentUserId,
            react: react,
          )
          .then(
            (result) => result.fold(
              (f) {},
              (_) {},
            ),
          );
    } else {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Chat-level Pin (from appbar menu)
  // ─────────────────────────────────────────────────────────────────────────

  void toggleChatPin() {
    if (state.chatPinnedMessage != null) {
      emitState(state.copyWith(chatPinnedMessage: () => null));
    } else {
      final pinnedMessages = state.messages.where((m) => m.isPinned).toList();

      if (pinnedMessages.isEmpty) {
        if (state.messages.isNotEmpty) {
          final lastMsg = state.messages.last;
          emitState(state.copyWith(chatPinnedMessage: () => lastMsg));
        }
        return;
      }

      final latestPinned = pinnedMessages.last;
      emitState(state.copyWith(chatPinnedMessage: () => latestPinned));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Star / Unstar a message
  // ─────────────────────────────────────────────────────────────────────────

  void toggleStarMessage({required int messageIndex}) {
    final messages = List<MessageEntity>.from(state.messages);

    if (messageIndex < 0 || messageIndex >= messages.length) {
      return;
    }

    final message = messages[messageIndex];
    final newStarred = !message.isStarred;

    messages[messageIndex] = message.copyWith(isStarred: newStarred);
    emitState(state.copyWith(messages: messages));
  }
}
