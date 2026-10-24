import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String criteriaNumber;
  final String evidenceNumber;
  final String? commentText;
  final String? commentLink;
  final String commenterId;
  final Timestamp commentDate;
  final String? fileName;
  final String? fileSize; // Placeholder for file name

  CommentModel({
    required this.commentId,
    required this.criteriaNumber,
    required this.evidenceNumber,
    this.commentText,
    this.commentLink,
    this.fileName,
    this.fileSize,
    required this.commenterId,
    required this.commentDate,
  });

  static const String commentIdField = 'Comment_Id';
  static const String criteriaNumberField = 'Criteria_Number';
  static const String evidenceNumberField = 'Evidence_Number';
  static const String commentTextField = 'Comment_Text';
  static const String commentLinkField = 'Comment_Link';
  static const String commenterIdField = 'Commenter_Id';
  static const String commentDateField = 'Comment_Date';
  static const String fileNameField = 'File_Name';
  static const String fileSizeField = 'File_Size';

  Map<String, dynamic> toMap() {
    return {
      commentIdField: commentId,
      criteriaNumberField: criteriaNumber,
      evidenceNumberField: evidenceNumber,
      commentTextField: commentText,
      commentLinkField: commentLink,
      commenterIdField: commenterId,
      commentDateField: commentDate,
      fileNameField: fileName,
      fileSizeField: fileSize,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map[commentIdField] ?? '',
      criteriaNumber: map[criteriaNumberField] ?? '',
      evidenceNumber: map[evidenceNumberField] ?? '',
      commentText: map[commentTextField],
      commentLink: map[commentLinkField],
      commenterId: map[commenterIdField] ?? '',
      commentDate: map[commentDateField] as Timestamp,
      fileName: map[fileNameField],
      fileSize: map[fileSizeField], // Assuming file size is stored as a string
    );
  }
}

class CommentHistoryModel {
  final String commentId;
  final List<int> timestamps;
  final List<String> criteriaNumber;
  final List<String> evidenceNumber;
  final List<String> commentText;
  final List<String> commentLink;
  final List<String> commenterId;
  final List<Timestamp> commentDate;
  final List<String> fileName;
  final List<String> fileSize;

  CommentHistoryModel({
    required this.commentId,
    required this.timestamps,
    required this.criteriaNumber,
    required this.evidenceNumber,
    required this.commentText,
    required this.commentLink,
    required this.commenterId,
    required this.commentDate,
    required this.fileName,
    required this.fileSize,
  });

  // Constants for database keys
  static const String kCommentIdKey = 'Comment_Id';
  static const String kTimestampsKey = 'timestamps';
  static const String kCriteriaNumberKey = 'Criteria_Number';
  static const String kEvidenceNumberKey = 'Evidence_Number';
  static const String kCommentTextKey = 'Comment_Text';
  static const String kCommentLinkKey = 'Comment_Link';
  static const String kCommenterIdKey = 'Commenter_Id';
  static const String kCommentDateKey = 'Comment_Date';
  static const String kFileNameKey = 'File_Name';
  static const String kFileSizeKey = 'File_Size';

  // Helper getters for current (latest) values
  String get currentCriteriaNumber =>
      criteriaNumber.isNotEmpty ? criteriaNumber.last : '';
  String get currentEvidenceNumber =>
      evidenceNumber.isNotEmpty ? evidenceNumber.last : '';
  String? get currentCommentText =>
      commentText.isNotEmpty && commentText.last.isNotEmpty
          ? commentText.last
          : null;
  String? get currentCommentLink =>
      commentLink.isNotEmpty && commentLink.last.isNotEmpty
          ? commentLink.last
          : null;
  String get currentCommenterId =>
      commenterId.isNotEmpty ? commenterId.last : '';
  Timestamp get currentCommentDate =>
      commentDate.isNotEmpty ? commentDate.last : Timestamp.now();
  String? get currentFileName =>
      fileName.isNotEmpty && fileName.last.isNotEmpty ? fileName.last : null;
  String? get currentFileSize =>
      fileSize.isNotEmpty && fileSize.last.isNotEmpty ? fileSize.last : null;
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  // Convert to legacy CommentModel
  CommentModel toLegacyModel() {
    return CommentModel(
      commentId: commentId,
      criteriaNumber: currentCriteriaNumber,
      evidenceNumber: currentEvidenceNumber,
      commentText: currentCommentText,
      commentLink: currentCommentLink,
      commenterId: currentCommenterId,
      commentDate: currentCommentDate,
      fileName: currentFileName,
      fileSize: currentFileSize,
    );
  }

