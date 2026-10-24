/// Module: knowledge_hub/kh1_create_new_knowledge/domain/entities
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_draft.dart
/// Description: The values of the create / edit form, ready to be saved.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

/// What the create / edit form saves. [imageUrl] and [documentUrl] are the
/// already-uploaded files (the existing ones when editing without a new file).
class KnowledgeDraft {
  const KnowledgeDraft({
    required this.nameEnglish,
    required this.nameArabic,
    required this.descriptionEnglish,
    required this.descriptionArabic,
    required this.documentType,
    required this.owningDepartment,
    required this.limitedDepartments,
    required this.schedulePublishing,
    required this.startDateTime,
    required this.endDateTime,
    required this.startTime,
    required this.endTime,
    required this.imageUrl,
    required this.documentUrl,
    required this.documentFileName,
    required this.documentExtension,
    required this.documentSize,
    required this.createdByEmail,
    required this.status,
  });

  final String nameEnglish;
  final String nameArabic;
  final String descriptionEnglish;
  final String descriptionArabic;
  final String documentType;
  final String owningDepartment;
  final List<String> limitedDepartments;
  final bool schedulePublishing;
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  /// "HH:mm", or null when no time was picked.
  final String? startTime;
  final String? endTime;
  final String? imageUrl;
  final String? documentUrl;
  final String documentFileName;
  final String documentExtension;
  final int documentSize;
  final String createdByEmail;
  final String status;

  KnowledgeDraft withFiles({String? imageUrl, String? documentUrl}) =>
      KnowledgeDraft(
        nameEnglish: nameEnglish,
        nameArabic: nameArabic,
        descriptionEnglish: descriptionEnglish,
        descriptionArabic: descriptionArabic,
        documentType: documentType,
        owningDepartment: owningDepartment,
        limitedDepartments: limitedDepartments,
        schedulePublishing: schedulePublishing,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        startTime: startTime,
        endTime: endTime,
        imageUrl: imageUrl ?? this.imageUrl,
        documentUrl: documentUrl ?? this.documentUrl,
        documentFileName: documentFileName,
        documentExtension: documentExtension,
        documentSize: documentSize,
        createdByEmail: createdByEmail,
        status: status,
      );
}
