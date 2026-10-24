/// Module: services / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: chat_repository_impl.dart
/// Purpose: Data-layer repository implementation for service-request comment
///          threads (load / send / edit / delete comments + upload
///          attachments). Implements the ChatRepository contract from
///          domain/base_repository/chat_repository.dart.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: cloud_firestore, firebase_storage, core/network/get_base_url.dart,
///               core/network/api_constants.dart, domain/base_repository/chat_repository.dart
/// Revision History: Renamed from ChatRepository -> ChatRepositoryImpl and made
///                    to implement the new ChatRepository interface, matching
///                    the GetServiceRepositoryImpl / CreateServicesRepository
///                    pattern used elsewhere in this module (was previously a
///                    bare class with no base_repository interface).
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/chat_repository.dart'
    as base;

import 'package:knowticed_plus/features/services/helpers/constants/services_firestore_paths.dart';

/// Plain data holder for a single comment, kept in the data layer so the
/// UI layer never depends on Firestore types directly.
class ChatMessageData {
  final String senderName;
  final String senderTitle;
  final String? text;
  final String? imagePath;
  final DateTime timestamp;
  final String docId;

  /// Lower-cased e-mail of the author (SVC-REQ-02). Empty on messages sent
  /// before 18/10/2026 — those can no longer be edited or deleted.
  final String senderEmail;

  ChatMessageData({
    required this.senderName,
    required this.senderTitle,
    required this.text,
    required this.imagePath,
    required this.timestamp,
    required this.docId,
    this.senderEmail = '',
  });
}

class ChatRepositoryImpl implements base.ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ChatRepositoryImpl({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : firestore = firestore ?? FirebaseFirestore.instance,
        storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _comments(String modelId) {
    return firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(modelId)
        .collection(ServicesFirestorePaths.requestComments);
  }

  @override
  Future<List<ChatMessageData>> loadComments(String modelId) async {
    final querySnapshot = await _comments(modelId).orderBy('timestamp').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return ChatMessageData(
        senderName: data['senderName'] ?? '',
        senderTitle: data['senderTitle'] ?? '',
        text: data['text'],
        imagePath: data['imagePath'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        docId: doc.id,
        senderEmail: (data['senderEmail'] ?? '').toString().toLowerCase(),
      );
    }).toList();
  }

  @override
  Future<void> sendComment({
    required String modelId,
    required String senderName,
    required String senderTitle,
    required String text,
    required DateTime timestamp,
    String senderEmail = '',
  }) async {
    await _comments(modelId).add({
      'senderName': senderName,
      'senderTitle': senderTitle,
      'senderEmail': senderEmail.trim().toLowerCase(),
      'text': text,
      'timestamp': timestamp,
    });
  }

  @override
  Future<void> editComment({
    required String modelId,
    required String docId,
    required String newText,
    required String actorEmail,
  }) async {
    final ref = _comments(modelId).doc(docId);
    await _assertAuthor(ref, actorEmail);
    await ref.update({'text': newText});
  }

  @override
  Future<void> deleteComment({
    required String modelId,
    required String docId,
    required String actorEmail,
  }) async {
    final ref = _comments(modelId).doc(docId);
    await _assertAuthor(ref, actorEmail);
    await ref.delete();
  }

  /// SVC-REQ-02: only the author may edit or delete a message. (Firestore
  /// security rules must enforce the same check server-side.)
  Future<void> _assertAuthor(
    DocumentReference<Map<String, dynamic>> ref,
    String actorEmail,
  ) async {
    final snap = await ref.get();
    final author = (snap.data()?['senderEmail'] ?? '').toString().toLowerCase();
    final actor = actorEmail.trim().toLowerCase();
    if (!snap.exists || author.isEmpty || author != actor) {
      throw StateError('Only the author can change this message');
    }
  }

  /// Uploads a local file to storage and returns its download URL.
  @override
  Future<String> uploadAttachment({
    required String fileName,
    required String filePath,
  }) async {
    final ref = storage.ref(
      '${getBaseUrl(FirestoreCollections.commentsAttachmentsStorage)}/${DateTime.now().millisecondsSinceEpoch}_$fileName',
    );
    await ref.putFile(File(filePath));
    return ref.getDownloadURL();
  }

  @override
  Future<void> sendAttachmentComment({
    required String modelId,
    required String senderName,
    required String senderTitle,
    required String text,
    required String imagePath,
    required DateTime timestamp,
    String senderEmail = '',
  }) async {
    await _comments(modelId).add({
      'senderName': senderName,
      'senderTitle': senderTitle,
      'senderEmail': senderEmail.trim().toLowerCase(),
      'text': text,
      'imagePath': imagePath,
      'timestamp': timestamp,
    });
  }
}
