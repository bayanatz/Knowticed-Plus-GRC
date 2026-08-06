import 'package:grc_module/features/roles/r1_role_management/domain/interfaces/module_permissions_sections_permissions.dart';
import 'package:grc_module/generated/l10n.dart';

enum SubmissionsPermissions implements ModulePermissionsSectionsPermission {
  editDocumentWithApproval,
  editDocumentWithoutApproval,
  removeDocuments,
  exportStatisticsTable;

  @override
  bool get isChild {
    return false;
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case editDocumentWithApproval:
        return 'Edit_Document_With_Approval';
      case editDocumentWithoutApproval:
        return 'Edit_Document_Without_Approval';
      case removeDocuments:
        return 'Remove_Documents';
      case exportStatisticsTable:
        return 'Export_Statistics_Table';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case editDocumentWithApproval:
        return S.current.editDocumentWithApproval;
      case editDocumentWithoutApproval:
        return S.current.editDocumentWithoutApproval;
      case removeDocuments:
        return S.current.removeDocuments;
      case exportStatisticsTable:
        return S.current.exportStatisticsTable;
    }
  }
}