  // Parse from Firestore map
  factory CommentHistoryModel.fromMap(Map<String, dynamic> map) {
    try {
      debugPrint("\n=== CommentHistoryModel.fromMap DEBUG ===");
      debugPrint("Available keys: ${map.keys.toList()}");

      final List<int> sharedTimestamps = (map[kTimestampsKey] as List<dynamic>?)
              ?.map((e) => e is int ? e : (e as num).toInt())
              .toList() ??
          [DateTime.now().millisecondsSinceEpoch];

      debugPrint("Timestamps count: ${sharedTimestamps.length}");
      debugPrint("=====================================\n");

      return CommentHistoryModel(
        commentId: map[kCommentIdKey] ?? map['_documentId'] ?? '',
        timestamps: sharedTimestamps,
        criteriaNumber: _parseListSafely(map[kCriteriaNumberKey]),
        evidenceNumber: _parseListSafely(map[kEvidenceNumberKey]),
        commentText: _parseListSafely(map[kCommentTextKey]),
        commentLink: _parseListSafely(map[kCommentLinkKey]),
        commenterId: _parseListSafely(map[kCommenterIdKey]),
        commentDate: _parseTimestampList(map[kCommentDateKey]),
        fileName: _parseListSafely(map[kFileNameKey]),
        fileSize: _parseListSafely(map[kFileSizeKey]),
      );
    } catch (e, stack) {
      debugPrint("❌ ERROR parsing CommentHistoryModel: $e");
      debugPrint("Stacktrace:\n$stack");
      rethrow;
    }
  }

