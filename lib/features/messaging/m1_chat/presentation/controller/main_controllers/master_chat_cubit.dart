/// Module: messaging/m1_chat
///
///*************************** FILE INFO ****************************///
/// File Name: master_chat_cubit.dart
/// Description: `MasterChatState` state, `MasterChatCubit` cubit (state management).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

/// Module: messaging / chat / presentation/controller/main_controllers/master_chat_cubit.dart
// Date: 6/8/2024
// Last update: 28/4/2026
// Purpose: Abstract base cubit for all chat types, with AES-256 message encryption.

import 'dart:async';
import 'package:dartz/dartz.dart' show Left;

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/core/helper/extensions.dart';
import 'package:grc_module/features/messaging/helpers/messaging_bridge/main_helper/incrption.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/edit_and_delete_message_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/forward_message_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/overlay_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/pin_message_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/functions_on_messages_controllers/reply_message_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/helper_controllers/chat_scroll_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/message_types_controllers/document_message_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/message_types_controllers/image_message_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/message_types_controllers/record_and_audio_cubit.dart';
import 'package:grc_module/features/messaging/m1_chat/presentation/controller/message_types_controllers/text_message_cubit.dart';

import 'package:grc_module/features/messaging/helpers/services/audio_record_service.dart';
import 'package:grc_module/features/messaging/helpers/enums/message_types.dart';
import 'package:grc_module/features/messaging/helpers/messaging_bridge/interface/entity/base_messaging_interface_parameters.dart';
import 'package:grc_module/features/messaging/m2_connections/domain/entities/single_connection_entity.dart';
import 'package:grc_module/features/messaging/m3_groups/domain/entities/group_entity.dart';
import 'package:grc_module/features/messaging/m4_messaging_home/domain/entities/chat_type_entity.dart';
import 'package:grc_module/features/messaging/m1_chat/domain/entity/message_entity.dart';
import 'package:grc_module/features/messaging/m1_chat/domain/entity/new_message_content_entity.dart';
import 'package:grc_module/features/messaging/m1_chat/domain/enum/media_type.dart';
import 'package:grc_module/features/messaging/m1_chat/domain/repository/chat_repository/base_chat_repository.dart';
import 'package:grc_module/features/messaging/m1_chat/domain/enum/reacts.dart';
import 'package:grc_module/features/messaging/helpers/messaging_bridge/main_helper/message_action_types.dart';
import 'package:grc_module/features/messaging/helpers/main/chat_settings_service.dart';
import 'package:grc_module/features/messaging/helpers/main/scheduled_messages_service.dart';

