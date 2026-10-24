import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/qiyas/qy3_common/users_tasks/domain/enums/evidence_submission_status.dart';

class EvidenceSubmissionModel {
  Timestamp? submissionDate;
  Timestamp? approvedDate;
  String? submittedBy;
  String? approvedBy;
  EvidenceSubmissionStatus submissionStatus;
  String submissionId;
  String evidenceNumber;
  String criteriaNumber;
  String filePath;
  String fileName;
  String fileSize;
  String? rejectionReason;
  String? submissionNote;
  String? managerId;
  Timestamp? managerResponseTime;

  EvidenceSubmissionModel(
      {required this.submissionDate,
      required this.submissionStatus,
      required this.submissionId,
      required this.evidenceNumber,
      required this.criteriaNumber,
      required this.submittedBy,
      this.approvedBy,
      this.approvedDate,
      this.filePath = '',
      this.fileName = '',
      this.fileSize = '',
      this.managerId = '',
      this.managerResponseTime,
      this.rejectionReason,
      this.submissionNote});

  static const String submissionDateKey = "Submission_Date";
  static const String submissionStatusKey = "Submission_Status";
  static const String submissionIdKey = "Submission_Id";
  static const String evidenceNumberKey = "Evidence_Number";
  static const String criteriaNumberKey = "Criteria_Number";
  static const String submittedByKey = "Submitted_By";
  static const String approvedByKey = "Approved_By";
  static const String approvedDateKey = "Approved_Date";
  static const String filePathKey = "File_Path";
  static const String fileNameKey = "File_Name";
  static const String fileSizeKey = "File_Size";
  static const String rejectionReasonKey = "Rejection_Reason";
  static const String submissionNoteKey = "Submission_Note";
  static const String managerIdKey = "Manager_Id";
  static const String managerResponseTimeKey = "Manager_Response_Time";

  Map<String, dynamic> toMap() {
    return {
      submissionDateKey: submissionDate,
      submissionStatusKey: submissionStatus.name,
      submissionIdKey: submissionId,
      evidenceNumberKey: evidenceNumber,
      criteriaNumberKey: criteriaNumber,
      submittedByKey: submittedBy,
      approvedByKey: approvedBy,
      approvedDateKey: approvedDate,
      filePathKey: filePath,
      fileNameKey: fileName,
      fileSizeKey: fileSize,
      rejectionReasonKey: rejectionReason,
      submissionNoteKey: submissionNote,
      managerIdKey: managerId,
      managerResponseTimeKey: managerResponseTime,
    };
  }

  factory EvidenceSubmissionModel.fromMap(Map<String, dynamic> map) {
    return EvidenceSubmissionModel(
      submissionDate: map[submissionDateKey],
      submissionStatus: EvidenceSubmissionStatus.values.firstWhere(
          (e) => e.name == map[submissionStatusKey],
          orElse: () => EvidenceSubmissionStatus.pending),
      submissionId: map[submissionIdKey],
      evidenceNumber: map[evidenceNumberKey],
      criteriaNumber: map[criteriaNumberKey],
      submittedBy: map[submittedByKey],
      approvedBy: map[approvedByKey],
      approvedDate: map[approvedDateKey],
      filePath: map[filePathKey] ?? '',
      fileName: map[fileNameKey] ?? '',
      fileSize: map[fileSizeKey] ?? '',
      rejectionReason: map[rejectionReasonKey],
      submissionNote: map[submissionNoteKey],
      managerId: map[managerIdKey],
      managerResponseTime: map[managerResponseTimeKey],
    );
  }
}

class EvidenceSubmissionHistoryModel {
  final String submissionId;
  final List<int> timestamps;
  final List<Timestamp> submissionDate;
  final List<Timestamp> approvedDate;
  final List<String> submittedBy;
  final List<String> approvedBy;
  final List<String> submissionStatus;
  final List<String> evidenceNumber;
  final List<String> criteriaNumber;
  final List<String> filePath;
  final List<String> fileName;
  final List<String> fileSize;
  final List<String> rejectionReason;
  final List<String> submissionNote;
  final List<String> managerId;
  final List<Timestamp> managerResponseTime;