  // Helper method to parse lists safely
  static List<String> _parseListSafely(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e?.toString() ?? '').toList();
    return [value.toString()];
  }

  // Helper method to parse Timestamp lists
  static List<Timestamp> _parseTimestampList(dynamic value) {
    if (value == null) return [Timestamp.now()];
    if (value is List) {
      return value.map((e) {
        if (e is Timestamp) return e;
        if (e is int) return Timestamp.fromMillisecondsSinceEpoch(e);
        if (e is Map && e.containsKey('_seconds')) {
          return Timestamp(e['_seconds'], e['_nanoseconds'] ?? 0);
        }
        return Timestamp.now();
      }).toList();
    }
    if (value is Timestamp) return [value];
    if (value is int) return [Timestamp.fromMillisecondsSinceEpoch(value)];
    return [Timestamp.now()];
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      kCommentIdKey: commentId,
      kTimestampsKey: timestamps,
      kCriteriaNumberKey: criteriaNumber,
      kEvidenceNumberKey: evidenceNumber,
      kCommentTextKey: commentText,
      kCommentLinkKey: commentLink,
      kCommenterIdKey: commenterId,
      kCommentDateKey:
          commentDate.map((t) => t.millisecondsSinceEpoch).toList(),
      kFileNameKey: fileName,
      kFileSizeKey: fileSize,
    };
  }

  String toJson() => json.encode(toMap());

  factory CommentHistoryModel.fromJson(String source) =>
      CommentHistoryModel.fromMap(json.decode(source));

  // CopyWith method that synchronizes ALL fields
  CommentHistoryModel copyWith({
    String? criteriaNumber,
    String? evidenceNumber,
    String? commentText,
    String? commentLink,
    String? commenterId,
    Timestamp? commentDate,
    String? fileName,
    String? fileSize,
  }) {
    debugPrint("\n=== CommentHistoryModel.copyWith DEBUG ===");

    // Add new timestamp for this update
    final newTimestamps = List<int>.from(timestamps)
      ..add(DateTime.now().millisecondsSinceEpoch);

    debugPrint(
        "Creating synchronized update at index ${newTimestamps.length - 1}");
    debugPrint("Edited fields:");
    if (criteriaNumber != null) {
      debugPrint("  - criteriaNumber: '$criteriaNumber'");
    }
    if (evidenceNumber != null) {
      debugPrint("  - evidenceNumber: '$evidenceNumber'");
    }
    if (commentText != null) debugPrint("  - commentText");
    if (commentLink != null) debugPrint("  - commentLink");
    if (commenterId != null) debugPrint("  - commenterId: '$commenterId'");
    if (commentDate != null) debugPrint("  - commentDate");
    if (fileName != null) debugPrint("  - fileName: '$fileName'");
    if (fileSize != null) debugPrint("  - fileSize: '$fileSize'");

    // ALL fields get updated - edited values OR current values repeated
    final result = CommentHistoryModel(
      commentId: commentId,
      timestamps: newTimestamps,
      criteriaNumber: List<String>.from(this.criteriaNumber)
        ..add(criteriaNumber ?? currentCriteriaNumber),
      evidenceNumber: List<String>.from(this.evidenceNumber)
        ..add(evidenceNumber ?? currentEvidenceNumber),
      commentText: List<String>.from(this.commentText)
        ..add(commentText ?? (currentCommentText ?? '')),
      commentLink: List<String>.from(this.commentLink)
        ..add(commentLink ?? (currentCommentLink ?? '')),
      commenterId: List<String>.from(this.commenterId)
        ..add(commenterId ?? currentCommenterId),
      commentDate: List<Timestamp>.from(this.commentDate)
        ..add(commentDate ?? currentCommentDate),
      fileName: List<String>.from(this.fileName)
        ..add(fileName ?? (currentFileName ?? '')),
      fileSize: List<String>.from(this.fileSize)
        ..add(fileSize ?? (currentFileSize ?? '')),
    );

    debugPrint(
        "✓ All arrays now have ${result.timestamps.length} entries (synchronized)");
    debugPrint("  - criteriaNumber length: ${result.criteriaNumber.length}");
    debugPrint("  - evidenceNumber length: ${result.evidenceNumber.length}");
    debugPrint("  - commentText length: ${result.commentText.length}");
    debugPrint("  - commentLink length: ${result.commentLink.length}");
    debugPrint("  - commenterId length: ${result.commenterId.length}");
    debugPrint("  - commentDate length: ${result.commentDate.length}");
    debugPrint("  - fileName length: ${result.fileName.length}");
    debugPrint("  - fileSize length: ${result.fileSize.length}");
    debugPrint("=====================================\n");

    return result;
  }

  // Factory constructor for creating new comments
  factory CommentHistoryModel.createNew({
    required String commentId,
    required String criteriaNumber,
    required String evidenceNumber,
    required String commenterId,
    String? commentText,
    String? commentLink,
    Timestamp? commentDate,
    String? fileName,
    String? fileSize,
  }) {
    return CommentHistoryModel(
      commentId: commentId,
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      criteriaNumber: [criteriaNumber],
      evidenceNumber: [evidenceNumber],
      commentText: [commentText ?? ''],
      commentLink: [commentLink ?? ''],
      commenterId: [commenterId],
      commentDate: [commentDate ?? Timestamp.now()],
      fileName: [fileName ?? ''],
      fileSize: [fileSize ?? ''],
    );
  }

  // Generate next comment ID
  static Future<String> generateNextCommentId({
    required String criteriaNumber,
    required String evidenceNumber,
  }) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(getBaseUrl('Comments'))
          .where(kCriteriaNumberKey, isEqualTo: criteriaNumber)
          .where(kEvidenceNumberKey, isEqualTo: evidenceNumber)
          .orderBy(kCommentIdKey, descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return "${criteriaNumber}_${evidenceNumber}_C001";
      }

      String lastId =
          snapshot.docs.first.get(kCommentIdKey) ?? snapshot.docs.first.id;
      // Extract the comment number from the last ID (e.g., "CR001_EV001_C005" -> "005")
      List<String> parts = lastId.split('_');
      String numericPart = parts.last.replaceAll(RegExp(r'[^0-9]'), '');
      int nextNumber = int.parse(numericPart.isEmpty ? '0' : numericPart) + 1;
      return "${criteriaNumber}_${evidenceNumber}_C${nextNumber.toString().padLeft(3, '0')}";
    } catch (e) {
      debugPrint('Error generating comment ID: $e');
      return "${criteriaNumber}_${evidenceNumber}_C${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  // Get history at a specific index
  CommentSnapshot? getSnapshotAt(int index) {
    if (index < 0 || index >= timestamps.length) return null;

    return CommentSnapshot(
      timestamp: timestamps[index],
      criteriaNumber:
          index < criteriaNumber.length ? criteriaNumber[index] : '',
      evidenceNumber:
          index < evidenceNumber.length ? evidenceNumber[index] : '',
      commentText: index < commentText.length && commentText[index].isNotEmpty
          ? commentText[index]
          : null,
      commentLink: index < commentLink.length && commentLink[index].isNotEmpty
          ? commentLink[index]
          : null,
      commenterId: index < commenterId.length ? commenterId[index] : '',
      commentDate:
          index < commentDate.length ? commentDate[index] : Timestamp.now(),
      fileName: index < fileName.length && fileName[index].isNotEmpty
          ? fileName[index]
          : null,
      fileSize: index < fileSize.length && fileSize[index].isNotEmpty
          ? fileSize[index]
          : null,
    );
  }

  // Get all history snapshots
  List<CommentSnapshot> getAllSnapshots() {
    return List.generate(timestamps.length, (index) => getSnapshotAt(index)!);
  }

  // Check if comment has been edited
  bool get hasBeenEdited => timestamps.length > 1;

  // Get number of edits
  int get editCount => timestamps.length - 1;

  // Get time of last edit
  DateTime? get lastEditTime {
    if (timestamps.length <= 1) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamps.last);
  }

  // Get time of original creation
  DateTime get creationTime {
    return DateTime.fromMillisecondsSinceEpoch(timestamps.first);
  }
}

// Helper class for representing a snapshot in time
class CommentSnapshot {
  final int timestamp;
  final String criteriaNumber;
  final String evidenceNumber;
  final String? commentText;
  final String? commentLink;
  final String commenterId;
  final Timestamp commentDate;
  final String? fileName;
  final String? fileSize;

  CommentSnapshot({
    required this.timestamp,
    required this.criteriaNumber,
    required this.evidenceNumber,
    this.commentText,
    this.commentLink,
    required this.commenterId,
    required this.commentDate,
    this.fileName,
    this.fileSize,
  });

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'dateTime': dateTime.toIso8601String(),
      'criteriaNumber': criteriaNumber,
      'evidenceNumber': evidenceNumber,
      'commentText': commentText,
      'commentLink': commentLink,
      'commenterId': commenterId,
      'commentDate': commentDate.toDate().toIso8601String(),
      'fileName': fileName,
      'fileSize': fileSize,
    };
  }

  // Check if comment has attachments
  bool get hasAttachment => fileName != null && fileName!.isNotEmpty;

  // Check if comment has link
  bool get hasLink => commentLink != null && commentLink!.isNotEmpty;

  // Check if comment has text
  bool get hasText => commentText != null && commentText!.isNotEmpty;
}
