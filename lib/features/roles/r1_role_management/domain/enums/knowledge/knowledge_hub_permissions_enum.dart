import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
import 'package:grc_module/generated/l10n.dart';

// Knowledge Hub Permissions Enum
enum KnowledgeHubPermissions implements ModulePermissionsSectionsPermission {
  createKnowledgeHub,
  selectOwningDepartment,
  downloadDocuments,
  viewDocuments,
  analytics,
  statistics,
  inquiriesAndComments,
  allowsRemovingDocumentsOwnedByAnyone;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case createKnowledgeHub:
        return 'Create_Knowledge_Hub';
      case selectOwningDepartment:
        return 'Select_Owning_Department';
      case downloadDocuments:
        return 'Download_Documents';
      case viewDocuments:
        return 'View_Documents';
      case analytics:
        return 'Analytics';
      case statistics:
        return 'Statistics';
      case inquiriesAndComments:
        return 'Inquiries_and_Comments';
      case allowsRemovingDocumentsOwnedByAnyone:
        return 'Allows_Removing_Documents_Owned_By_Anyone';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createKnowledgeHub:
        return S.current.createKnowledgeHub;
      case selectOwningDepartment:
        return S.current.selectOwningDepartment;
      case downloadDocuments:
        return S.current.downloadDocuments;
      case viewDocuments:
        return S.current.viewDocuments;
      case analytics:
        return S.current.analytics;
      case statistics:
        return S.current.statistics;
      case inquiriesAndComments:
        return S.current.inquiriesAndComments;
      case allowsRemovingDocumentsOwnedByAnyone:
        return S.current.allowsRemovingDocumentsOwnedByAnyone;
    }
  }
}