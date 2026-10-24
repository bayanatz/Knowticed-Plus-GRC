/// Module: knowledge_hub/data/models
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_getters.dart
/// Description: Current values and status rules of `CreateKnowledgeModel`.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';

extension CreateKnowledgeGetters on CreateKnowledgeModel {
  String get currentKnowledgeId =>
      knowledgeId.isNotEmpty ? knowledgeId.last : '';
  String get currentNameEnglish =>
      nameEnglish.isNotEmpty ? nameEnglish.last : '';
  String get currentNameArabic => nameArabic.isNotEmpty ? nameArabic.last : '';
  String get currentDescriptionEnglish =>
      descriptionEnglish.isNotEmpty ? descriptionEnglish.last : '';
  String get currentDescriptionArabic =>
      descriptionArabic.isNotEmpty ? descriptionArabic.last : '';
  String get currentKnowledgeDocumentType =>
      knowledgeDocumentType.isNotEmpty ? knowledgeDocumentType.last : '';
  String get currentOwningDepartment =>
      owningDepartment.isNotEmpty ? owningDepartment.last : '';
  bool get currentSchedulePublishing =>
      schedulePublishing.isNotEmpty ? schedulePublishing.last : false;
  Timestamp? get currentStartDateTime =>
      startDateTime.isNotEmpty ? startDateTime.last : null;
  Timestamp? get currentEndDateTime =>
      endDateTime.isNotEmpty ? endDateTime.last : null;
  String get currentStartTime => startTime.isNotEmpty ? startTime.last : '';
  String get currentEndTime => endTime.isNotEmpty ? endTime.last : '';
  String get currentImageUrl =>
      (imageUrl?.isNotEmpty ?? false) ? imageUrl!.last : '';
  String get currentDocumentUrl =>
      documentUrl.isNotEmpty ? documentUrl.last : '';
  String get currentDocumentFileName =>
      documentFileName.isNotEmpty ? documentFileName.last : '';
  String get currentDocumentExtension =>
      documentExtension.isNotEmpty ? documentExtension.last : '';
  int get currentDocumentSize =>
      documentSize.isNotEmpty ? documentSize.last : 0;
  String get currentStatus => status.isNotEmpty ? status.last : '';
  int? get currentTimestamp => timestamps.isNotEmpty ? timestamps.last : null;
  int? getTimestampAt(int index) =>
      index >= 0 && index < timestamps.length ? timestamps[index] : null;

  /// The document's author: the first entry, which an edit never changes.
  String get currentCreatedByEmail =>
      createdByEmail.isNotEmpty ? createdByEmail.first : '';
  String get authorEmail => currentCreatedByEmail;

  /// The reason recorded with the status at [index], or ''.
  String reasonForStatusAt(int index) =>
      index < 0 || index >= statusReason.length ? '' : statusReason[index];
  String get currentStatusReason => reasonForStatusAt(status.length - 1);

  /// The reason given when the document was last removed, or ''.
  String get removalReason => reasonForStatusAt(status.lastIndexOf('removed'));

  /// When the document first reached [target] status, or null. Status and
  /// timestamps line up from the END (older edits added a timestamp only).
  DateTime? firstTimeOfStatus(String target) {
    final String t = target.trim().toLowerCase();
    final int offset = timestamps.length - status.length;
    for (int i = 0; i < status.length; i++) {
      if (status[i].trim().toLowerCase() != t) continue;
      final int j = i + offset;
      if (j < 0 || j >= timestamps.length) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamps[j]);
    }
    return null;
  }

  /// When the document went live, or null if it never did. A scheduled,
  /// approved document went live at its start time.
  DateTime? get publishedAt {
    final DateTime? firstPublished = firstTimeOfStatus('published');
    if (firstPublished != null) return firstPublished;
    if (currentStatus.trim().toLowerCase() == 'approved' &&
        isLiveAt(DateTime.now())) {
      return currentStartDateTime?.toDate();
    }
    return null;
  }

  /// Whether the document is visible on the hub at [now] (KH-SUBMIT-03):
  /// published until its scheduled end; approved only between its scheduled
  /// start and end; anything else is not live.
  bool isLiveAt(DateTime now) {
    final String s = currentStatus.trim().toLowerCase();
    final bool scheduled = currentSchedulePublishing;
    final DateTime? start = currentStartDateTime?.toDate();
    final DateTime? end = currentEndDateTime?.toDate();
    final bool ended = scheduled && end != null && !now.isBefore(end);
    if (s == 'published') return !ended;
    if (s == 'approved') {
      return scheduled && start != null && !now.isBefore(start) && !ended;
    }
    return false;
  }

  /// The departments the document is limited to; `[]` when public.
  List<String> get currentLimitedDepartmentsList =>
      CreateKnowledgeModel.decodeDepartments(limitedDepartments) ?? const [];

  /// True when the restriction cannot be read: treat as restricted.
  bool get departmentsUnreadable =>
      CreateKnowledgeModel.decodeDepartments(limitedDepartments) == null;

  /// The flat fields the visibility query and the security rules filter on.
  Map<String, dynamic> get visibilityFields {
    final List<String> depts = currentLimitedDepartmentsList
        .map((e) => e.toLowerCase().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return {
      CreateKnowledgeKeys.currentStatus: currentStatus.trim().toLowerCase(),
      CreateKnowledgeKeys.isPublic: !departmentsUnreadable && depts.isEmpty,
      CreateKnowledgeKeys.accessDepartments: depts,
    };
  }

  /// True while an edit of this live document waits for approval.
  bool get hasPendingEdit => pendingEdit != null && pendingEdit!.isNotEmpty;

  /// The document as it will look if the pending edit is approved.
  CreateKnowledgeModel? get pendingEditModel => hasPendingEdit
      ? CreateKnowledgeModel.fromJson(
          Map<String, dynamic>.from(pendingEdit!),
          firestoreDocumentId,
        )
      : null;
}
