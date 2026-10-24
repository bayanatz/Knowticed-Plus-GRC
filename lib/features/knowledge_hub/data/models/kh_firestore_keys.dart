/// Module: knowledge_hub/data/models
/// ************************* FILE INFO *************************** ///
/// File Name: kh_firestore_keys.dart
/// Description: Firestore field names the Knowledge Hub data sources read
///              and write, other than a knowledge document's own fields
///              (those are in `CreateKnowledgeKeys`) and an Employees
///              record's (`EmployeeKeys`).
/// Author: Amr Mesbah
/// Created at: 23/10/2026
library;

/// A view / download / export row of the document utilisation collection.
class KhFileActionKeys {
  const KhFileActionKeys._();
  static const String fileId = 'fileId';
  static const String actionTimestamp = 'actionTimestamp';
}

/// A Knowledge Hub comment, as written by the hub.
class KhCommentKeys {
  const KhCommentKeys._();
  static const String knowledgeId = 'knowledgeId';
  static const String commentId = 'commentId';
  static const String commentText = 'commentText';
}

/// The fields the shared comment box (UniversalCommentSection) reads and
/// writes in the same comments collection (KH-SUBMIT-02).
class KhSharedCommentKeys {
  const KhSharedCommentKeys._();
  static const String requestId = 'Request_Id';
  static const String commentId = 'Comment_Id';
  static const String commentText = 'Comment_Text';
  static const String commenterId = 'Commenter_Id';
  static const String commentDate = 'Comment_Date';
  static const String commentLink = 'Comment_Link';
  static const String fileName = 'File_Name';
  static const String fileSize = 'File_Size';
}

/// The map returned after a comment attachment is uploaded.
class KhAttachmentKeys {
  const KhAttachmentKeys._();
  static const String url = 'url';
  static const String name = 'name';
  static const String extension = 'extension';
  static const String size = 'size';
  static const String icon = 'icon';
}

/// A Departments record.
class KhDepartmentKeys {
  const KhDepartmentKeys._();
  static const String id = 'id';
  static const String departmentId = 'Department_ID';
  static const String departmentName = 'Department_Name';
}

/// Older or alternative e-mail / supervisor fields some Employees records
/// carry, read as fallbacks next to `EmployeeKeys`.
class KhEmployeeFallbackKeys {
  const KhEmployeeFallbackKeys._();
  static const String currentEmployeeEmail = 'currentemployeeEmail';
  static const String supervisorEmail = 'supervisorEmail';
  static const String managerEmail = 'managerEmail';
  static const String headOfDepartment = 'headOfDepartment';
}

/// A marker in the notification log that stops a timed notification from
/// being sent twice (KH-CREATE-19).
class KhNotificationLogKeys {
  const KhNotificationLogKeys._();
  static const String knowledgeId = 'knowledgeId';
  static const String eventKey = 'eventKey';
  static const String dueMillis = 'dueMillis';
  static const String raisedAt = 'raisedAt';
}
