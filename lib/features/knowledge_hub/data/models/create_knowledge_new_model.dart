/// Module: knowledge_hub/data/models
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_new_model.dart
/// Description: `CreateKnowledgeModel` — a knowledge document. Every field is
///              a history list; the current value is the last entry.
/// Author: Youssef Khaled
/// Created at: 11/10/2025
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/utils/knowledge_departments_codec.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_json.dart';

export 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_copy.dart';
export 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_getters.dart';
export 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_keys.dart';

class CreateKnowledgeModel {
  CreateKnowledgeModel({
    this.firestoreDocumentId,
    required this.timestamps,
    required this.knowledgeId,
    this.knowledgeImage,
    required this.nameEnglish,
    required this.nameArabic,
    required this.descriptionEnglish,
    required this.descriptionArabic,
    required this.knowledgeDocumentType,
    required this.owningDepartment,
    required this.limitedDepartments,
    required this.schedulePublishing,
    required this.startDateTime,
    required this.endDateTime,
    required this.startTime,
    required this.endTime,
    this.imageUrl,
    required this.documentUrl,
    required this.documentFileName,
    required this.timeStamp,
    required this.documentExtension,
    required this.documentSize,
    required this.status,
    required this.createdByEmail,
    this.statusReason = const [],
    this.editedByEmail = const [],
    this.pendingEdit,
  });

  factory CreateKnowledgeModel.fromJson(
    Map<String, dynamic> json, [
    String? docId,
  ]) => CreateKnowledgeJson.fromJson(json, docId);

  /// A new document with one entry in every history list.
  factory CreateKnowledgeModel.createNew({
    String? firestoreDocumentId,
    required String knowledgeId,
    String? knowledgeImage,
    required String nameEnglish,
    required String nameArabic,
    required String descriptionEnglish,
    required String descriptionArabic,
    required String knowledgeDocumentType,
    required String owningDepartment,
    List<String>? limitedDepartments,
    bool? schedulePublishing,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? startTime,
    String? endTime,
    String? imageUrl,
    required String documentUrl,
    required String documentFileName,
    required String documentExtension,
    required int documentSize,
    required String createdByEmail,
    required String timeStamp,
    required String status,
    String statusReason = '',
  }) => CreateKnowledgeModel(
    firestoreDocumentId: firestoreDocumentId,
    timestamps: [DateTime.now().millisecondsSinceEpoch],
    knowledgeId: [knowledgeId],
    knowledgeImage: [knowledgeImage ?? ''],
    nameEnglish: [nameEnglish],
    nameArabic: [nameArabic],
    descriptionEnglish: [descriptionEnglish],
    descriptionArabic: [descriptionArabic],
    knowledgeDocumentType: [knowledgeDocumentType],
    owningDepartment: [owningDepartment],
    limitedDepartments: [
      KnowledgeDepartmentsCodec.encode(limitedDepartments ?? const []),
    ],
    schedulePublishing: [schedulePublishing ?? false],
    startDateTime: [
      if (startDateTime != null) Timestamp.fromDate(startDateTime),
    ],
    endDateTime: [if (endDateTime != null) Timestamp.fromDate(endDateTime)],
    startTime: [startTime ?? ''],
    endTime: [endTime ?? ''],
    imageUrl: [imageUrl ?? ''],
    documentUrl: [documentUrl],
    documentFileName: [documentFileName],
    timeStamp: [timeStamp],
    documentExtension: [documentExtension],
    documentSize: [documentSize],
    createdByEmail: [createdByEmail],
    status: [status],
    statusReason: [statusReason],
  );

  /// The Firestore document id.
  final String? firestoreDocumentId;

  /// One entry per change, shared by all the history lists.
  final List<int> timestamps;
  final List<String> knowledgeId;
  final List<String>? knowledgeImage;
  final List<String> nameEnglish;
  final List<String> nameArabic;
  final List<String> descriptionEnglish;
  final List<String> descriptionArabic;
  final List<String> knowledgeDocumentType;
  final List<String> owningDepartment;

  /// JSON-encoded department lists (see [KnowledgeDepartmentsCodec]).
  final List<String> limitedDepartments;
  final List<bool> schedulePublishing;
  final List<Timestamp> startDateTime;
  final List<Timestamp> endDateTime;

  /// "HH:mm".
  final List<String> startTime;
  final List<String> endTime;
  final List<String>? imageUrl;
  final List<String> documentUrl;
  final List<String> documentFileName;
  final List<String> documentExtension;
  final List<int> documentSize;

  /// The author is the first entry and never changes (KH-CREATE-03).
  final List<String> createdByEmail;
  final List<String> timeStamp;
  final List<String> status;

  /// The reason for the matching [status] entry ('' when none). Older
  /// documents have a shorter list; read it with `reasonForStatusAt`.
  final List<String> statusReason;

  /// Who made each edit (KH-CREATE-03).
  final List<String> editedByEmail;

  /// An edit of a live document waiting for approval, in the same JSON shape
  /// as the document; null when there is none.
  final Map<String, dynamic>? pendingEdit;

  Map<String, dynamic> toJson() => CreateKnowledgeJson.toJson(this);

  /// See [KnowledgeDepartmentsCodec.decode].
  static List<String>? decodeDepartments(List<String> raw) =>
      KnowledgeDepartmentsCodec.decode(raw);
}
