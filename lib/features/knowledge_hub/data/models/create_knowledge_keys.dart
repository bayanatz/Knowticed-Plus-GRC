/// Module: knowledge_hub/data/models
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_keys.dart
/// Description: Firestore field names of a knowledge document.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

class CreateKnowledgeKeys {
  const CreateKnowledgeKeys._();

  static const String timestamps = 'timestamps';
  static const String knowledgeId = 'knowledgeId';
  static const String knowledgeImage = 'knowledgeImage';
  static const String nameEnglish = 'nameEnglish';
  static const String nameArabic = 'nameArabic';
  static const String descriptionEnglish = 'descriptionEnglish';
  static const String descriptionArabic = 'descriptionArabic';
  static const String knowledgeDocumentType = 'knowledgeDocumentType';
  static const String owningDepartment = 'owningDepartment';
  static const String limitedDepartments = 'limitedDepartments';
  static const String schedulePublishing = 'schedulePublishing';
  static const String startDateTime = 'startDateTime';
  static const String endDateTime = 'endDateTime';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';
  static const String imageUrl = 'imageUrl';
  static const String documentUrl = 'documentUrl';
  static const String documentFileName = 'documentFileName';
  static const String timeStamp = 'timeStamp';
  static const String documentExtension = 'documentExtension';
  static const String documentSize = 'documentSize';
  static const String createdByEmail = 'createdByEmail';
  static const String status = 'status';
  static const String statusReason = 'statusReason';
  static const String editedByEmail = 'editedByEmail';
  static const String pendingEdit = 'pendingEdit';
  static const String pendingEditAt = 'pendingEditAt';
  static const String pendingEditBy = 'pendingEditBy';
  static const String updatedAt = 'updatedAt';

  /// The Firestore document ID, copied into the data map when it is read.
  static const String id = 'id';

  // Flat, queryable copies of the current values (KH-CREATE-06).
  static const String currentStatus = 'currentStatus';
  static const String isPublic = 'isPublic';
  static const String accessDepartments = 'accessDepartments';
}
