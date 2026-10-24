/// Module: knowledge_hub/data/models
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_copy.dart
/// Description: Applying one edit to a `CreateKnowledgeModel`.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/utils/knowledge_departments_codec.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';

extension CreateKnowledgeCopy on CreateKnowledgeModel {
  /// This document with one EDIT applied (KH-CREATE-03): every changed field
  /// gets a new entry, the author is never changed, the editor goes to
  /// `editedByEmail`, and every edit adds a status entry so status and
  /// timestamps stay the same length.
  CreateKnowledgeModel copyWith({
    String? firestoreDocumentId,
    String? knowledgeId,
    String? knowledgeImage,
    String? nameEnglish,
    String? nameArabic,
    String? descriptionEnglish,
    String? descriptionArabic,
    String? knowledgeDocumentType,
    String? owningDepartment,
    List<String>? limitedDepartments,
    bool? schedulePublishing,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? startTime,
    String? endTime,
    String? imageUrl,
    String? documentUrl,
    String? documentFileName,
    String? documentExtension,
    int? documentSize,
    String? editedByEmail,
    String? timeStamp,
    String? status,
    String? statusReason,
  }) {
    List<T> add<T>(List<T> old, T? value) =>
        value == null ? List<T>.from(old) : (List<T>.from(old)..add(value));

    final List<String> reasons = List<String>.from(this.statusReason);
    while (reasons.length < this.status.length) {
      reasons.add('');
    }
    reasons.add(statusReason ?? '');

    return CreateKnowledgeModel(
      firestoreDocumentId: firestoreDocumentId ?? this.firestoreDocumentId,
      timestamps: List<int>.from(timestamps)
        ..add(DateTime.now().millisecondsSinceEpoch),
      knowledgeId:
          knowledgeId != null && !this.knowledgeId.contains(knowledgeId)
          ? (List<String>.from(this.knowledgeId)..add(knowledgeId))
          : List<String>.from(this.knowledgeId),
      knowledgeImage: add(this.knowledgeImage ?? <String>[], knowledgeImage),
      nameEnglish: add(this.nameEnglish, nameEnglish),
      nameArabic: add(this.nameArabic, nameArabic),
      descriptionEnglish: add(this.descriptionEnglish, descriptionEnglish),
      descriptionArabic: add(this.descriptionArabic, descriptionArabic),
      knowledgeDocumentType: add(
        this.knowledgeDocumentType,
        knowledgeDocumentType,
      ),
      owningDepartment: add(this.owningDepartment, owningDepartment),
      limitedDepartments: add(
        this.limitedDepartments,
        limitedDepartments == null
            ? null
            : KnowledgeDepartmentsCodec.encode(limitedDepartments),
      ),
      schedulePublishing: add(this.schedulePublishing, schedulePublishing),
      startDateTime: add(
        this.startDateTime,
        startDateTime == null ? null : Timestamp.fromDate(startDateTime),
      ),
      endDateTime: add(
        this.endDateTime,
        endDateTime == null ? null : Timestamp.fromDate(endDateTime),
      ),
      startTime: add(this.startTime, startTime),
      endTime: add(this.endTime, endTime),
      imageUrl: add(this.imageUrl ?? <String>[], imageUrl),
      documentUrl: add(this.documentUrl, documentUrl),
      documentFileName: add(this.documentFileName, documentFileName),
      timeStamp: add(this.timeStamp, timeStamp),
      documentExtension: add(this.documentExtension, documentExtension),
      documentSize: add(this.documentSize, documentSize),
      createdByEmail: List<String>.from(createdByEmail),
      editedByEmail: add(this.editedByEmail, editedByEmail),
      status: add(this.status, status ?? currentStatus),
      statusReason: reasons,
    );
  }
}
