/// Module: knowledge_hub/kh3_view_knowledge_details/presentation/controller
/// ************************* FILE INFO *************************** ///
/// File Name: comments_cubit.dart
/// Description: Comments, attachments and view / download records of one
///              knowledge document.
/// Author: Amr Mesbah
/// Created at: 12/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_people.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/kh_firestore_keys.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/notifications/knowledge_hub_notification_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/domain/base_repository/comments_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/presentation/controller/comments_states.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit(this._repository, this.people) : super(CommentsInitial());

  final CommentsBaseRepository _repository;

  /// Signed-in employee + employee / department lookups (injected).
  final KhPeople people;

  List<CreateNewCommentModel> _commentsList = [];
  Map<String, dynamic>? _attachmentData;
  final Map<String, EmployeeData> _usersCache = {};

  List<CreateNewCommentModel> get commentsList => _commentsList;
  Map<String, dynamic>? get attachmentData => _attachmentData;
  Map<String, EmployeeData> get usersCache => _usersCache;

  @override
  void emit(CommentsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> fetchComments(String knowledgeId, {bool silent = false}) async {
    if (!silent) emit(CommentsLoading());
    try {
      _commentsList = await _repository.fetchCommentsByKnowledgeId(knowledgeId);
      await _cacheUsers(_commentsList.map((c) => c.currentCreatedById));
      emit(CommentsLoadedSuccess(_commentsList));
      _watchedKnowledgeId = knowledgeId;
      _live.watchPaths([getBaseUrl(FirebaseCollections.knowledgeComments)], () {
        final String? id = _watchedKnowledgeId;
        if (id != null) fetchComments(id, silent: true);
      });
    } catch (e) {
      // KH-CREATE-24: the technical error is logged; the UI shows a
      // translated message with Retry.
      khLog('Loading comments failed: $e', name: 'CommentsCubit');
      if (!silent) emit(CommentsLoadedFailure(e.toString()));
    }
  }

  final LiveRefresh _live = LiveRefresh();
  String? _watchedKnowledgeId;

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  /// Loads the people behind [userIds] that are not cached yet.
  Future<void> _cacheUsers(Iterable<String> userIds) async {
    final List<String> missing = userIds
        .where((id) => id.isNotEmpty && !_usersCache.containsKey(id))
        .toSet()
        .toList();
    if (missing.isEmpty) return;
    try {
      _usersCache.addAll(await _repository.fetchMultipleUserData(missing));
    } catch (e) {
      khLog('Loading comment authors failed: $e', name: 'CommentsCubit');
    }
  }

  Future<void> uploadAttachment(File file) async {
    emit(UploadAttachmentLoading());
    try {
      final Map<String, dynamic>? data =
          await _repository.uploadCommentAttachment(file);
      if (data == null) {
        emit(UploadAttachmentFailure(''));
        return;
      }
      _attachmentData = data;
      emit(UploadAttachmentSuccess(data));
    } catch (e) {
      khLog('Uploading attachment failed: $e', name: 'CommentsCubit');
      emit(UploadAttachmentFailure(e.toString()));
    }
  }

  void clearAttachment() => _attachmentData = null;

  /// Saves a comment (with the uploaded attachment, if any) and tells the
  /// document's owner a new inquiry arrived.
  Future<void> createComment({
    required String knowledgeId,
    required String commentText,
    required String createdById,
    required String createdByEmail,
  }) async {
    emit(CreateCommentLoading());
    try {
      final Map<String, dynamic>? attachment = _attachmentData;
      final bool success = await _repository.createComment(
        knowledgeId: knowledgeId,
        commentText: commentText,
        createdById: createdById,
        createdByEmail: createdByEmail,
        attachmentExtension: attachment?[KhAttachmentKeys.extension],
        attachmentSize: attachment?[KhAttachmentKeys.size],
        attachmentUrl: attachment?[KhAttachmentKeys.url],
        attachmentName: attachment?[KhAttachmentKeys.name],
      );
      if (!success) {
        emit(CreateCommentFailure(''));
        return;
      }
      _attachmentData = null;
      emit(
        CreateCommentSuccess(
          CreateNewCommentModel.createNew(
            commentId: DateTime.now().millisecondsSinceEpoch.toString(),
            commentText: commentText,
            createdById: createdById,
            createdByEmail: createdByEmail,
            attachmentExtension: attachment?[KhAttachmentKeys.extension],
            attachmentSize: attachment?[KhAttachmentKeys.size],
            attachmentUrl: attachment?[KhAttachmentKeys.url],
            attachmentName: attachment?[KhAttachmentKeys.name],
          ),
        ),
      );
      unawaited(
        _notifyDocumentOwnerOfInquiry(
          knowledgeId: knowledgeId,
          commenterEmail: createdByEmail,
        ),
      );
      await fetchComments(knowledgeId);
    } catch (e) {
      khLog('Saving comment failed: $e', name: 'CommentsCubit');
      emit(CreateCommentFailure(e.toString()));
    }
  }

  /// The author of a knowledge document is the first entry of its
  /// created-by history. Never throws: the comment is already saved.
  Future<void> _notifyDocumentOwnerOfInquiry({
    required String knowledgeId,
    required String commenterEmail,
  }) async {
    try {
      final CreateKnowledgeModel? document =
          await _repository.fetchKnowledgeByKnowledgeId(knowledgeId);
      if (document == null) return;
      final String ownerEmail = document.currentCreatedByEmail;
      if (ownerEmail.isEmpty) return;
      await KnowledgeHubNotificationService.notifyOwnerOfInquiry(
        documentId: knowledgeId,
        commenterEmail: commenterEmail,
        ownerEmail: ownerEmail,
        documentNameEn: document.currentNameEnglish,
        documentNameAr: document.currentNameArabic,
        isArabic: KhLocale.isArabicNow,
      );
    } catch (e) {
      khLog('Inquiry notification failed: $e', name: 'CommentsCubit');
    }
  }

  Future<void> deleteComment(String commentId, String knowledgeId) async {
    try {
      final bool success = await _repository.deleteComment(commentId);
      if (!success) {
        emit(DeleteCommentFailure(''));
        return;
      }
      emit(DeleteCommentSuccess());
      await fetchComments(knowledgeId);
    } catch (e) {
      emit(DeleteCommentFailure(e.toString()));
    }
  }

  /// Records a 'view' or 'download' of the document by [employeeId].
  Future<void> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String employeeId,
  }) async {
    emit(RecordFileActionLoading());
    try {
      final bool success = await _repository.recordFileAction(
        knowledgeId: knowledgeId,
        typeOfAction: typeOfAction,
        employeeId: employeeId,
      );
      emit(
        success
            ? RecordFileActionSuccess(typeOfAction)
            : RecordFileActionFailure(typeOfAction),
      );
    } catch (e) {
      emit(RecordFileActionFailure(e.toString()));
    }
  }
}
