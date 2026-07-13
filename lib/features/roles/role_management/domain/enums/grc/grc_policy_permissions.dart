import 'package:demo_app/features/roles/helper/form_builder_module/core/constants/strings.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/form_builder_module/core/constants/strings.dart';
import 'package:demo_app/features/roles/role_management/domain/interfaces/module_permissions_sections_permissions.dart';

enum GrcModulePermissions implements ModulePermissionsSectionsPermission {
  createSinglePolicy,
  createBulkUploadPolicy,
  draftPolicy,
  editPolicy,
  changeStatusOfPolicy,
  deletePolicy,
  policyWeightIssue,
  editPolicyWeightIssue,
  policyScore;

  @override
  bool get isChild => false;

  @override
  String get getDataBaseName {
    switch (this) {
      case createSinglePolicy:
        return 'Create_Single_Policy';
      case createBulkUploadPolicy:
        return 'Create_Bulk_Upload_Policy';
      case draftPolicy:
        return 'Draft_Policy';
      case editPolicy:
        return 'Edit_Policy';
      case changeStatusOfPolicy:
        return 'Change_Status_Of_Policy';
      case deletePolicy:
        return 'Delete_Policy';
      case policyWeightIssue:
        return 'Policy_Weight_Issue';
      case editPolicyWeightIssue:
        return 'Edit_Policy_Weight_Issue';
      case policyScore:
        return 'Policy_Score';
      
    }
  }

  @override
  String get getUiName {
    switch (this) {
      case createSinglePolicy:
        return AppConstanstForm.createSinglePolicy.tr;
      case createBulkUploadPolicy:
        return AppConstanstForm.createBulkUploadPolicy.tr;
      case draftPolicy:
        return AppConstanstForm.draftPolicy.tr;
      case editPolicy:
        return AppConstanstForm.editPolicy.tr;
      case changeStatusOfPolicy:
        return AppConstanstForm.changeStatusOfPolicy.tr;
      case deletePolicy:
        return AppConstanstForm.deletePolicy.tr;
      case policyWeightIssue:
        return AppConstanstForm.policyWeightIssue.tr;
      case editPolicyWeightIssue:
        return AppConstanstForm.editPolicyWeightIssue.tr;
      case policyScore:
        return AppConstanstForm.policyScore.tr;
    }
  }
}

      