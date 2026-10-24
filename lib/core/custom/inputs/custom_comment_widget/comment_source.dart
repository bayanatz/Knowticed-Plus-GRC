/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: comment_source.dart
/// Description: `CommentEntry` + `CommentSource` — where the shared
///          Inquiries And Comments box reads and writes its comments.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// 22/10/2026 (Moataz): "Settings → Requests, Inquiries And Comments is the
/// perfect model — apply it everywhere." Every module now shows the SAME box
/// (`UniversalCommentSection`); only the data behind it differs. A module
/// that keeps its comments somewhere else (Time Tracker's sub-collection,
/// Inventory's chat, …) hands the box a [CommentSource]; the default is
/// [FirestoreCommentSource], the flat collection the box always used.

part of '../custom_comment_widget.dart';

/// One comment as the box shows it, whichever module stores it.
class CommentEntry {
  const CommentEntry({
    required this.id,
    this.text,
    this.commenterEmail,
    this.date,
    this.fileUrl,
    this.fileName,
    this.isEdited = false,
    this.canModify,
    this.handle,
    this.name,
    this.subtitle,
    this.photo,
  });

  final String id;
  final String? text;

  /// The commenter's email — name, photo and department are looked up by it.
  final String? commenterEmail;
  final DateTime? date;
  final String? fileUrl;
  final String? fileName;
  final bool isEdited;

  /// Whether Edit / Delete are offered. null = "it is mine" (commenter is
  /// the current user); a source sets false for read-only comments.
  final bool? canModify;

  /// The source's own object for this comment (a document reference, an id).
  final Object? handle;

  /// Author details the source already holds (Database stores them on each
  /// comment, keyed by employee id rather than email). Null = looked up by
  /// [commenterEmail].
  final String? name;
  final String? subtitle;
  final String? photo;
}

/// Where the box's comments come from and go to.
abstract class CommentSource {
  const CommentSource();

  /// Same identity = same thread: the box keeps its stream across rebuilds
  /// and re-subscribes only when this changes.
  String get identity;

  /// The thread, oldest first.
  Stream<List<CommentEntry>> watch();

  /// False hides the "Write A Comment" row (no permission to write).
  bool get canWrite => true;

  /// False hides the attachment button.
  bool get supportsFiles => true;

  /// False hides Edit in a comment's menu (Delete stays).
  bool get supportsEdit => true;

  /// [fileUrl] is already uploaded by the box.
  Future<void> add({
    required String currentUserId,
    String? text,
    String? fileUrl,
    String? fileName,
    String? fileSize,
  });

  Future<void> edit(CommentEntry comment, String text);

  /// True = deleted (the box's confirm dialog closes on it).
  Future<bool> delete(CommentEntry comment);

  Future<void> replaceFile(
    CommentEntry comment, {
    required String url,
    required String name,
    required String size,
  }) async {}
}

/// The box's own store: one flat collection, filtered by [filterFields]
/// (Settings → Requests, GRC, Knowledge Hub approvals, Services, …).
class FirestoreCommentSource extends CommentSource {
  const FirestoreCommentSource({
    required this.collectionPath,
    required this.filterFields,
    this.customAddComment,
    this.onCommentAdded,
  });

  final String collectionPath;
  final Map<String, dynamic> filterFields;
  final Future<void> Function({
    required String currentUserId,
    String? commentText,
    String? mediaPath,
  })? customAddComment;
  final Function(Map<String, dynamic> commentData)? onCommentAdded;

  @override
  String get identity => '$collectionPath|$filterFields';

  @override
  Stream<List<CommentEntry>> watch() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection(collectionPath);
    filterFields.forEach((field, value) {
      query = query.where(field, isEqualTo: value);
    });
    return query.snapshots().map((snapshot) {
      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final aDate = a.data()['Comment_Date'] as Timestamp?;
          final bDate = b.data()['Comment_Date'] as Timestamp?;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return aDate.compareTo(bDate);
        });
      return docs.map((doc) {
        final data = doc.data();
        return CommentEntry(
          id: doc.id,
          text: data['Comment_Text'] as String?,
          commenterEmail: data['Commenter_Id'] as String?,
          date: (data['Comment_Date'] as Timestamp?)?.toDate(),
          fileUrl: data['Comment_Link'] as String?,
          fileName: data['File_Name'] as String?,
          isEdited: data['Is_Edited'] == true,
          handle: doc.reference,
        );
      }).toList();
    });
  }

  @override
  Future<void> add({
    required String currentUserId,
    String? text,
    String? fileUrl,
    String? fileName,
    String? fileSize,
  }) async {
    if (customAddComment != null) {
      await customAddComment!(
        currentUserId: currentUserId,
        commentText: text,
        mediaPath: fileUrl,
      );
      return;
    }
    final commentData = {
      ...filterFields,
      'Comment_Id': '${currentUserId}_${DateTime.now().millisecondsSinceEpoch}',
      'Comment_Text': text,
      'Commenter_Id': currentUserId,
      'Comment_Date': Timestamp.now(),
      'Comment_Link': fileUrl,
      'File_Name': fileName,
      'File_Size': fileSize,
    };
    await FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(commentData['Comment_Id'] as String)
        .set(commentData);
    onCommentAdded?.call(commentData);
  }

  DocumentReference<Map<String, dynamic>> _ref(CommentEntry c) =>
      c.handle as DocumentReference<Map<String, dynamic>>;

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
      _ref(comment).update({
        'Comment_Link': url,
        'File_Name': name,
        'File_Size': size,
      });
}
