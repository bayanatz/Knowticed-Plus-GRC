/// Module: roles / r1_role_management / domain / enums / knowledge
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hubssections_enum.dart
/// Description: Declares `KnowledgeHubPermissionsSections`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:grc_module/features/roles/r1_role_management/domain/enums/knowledge_hub/submissions_permissions_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/knowledge_hub/approval_permissions.dart';
import 'package:grc_module/features/roles/r1_role_management/domain/enums/knowledge_hub/knowledge_hub_permissions_enum.dart';
import 'package:grc_module/generated/l10n.dart';

enum KnowledgeHubPermissionsSections
    implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  knowledgeHubPermissions,
  submissions,
  approval,
  dashboard,
  allowsRemovingDocumentsOwnedByAnyone;

  @override
  String get getName {
    switch (this) {
      case KnowledgeHubPermissionsSections.knowledgeHubPermissions:
        return S.current.knowledgeHubPermissions;
      case KnowledgeHubPermissionsSections.submissions:
        return S.current.submissions;
      case KnowledgeHubPermissionsSections.approval:
        return S.current.approval;
      case KnowledgeHubPermissionsSections.dashboard:
        return S.current.dashboard;
      case KnowledgeHubPermissionsSections.allowsRemovingDocumentsOwnedByAnyone:
        return S.current.allowsRemovingDocumentsOwnedByAnyone;
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case KnowledgeHubPermissionsSections.knowledgeHubPermissions:
        return 'Knowledge_Hub_Permissions';
      case KnowledgeHubPermissionsSections.submissions:
        return 'Submissions';
      case KnowledgeHubPermissionsSections.approval:
        return 'Approval';
      case KnowledgeHubPermissionsSections.dashboard:
        return 'Dashboard';
      case KnowledgeHubPermissionsSections.allowsRemovingDocumentsOwnedByAnyone:
        return 'Allows_Removing_Documents_Owned_By_Anyone';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case KnowledgeHubPermissionsSections.knowledgeHubPermissions:
        return S.current.knowledgeHubPermissions;
      case KnowledgeHubPermissionsSections.submissions:
        return S.current.submissions;
      case KnowledgeHubPermissionsSections.approval:
        return S.current.approval;
      case KnowledgeHubPermissionsSections.dashboard:
        return S.current.dashboard;
      case KnowledgeHubPermissionsSections.allowsRemovingDocumentsOwnedByAnyone:
        return S.current.allowsRemovingDocumentsOwnedByAnyone;
    }
  }

  @override
  bool get isChild {
    return false;
  }

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case KnowledgeHubPermissionsSections.knowledgeHubPermissions:
        return KnowledgeHubPermissions.values;
      case KnowledgeHubPermissionsSections.submissions:
        // CHANGED 15/10/2026 — KH large-screen report p.31, as written:
        // "remove this switch, leave only the switch of Edit Document With
        // Approval — if it is open, edit without [approval]; if it is closed,
        // edit with approval". So the ONE edit switch shown is
        // "Edit Document With Approval" (see KnowledgeHubAccess.editAccess).
        return SubmissionsPermissions.values
            .where(
                (p) => p != SubmissionsPermissions.editDocumentWithoutApproval)
            .toList();
      case KnowledgeHubPermissionsSections.approval:
        return ApprovalPermissions.values;
      default:
        return [];
    }
  }

  static List<Enum> get firstColumnValues {
    return [
      KnowledgeHubPermissionsSections.knowledgeHubPermissions,
      // 15/10/2026 — KH large-screen report p.31: the stand-alone
      // "Allows Removing Documents Owned By Anyone" row under the Knowledge Hub
      // card was a duplicate of the switch inside it (same Firestore key), so
      // it is no longer shown. The enum value stays: permission checks use it.
    ];
  }

  static List<Enum> get lastColumnValues {
    return [
      KnowledgeHubPermissionsSections.submissions,
      KnowledgeHubPermissionsSections.approval,
      KnowledgeHubPermissionsSections.dashboard,
    ];
  }
}
