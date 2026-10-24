// [module-file:qiyas] — deleted when the qiyas module is split out
import 'package:get/get.dart';

import 'package:knowticed_plus/features/qiyas/data/legacy_core/constants/strings.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/qiyas_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/module_permissions_sections_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/qiyas/champions.dart';

enum QiyasPermissionsSections
    implements ModulePermissionsSections, ModulePermissionsSectionsPermission {
  qiyasPermissions,
  assignedEvidence,
  champions,
  approvals,
  changeSubmissionStatus,
  dashboard,
  uploadedDocuments;

  @override
  String get getName {
    switch (this) {
      case QiyasPermissionsSections.qiyasPermissions:
        return AppConstanstForm.qiyasPermissions.tr;
      case QiyasPermissionsSections.champions:
        return AppConstanstForm.championsPermissions.tr;
      case QiyasPermissionsSections.approvals:
        return AppConstanstForm.approvals.tr;
      case QiyasPermissionsSections.changeSubmissionStatus:
        return AppConstanstForm.changeSubmissionStatus.tr;
      case QiyasPermissionsSections.dashboard:
        return AppConstanstForm.dashboard.tr;
      case QiyasPermissionsSections.assignedEvidence:
        return AppConstanstForm.assignedEvidence.tr;
      case QiyasPermissionsSections.uploadedDocuments:
        return AppConstanstForm.uploadedDocuments.tr;
    }
  }

  @override
  String get getDataBaseName {
    switch (this) {
      case QiyasPermissionsSections.qiyasPermissions:
        return 'Qiyas_Permissions_Module';
      case QiyasPermissionsSections.champions:
        return 'Champions_Module';
      case QiyasPermissionsSections.approvals:
        return 'Approvals_Module';
      case QiyasPermissionsSections.changeSubmissionStatus:
        return 'Change_Submission_Status_Module';
      case QiyasPermissionsSections.dashboard:
        return 'Dashboard_Module';
      case QiyasPermissionsSections.assignedEvidence:
        return 'Assigned_Evidence_Module';
      case QiyasPermissionsSections.uploadedDocuments:
        return 'Uploaded_Documents_Module';
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case QiyasPermissionsSections.qiyasPermissions:
        return AppConstanstForm.qiyasPermissionsModule.tr;
      case QiyasPermissionsSections.champions:
        return AppConstanstForm.championsModule.tr;
      case QiyasPermissionsSections.approvals:
        return AppConstanstForm.approvalsModule.tr;
      case QiyasPermissionsSections.changeSubmissionStatus:
        return AppConstanstForm.changeSubmissionStatusModule.tr;
      case QiyasPermissionsSections.dashboard:
        return AppConstanstForm.dashboard.tr;
      case QiyasPermissionsSections.assignedEvidence:
        return AppConstanstForm.assignedEvidence.tr;
      case QiyasPermissionsSections.uploadedDocuments:
        return AppConstanstForm.uploadedDocumentsModule.tr;
    }
  }

  @override
  bool get isChild => false;

  @override
  List<Enum> get sectionPermissions {
    switch (this) {
      case QiyasPermissionsSections.qiyasPermissions:
        return QiyasPermissions.values;
      case QiyasPermissionsSections.champions:
        return Champions.values;
      default:
        return [];
    }
  }

  static List<Enum> get firstColumnValues => [
        QiyasPermissionsSections.qiyasPermissions,
        QiyasPermissionsSections.assignedEvidence,
      ];

  static List<Enum> get lastColumnValues => [
        QiyasPermissionsSections.champions,
        QiyasPermissionsSections.approvals,
        QiyasPermissionsSections.changeSubmissionStatus,
        QiyasPermissionsSections.dashboard,
        QiyasPermissionsSections.uploadedDocuments,
      ];
}