part 'master_chat_cubit/master_chat_cubit_methods.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class MasterChatState {
  final ChatTypeEntity? otherConnectionSide;
  final bool isShowMedia;
  final bool isShowContactInfo; // ✅ NEW
  final bool isExpansionTabletChat;
  final Map<MediaType, Map<String, List<MessageEntity>>> mediaMessages;
  final List<MessageEntity> messages;
  final bool selectMessages;
  final MessageActionTypes messageActionType;
  final MessageEntity? selectedMessage;
  final MessageTypes newMessageType;
  final int? firstUnreadIndex;
  final int swiperIndex;
  final BaseMessagingInterfaceParameters? currentUser;
  final bool isSending;

  // ✅ Multi-file support
  final List<String> selectedMediaPaths;
  final List<String> selectedDocPaths;

  // ✅ Chat-level pinned message (from appbar menu "Pin")
  final MessageEntity? chatPinnedMessage;

  MasterChatState({
    this.otherConnectionSide,
    this.isShowMedia = false,
    this.isShowContactInfo = false, // ✅ NEW
    this.isExpansionTabletChat = false,
    this.mediaMessages = const {},
    this.messages = const [],
    this.selectMessages = false,
    this.messageActionType = MessageActionTypes.newMessage,
    this.selectedMessage,
    this.newMessageType = MessageTypes.text,
    this.firstUnreadIndex,
    this.swiperIndex = 0,
    this.currentUser,
    this.isSending = false,
    this.selectedMediaPaths = const [],
    this.selectedDocPaths = const [],
    this.chatPinnedMessage,
  });

  /// ✅ Helper: true when any file (image/video/doc) is queued for preview
  bool get hasSelectedFiles =>
      selectedMediaPaths.isNotEmpty || selectedDocPaths.isNotEmpty;

  MasterChatState copyWith({
    ChatTypeEntity? otherConnectionSide,
    bool? isShowMedia,
    bool? isShowContactInfo, // ✅ NEW
    bool? isExpansionTabletChat,
    Map<MediaType, Map<String, List<MessageEntity>>>? mediaMessages,
    List<MessageEntity>? messages,
    bool? selectMessages,
    MessageActionTypes? messageActionType,
    MessageEntity? Function()? selectedMessage,
    MessageTypes? newMessageType,
    int? Function()? firstUnreadIndex,
    int? swiperIndex,
    BaseMessagingInterfaceParameters? currentUser,
    bool? isSending,
    List<String>? selectedMediaPaths,
    List<String>? selectedDocPaths,
    MessageEntity? Function()? chatPinnedMessage,
  }) {
    return MasterChatState(
      otherConnectionSide: otherConnectionSide ?? this.otherConnectionSide,
      isShowMedia: isShowMedia ?? this.isShowMedia,
      isShowContactInfo: isShowContactInfo ?? this.isShowContactInfo, // ✅ NEW
      isExpansionTabletChat:
          isExpansionTabletChat ?? this.isExpansionTabletChat,
      mediaMessages: mediaMessages ?? this.mediaMessages,
      messages: messages ?? this.messages,
      selectMessages: selectMessages ?? this.selectMessages,
      messageActionType: messageActionType ?? this.messageActionType,
      selectedMessage:
          selectedMessage != null ? selectedMessage() : this.selectedMessage,
      newMessageType: newMessageType ?? this.newMessageType,
      firstUnreadIndex:
          firstUnreadIndex != null ? firstUnreadIndex() : this.firstUnreadIndex,
      swiperIndex: swiperIndex ?? this.swiperIndex,
      currentUser: currentUser ?? this.currentUser,
      isSending: isSending ?? this.isSending,
      selectedMediaPaths: selectedMediaPaths ?? this.selectedMediaPaths,
      selectedDocPaths: selectedDocPaths ?? this.selectedDocPaths,
      chatPinnedMessage: chatPinnedMessage != null
          ? chatPinnedMessage()
          : this.chatPinnedMessage,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Abstract Base Cubit
// ─────────────────────────────────────────────────────────────────────────────

abstract class MasterChatCubit extends Cubit<MasterChatState> {
  /// Public [emit] for this cubit's extension / part files and widgets
  /// ([emit] itself is protected).
  void emitState(MasterChatState state) => emit(state);

  final BaseChatRepository chatRepository;

  // ── Encryption ────────────────────────────────────────────────────────────
  final _encryptionService = MessageEncryptionService();

  // ── Controllers ───────────────────────────────────────────────────────────
  final messageFocusNode = FocusNode();
  final TextEditingController textMessageEditingController =
      TextEditingController();
  final SwiperController swiperController = SwiperController();
  List<TextEditingController> captionControllers = [];

  StreamSubscription<dynamic>? chatMessagesSubscription;

  late ChatScrollCubit chatScrollCubit;
  late PinMessageCubit pinnedMessageCubit;
  late OverlayCubit overlayCubit;
  late ForwardMessageCubit forwardMessageCubit;
  late ReplyMessageCubit replyMessageCubit;
  late ImageMessageCubit imageMessageCubit;
  late EditAndDeleteMessageCubit editAndDeleteMessageCubit;
  late TextMessageCubit textMessageCubit;
  late DocumentMessageCubit documentMessageCubit;
  late RecordAndAudioCubit recordAndAudioCubit;

  MasterChatCubit({
    required this.chatRepository,
    MasterChatState? initialState,
  }) : super(initialState ?? MasterChatState()) {
    chatScrollCubit = ChatScrollCubit(masterChatCubit: this);
    pinnedMessageCubit = PinMessageCubit(masterChatCubit: this);
    overlayCubit = OverlayCubit();
    forwardMessageCubit = ForwardMessageCubit();
    _initialize();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    messageFocusNode.dispose();
    textMessageEditingController.dispose();
    for (final controller in captionControllers) {
      controller.dispose();
    }
    cancelChatMessagesSubscription();
    resetResources();
    return super.close();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Encryption helpers  ✅
  // ─────────────────────────────────────────────────────────────────────────

  String _resolveChatId() {
    final side = state.otherConnectionSide;
    if (side == null) return '';
    if (side is SingleConnectionEntity) return side.connectionId;
    if (side is GroupEntity) return side.groupId;
    return side.otherSideId;
  }

  String encryptMessage(String plainText) {
    if (plainText.isEmpty) return plainText;
    final chatId = _resolveChatId();
    if (chatId.isEmpty) return plainText;
    return _encryptionService.encrypt(plainText, chatId: chatId);
  }

  String decryptMessage(String encryptedContent) {
    if (encryptedContent.isEmpty) return encryptedContent;
    final chatId = _resolveChatId();
    if (chatId.isEmpty) return encryptedContent;
    // Error handling lives in the cubit (C1), so the UI never wraps decrypt in
    // try/catch (§11.2). On failure we fall back to the raw content.
    try {
      return _encryptionService.decrypt(encryptedContent, chatId: chatId);
    } catch (_) {
      return encryptedContent;
    }
  }

  List<MessageEntity> decryptMessagesList(List<MessageEntity> messages) {
    final decrypted = messages.map((msg) {
      if (msg.messageType != MessageTypes.text) return msg;
      if (msg.messageContent == null || msg.messageContent!.isEmpty) return msg;
      return msg.copyWith(
        messageContent: () => decryptMessage(msg.messageContent!),
      );
    }).toList();
    // Every message list reaching the UI passes through here, so this is
    // where Disappearing Messages (bug report #19) hides expired messages.
    return applyDisappearing(decrypted);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Chat settings: Pin / Mute / Disappearing (bug report #19–#22)
  // ─────────────────────────────────────────────────────────────────────────

  /// Key of the open chat in ChatSettingsService ('' when no chat is open).
  String get chatSettingsKey {
    final side = state.otherConnectionSide;
    final me = state.currentUser?.userId ?? '';
    if (side is GroupEntity) return ChatSettingsService.groupKey(side.groupId);
    if (side is SingleConnectionEntity && me.isNotEmpty) {
      return ChatSettingsService.directKey(me, side.userId);
    }
    return '';
  }

  /// When Disappearing Messages started for the open chat, or null when off.
  /// A group created with the switch on counts from its creation time.
  DateTime? get _disappearingSince {
    final key = chatSettingsKey;
    if (key.isEmpty) return null;
    final settings = ChatSettingsService.cached(key);
    if (settings.hasDisappearingSetting) {
      return settings.disappearingSince?.toDate();
    }
    final side = state.otherConnectionSide;
    if (side is GroupEntity && side.isDisappearingMessages) {
      return side.createdAt.toDate();
    }
    return null;
  }

  bool get isDisappearingOn => _disappearingSince != null;

  /// When the open chat was opened (see "Always" in [applyDisappearing]).
  DateTime _chatOpenedAt = DateTime.now();

  /// Timer of the open chat: 24 / 168 / 2160 hours, or 0 = "Always"
  /// (a message disappears once seen). Groups created with the switch on
  /// and no stored choice use 24 hours.
  int get _disappearingHours {
    final key = chatSettingsKey;
    if (key.isEmpty) return 24;
    return ChatSettingsService.cached(key).effectiveDisappearingHours;
  }

  /// Option picked in the Disappearing Messages dialog, or null when off.
  int? get disappearingHoursOption =>
      isDisappearingOn ? _disappearingHours : null;

  /// Whether the current user muted the open chat (timed mutes included).
  bool get isChatMuted {
    final key = chatSettingsKey;
    return key.isNotEmpty && ChatSettingsService.isMuted(key);
  }

  /// Loads the open chat's settings, then re-applies them to what is on
  /// screen. Call right after a chat is started.
  Future<void> loadChatSettings() async {
    _chatOpenedAt = DateTime.now();
    final key = chatSettingsKey;
    if (key.isEmpty) return;
    final me = state.currentUser?.userId;
    if (me != null) ChatSettingsService.watch(me);
    await ChatSettingsService.load(key);
    if (isClosed || key != chatSettingsKey) return;
    emit(state.copyWith(messages: applyDisappearing(state.messages)));
  }

  /// Pin / unpin the open chat (pin icon on its card). Returns new state.
  Future<bool> togglePinChat() async {
    final key = chatSettingsKey;
    final me = state.currentUser?.userId;
    if (key.isEmpty || me == null) return false;
    final pinned = await ChatSettingsService.togglePinned(key, me);
    emit(state.copyWith());
    return pinned;
  }

  /// Mute / unmute notifications from the open chat. Returns new state.
  Future<bool> toggleMuteChat() async {
    final key = chatSettingsKey;
    final me = state.currentUser?.userId;
    if (key.isEmpty || me == null) return false;
    final muted = await ChatSettingsService.toggleMuted(key, me);
    emit(state.copyWith());
    return muted;
  }

  /// Mute Notifications dialog (Figma 6799:16763): mutes the open chat for
  /// [duration] (8 hours / 1 week) or until unmuted when null ("Always").
  Future<bool> muteChatFor(Duration? duration) async {
    final key = chatSettingsKey;
    final me = state.currentUser?.userId;
    if (key.isEmpty || me == null) return false;
    final ok = await ChatSettingsService.muteFor(key, me, duration);
    if (!isClosed) emit(state.copyWith());
    return ok;
  }

  Future<bool> unmuteChat() async {
    final key = chatSettingsKey;
    final me = state.currentUser?.userId;
    if (key.isEmpty || me == null) return false;
    final ok = await ChatSettingsService.unmute(key, me);
    if (!isClosed) emit(state.copyWith());
    return ok;
  }

  /// Disappearing Messages dialog (Figma 6799:16789): [hours] is 24, 168,
  /// 2160 or 0 ("Always"); null turns it off. Returns true on success.
  Future<bool> setDisappearingOption(int? hours) async {
    final key = chatSettingsKey;
    if (key.isEmpty) return false;
    final bool enable = hours != null;
    final bool result = await ChatSettingsService.setDisappearing(key, enable,
        hours: hours ?? 24);
    if (result != enable) return false; // write failed
    // A different timer may hide or bring back messages — re-read them.
    await getChatMessages();
    return true;
  }

  /// Turn Disappearing Messages on / off for the open chat. Returns new state.
  Future<bool> toggleDisappearingChat() async {
    final key = chatSettingsKey;
    if (key.isEmpty) return false;
    final enabled =
        await ChatSettingsService.setDisappearing(key, !isDisappearingOn);
    if (enabled) {
      emit(state.copyWith(messages: applyDisappearing(state.messages)));
    } else {
      // Re-subscribe so the messages that were hidden come back.
      await getChatMessages();
    }
    return enabled;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Caption controllers
  // ─────────────────────────────────────────────────────────────────────────

  void generateCaptionsFormFields(int count) {
    for (final controller in captionControllers) {
      controller.dispose();
    }
    captionControllers = List.generate(count, (_) => TextEditingController());
  }

  void updateSwiperIndex(int index) {
    emit(state.copyWith(swiperIndex: index));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Multi-file selection helpers
  // ─────────────────────────────────────────────────────────────────────────

  void addSelectedMediaPaths(List<String> paths) {
    final updated = List<String>.from(state.selectedMediaPaths)..addAll(paths);
    emit(state.copyWith(selectedMediaPaths: updated));
  }

  void removeSelectedMedia(int index) {
    final updated = List<String>.from(state.selectedMediaPaths)
      ..removeAt(index);
    emit(state.copyWith(selectedMediaPaths: updated));
  }

  void addSelectedDocPaths(List<String> paths) {
    final updated = List<String>.from(state.selectedDocPaths)..addAll(paths);
    emit(state.copyWith(selectedDocPaths: updated));
  }

  void removeSelectedDoc(int index) {
    final updated = List<String>.from(state.selectedDocPaths)..removeAt(index);
    emit(state.copyWith(selectedDocPaths: updated));
  }

  void clearAllSelectedFiles() {
    emit(state.copyWith(
      selectedMediaPaths: [],
      selectedDocPaths: [],
    ));
  }

  void clearSelectedImage() {
    clearAllSelectedFiles();
  }

  void setSelectedImagePath(String path) {
    addSelectedMediaPaths([path]);
  }

  // ─────────────────────────────────────────────────────────────────────────

  void setSending(bool value) {
    emit(state.copyWith(isSending: value));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Abstract methods — implemented by subclasses
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> getChatMessages();

  Future<void> startChat({
    required ChatTypeEntity otherSideData,
    required BaseMessagingInterfaceParameters currentUserData,
  }) async {
    emit(state.copyWith(
      otherConnectionSide: otherSideData,
      currentUser: currentUserData,
    ));
  }

  Future<void> updateUnSeenMessages();

  Future<void> clearNumOfUnReadMessages({
    required String currentUserId,
    required String otherUserId,
  });

  Future<void> sendNewMessage({String? repliedMessageId});

  // ─────────────────────────────────────────────────────────────────────────
  // Subscription
  // ─────────────────────────────────────────────────────────────────────────

  void cancelChatMessagesSubscription() {
    chatMessagesSubscription?.cancel();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Resources
  // ─────────────────────────────────────────────────────────────────────────

  void resetResources() {
    chatScrollCubit.resetResources();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Message selection
  // ─────────────────────────────────────────────────────────────────────────

  void toggleSelectMessages(bool value) {
    emit(state.copyWith(selectMessages: value));
  }

  Future<bool> sendLocationMessage(LocationPayload location) =>
      _sendContent(LocationMessageContentEntity(location: location));

  Future<bool> sendContactMessage(ContactPayload contact) =>
      _sendContent(ContactMessageContentEntity(contact: contact));

  /// Poll dialog (Figma 6799:5666) → Send.
  Future<bool> sendPollMessage(PollPayload poll) =>
      _sendContent(PollMessageContentEntity(poll: poll));

  /// Next pending scheduled send in the open chat (yellow appbar banner).
  Stream<DateTime?> nextScheduledMessage() {
    final key = chatSettingsKey;
    final me = state.currentUser?.userId;
    if (key.isEmpty || me == null) return Stream<DateTime?>.value(null);
    return ScheduledMessagesService.nextFor(key, me);
  }

  /// This session's own reaction per message id (see [reactToMessage]).
  final Map<String, Reacts> _myReacts = <String, Reacts>{};

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Contact Info panel toggle (side panel like Media/Links/Docs)
  // ─────────────────────────────────────────────────────────────────────────

  void toggleContactInfoState() {
    // Close media panel if open, then toggle contact info
    if (state.isShowMedia) {
      emit(state.copyWith(isShowMedia: false));
    }
    emit(state.copyWith(isShowContactInfo: !state.isShowContactInfo));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI helpers
  // ─────────────────────────────────────────────────────────────────────────

  void setCurrentMessage(String message) {
    emit(state.copyWith());
  }

  void toggleMediaState() {
    // Close contact info panel if open, then toggle media
    if (state.isShowContactInfo) {
      emit(state.copyWith(isShowContactInfo: false));
    }
    emit(state.copyWith(isShowMedia: !state.isShowMedia));
  }

  void toggleExpansion() {
    emit(state.copyWith(isExpansionTabletChat: !state.isExpansionTabletChat));
  }

  void updateMessages(List<MessageEntity> messages) {
    final decrypted = decryptMessagesList(messages);
    emit(state.copyWith(messages: decrypted));

    // ✅ Update hasPinnedMessage on the connection/group entity
    final otherSide = state.otherConnectionSide;
    if (otherSide is SingleConnectionEntity) {
      otherSide.hasPinnedMessage = decrypted.any((m) => m.isPinned);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Unread index
  // ─────────────────────────────────────────────────────────────────────────

  void getFirstUnreadIndex() {
    final firstUnread =
        state.messages.indexWhere((element) => element.isSeen == false);

    if (firstUnread == -1) {
      emit(state.copyWith(firstUnreadIndex: () => null));
      return;
    }

    emit(state.copyWith(firstUnreadIndex: () => firstUnread));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Media filtering
  // ─────────────────────────────────────────────────────────────────────────

  void filterMessagesMedia() {
    final mediaMessages = <MediaType, Map<String, List<MessageEntity>>>{};
    mediaMessages[MediaType.media] = handleFilterMediaMessages();
    mediaMessages[MediaType.links] = handleFilterLinksMessages();
    mediaMessages[MediaType.documents] = handleFilterDocumentMessages();
    emit(state.copyWith(mediaMessages: mediaMessages));
  }

  Map<String, List<MessageEntity>> handleFilterMediaMessages() {
    final list = state.messages
        .where((m) =>
            m.messageType == MessageTypes.galleryImage ||
            m.messageType == MessageTypes.cameraImage ||
            m.messageType == MessageTypes.video)
        .toList();
    return filterMessagesListByMonth(list);
  }

  Map<String, List<MessageEntity>> handleFilterLinksMessages() {
    final list = state.messages
        .where((m) =>
            m.messageType == MessageTypes.text &&
            (m.messageContent?.isLink() ?? false))
        .toList();
    return filterMessagesListByMonth(list);
  }

  Map<String, List<MessageEntity>> handleFilterDocumentMessages() {
    final list =
        state.messages.where((m) => m.messageType == MessageTypes.doc).toList();
    return filterMessagesListByMonth(list);
  }

  Map<String, List<MessageEntity>> filterMessagesListByMonth(
      List<MessageEntity> messages) {
    final messagesByMonth = <String, List<MessageEntity>>{};
    for (final message in messages) {
      final sendTime = message.time.toDate();
      final isCurrentMonth =
          sendTime.isAfter(DateTime(DateTime.now().year, DateTime.now().month));
      final monthKey =
          isCurrentMonth ? 'Last Month' : '${sendTime.month}/${sendTime.year}';

      messagesByMonth.putIfAbsent(monthKey, () => []).add(message);
    }
    return messagesByMonth;
  }
}
