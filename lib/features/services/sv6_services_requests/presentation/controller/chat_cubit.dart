/// Module: services / sv6_services_requests / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: chat_cubit.dart
/// Purpose: Cubit for the comment thread of one service request: load, send
///          text, send an attachment, edit and delete. Firestore and Storage
///          go through the injected ChatRepository, picking through the
///          injected MediaPickerService.
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/core/app_services/media_picker_service.dart';
import 'package:knowticed_plus/features/services/data/repository/chat_repository_impl.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/chat_repository.dart';
import 'package:knowticed_plus/features/services/sv6_services_requests/presentation/controller/chat_state.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

class ChatCubit extends Cubit<ChatState> {
  final LiveRefresh _live = LiveRefresh();

  // Guards every emit against the cubit being closed mid-await.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final ChatRepository repository;
  final MediaPickerService mediaPicker;
  final String modelId;

  /// Signed-in user's e-mail, lower-cased; used to decide who may edit or
  /// delete a message.
  final String currentUserEmail;

  /// [repository] and [mediaPicker] are created once at the module root and
  /// passed in by the widget.
  ChatCubit({
    required this.modelId,
    required this.repository,
    required this.mediaPicker,
    required String currentUserEmail,
  })  : currentUserEmail = currentUserEmail.trim().toLowerCase(),
        super(const ChatInitial());

  void _log(String action, Object error) {
    if (kDebugMode) svcLog('ChatCubit $action failed: $error');
  }

  /// Function Name: [loadComments]
  ///
  /// Purpose: Loads the thread of [modelId] and emits [ChatLoaded], or
  /// [ChatError] with [ChatErrorType.load].
  Future<void> loadComments({bool silent = false}) async {
    if (!silent) emit(const ChatLoading());
    try {
      final messages = await repository.loadComments(modelId);
      final current = state;
      emit(
        silent && current is ChatLoaded
            ? current.copyWith(messages: messages)
            : ChatLoaded(messages: messages),
      );
      // Live refresh: new messages show without leaving the thread.
      _live.watchPaths([
        '${getBaseUrl(FirestoreCollections.requestServicesRoot)}/$modelId/comments',
      ], () => loadComments(silent: true));
    } catch (e) {
      _log('load', e);
      if (!silent) emit(const ChatError(ChatErrorType.load));
    }
  }

  /// Only the author of a message may edit or delete it.
  bool canModify(ChatMessageData message) =>
      message.senderEmail.isNotEmpty && message.senderEmail == currentUserEmail;

  Future<Map<String, String>> _currentSenderInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString('firstNameRequester') ?? '';
    final lastName = prefs.getString('lastNameRequester') ?? '';
    final jobTitle = prefs.getString('jobTitleRequester') ?? '';
    return {'fullName': '$firstName $lastName'.trim(), 'jobTitle': jobTitle};
  }

  /// Function Name: [sendTextMessage]
  ///
  /// Purpose: Sends [text] as a comment and reloads the thread.
  ///
  /// Parameters:
  /// - [text]: the message; ignored when blank.
  Future<void> sendTextMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    try {
      final sender = await _currentSenderInfo();
      final now = DateTime.now();

      await repository.sendComment(
        modelId: modelId,
        senderName: sender['fullName']!,
        senderTitle: sender['jobTitle']!,
        text: trimmed,
        timestamp: now,
        senderEmail: currentUserEmail,
      );

      await loadComments();
    } catch (e) {
      _log('send', e);
      emit(const ChatError(ChatErrorType.send));
      emit(current);
    }
  }

  /// Function Name: [sendImageMessage]
  ///
  /// Purpose: Picks an image (camera or gallery), uploads it and sends it.
  ///
  /// Parameters:
  /// - [fromCamera]: take a photo instead of choosing one.
  Future<void> sendImageMessage({required bool fromCamera}) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    emit(current.copyWith(isBusy: true));

    try {
      final picked = await mediaPicker.pickImage(fromCamera: fromCamera);
      if (picked == null || picked.path == null) {
        emit(current.copyWith(isBusy: false));
        return;
      }
      await _uploadAndSend(filePath: picked.path!, fileName: picked.name);
    } catch (e) {
      _log('image upload', e);
      emit(const ChatError(ChatErrorType.upload));
      emit(current.copyWith(isBusy: false));
    }
  }

  /// Function Name: [sendDocumentMessage]
  ///
  /// Purpose: Picks a document, uploads it and sends it.
  Future<void> sendDocumentMessage() async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    emit(current.copyWith(isBusy: true));

    try {
      final picked = await mediaPicker.pickDocument();
      if (picked == null || picked.path == null) {
        emit(current.copyWith(isBusy: false));
        return;
      }
      await _uploadAndSend(filePath: picked.path!, fileName: picked.name);
    } catch (e) {
      _log('document upload', e);
      emit(const ChatError(ChatErrorType.upload));
      emit(current.copyWith(isBusy: false));
    }
  }

  Future<void> _uploadAndSend({
    required String filePath,
    required String fileName,
  }) async {
    final sender = await _currentSenderInfo();
    final downloadUrl = await repository.uploadAttachment(
      fileName: fileName,
      filePath: filePath,
    );

    final now = DateTime.now();
    await repository.sendAttachmentComment(
      modelId: modelId,
      senderName: sender['fullName']!,
      senderTitle: sender['jobTitle']!,
      text: fileName,
      imagePath: downloadUrl,
      timestamp: now,
      senderEmail: currentUserEmail,
    );

    await loadComments();
  }

  /// Function Name: [editMessage]
  ///
  /// Purpose: Replaces the text of one of the user's own messages.
  ///
  /// Parameters:
  /// - [docId]: the message id.
  /// - [newText]: the new text; ignored when blank.
  Future<void> editMessage({
    required String docId,
    required String newText,
  }) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;
    final trimmed = newText.trim();
    if (trimmed.isEmpty) return;
    if (!_ownsMessage(current, docId)) {
      emit(const ChatError(ChatErrorType.notAuthor));
      emit(current);
      return;
    }

    try {
      await repository.editComment(
        modelId: modelId,
        docId: docId,
        newText: trimmed,
        actorEmail: currentUserEmail,
      );
      await loadComments();
    } catch (e) {
      _log('edit', e);
      emit(const ChatError(ChatErrorType.edit));
      emit(current);
    }
  }

  /// Function Name: [deleteMessage]
  ///
  /// Purpose: Deletes one of the user's own messages.
  ///
  /// Parameters:
  /// - [docId]: the message id.
  ///
  /// Returns: whether the message was deleted.
  Future<bool> deleteMessage(String docId) async {
    if (state is! ChatLoaded) return false;
    final current = state as ChatLoaded;
    if (!_ownsMessage(current, docId)) {
      emit(const ChatError(ChatErrorType.notAuthor));
      emit(current);
      return false;
    }

    try {
      await repository.deleteComment(
        modelId: modelId,
        docId: docId,
        actorEmail: currentUserEmail,
      );
      await loadComments();
      return true;
    } catch (e) {
      _log('delete', e);
      emit(const ChatError(ChatErrorType.delete));
      emit(current);
      return false;
    }
  }

  bool _ownsMessage(ChatLoaded current, String docId) {
    for (final m in current.messages) {
      if (m.docId == docId) return canModify(m);
    }
    return false;
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