  EvidenceSubmissionHistoryModel({
    required this.submissionId,
    required this.timestamps,
    required this.submissionDate,
    required this.approvedDate,
    required this.submittedBy,
    required this.approvedBy,
    required this.submissionStatus,
    required this.evidenceNumber,
    required this.criteriaNumber,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.rejectionReason,
    required this.submissionNote,
    required this.managerId,
    required this.managerResponseTime,
  });

  // Constants for database keys
  static const String kSubmissionIdKey = 'Submission_Id';
  static const String kTimestampsKey = 'timestamps';
  static const String kSubmissionDateKey = 'Submission_Date';
  static const String kApprovedDateKey = 'Approved_Date';
  static const String kSubmittedByKey = 'Submitted_By';
  static const String kApprovedByKey = 'Approved_By';
  static const String kSubmissionStatusKey = 'Submission_Status';
  static const String kEvidenceNumberKey = 'Evidence_Number';
  static const String kCriteriaNumberKey = 'Criteria_Number';
  static const String kFilePathKey = 'File_Path';
  static const String kFileNameKey = 'File_Name';
  static const String kFileSizeKey = 'File_Size';
  static const String kRejectionReasonKey = 'Rejection_Reason';
  static const String kSubmissionNoteKey = 'Submission_Note';
  static const String kManagerIdKey = 'Manager_Id';
  static const String kManagerResponseTimeKey = 'Manager_Response_Time';

  // Helper getters for current (latest) values
  Timestamp get currentSubmissionDate =>
      submissionDate.isNotEmpty ? submissionDate.last : Timestamp.now();
  Timestamp? get currentApprovedDate =>
      approvedDate.isNotEmpty && approvedDate.last.seconds != 0
          ? approvedDate.last
          : null;
  String get currentSubmittedBy =>
      submittedBy.isNotEmpty ? submittedBy.last : '';
  String? get currentApprovedBy =>
      approvedBy.isNotEmpty && approvedBy.last.isNotEmpty
          ? approvedBy.last
          : null;
  EvidenceSubmissionStatus get currentSubmissionStatus =>
      submissionStatus.isNotEmpty
          ? EvidenceSubmissionStatus.values.firstWhere(
              (e) => e.name == submissionStatus.last,
              orElse: () => EvidenceSubmissionStatus.pending)
          : EvidenceSubmissionStatus.pending;
  String get currentEvidenceNumber =>
      evidenceNumber.isNotEmpty ? evidenceNumber.last : '';
  String get currentCriteriaNumber =>
      criteriaNumber.isNotEmpty ? criteriaNumber.last : '';
  String get currentFilePath => filePath.isNotEmpty ? filePath.last : '';
  String get currentFileName => fileName.isNotEmpty ? fileName.last : '';
  String get currentFileSize => fileSize.isNotEmpty ? fileSize.last : '';
  String? get currentRejectionReason =>
      rejectionReason.isNotEmpty && rejectionReason.last.isNotEmpty
          ? rejectionReason.last
          : null;
  String? get currentSubmissionNote =>
      submissionNote.isNotEmpty && submissionNote.last.isNotEmpty
          ? submissionNote.last
          : null;
  String? get currentManagerId =>
      managerId.isNotEmpty && managerId.last.isNotEmpty ? managerId.last : null;
  Timestamp? get currentManagerResponseTime =>
      managerResponseTime.isNotEmpty && managerResponseTime.last.seconds != 0
          ? managerResponseTime.last
          : null;
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;

