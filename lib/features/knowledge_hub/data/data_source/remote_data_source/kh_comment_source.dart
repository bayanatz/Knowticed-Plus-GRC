/// Module: knowledge_hub / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: kh_comment_source.dart
/// Purpose: Declares `KhCommentSource` — a knowledge document's thread, as
///          the shared comments box (`UniversalCommentSection`) reads it.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// Moataz 22/10/2026 ("fix the knowledge"): the shared box filtered the hub's
/// comments by `Request_Id` only, so comments written before KH-SUBMIT-02
/// (11/10/2026), which carry only `knowledgeId`, never showed. This source
/// reads with the service's own query — `knowledgeId` OR `Request_Id` — and
/// its two-format reader, so every comment shows on every hub screen.
/// New comments go through `createComment`, which writes both field sets.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/custom/inputs/custom_comment_widget.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/create_comment_firebase_service.dart';

class KhCommentSource extends CommentSource {
  KhCommentSource({required this.knowledgeId});

  final String knowledgeId;
  final CommentsFirebaseServices _service = CommentsFirebaseServices();

  @override
  String get identity => 'knowledge_hub|$knowledgeId';

  @override
  Stream<List<CommentEntry>> watch() =>
      _service.commentsQuery(knowledgeId).snapshots().map((snapshot) {
        final List<CommentEntry> list = <CommentEntry>[];
        for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
            in snapshot.docs) {
          final Map<String, dynamic> data = doc.data();
          final CreateNewCommentModel c =
              CommentsFirebaseServices.commentFromAnyFormat(data, doc.id);
          String first(List<String> v) => v.isEmpty ? '' : v.first;
          final String fileUrl = first(c.attachmentUrl);
          final String fileName = first(c.attachmentName);
          final int? millis = int.tryParse(first(c.timestamps));
          final String text = first(c.commentText);
          list.add(CommentEntry(
            id: doc.id,
            text: text.isEmpty ? null : text,
            commenterEmail: first(c.createdByEmail),
            date: millis == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(millis),
            fileUrl: fileUrl.isEmpty ? null : fileUrl,
            fileName: fileUrl.isEmpty
                ? null
                : (fileName.isEmpty ? fileUrl.split('/').last : fileName),
            isEdited: data['Is_Edited'] == true,
            handle: doc.reference,
          ));
        }
        list.sort(
            (a, b) => (a.date ?? DateTime(0)).compareTo(b.date ?? DateTime(0)));
        return list;
      });

  @override
  Future<void> add({
    required String currentUserId,
    String? text,
    String? fileUrl,
    String? fileName,
    String? fileSize,
  }) async {
    final bool ok = await _service.createComment(
      knowledgeId: knowledgeId,
      commentText: text ?? '',
      createdById: currentUserId,
      createdByEmail: currentUserId,
      attachmentUrl: fileUrl,
      attachmentName: fileName,
    );
    if (!ok) throw Exception('Failed to add comment');
  }

  DocumentReference<Map<String, dynamic>> _ref(CommentEntry c) =>
      c.handle! as DocumentReference<Map<String, dynamic>>;

  @override
  Future<void> edit(CommentEntry comment, String text) =>
      _ref(comment).update(<String, dynamic>{
        'Comment_Text': text,
        'Is_Edited': true,
      });

  @override
  Future<bool> delete(CommentEntry comment) async {
    try {
      await _ref(comment).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> replaceFile(
    CommentEntry comment, {
    required String url,
    required String name,
    required String size,
  }) =>
      _ref(comment).update(<String, dynamic>{
        'Comment_Link': url,
        'File_Name': name,
        'attachmentUrl': <String>[url],
        'attachmentName': <String>[name],
      });
}
