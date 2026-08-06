/// Module: messaging / chat / presentation/controller/main_controllers/master_chat_cubit.dart
// Date: 6/8/2024
// Last update: 28/4/2026
// Purpose: Abstract base cubit for all chat types, with AES-256 message encryption.

import 'dart:async';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/core/helper/main_helper/extensions.dart';
import 'package:grc_module/core/helper/message_module/main_helper/incrption.dart';
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

import 'package:grc_module/core/services/message_module/audio_record_service.dart';
import 'package:grc_module/core/enums/message_module/message_types.dart';
import '../../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../m2_connections/domain/entities/single_connection_entity.dart';
import '../../../../m3_groups/domain/entities/group_entity.dart';
import '../../../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../../../domain/entity/message_entity.dart';
import '../../../domain/enum/media_type.dart';
import '../../../domain/repository/chat_repository/base_chat_repository.dart';
import '../../../domain/enum/reacts.dart';
import '../../../../../../core/helper/message_module/main_helper/message_action_types.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class MasterChatState {
  final ChatTypeEntity? otherConnectionSide;
  final bool isShowMedia;
  final bool isShowContactInfo;  // ✅ NEW
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
    this.isShowContactInfo = false,  // ✅ NEW
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
    bool? isShowContactInfo,  // ✅ NEW
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
      isShowContactInfo: isShowContactInfo ?? this.isShowContactInfo,  // ✅ NEW
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
  // Async initialization
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initialize() async {
    try {
      await AudioRecordService.initializeController();
    } catch (e) {
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
    }
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
    return messages.map((msg) {
      if (msg.messageType != MessageTypes.text) return msg;
      if (msg.messageContent == null || msg.messageContent!.isEmpty) return msg;
      return msg.copyWith(
        messageContent: () => decryptMessage(msg.messageContent!),
      );
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Caption controllers
  // ─────────────────────────────────────────────────────────────────────────

  void generateCaptionsFormFields(int count) {
    for (final controller in captionControllers) {
      controller.dispose();
    }
    captionControllers =
        List.generate(count, (_) => TextEditingController());
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
    final updated = List<String>.from(state.selectedMediaPaths)..removeAt(index);
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

  void selectMessageToMakeAction({
    required MessageEntity? message,
    required MessageActionTypes actionType,
    required MessageTypes? newMessageType,
    required BuildContext context,
  }) {
    emit(state.copyWith(
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
        setSending(true);
        try {
          if (hasMedia) {
            await imageMessageCubit.sendMultipleMedia(state.selectedMediaPaths);
          }
          if (hasDocs) {
            await documentMessageCubit
                .sendMultipleDocumentsFromPaths(state.selectedDocPaths);
          }
        } catch (e) {
        } finally {
          setSending(false);
          clearAllSelectedFiles();
        }
      } else {
        await sendNewMessage();
      }
    }

    if (state.messageActionType == MessageActionTypes.editMessage) {
      await editAndDeleteMessageCubit.submitEditMessage(context);
    }

    if (state.messageActionType == MessageActionTypes.deleteMessage) {
      await editAndDeleteMessageCubit.deleteMessage();
    }

    if (state.messageActionType == MessageActionTypes.replyMessage) {
      await replyMessageCubit.submitMessageReply(context);
    }

    emit(state.copyWith(
      messageActionType: MessageActionTypes.newMessage,
      newMessageType: MessageTypes.text,
    ));
    textMessageEditingController.clear();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reactions
  // ─────────────────────────────────────────────────────────────────────────

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
    final existingIndex = message.reacts.indexOf(react);
    final newReacts = List<Reacts>.from(message.reacts);
    if (existingIndex != -1) {
      newReacts.removeAt(existingIndex);
    } else {
      newReacts.add(react);
    }
    messages[messageIndex] = message.copyWith(reacts: newReacts);

    emit(state.copyWith(messages: messages));

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
    } else {
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Chat-level Pin (from appbar menu)
  // ─────────────────────────────────────────────────────────────────────────

  void toggleChatPin() {
    if (state.chatPinnedMessage != null) {
      emit(state.copyWith(chatPinnedMessage: () => null));
    } else {
      final pinnedMessages =
      state.messages.where((m) => m.isPinned).toList();

      if (pinnedMessages.isEmpty) {
        if (state.messages.isNotEmpty) {
          final lastMsg = state.messages.last;
          emit(state.copyWith(chatPinnedMessage: () => lastMsg));
        }
        return;
      }

      final latestPinned = pinnedMessages.last;
      emit(state.copyWith(chatPinnedMessage: () => latestPinned));
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
    emit(state.copyWith(messages: messages));
  }

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
    final list = state.messages
        .where((m) => m.messageType == MessageTypes.doc)
        .toList();
    return filterMessagesListByMonth(list);
  }

  Map<String, List<MessageEntity>> filterMessagesListByMonth(
      List<MessageEntity> messages) {
    final messagesByMonth = <String, List<MessageEntity>>{};
    for (final message in messages) {
      final sendTime = message.time.toDate();
      final isCurrentMonth = sendTime
          .isAfter(DateTime(DateTime.now().year, DateTime.now().month));
      final monthKey = isCurrentMonth
          ? 'Last Month'
          : '${sendTime.month}/${sendTime.year}';

      messagesByMonth.putIfAbsent(monthKey, () => []).add(message);
    }
    return messagesByMonth;
  }
}