  // Convert to legacy model
  EvidenceSubmissionModel toLegacyModel() {
    return EvidenceSubmissionModel(
      submissionDate: currentSubmissionDate,
      submissionStatus: currentSubmissionStatus,
      submissionId: submissionId,
      evidenceNumber: currentEvidenceNumber,
      criteriaNumber: currentCriteriaNumber,
      submittedBy: currentSubmittedBy,
      approvedBy: currentApprovedBy,
      approvedDate: currentApprovedDate,
      filePath: currentFilePath,
      fileName: currentFileName,
      fileSize: currentFileSize,
      rejectionReason: currentRejectionReason,
      submissionNote: currentSubmissionNote,
      managerId: currentManagerId,
      managerResponseTime: currentManagerResponseTime,
    );
  }

  // Parse from Firestore map
  factory EvidenceSubmissionHistoryModel.fromMap(Map<String, dynamic> map) {
    try {
      debugPrint("\n=== EvidenceSubmissionHistoryModel.fromMap DEBUG ===");
      // print("Available keys: ${map.keys.toList()}");

      final List<int> sharedTimestamps = (map[kTimestampsKey] as List<dynamic>?)
              ?.map((e) => e is int ? e : (e as num).toInt())
              .toList() ??
          [DateTime.now().millisecondsSinceEpoch];

      //F   print("Timestamps count: ${sharedTimestamps.length}");
      // print("=====================================\n");

      return EvidenceSubmissionHistoryModel(
        submissionId: map[kSubmissionIdKey] ?? map['_documentId'] ?? '',
        timestamps: sharedTimestamps,
        submissionDate: _parseTimestampList(map[kSubmissionDateKey]),
        approvedDate: _parseTimestampList(map[kApprovedDateKey]),
        submittedBy: _parseListSafely(map[kSubmittedByKey]),
        approvedBy: _parseListSafely(map[kApprovedByKey]),
        submissionStatus: _parseListSafely(map[kSubmissionStatusKey]),
        evidenceNumber: _parseListSafely(map[kEvidenceNumberKey]),
        criteriaNumber: _parseListSafely(map[kCriteriaNumberKey]),
        filePath: _parseListSafely(map[kFilePathKey]),
        fileName: _parseListSafely(map[kFileNameKey]),
        fileSize: _parseListSafely(map[kFileSizeKey]),
        rejectionReason: _parseListSafely(map[kRejectionReasonKey]),
        submissionNote: _parseListSafely(map[kSubmissionNoteKey]),
        managerId: _parseListSafely(map[kManagerIdKey]),
        managerResponseTime: _parseTimestampList(map[kManagerResponseTimeKey]),
      );
    } catch (e, stack) {
      debugPrint("❌ ERROR parsing EvidenceSubmissionHistoryModel: $e");
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
    if (value == null) return [Timestamp.fromMillisecondsSinceEpoch(0)];
    if (value is List) {
      return value.map((e) {
        if (e is Timestamp) return e;
        if (e is int) return Timestamp.fromMillisecondsSinceEpoch(e);
        if (e is Map && e.containsKey('_seconds')) {
          return Timestamp(e['_seconds'], e['_nanoseconds'] ?? 0);
        }
        return Timestamp.fromMillisecondsSinceEpoch(0);
      }).toList();
    }
    if (value is Timestamp) return [value];
    if (value is int) return [Timestamp.fromMillisecondsSinceEpoch(value)];
    return [Timestamp.fromMillisecondsSinceEpoch(0)];
  }

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      kSubmissionIdKey: submissionId,
      kTimestampsKey: timestamps,
      kSubmissionDateKey:
          submissionDate.map((t) => t.millisecondsSinceEpoch).toList(),
      kApprovedDateKey:
          approvedDate.map((t) => t.millisecondsSinceEpoch).toList(),
      kSubmittedByKey: submittedBy,
      kApprovedByKey: approvedBy,
      kSubmissionStatusKey: submissionStatus,
      kEvidenceNumberKey: evidenceNumber,
      kCriteriaNumberKey: criteriaNumber,
      kFilePathKey: filePath,
      kFileNameKey: fileName,
      kFileSizeKey: fileSize,
      kRejectionReasonKey: rejectionReason,
      kSubmissionNoteKey: submissionNote,
      kManagerIdKey: managerId,
      kManagerResponseTimeKey:
          managerResponseTime.map((t) => t.millisecondsSinceEpoch).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  factory EvidenceSubmissionHistoryModel.fromJson(String source) =>
      EvidenceSubmissionHistoryModel.fromMap(json.decode(source));

  // CopyWith method that synchronizes ALL fields
  EvidenceSubmissionHistoryModel copyWith({
    Timestamp? submissionDate,
    Timestamp? approvedDate,
    String? submittedBy,
    String? approvedBy,
    EvidenceSubmissionStatus? submissionStatus,
    String? evidenceNumber,
    String? criteriaNumber,
    String? filePath,
    String? fileName,
    String? fileSize,
    String? rejectionReason,
    String? submissionNote,
    String? managerId,
    Timestamp? managerResponseTime,
  }) {
    debugPrint("\n=== EvidenceSubmissionHistoryModel.copyWith DEBUG ===");

    // Add new timestamp for this update
    final newTimestamps = List<int>.from(timestamps)
      ..add(DateTime.now().millisecondsSinceEpoch);

    debugPrint(
        "Creating synchronized update at index ${newTimestamps.length - 1}");
    debugPrint("Edited fields:");
    if (submissionDate != null) debugPrint("  - submissionDate");
    if (approvedDate != null) debugPrint("  - approvedDate");
    if (submittedBy != null) debugPrint("  - submittedBy: '$submittedBy'");
    if (approvedBy != null) debugPrint("  - approvedBy: '$approvedBy'");
    if (submissionStatus != null) {
      debugPrint("  - submissionStatus: $submissionStatus");
    }
    if (evidenceNumber != null) {
      debugPrint("  - evidenceNumber: '$evidenceNumber'");
    }
    if (criteriaNumber != null) {
      debugPrint("  - criteriaNumber: '$criteriaNumber'");
    }
    if (filePath != null) debugPrint("  - filePath: '$filePath'");
    if (fileName != null) debugPrint("  - fileName: '$fileName'");
    if (fileSize != null) debugPrint("  - fileSize: '$fileSize'");
    if (rejectionReason != null) debugPrint("  - rejectionReason");
    if (submissionNote != null) debugPrint("  - submissionNote");
    if (managerId != null) debugPrint("  - managerId: '$managerId'");
    if (managerResponseTime != null) debugPrint("  - managerResponseTime");

    // ALL fields get updated - edited values OR current values repeated
    final result = EvidenceSubmissionHistoryModel(
      submissionId: submissionId,
      timestamps: newTimestamps,
      submissionDate: List<Timestamp>.from(this.submissionDate)
        ..add(submissionDate ?? currentSubmissionDate),
      approvedDate: List<Timestamp>.from(this.approvedDate)
        ..add(approvedDate ??
            (currentApprovedDate ?? Timestamp.fromMillisecondsSinceEpoch(0))),
      submittedBy: List<String>.from(this.submittedBy)
        ..add(submittedBy ?? currentSubmittedBy),
      approvedBy: List<String>.from(this.approvedBy)
        ..add(approvedBy ?? (currentApprovedBy ?? '')),
      submissionStatus: List<String>.from(this.submissionStatus)
        ..add(submissionStatus?.name ?? currentSubmissionStatus.name),
      evidenceNumber: List<String>.from(this.evidenceNumber)
        ..add(evidenceNumber ?? currentEvidenceNumber),
      criteriaNumber: List<String>.from(this.criteriaNumber)
        ..add(criteriaNumber ?? currentCriteriaNumber),
      filePath: List<String>.from(this.filePath)
        ..add(filePath ?? currentFilePath),
      fileName: List<String>.from(this.fileName)
        ..add(fileName ?? currentFileName),
      fileSize: List<String>.from(this.fileSize)
        ..add(fileSize ?? currentFileSize),
      rejectionReason: List<String>.from(this.rejectionReason)
        ..add(rejectionReason ?? (currentRejectionReason ?? '')),
      submissionNote: List<String>.from(this.submissionNote)
        ..add(submissionNote ?? (currentSubmissionNote ?? '')),
      managerId: List<String>.from(this.managerId)
        ..add(managerId ?? (currentManagerId ?? '')),
      managerResponseTime: List<Timestamp>.from(this.managerResponseTime)
        ..add(managerResponseTime ??
            (currentManagerResponseTime ??
                Timestamp.fromMillisecondsSinceEpoch(0))),
    );

    debugPrint(
        "✓ All arrays now have ${result.timestamps.length} entries (synchronized)");
    debugPrint("  - submissionDate length: ${result.submissionDate.length}");
    debugPrint("  - approvedDate length: ${result.approvedDate.length}");
    debugPrint("  - submittedBy length: ${result.submittedBy.length}");
    debugPrint("  - approvedBy length: ${result.approvedBy.length}");
    debugPrint(
        "  - submissionStatus length: ${result.submissionStatus.length}");
    debugPrint("  - evidenceNumber length: ${result.evidenceNumber.length}");
    debugPrint("  - criteriaNumber length: ${result.criteriaNumber.length}");
    debugPrint("  - filePath length: ${result.filePath.length}");
    debugPrint("  - fileName length: ${result.fileName.length}");
    debugPrint("  - fileSize length: ${result.fileSize.length}");
    debugPrint("  - rejectionReason length: ${result.rejectionReason.length}");
    debugPrint("  - submissionNote length: ${result.submissionNote.length}");
    debugPrint("  - managerId length: ${result.managerId.length}");
    debugPrint(
        "  - managerResponseTime length: ${result.managerResponseTime.length}");
    debugPrint("=====================================\n");

    return result;
  }

  // Factory constructor for creating new submissions
  factory EvidenceSubmissionHistoryModel.createNew({
    required String submissionId,
    required Timestamp submissionDate,
    required String submittedBy,
    required EvidenceSubmissionStatus submissionStatus,
    required String evidenceNumber,
    required String criteriaNumber,
    String filePath = '',
    String fileName = '',
    String fileSize = '',
    String? approvedBy,
    Timestamp? approvedDate,
    String? rejectionReason,
    String? submissionNote,
    String? managerId,
    Timestamp? managerResponseTime,
  }) {
    return EvidenceSubmissionHistoryModel(
      submissionId: submissionId,
      timestamps: [DateTime.now().millisecondsSinceEpoch],
      submissionDate: [submissionDate],
      approvedDate: [approvedDate ?? Timestamp.fromMillisecondsSinceEpoch(0)],
      submittedBy: [submittedBy],
      approvedBy: [approvedBy ?? ''],
      submissionStatus: [submissionStatus.name],
      evidenceNumber: [evidenceNumber],
      criteriaNumber: [criteriaNumber],
      filePath: [filePath],
      fileName: [fileName],
      fileSize: [fileSize],
      rejectionReason: [rejectionReason ?? ''],
      submissionNote: [submissionNote ?? ''],
      managerId: [managerId ?? ''],
      managerResponseTime: [
        managerResponseTime ?? Timestamp.fromMillisecondsSinceEpoch(0)
      ],
    );
  }

  // Generate next submission ID
  static Future<String> generateNextSubmissionId() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(getBaseUrl('Evidence_Submissions'))
          .orderBy(kSubmissionIdKey, descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return "SUB001";
      }

      String lastId =
          snapshot.docs.first.get(kSubmissionIdKey) ?? snapshot.docs.first.id;
      String numericPart = lastId.replaceAll(RegExp(r'[^0-9]'), '');
      int nextNumber = int.parse(numericPart.isEmpty ? '0' : numericPart) + 1;
      return "SUB${nextNumber.toString().padLeft(3, '0')}";
    } catch (e) {
      debugPrint('Error generating submission ID: $e');
      return "SUB${DateTime.now().millisecondsSinceEpoch}";
    }
  }
}
